package arm;


import js.html.Navigator;
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
import iron.math.RayCaster;
import armory.system.Event;

class KS1RS_Base extends iron.Trait {

	@prop 
	var bboName: String = "KS1RS_BBO";
	@prop 
	var frontName: String = "KS1RS_Front";
	@prop 
	var screwName: String = "KS1RS_Screw";
	@prop
	var ringName: String = "KS1RS_Ring";	

	var children: Array <Object>;
	var nScale: Vec4  = new Vec4(0.01,0.01,0.01,1);

	var screwTopDist: Float = 0.0;
	var screwBotDist: Float = 0.0;
	var screwMidDist: Float = 0.0;
	var screwTrans: Float = 0.0005;
	var screwPosLim: Float;
	var screwNegLim: Float;
	var screwTravelDist: Float;

	
	var ringAngle: Float;

	var screwTop: Object;
	var screwBot: Object;
	var screwMid: Object;
	var front: Object;
	var bbo: Object;
	var ring: Object;

	var movingObj: Object = null;
	var xyPlane: Object = null;
	var hitVec: Vec4 = null;
	var planegroup: Int = 2; //third square in Blender 2^(n); n=2 (first square is n=0)
	var visib: Bool =  false;

	public function new() {
		super();
		
		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);

	};

	function onInit() {
		initProps(object);
		
		if (object.properties["ringAngle"] != null) allPropsToVariables(object);
		else allVariablesToProbs(object);

		if (object.properties["ringAngle"] != null) visib = true;

		if (ringAngle == null) ringAngle = 0;
		

		screwTop = spawnObject(screwName,false);
		var mST = object.getChild("C_Screw_Top_Zero_KS1RS_Base").transform.world;
		screwTop.transform.setMatrix(mST);
		screwTop.transform.scale = nScale;
		screwTop.visible = visib;
		rbSync(screwTop);

		screwBot = spawnObject(screwName,false);
		var mSB = object.getChild("C_Screw_Bottom_Zero_KS1RS_Base").transform.world;
		screwBot.transform.setMatrix(mSB);
		screwBot.transform.scale = nScale;
		screwBot.visible = visib;
		rbSync(screwBot);

		screwMid = spawnObject(screwName,false);
		var mSM = object.getChild("C_Screw_Middle_Zero_KS1RS_Base").transform.world;
		screwMid.transform.setMatrix(mSM);
		screwMid.transform.scale = nScale;
		screwMid.visible = visib;
		rbSync(screwMid);

		front = spawnObject(frontName,false);
		front.transform.setMatrix(mSM);
		front.transform.scale = nScale;
		front.visible = visib;
		rbSync(front);

		for (child in front.getChildren()){
			child.transform.scale = nScale;
		}

		ring = spawnObject(ringName,false);
		var mR = front.getChildren()[0].transform.world;
		ring.transform.setMatrix(mR);
		ring.transform.scale = nScale;
		ring.visible = visib;
		ring.transform.rotate(ring.transform.look().normalize(), ringAngle);
		rbSync(ring);


		bbo = spawnObject(bboName,false);
		var mB = ring.getChildren()[0].transform.world;
		bbo.transform.setMatrix(mB);
		bbo.transform.scale = nScale;
		bbo.visible = visib;
		rbSync(bbo);

		screwPosLim = (object.getChild("C_Screw_Bottom_Limit_KS1RS_Base").transform.world.getLoc().distanceTo( screwBot.getChildren()[0].transform.world.getLoc()));
		screwNegLim = (object.getChild("C_Screw_Bottom_Zero_KS1RS_Base").transform.world.getLoc().distanceTo(object.getChild("C_Screw_Bottom_Limit_z_KS1RS_Base").transform.world.getLoc()));
		screwTravelDist = Math.abs(screwPosLim) + Math.abs(screwNegLim);

		updateParts();
		
		// Event added with object id as a mask, the postholder trait UPH2_Base will send this event to its componente object when moved
		Event.add("updateParts",updateParts,object.uid);
	}
	
			
	function onUpdate(){
		
		var keyboard = Input.getKeyboard();
		var mouse = Input.getMouse();		
		var rb = null;
		var physics = armory.trait.physics.PhysicsWorld.active;	

		if (mouse.started("left")){

			rb = physics.pickClosest(mouse.x, mouse.y);
			if (rb !=null) {
				movingObj = rb.object;
				if (movingObj.name == "xyPlane") movingObj.remove();
			}
			
		}

		if (mouse.released("left")) {
			movingObj = null;
			if (xyPlane != null) xyPlane.remove();
			hitVec = null;
			updateParts();
			if (Scene.active.getChild("xyPlane") != null ) Scene.active.getChild("xyPlane").remove;
		}
		if (mouse.down("left") && movingObj == ring){
			if (hitVec == null){
				hitVec = mouseToPlaneHit(mouse.x,mouse.y,1,1<<0);
				if (hitVec!=null) xyPlane = spawnXZPlane(front.getChild("C_Ring_KS1RS_Front").transform.world.getLoc(), new Quat().fromTo(new Vec4(0,0,1,1), ring.transform.look().normalize()) );
				hitVec = mouseToPlaneHit(mouse.x,mouse.y,planegroup+1,1<<planegroup);
			}
			var newHitVec = mouseToPlaneHit(mouse.x,mouse.y,planegroup+1,1<<planegroup);
			if (newHitVec!= null ) {
				var angleNew:Float;
				var angle: Float;

				var dirVec = new Vec4().setFrom(hitVec).sub(front.getChild("C_Ring_KS1RS_Front").transform.world.getLoc());
				dirVec.normalize();
				var upAngle = angle3d(dirVec, front.getChild("C_Ring_KS1RS_Front").transform.up().normalize());
				var rAngle = angle3d(dirVec, front.getChild("C_Ring_KS1RS_Front").transform.right().normalize());


				var dirVecNew = new Vec4().setFrom(newHitVec).sub(front.getChild("C_Ring_KS1RS_Front").transform.world.getLoc());
				dirVecNew.normalize();
				var upAngleNew = angle3d(dirVecNew, front.getChild("C_Ring_KS1RS_Front").transform.up().normalize());
				var rAngleNew = angle3d(dirVecNew, front.getChild("C_Ring_KS1RS_Front").transform.right().normalize());


				if (rAngleNew< Math.PI/2) angleNew = upAngleNew;
				else angleNew = Math.PI*2 - upAngleNew;

				if (rAngle< Math.PI/2) angle = upAngle;
				else angle = Math.PI*2 - upAngle;

				ringAngle = (ringAngle - (angleNew-angle) ) % (Math.PI*2);

				hitVec = newHitVec;
				allVariablesToProbs(object);
				updateParts();
			}
			else trace("xyPlane not detected by rayCastmethod");
		}
		

		if (mouse.down("left")){
			var mouse_c = iron.system.Input.getMouse();
			var coords = new Vec4(mouse_c.x, mouse_c.y,0,1);
			var physics = armory.trait.physics.PhysicsWorld.active;
			
			var rb = physics.pickClosest(coords.x, coords.y);
			if (rb != null && rb.object == screwBot){
				if (screwBotDist < screwPosLim + screwTrans){
					screwBotDist = screwBotDist + screwTrans;
					trace(screwBotDist);
				}
				updateParts();
			}
			else if (rb != null && rb.object == screwTop){
				if (screwTopDist < screwPosLim + screwTrans){
					screwTopDist = screwTopDist + screwTrans;
					trace(screwTopDist);
				}
				updateParts();
			}
			else if (rb != null && rb.object == screwMid){
				if (screwMidDist < screwPosLim + screwTrans){
					screwMidDist = screwMidDist + screwTrans;
					trace(screwMidDist);
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
					trace(screwBotDist);
				}
				updateParts();
			}
			else if (rb != null && rb.object == screwTop){
				if (-1*screwNegLim < screwTopDist - screwTrans){
					screwTopDist = screwTopDist - screwTrans;
					trace(screwTopDist);
				}
				updateParts();
			}
			else if (rb != null && rb.object == screwMid){
				if (-1*screwNegLim < screwMidDist - screwTrans){
					screwMidDist = screwMidDist - screwTrans;
					trace(screwMidDist);
				}
				updateParts();
			}
		}

			// notifyOnRemove(function() {
			// });
	}

	public function updateParts() {

		nScale = new Vec4(0.01,0.01,0.01,1);

		allPropsToVariables(object);
		
		

		var numberRevolutions = 10;
		var mST = object.getChild("C_Screw_Top_Zero_KS1RS_Base").transform.world;
		screwTop.transform.setMatrix(mST);
		screwTop.transform.move(screwTop.transform.look().normalize(), screwTopDist);
		screwTop.transform.rotate(screwTop.transform.look().normalize(), screwTopDist/screwTravelDist * numberRevolutions * 2* Math.PI);
		screwTop.transform.scale = nScale;
		rbSync(screwTop);

		var mSB = object.getChild("C_Screw_Bottom_Zero_KS1RS_Base").transform.world;
		screwBot.transform.setMatrix(mSB);
		screwBot.transform.move(screwBot.transform.look().normalize(),screwBotDist);
		screwBot.transform.rotate(screwBot.transform.look().normalize(), screwBotDist/screwTravelDist * numberRevolutions * 2 * Math.PI);
		screwBot.transform.scale = nScale;
		rbSync(screwBot);

		var mSM = object.getChild("C_Screw_Middle_Zero_KS1RS_Base").transform.world;
		screwMid.transform.setMatrix(mSM);
		screwMid.transform.move(screwMid.transform.look().normalize(), screwMidDist);
		screwMid.transform.rotate(screwMid.transform.look().normalize(), screwMidDist/screwTravelDist * numberRevolutions * 2 * Math.PI);
		screwMid.transform.scale = nScale;
		rbSync(screwMid);


		// calculate correct rotation of mirror
		var loc_cF = screwMid.transform.world.getLoc();
		var loc_ST = screwTop.transform.world.getLoc();
		var loc_SB = screwBot.transform.world.getLoc();
	
		var rotVecT = new Vec4().setFrom(loc_ST).sub(loc_cF).normalize();
		var rotVecB = new Vec4().setFrom(loc_SB).sub(loc_cF).normalize();

		// calculate angles
		var vU = new Vec4().setFrom(object.transform.up()).normalize();
		var sgnU = Std.int((screwTopDist - screwMidDist)/Math.abs(screwTopDist - screwMidDist));
		var angU = Math.acos(rotVecT.dot(vU))*sgnU;

		var vR = new Vec4().setFrom(object.transform.right()).normalize();
		var sgnB = Std.int((screwBotDist - screwMidDist)/Math.abs(screwBotDist - screwMidDist));
		var angB = Math.acos(rotVecB.dot(vR))*sgnB;
		
		// update transform matrix
		var mSM = object.getChild("C_Screw_Middle_Zero_KS1RS_Base").transform.world;
		front.transform.setMatrix(mSM);
		front.transform.scale = nScale;
		front.transform.move(screwMid.transform.look().normalize(), screwMidDist);

		//calculate quaternions from angles, and calculate new total quaterion for rotation in new transfrom matrix
		var q1 = new Quat().fromAxisAngle(new Vec4().setFrom(object.transform.right()).normalize(), angU*-1);
		var q2 = new Quat().fromAxisAngle(new Vec4().setFrom(object.transform.up()).normalize(), angB);
		var rotF = new Quat();
		rotF.mult(q1);
		rotF.mult(q2);
		rotF.mult(object.transform.rot);
		front.transform.rot = rotF;
		if (screwMidDist == screwBotDist && screwTopDist == screwBotDist ){ // if the values are equal rotF is NaN, by this check it is prevented, that the objects rot Value is Nan 
			front.transform.rot = object.transform.rot;
		} 
		front.transform.buildMatrix();
		
		rbSync(front);


		var mR = front.getChildren()[0].transform.world;
		ring.transform.setMatrix(mR);
		ring.transform.scale = nScale;
		ring.transform.rotate(ring.transform.look().normalize(), ringAngle);
		rbSync(ring);


		var mB = ring.getChildren()[0].transform.world;
		bbo.transform.setMatrix(mB);
		bbo.transform.scale = nScale;
		rbSync(bbo);
		
		Event.send("Calc_Beams"); // Event of the scene trait calc beams, makes a new calculation of the Beams
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
	
	inline function allPropsToVariables(object:Object){
		ringAngle   = object.properties["ringAngle"];
	}
	
	inline function allVariablesToProbs(object:Object){
		object.properties["ringAngle"] 	= ringAngle  ;
	}

	
	function spawnXZPlane(loc: Vec4, rot: Quat):Object{
		// helping function to spawn invisible plane in XY
		// used to project mouse from the screen coordinates to the world
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
		//object.visible = true;
		object.transform.loc = loc;
		object.transform.rot = rot;
		//trace(loc);
		//trace(object.getTrait(RigidBody).group);
		rbSync(object);
		return object;
	}

	function mouseToPlaneHit (inputX, inputY,group, mask):Dynamic{
		// rayCasts mouse position according to camera to return a vector
		// modified by group and mask
		// mask is a bitwise shifted integer
		// used together with function spawnXYPlane()
		// depends on  iron.math.RayCaster
		var camera = iron.Scene.active.camera;
		var physics = armory.trait.physics.PhysicsWorld.active;
		var start = new Vec4();
		var end = new Vec4();
		RayCaster.getDirection(start, end, inputX, inputY, camera); // changes arguments end
		var hit = physics.rayCast(camera.transform.world.getLoc(), end,  group,mask);

		if (hit!=null) return new Vec4().setFrom(hit.pos);
		else return null;
	}

	function angle3d(vec1:Vec4 ,vec2:Vec4): Float{
		var arg1 = new Vec4().setFrom(vec1);
		arg1.cross(vec2);
		var arg2 = new Vec4().setFrom(vec1);
		var angle = Math.atan2(arg1.length(), arg2.dot(vec2));
		return angle;
	}

}
	

	