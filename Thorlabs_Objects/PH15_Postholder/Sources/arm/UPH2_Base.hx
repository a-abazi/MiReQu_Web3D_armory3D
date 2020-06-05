
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

	var children: Array <Object>;
	var nScale: Vec4  = new Vec4(0.01,0.01,0.01,1);

	var mSTravel: Float = 2.7;
	var mState: Int = 0;

	var sTravel: Float = 1.5;
	var sState: Int = 0;

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



	function onInit() {
		children = object.getChildren();
		plate = Scene.active.getChild(plateName);
		
		zero = plate.getChildren()[2].transform.world.getLoc();
		baseX = plate.getChildren()[0].transform.world.getLoc().sub(zero);
		baseY = plate.getChildren()[1].transform.world.getLoc().sub(zero);

		object.transform.translate(0,0,zero.z -  children[0].transform.world.getLoc().z);
		object.transform.buildMatrix();
		rbSync(object);

		mScrew = spawnObject(mScrewName,false);
		var mST = object.getChild("C_Screw_Pos").transform.world;
		mScrew.transform.setMatrix(mST);
		mScrew.transform.scale = nScale;
		mScrew.visible = true;
		rbSync(mScrew);

		var corrVxy: Vec4 = xySnapToBasis(object,mScrew,zero,baseX,baseY);
		object.transform.translate(corrVxy.x,corrVxy.y,0);
		object.transform.buildMatrix();
		rbSync(object);
		mScrew.transform.translate(corrVxy.x,corrVxy.y,0);
		rbSync(mScrew);


		top = spawnObject(topName,false);
		var mT = object.getChild("C_UPH").transform.world;
		top.transform.setMatrix(mT);
		top.transform.scale = nScale;
		rbSync(top);
		corrVTop = new Vec4().setFrom(top.getChild("C_Bottom").transform.world.getLoc()).sub(top.transform.loc);
		trace(corrVTop);
		top.transform.loc.sub(corrVTop);
		top.visible = true;
		rbSync(top);

		screw = spawnObject(screwName,false);
		var mS = top.getChild("C_Screw").transform.world;
		screw.transform.setMatrix(mS);
		screw.transform.scale = nScale;
		rbSync(screw);
		corrScrew = new Vec4().setFrom(screw.getChild("C").transform.world.getLoc()).sub(screw.transform.loc).mult(0.5);
		screw.transform.loc.sub(corrScrew);
		screw.visible = true;
		rbSync(screw);


		post = spawnObject(postName,false);
		var mP = top.getChild("C_Top").transform.world;
		post.transform.setMatrix(mP);
		post.transform.scale = nScale;
		post.visible = true;
		post.transform.rotate(post.transform.up().normalize(),postAngle);
		rbSync(post);

		postPosLim = (post.getChild("C_PostBottom").transform.world.getLoc().distanceTo( top.getChild("C_Top").transform.world.getLoc()));
		postNegLim = (post.getChild("C_PostBottom").transform.world.getLoc().distanceTo( top.getChild("C_Bottom").transform.world.getLoc()));
		postTravelDist = Math.abs(postPosLim) + Math.abs(postNegLim);

		baseAngle = object.transform.rot.toAxisAngle(object.transform.up());
		updatePartsSnap();
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

		if (keyboard.down("up")){
			if (postDist + postTrans < postPosLim){
				postDist = postDist + postTrans;
			}
			updatePartsSnap();

		}
		
		if (keyboard.down("down")){
			if (postDist- postTrans > postNegLim ){
				postDist = postDist - postTrans;
			}
			updatePartsSnap();

		}

		
		if (keyboard.down("left")){
			//postAngle = (postAngle + postAngleTravel) % (Math.PI*2);
			baseAngle = (baseAngle + baseAngleTravel) % (Math.PI*2);

			updatePartsSnap();

		}
		if (keyboard.down("right")){
			//postAngle = (postAngle - postAngleTravel) % (Math.PI*2);
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
			if (rb != null && rb.object == screw){
				if (sState == 0){
					screw.transform.move(screw.transform.look(), -1*sTravel);
					sState = 1;
					rbSync(screw);
				}
				else {
					screw.transform.move(mScrew.transform.look(), sTravel);
					sState = 0;
					rbSync(screw);
				}
			}
			var mouse_c = iron.system.Input.getMouse();
			var coords = new Vec4(mouse_c.x, mouse_c.y,0,1);
			var physics = armory.trait.physics.PhysicsWorld.active;
			
			var rb = physics.pickClosest(coords.x, coords.y);
			if (rb != null && rb.object == object && mState == 1){
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


	function xySnapToBasis(mainObj: Object, mScrew: Object, zero: Vec4, baseX: Vec4, baseY: Vec4):Vec4 {
		var sV: Vec4 = new Vec4().setFrom(mScrew.transform.loc); // initial location of screw

		sV.sub(zero);
		sV.x = sV.x % baseX.x;
		if (2 * sV.x> baseX.x) sV.x = baseX.x - sV.x;
		else sV.x = sV.x*-1;
		sV.y = sV.y % baseY.y;
		if (2 * sV.y> baseY.y) sV.y = baseY.y - sV.y;
		else sV.y = sV.y*-1;
		//sV.mult(1);
		sV.z = 0;

		return sV;
	}
	
	function spawnObject(objectName: String, visible: Bool):Object {
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
		var rigidBody = object.getTrait(RigidBody);
		if (rigidBody != null) rigidBody.syncTransform();
	}
	
}