
package arm;
import iron.Scene;
import kha.graphics4.hxsl.Types.Vec;
import iron.math.Quat;
import iron.system.Input;
import iron.object.Object;
import iron.object.Transform;

import armory.trait.physics.RigidBody;

import iron.Trait;
import iron.math.Vec4;

import iron.math.Mat4;
	

class UPH2_Base extends iron.Trait {	

	@prop 
	var plateName: String = "Platte";

	@prop 
	var mScrewName: String = "UPH2_M_Schraube";
	@prop 
	var screwName: String = "UPH2_Screw";
	@prop 
	var postName: String = "UPH2_Post";
	@prop 
	var topName: String = "UPH2_Top";

	//var children: Array <Object>;
	var nScale: Vec4  = new Vec4(0.01,0.01,0.01,1);

	var mSTravel: Float = 2.7; 			// complete travel distance of mScrew
	var mState: Int = 0; 				// different states of the screw on the base, Controls Base
						 				// 0 Locked(snaps to holes), 
						 				// 1 partially locked, rotation of base changeable, and dist between base and screw
						 				// 2 free, base translatable in loc


	var sTravel: Float = 1.5;			// complete travel distance of screw (hexScrew)
	var sState: Int = 0;	 			// different states of the screw on the Top (HexScrew), Controls Post
										// 0 Locked,
										// 1 Post can be rotated and moved up/down 


	var postDist: Float = 0.0;
	var postTrans: Float = 0.01;
	var postPosLim: Float;
	var postNegLim: Float;
	var postTravelDist: Float;

	var postAngle: Float = 0;
	var postAngleTravel: Float = Math.PI*2./100.;

	var baseAngle: Float;
	var baseAngleTravel: Float = Math.PI*2./100.;

	var plate: Object;
	var mScrew: Object;
	var screw: Object;
	var post: Object;
	var top: Object;

	var zero: Vec4;
	var baseX: Vec4;
	var baseY: Vec4;

	var corrVTop: Vec4;
	var corrScrew: Vec4;

	public function new() {
		super();
		
		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);

	};

	// TODO: Movements !!!
	// bugs: 
	// 		- inital angle not correct for angles larger than pi (method of Quat(Iron) toAxisAngle)
	// 		- Hex Screw translates relative to Top when base is rotated.



	function onInit() {
		// TODO: not working for angles larger than PI, error in function from IRON, Method of Quat()
		baseAngle = object.transform.rot.toAxisAngle(object.transform.up());

		// get base system from the plate object
		plate = Scene.active.getChild(plateName);
		zero = plate.getChildren()[2].transform.world.getLoc();
		baseX = plate.getChildren()[0].transform.world.getLoc().sub(zero);
		baseY = plate.getChildren()[1].transform.world.getLoc().sub(zero);


		// set the object to correct z stage and to the baseAngle Value(outcommented)
		object.transform.translate(0,0,zero.z -  object.getChild("C_Platte").transform.world.getLoc().z);
		//object.transform.rot.fromAxisAngle(object.transform.up().normalize(), baseAngle);
		object.transform.buildMatrix();
		rbSync(object);


		//spawn the screw and setup location
		mScrew = spawnObject(mScrewName,false);
		var mST = object.getChild("C_Screw_Pos").transform.world;
		mScrew.transform.setMatrix(mST);
		mScrew.transform.scale = nScale;
		mScrew.visible = true;
		rbSync(mScrew);

		//  snap the screw to correct place and base, too
		var corrVxy: Vec4 = xySnapToBasis(object,mScrew,zero,baseX,baseY);
		object.transform.translate(corrVxy.x,corrVxy.y,0);
		object.transform.buildMatrix();
		rbSync(object);
		mScrew.transform.translate(corrVxy.x,corrVxy.y,0);
		rbSync(mScrew);

		// spawn "Top" on the base, corrVTop is the correction vector concerning the location
		top = spawnObject(topName,false);
		var mT = object.getChild("C_UPH").transform.world;
		top.transform.setMatrix(mT);
		top.transform.scale = nScale;
		rbSync(top);
		corrVTop = new Vec4().setFrom(top.getChild("C_Bottom").transform.world.getLoc()).sub(top.transform.loc);
		top.transform.loc.sub(corrVTop);
		top.visible = true;
		rbSync(top);

		// spawn the hex screw on the top part, see above  for corrScrew
		screw = spawnObject(screwName,false);
		var mS = top.getChild("C_Screw").transform.world;
		screw.transform.setMatrix(mS);
		screw.transform.scale = nScale;
		rbSync(screw);
		corrScrew = new Vec4().setFrom(screw.getChild("C").transform.world.getLoc()).sub(screw.transform.loc).mult(0.5);
		screw.transform.loc.sub(corrScrew);
		screw.visible = true;
		rbSync(screw);

		// spawn the post inside the top, with specified postDist and angle
		post = spawnObject(postName,false);
		var mP = top.getChild("C_Top").transform.world;
		post.transform.setMatrix(mP);
		post.transform.scale = nScale;
		post.visible = true;
		post.transform.move(post.transform.up(),postDist);
		post.transform.rotate(post.transform.up().normalize(),postAngle);
		rbSync(post);


		// measure limits from the empty child objects, limits for postTravel and TODO: limit  for base Travel,
		// (Angles don't need limits)
		postPosLim = (post.getChild("C_PostBottom").transform.world.getLoc().distanceTo( top.getChild("C_Top").transform.world.getLoc()));
		postNegLim = (post.getChild("C_PostBottom").transform.world.getLoc().distanceTo( top.getChild("C_Bottom").transform.world.getLoc()));
		postTravelDist = Math.abs(postPosLim) + Math.abs(postNegLim);

	}
			
	function onUpdate(){
		//updateParts();
		var keyboard = Input.getKeyboard();
		var mouse = Input.getMouse();

		var vec = new Vec4(0.01,0,0,1);
		var vec_B = new Vec4(-0.01,0,0,1);


		if (keyboard.down("w")){
			object.transform.loc.add(vec);
			object.transform.buildMatrix();
			
			var rigidBody = object.getTrait(RigidBody);
			if (rigidBody != null) rigidBody.syncTransform();
			updatePartsMoving();
		}

		if (keyboard.down("s")){
			object.transform.loc.add(vec_B);
			object.transform.buildMatrix();

			var rigidBody = object.getTrait(RigidBody);
			if (rigidBody != null) rigidBody.syncTransform();
			updatePartsMoving();
		}

		if (keyboard.down("up")) transPost(1);
		
		if (keyboard.down("down")) transPost(-1);

		
		if (keyboard.down("left")){
			postAngle = (postAngle + postAngleTravel) % (Math.PI*2);
			baseAngle = (baseAngle + baseAngleTravel) % (Math.PI*2);

			updatePartsSnap();

		}
		if (keyboard.down("right")){
			postAngle = (postAngle - postAngleTravel) % (Math.PI*2);
			baseAngle = (baseAngle - baseAngleTravel) % (Math.PI*2);
			updatePartsSnap();
			
		}




		if (keyboard.down("space")){
			updatePartsSnap();
		}


		if (mouse.started("left")){
			var mouse_c = iron.system.Input.getMouse();
			var coords = new Vec4(mouse_c.x, mouse_c.y,0,1);
			var physics = armory.trait.physics.PhysicsWorld.active;
			
			var rb = physics.pickClosest(coords.x, coords.y);
			if (rb != null && rb.object == mScrew){
				switchStateMScrew();
			}
			if (rb != null && rb.object == screw){
				switchStateScrew();
			}

			if (rb != null && rb.object == object && mState == 0){
				trace("state 0 Locked yo");
				//updateParts();
			}
			else if (rb != null && rb.object == object && mState == 1){
				trace("state 1 now transl");
				//updateParts();
			}
			else if (rb != null && rb.object == object && mState == 2){
				trace("state 2 now translating");
				//updateParts();
			}

		}

	}




	function updatePartsMoving() {
		// moving function to update all rigidbodys and children
		// does not include the snap, TODO: integrate to one function
		nScale = new Vec4(0.01,0.01,0.01,1);
		
		var mST = object.getChild("C_Screw_Pos").transform.world;
		mScrew.transform.setMatrix(mST);
		mScrew.transform.scale = nScale;
		rbSync(mScrew);

		var mT = object.getChild("C_UPH").transform.world;
		top.transform.setMatrix(mT);
		top.transform.scale = nScale;
		top.transform.loc.sub(corrVTop);
		rbSync(top);

		var mS = top.getChild("C_Screw").transform.world;
		screw.transform.setMatrix(mS);
		screw.transform.scale = nScale;
		screw.transform.loc.sub(corrScrew);
		rbSync(screw);


		var mP = top.getChild("C_Top").transform.world;
		post.transform.setMatrix(mP);
		post.transform.scale = nScale;
		post.transform.move(post.transform.up(),postDist);
		post.transform.rotate(post.transform.up().normalize(),postAngle);
		rbSync(post);
		
		
	}

	function updatePartsSnap() {
		nScale = new Vec4(0.01,0.01,0.01,1);
		
		var mST = object.getChild("C_Screw_Pos").transform.world;
		mScrew.transform.setMatrix(mST);
		mScrew.transform.scale = nScale;
		rbSync(mScrew);

		var corrVxy: Vec4 = xySnapToBasis(object,mScrew,zero,baseX,baseY);
		object.transform.translate(corrVxy.x,corrVxy.y,0);
		object.transform.buildMatrix();
		rbSync(object);
		mScrew.transform.translate(corrVxy.x,corrVxy.y,0);
		rbSync(mScrew);

		object.transform.rot.fromAxisAngle(object.transform.up().normalize(), baseAngle);
		rbSync(object);
		var corrVrot = new Vec4().setFrom(object.getChild("C_Screw_Pos").transform.world.getLoc());
		corrVrot.sub(mScrew.transform.loc);
		object.transform.translate(-1*corrVrot.x, -1*corrVrot.y, 0);
		rbSync(object);


		var mT = object.getChild("C_UPH").transform.world;
		top.transform.setMatrix(mT);
		top.transform.scale = nScale;
		top.transform.loc.sub(corrVTop);
		rbSync(top);

		var mS = top.getChild("C_Screw").transform.world;
		screw.transform.setMatrix(mS);
		screw.transform.scale = nScale;
		screw.transform.loc.sub(corrScrew);
		rbSync(screw);


		var mP = top.getChild("C_Top").transform.world;
		post.transform.setMatrix(mP);
		post.transform.scale = nScale;
		post.transform.move(post.transform.up(),postDist);
		post.transform.rotate(post.transform.up().normalize(),postAngle);
		rbSync(post);
		
	}


	function transPost(multiplier: Float){
		if (sState==1){
			if (multiplier<0){
				if (postDist + multiplier*postTrans > postNegLim ){
					postDist = postDist + multiplier*postTrans;
				}
			}
			else if(multiplier>0){			
				if (postDist + multiplier*postTrans < postPosLim){
					postDist = postDist + multiplier*postTrans;
				}
			}
		updatePartsSnap();	
		}
	}

	function xySnapToBasis(mainObj: Object, mScrew: Object, zero: Vec4, baseX: Vec4, baseY: Vec4):Vec4 {
		var sV: Vec4 = new Vec4().setFrom(mScrew.transform.loc); // initial location of screw

		sV.sub(zero);
		sV.x = sV.x % baseX.x;
		if (2 * sV.x> baseX.x) sV.x = baseX.x - sV.x;
		else sV.x = sV.x*-1;
		sV.y = sV.y % baseY.y;
		if (2 * sV.y> baseY.y) sV.y = baseY.y - sV.y;
		else sV.y = sV.y*-1;

		sV.z = 0;

		return sV;
	}
	
	function switchStateScrew() {
		if (sState == 0){
			//screw.transform.move(screw.transform.look(), -1*sTravel);
			//top.getChild("C_Screw").transform.move(top.getChild("C_Screw").transform.look(), -1*sTravel);
			//rbSync(top);
			sState = 1;
			//rbSync(screw);
			updatePartsSnap();
		}
		else {
			//screw.transform.move(mScrew.transform.look(), sTravel);
			//top.getChild("C_Screw").transform.move(top.getChild("C_Screw").transform.look(), 1*sTravel);
			//rbSync(top);
			sState = 0;
			//rbSync(screw);
			updatePartsSnap();
		}
	}

	function switchStateMScrew(){
		if (mState == 0){
			mScrew.transform.move(mScrew.transform.up(), mSTravel);
			mState = 1;
			rbSync(mScrew);
		} 
		else if (mState == 1){
			mScrew.transform.move(mScrew.transform.up(), mSTravel);
			mState = 2;
			rbSync(mScrew);
		}
		else {
			mScrew.transform.move(mScrew.transform.up(), -2*mSTravel);
			mState = 0;
			rbSync(mScrew);
		}
	}

	function spawnObject(objectName: String, visible: Bool):Object {
		// helping function to spawn an object
		var object: Object;
		var matrix = null;
		var spawnChildren = true;

		iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
			object = o;
			if (matrix != null) {
				object.transform.setMatrix(matrix);
			
				var rigidBody = object.getTrait(RigidBody);
				if (rigidBody != null) {
					object.transform.buildMatrix();
					rigidBody.syncTransform();
				}
			}
			object.visible = visible;
		}, spawnChildren);

		return object;
	}


	function rbSync(object:Object) { 
		// helping function for a rigid body object, 
		// is used to align the child objects of the rigid body to their new parent matrix (location and rotation)
		var rigidBody = object.getTrait(RigidBody);
		if (rigidBody != null) rigidBody.syncTransform();
	}
	
}