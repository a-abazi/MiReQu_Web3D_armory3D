
package arm;
import iron.Scene;
import kha.graphics4.hxsl.Types.Vec;
import iron.math.Quat;
import iron.system.Input;
import iron.object.Object;
import iron.object.Transform;

import armory.trait.physics.RigidBody;
import armory.trait.physics.PhysicsWorld;

import iron.Trait;
import iron.math.Vec4;

import iron.math.Mat4;
import iron.math.RayCaster;

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



	var postAngle: Float = 0;
	var postAngleTravel: Float = Math.PI*2./100.;

	var postDist: Float = 0.0;
	var postTrans: Float = 0.01;
	var postPosLim: Float;
	var postNegLim: Float;
	var postTravelDist: Float;

	var baseAngle: Float;
	var baseAngleTravel: Float = Math.PI*2./100.;

	var baseDist: Float = 0.0;
	var baseTrans: Float = 0.1;
	var basePosLim: Float;
	var baseNegLim: Float;
	var baseTravelDist: Float;


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

	var movingObj: Object = null;
	var xyPlane: Object = null;
	var hitVec: Vec4 = null;
	var planegroup: Int = 3; //collection group for the helper plane

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
		mScrew.transform.move(mScrew.transform.up(), mState * mSTravel);
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
		corrScrew = new Vec4().setFrom(screw.getChild("C").transform.world.getLoc()).sub(screw.transform.loc);
		if (sState == 0)
			corrScrew.mult(0.5);

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

		//basePosLim = (object.getChild("C_Screw_Pos").transform.world.getLoc().distanceTo( object.getChild("C_Screw_LimPos").transform.world.getLoc()));
		//baseNegLim = -1*(object.getChild("C_Screw_Pos").transform.world.getLoc().distanceTo( object.getChild("C_Screw_LimNeg").transform.world.getLoc()));
		//baseTravelDist = Math.abs(basePosLim)+ Math.abs(baseNegLim);

	}



			
	function onUpdate(){
		//updateParts();
		var keyboard = Input.getKeyboard();
		var mouse = Input.getMouse();
		var rb = null;

		if (mouse.started("left")){
			var coords = new Vec4(mouse.x, mouse.y,0,1);
			var physics = armory.trait.physics.PhysicsWorld.active;	

			//helper plane to calculate movement of object in xy

			

			rb = physics.pickClosest(coords.x, coords.y);
			if (rb !=null) {
				movingObj = rb.object;

				if (rb.object == mScrew){
					switchStateMScrew();
				}
	
				else if (rb.object == screw){
					switchStateScrew();
				}
	

			}
		}
		
		if (mouse.released("left")) {
			movingObj = null;
			if (xyPlane != null) xyPlane.remove();
			hitVec = null;
			updateParts();
		}

		if (mouse.down("left")&& movingObj != null ){
			if (movingObj == post) {
				var multip = 0.1;
				rotPost(mouse.movementX * multip);
				transPost(mouse.movementY * -1 *multip);
			}

			else if (movingObj == object && mState == 0){
				trace("state 0 Locked yo");
				//updateParts();
			}
			else if (movingObj == object && mState == 1){
				trace("state 1 now transl");
				var multip = 0.025;
				//var movingV = screenMoveToWorldMove(new Vec4(mouse.movementX * multip,mouse.movementY * -multip,0));
				var clickpos = worldToScreenSpace(new Vec4(mouse.x,mouse.y,0));
				trace (clickpos.sub(object.transform.loc));

				//updateParts();
			}
			else if (movingObj == object && mState == 2){
				if (hitVec == null){
					hitVec = mouseToPlaneHit(mouse.x,mouse.y,1,1<<0);
					if (hitVec!= null ) xyPlane = spawnXYPlane(hitVec);
					//TODo: figure out movement
					//hitVec.subvecs(object.transform.loc, hitVec);
				} 
				
				var moveVec = mouseToPlaneHit(mouse.x,mouse.y,1,1<<planegroup-1) ; 
				trace(moveVec);
				moveVec.sub(object.transform.loc);
				//moveVec.sub(hitVec);
				trace(moveVec);
				object.transform.translate( moveVec.x,moveVec.y ,0);
				rbSync(object);
				updateParts();
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
		mScrew.transform.move(mScrew.transform.up(), mState * mSTravel);
		rbSync(mScrew);


		var mT = object.getChild("C_UPH").transform.world;
		top.transform.setMatrix(mT);
		top.transform.scale = nScale;
		top.transform.loc.sub(corrVTop);
		rbSync(top);

		var mS = top.getChild("C_Screw").transform.world;
		screw.transform.setMatrix(mS);
		screw.transform.scale = nScale;
		rbSync(screw);
		corrScrew = new Vec4().setFrom(screw.getChild("C").transform.world.getLoc()).sub(screw.transform.loc);
		if (sState == 0)
			corrScrew.mult(0.5);
		screw.transform.loc.sub(corrScrew);
		rbSync(screw);


		var mP = top.getChild("C_Top").transform.world;
		post.transform.setMatrix(mP);
		post.transform.scale = nScale;
		post.transform.move(post.transform.up(),postDist);
		post.transform.rotate(post.transform.up().normalize(),postAngle);
		rbSync(post);
		
		
	}

	function updateParts() {
		nScale = new Vec4(0.01,0.01,0.01,1);
		
		var mST = object.getChild("C_Screw_Pos").transform.world;
		mScrew.transform.setMatrix(mST);
		mScrew.transform.scale = nScale;
		rbSync(mScrew);

		mScrew.transform.move(mScrew.transform.up(), mState * mSTravel);
		rbSync(mScrew);

		if (mState == 0 || mState ==1 ){
			var corrVxy: Vec4 = xySnapToBasis(object,mScrew,zero,baseX,baseY);
			rbSync(object);
			mScrew.transform.translate(corrVxy.x,corrVxy.y,0);
			rbSync(mScrew);
	
			object.transform.rot.fromAxisAngle(object.transform.up().normalize(), baseAngle);
			rbSync(object);
			var corrVrot = new Vec4().setFrom(object.getChild("C_Screw_Pos").transform.world.getLoc());
			corrVrot.sub(mScrew.transform.loc);
			object.transform.translate(-1*corrVrot.x , -1*corrVrot.y , 0);
			rbSync(object);
		}

		var mT = object.getChild("C_UPH").transform.world;
		top.transform.setMatrix(mT);
		top.transform.scale = nScale;
		top.transform.loc.sub(corrVTop);
		rbSync(top);

		var mS = top.getChild("C_Screw").transform.world;
		screw.transform.setMatrix(mS);
		screw.transform.scale = nScale;
		rbSync(screw);
		corrScrew = new Vec4().setFrom(screw.getChild("C").transform.world.getLoc()).sub(screw.transform.loc);
		if (sState == 0)
			corrScrew.mult(0.5);
		screw.transform.loc.sub(corrScrew);
		rbSync(screw);


		var mP = top.getChild("C_Top").transform.world;
		post.transform.setMatrix(mP);
		post.transform.scale = nScale;
		post.transform.move(post.transform.up(),postDist);
		post.transform.rotate(post.transform.up().normalize(),postAngle);
		rbSync(post);
		
	}

	function rotBase(multiplier: Float){
		if ( mState ==1){
			baseAngle = (baseAngle + multiplier * baseAngleTravel) % (Math.PI*2);
			updateParts();
		}
	}

	function transBase(multiplier: Float){
		if (mState==1){
			multiplier = multiplier*-1;
			var scalefactor = 0.01; // factor which results due to scaling, needs to be adjusted for other scales
			if (multiplier<0){
				var baseDist = (object.getChild("C_Screw_Pos").transform.world.getLoc().distanceTo( object.getChild("C_Screw_LimNeg").transform.world.getLoc()));
				if (baseDist + multiplier*baseTrans*scalefactor>0){
					trace(baseDist);
					trace(multiplier*baseTrans);
					object.getChild("C_Screw_Pos").transform.translate(0,multiplier*baseTrans,0);
					rbSync(object);
				}
			}
			else if(multiplier>0){			
				var baseDist = (object.getChild("C_Screw_Pos").transform.world.getLoc().distanceTo( object.getChild("C_Screw_LimPos").transform.world.getLoc())); 
				if (baseDist - multiplier*baseTrans*scalefactor >0){
					trace(baseDist);
					object.getChild("C_Screw_Pos").transform.translate(0,multiplier*baseTrans,0);
					rbSync(object);
				}
			}
		updateParts();	
		}
	}


	function rotPost(multiplier: Float){
		if (sState==1){
			postAngle = (postAngle + multiplier * postAngleTravel) % (Math.PI*2);
			updateParts();
		}
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
		updateParts();	
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
			sState = 1;
			updateParts();
		}
		else {
			sState = 0;
			updateParts();
		}
	}

	function switchStateMScrew(){
		if (mState == 0){
			mState = 1;
			updateParts();
		} 
		else if (mState == 1){
			mState = 2;
			updateParts();
		}
		else {
			mState = 0;
			updateParts();
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

	function spawnXYPlane(loc: Vec4):Object {
		var object: Object;
		var matrix = null;
		var spawnChildren = false;

		iron.Scene.active.spawnObject("xyPlane", null, function(o: Object) {
			object = o;
			if (matrix != null) {
				object.transform.setMatrix(matrix);
			
				var rigidBody = object.getTrait(RigidBody);
				if (rigidBody != null) {
					object.transform.buildMatrix();
					rigidBody.syncTransform();
					rigidBody.group = planegroup;
				}
			}
			object.visible = false;
		}, spawnChildren);
		object.transform.loc = loc;
		
		return object;
	}

	function rbSync(object:Object) { 
		// helping function for a rigid body object, 
		// is used to align the child objects of the rigid body to their new parent matrix (location and rotation)
		var rigidBody = object.getTrait(RigidBody);
		if (rigidBody != null) rigidBody.syncTransform();
	}
	

	function screenToWorldSpace(v1: Vec4): Vec4 {
		var v = new Vec4();
		var m = Mat4.identity();

		if (v1 == null) return null;

		var cam = iron.Scene.active.camera;
		v.setFrom(v1);
		m.getInverse(cam.P);
		v.applyproj(m);
		m.getInverse(cam.V);
		v.applyproj(m);

		return v;
	}

	function screenMoveToWorldMove(v1: Vec4): Vec4 {
		var v = new Vec4();
		var axis = object.transform.up().normalize();
		var angle = Scene.active.camera.transform.rot.toAxisAngle(axis);
		
		v.setFrom(v1);
		v.applyAxisAngle( axis, angle);
		return v;
	}


	function worldToScreenSpace(v1 : Vec4): Vec4 {
		var v = new Vec4();
		if (v1 == null) return null;

		var cam = iron.Scene.active.camera;
		v.setFrom(v1);
		v.applyproj(cam.V);
		v.applyproj(cam.P);

		return v;
	}


	function mouseToPlaneHit (inputX, inputY,group, mask):Dynamic{		
		var camera = iron.Scene.active.camera;
		var physics = armory.trait.physics.PhysicsWorld.active;
		var start = new Vec4();
		var end = new Vec4();
		RayCaster.getDirection(start, end, inputX, inputY, camera);
		var hit = physics.rayCast(camera.transform.world.getLoc(), end,  group,mask);

		if (hit!=null) return new Vec4().setFrom(hit.pos);
		else return null;
	}

}	