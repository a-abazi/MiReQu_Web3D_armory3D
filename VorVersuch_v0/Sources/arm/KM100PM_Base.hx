package arm;


import js.html.RadioNodeList;
import kha.graphics4.hxsl.Types.Vec;
import iron.math.Quat;
import iron.system.Input;
import iron.object.Object;
import iron.object.Transform;

import armory.trait.physics.RigidBody;

import iron.Trait;
import iron.math.Vec4;

import iron.math.Mat4;
import armory.system.Event;

class KM100PM_Base extends iron.Trait {

	@prop 
	var pbsName: String = "KM100PM_Beamsplitter";
	@prop 
	var frontName: String = "KM100PM_Front";
	@prop 
	var screwName: String = "KM100PM_Screw";
	@prop 
	var holderName: String = "KM100PM_Holder";
	@prop 
	var stageName: String = "KM100PM_Stage";
	
	
	var children: Array <Object>;
	var scale: Vec4  = new Vec4(0.01,0.01,0.01,1);

	var screwTopDist: Float = 0.0;
	var screwBotDist: Float = 0.0;
	var screwTrans: Float = 0.0005;
	var screwPosLim: Float;
	var screwNegLim: Float;
	var screwTravelDist: Float;

	var screwTop: Object;
	var screwBot: Object;
	var front: Object;
	var pbs: Object;
	var holder: Object;
	var stage: Object;
	var visib: Bool =  false;

	var objList: Array<Object> = [];

	public function new() {
		super();
		
		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);
		notifyOnRemove(onRemove);
	};

	public function pauseUpdate():Bool{
		removeUpdate(onUpdate);
		return true;
	}

	public function resumeUpdate():Bool{
		notifyOnUpdate(onUpdate);
		return true;
	}
	function onInit() {
		initProps(object);

		if (object.properties["spawned"]){
			visib = true;
			}

		screwTop = spawnObject(screwName,false);
		var mST = object.getChild("C_KM100PM_Screw_Top_Zero").transform.world;
		screwTop.transform.setMatrix(mST);
		screwTop.transform.scale = scale;
		screwTop.visible = visib;
		rbSync(screwTop);

		screwBot = spawnObject(screwName,false);
		var mSB = object.getChild("C_KM100PM_Screw_Bottom_Zero").transform.world;
		screwBot.transform.setMatrix(mSB);
		screwBot.transform.scale = scale;
		screwBot.visible = visib;
		rbSync(screwBot);

		front = spawnObject(frontName,false);
		var mF = object.getChild("C_KM100PM_Front").transform.world;
		front.transform.setMatrix(mF);
		front.transform.scale = scale;
		front.visible = visib;
		rbSync(front);
		

		for (child in front.getChildren()){
			child.transform.scale = scale;
		}

		pbs = spawnObject(pbsName,false);
		var mM = front.getChildren()[1].transform.world;
		pbs.transform.setMatrix(mM);
		pbs.transform.scale = scale;
		pbs.visible = visib;
		pbs.getChildren()[0].visible = visib;
		rbSync(pbs);
		

		holder = spawnObject(holderName,false);
		var mM = front.getChildren()[0].transform.world;
		holder.transform.setMatrix(mM);
		holder.transform.scale = scale;
		holder.visible = visib;
		rbSync(holder);

		stage = spawnObject(stageName,false);
		var mM = front.getChildren()[2].transform.world;
		stage.transform.setMatrix(mM);
		stage.transform.scale = scale;
		stage.visible = visib;
		rbSync(stage);



		screwPosLim = (object.getChild("C_KM100PM_Screw_Bottom_Limit").transform.world.getLoc().distanceTo( screwBot.getChildren()[0].transform.world.getLoc()));
		screwNegLim = (object.getChild("C_KM100PM_Screw_Bottom_Zero").transform.world.getLoc().distanceTo( object.getChild("Z_KM100PM_Screw_Bottom_LimitNeg").transform.world.getLoc()));
		screwTravelDist = Math.abs(screwPosLim) + Math.abs(screwNegLim);
		
		Event.add("updateParts",updateParts,object.uid);

		objList.push(object);
		objList.push(screwBot);
		objList.push(screwTop);
		objList.push(front);
		objList.push(pbs);
		objList.push(holder);
		objList.push(stage);

		for (obj in objList){
			initProps(obj);
			if (obj != object) obj.properties.set("TraitObj",object);
			else obj.properties.set("TraitObj","self");
			obj.properties.set("TraitName","KM100PM"+"_Base");
			obj.properties.set("PauseResume",true);
		}
		pauseUpdate();
		updateParts();
	}
	
			
	function onUpdate(){
		//var keyboard = Input.getKeyboard();
		//trace(object.name+Std.string(object.uid)+"_Active");
		var mouse = Input.getMouse();

		if (mouse.released("left")|| mouse.released("right")) {
			updateParts();
			pauseUpdate();
		}

		if (mouse.down("left")){
			var mouse_c = iron.system.Input.getMouse();
			var coords = new Vec4(mouse_c.x, mouse_c.y,0,1);
			var physics = armory.trait.physics.PhysicsWorld.active;
			
			var rb = physics.pickClosest(coords.x, coords.y);
			if (rb != null && rb.object == screwBot){
				if (screwBotDist < screwPosLim + screwTrans){
					screwBotDist = screwBotDist + screwTrans;
				}
				updateParts();
			}
			else if (rb != null && rb.object == screwTop){
				if (screwTopDist < screwPosLim + screwTrans){
					screwTopDist = screwTopDist + screwTrans;
				}
				updateParts();
			}
		}
		
		if (mouse.down("right")){
			var mouse_c = iron.system.Input.getMouse();
			var coords = new Vec4(mouse_c.x, mouse_c.y,0,1);
			var physics = armory.trait.physics.PhysicsWorld.active;
			
			var rb = physics.pickClosest(coords.x, coords.y);
			if (rb != null && rb.object == screwBot){
				if (-1*screwNegLim < screwBotDist - screwTrans){
					screwBotDist = screwBotDist - screwTrans;
				}
				updateParts();
			}
			else if (rb != null && rb.object == screwTop){
				if (-1*screwNegLim < screwTopDist - screwTrans){
					screwTopDist = screwTopDist - screwTrans;
				}
				updateParts();
			}
		}

			// notifyOnRemove(function() {
			// });
	}

	function onRemove(){
		for (obj in objList){
			if (obj == object) continue;
			obj.remove();
		}
	}

	function updateParts() {

		scale = new Vec4(0.01,0.01,0.01,1);

		// update top screw 
		var numberRevolutions = 10;
		
		var mST = object.getChild("C_KM100PM_Screw_Top_Zero").transform.world;
		screwTop.transform.setMatrix(mST);
		screwTop.transform.move(screwTop.transform.look(), -1 *screwTopDist);
		screwTop.transform.rotate(screwTop.transform.look(), screwTopDist/screwTravelDist * numberRevolutions * 2* Math.PI);
		screwTop.transform.scale = scale;
		rbSync(screwTop);

		// update bottom screw
		var mSB = object.getChild("C_KM100PM_Screw_Bottom_Zero").transform.world;
		screwBot.transform.setMatrix(mSB);
		screwBot.transform.move(screwBot.transform.look(), -1 *screwBotDist);
		screwBot.transform.rotate(screwBot.transform.look(), screwBotDist/screwTravelDist * numberRevolutions * 2 * Math.PI);
		screwBot.transform.scale = scale;
		rbSync(screwBot);


		// calculate correct rotation of mirror, by calculating vectors
		var loc_cF = object.getChild("C_KM100PM_Front").transform.world.getLoc();
		var loc_ST = screwTop.transform.world.getLoc();
		var loc_SB = screwBot.transform.world.getLoc();
	
		var rotVecT = new Vec4().setFrom(loc_ST).sub(loc_cF).normalize();
		var rotVecB = new Vec4().setFrom(loc_SB).sub(loc_cF).normalize();

		var vU = new Vec4().setFrom(object.transform.up()).normalize();
		var vR = new Vec4().setFrom(object.transform.right()).normalize();

		//calculate quaternions from vectors, and calculate new total quaterion for rotation in new transfrom matrix
		var q1 = quatFromV1toV2(vU,rotVecT);
		var q2 = quatFromV1toV2(vR,rotVecB);

		var rotF = new Quat();
		rotF.mult(q2);
		rotF.mult(q1);
		rotF.mult(object.transform.rot);

		// update transform matrix
		var mF = object.getChild("C_KM100PM_Front").transform.world;
		front.transform.setMatrix(mF);
		front.transform.scale = scale;
		front.transform.rot = rotF;
		front.transform.buildMatrix();
		rbSync(front);


		var mM = front.getChildren()[1].transform.world;
		pbs.transform.setMatrix(mM);
		pbs.transform.scale = scale;
		rbSync(pbs);

		var mM = front.getChildren()[0].transform.world;
		holder.transform.setMatrix(mM);
		holder.transform.scale = scale;
		rbSync(holder);

		var mM = front.getChildren()[2].transform.world;
		stage.transform.setMatrix(mM);
		stage.transform.scale = scale;
		rbSync(stage);

	}
	

	function quatFromV1toV2(v1:Vec4,v2: Vec4): Quat {
		/* This Function calculates the quaternion to obtain a rotation from one vector to another
		detailed description on https://stackoverflow.com/questions/1171849/finding-quaternion-representing-the-rotation-from-one-vector-to-another
		*/
		var q = new Quat();
		var a = new Vec4().crossvecs(v1,v2);
		q.x = a.x;
		q.y = a.y;
		q.z = a.z;
		q.w = Math.sqrt( v1.length() * v1.length() * v2.length() * v2.length() ) +  new Vec4().setFrom(v1).dot(v2);
		q.normalize();

		return q;
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
	
	inline function initProps(object:Object){
		if (object == null) return;
		if (object.properties == null) object.properties = new Map();
	}
	
}
	