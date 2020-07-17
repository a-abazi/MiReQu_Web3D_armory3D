package arm;


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
 
class KM100_Base extends iron.Trait {

	@prop 
	var mirrorName: String = "KM100_Mirror";
	@prop 
	var frontName: String = "KM100_Front";
	@prop 
	var screwName: String = "KM100_Screw";
	
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
	var mirror: Object;

	
	var objList: Array<Object> = [];

	public function new() {
		super();
		
		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);
	};

	function onInit() {
		initProps(object);

		children = object.getChildren();

		screwTop = spawnObject(screwName,false);
		var mST = children[4].transform.world;
		screwTop.transform.setMatrix(mST);
		screwTop.transform.scale = scale;
		screwTop.visible = true;
		rbSync(screwTop);

		screwBot = spawnObject(screwName,false);
		var mSB = children[2].transform.world;
		screwBot.transform.setMatrix(mSB);
		screwBot.transform.scale = scale;
		screwBot.visible = true;
		rbSync(screwBot);

		front = spawnObject(frontName,false);
		var mF = children[0].transform.world;
		front.transform.setMatrix(mF);
		front.transform.scale = scale;
		front.visible = true;
		rbSync(front);

		for (child in front.getChildren()){
			child.transform.scale = scale;
		}

		mirror = spawnObject(mirrorName,false);
		var mM = front.getChildren()[0].transform.world;
		mirror.transform.setMatrix(mM);
		mirror.transform.scale = scale;
		mirror.visible = true;
		rbSync(mirror);

		screwPosLim = (children[1].transform.world.getLoc().distanceTo( screwBot.getChildren()[0].transform.world.getLoc()));
		screwNegLim = (children[2].transform.world.getLoc().distanceTo( children[6].transform.world.getLoc()));
		screwTravelDist = Math.abs(screwPosLim) + Math.abs(screwNegLim);

		updateParts();
		//unused 
		//object.properties.set("objRdy", true);
		
		// Event added with object id as a mask, the postholder trait UPH2_Base will send this event to its componente object when moved
		Event.add("updateParts",updateParts,object.uid);

		
		

		objList.push(object);
		objList.push(screwBot);
		objList.push(screwTop);
		objList.push(front);
		objList.push(mirror);

		for (obj in objList){
			initProps(obj);
			if (obj != object) obj.properties.set("TraitObj",object);
			else obj.properties.set("TraitObj","self");
			obj.properties.set("TraitName","KM100"+"_Base");
			obj.properties.set("PauseResume",true);
		}
		pauseUpdate();
	}
	
			
	function onUpdate(){
		//var keyboard = Input.getKeyboard();
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

	}

	public function pauseUpdate():Bool{
		removeUpdate(onUpdate);
		return true;
	}

	public function resumeUpdate():Bool{
		notifyOnUpdate(onUpdate);
		return true;
	}
	function updateParts() {
		scale = new Vec4(0.01,0.01,0.01,1);

		// update top screw 
		var numberRevolutions = 10;
		
		var mST = children[4].transform.world;
		screwTop.transform.setMatrix(mST);
		screwTop.transform.move(screwTop.transform.look(), -1 *screwTopDist);
		screwTop.transform.rotate(screwTop.transform.look(), screwTopDist/screwTravelDist * numberRevolutions * 2* Math.PI);
		screwTop.transform.scale = scale;
		rbSync(screwTop);

		// update bottom screw
		var mSB = children[2].transform.world;
		screwBot.transform.setMatrix(mSB);
		screwBot.transform.move(screwBot.transform.look(), -1 *screwBotDist);
		screwBot.transform.rotate(screwBot.transform.look(), screwBotDist/screwTravelDist * numberRevolutions * 2 * Math.PI);
		screwBot.transform.scale = scale;
		rbSync(screwBot);


		// calculate correct rotation of mirror
		var loc_cF = children[0].transform.world.getLoc();
		var loc_ST = screwTop.transform.world.getLoc();
		var loc_SB = screwBot.transform.world.getLoc();
	
		var rotVecT = new Vec4().setFrom(loc_ST).sub(loc_cF).normalize();
		var rotVecB = new Vec4().setFrom(loc_SB).sub(loc_cF).normalize();

		// calculate angles
		var vU = new Vec4().setFrom(object.transform.up()).normalize();
		var sgnU = Std.int(screwTopDist/Math.abs(screwTopDist));
		var angU = Math.acos(rotVecT.dot(vU))*sgnU;

		var vR = new Vec4().setFrom(object.transform.right()).normalize().mult(-1);
		var sgnB = Std.int(screwBotDist/Math.abs(screwBotDist));
		var angB = Math.acos(rotVecB.dot(vR))*sgnB;
		
		// update transform matrix
		var mF = children[0].transform.world;
		front.transform.setMatrix(mF);
		front.transform.scale = scale;

		//calculate quaternions from angles, and calculate new total quaterion for rotation in new transfrom matrix
		var q1 = new Quat().fromAxisAngle(new Vec4().setFrom(object.transform.right()).normalize(), angU);
		var q2 = new Quat().fromAxisAngle(new Vec4().setFrom(object.transform.up()).normalize(), angB);
		var rotF = new Quat();
		rotF.mult(q1);
		rotF.mult(q2);
		rotF.mult(object.transform.rot);
		front.transform.rot = rotF;
		front.transform.buildMatrix();
		rbSync(front);

		// update mirror to front of mirrorholder
		var mM = front.getChildren()[0].transform.world;
		mirror.transform.setMatrix(mM);
		mirror.transform.scale = scale;
		rbSync(mirror);

		//Event.send("Calc_Beams"); // Event of the scene trait calc beams, makes a new calculation of the Beams
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
	