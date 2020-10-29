package arm;


import js.html.CompositionEvent;
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

/*TODO: let it add a trait to the waveplate 
  TODO: Bug with the "XZ plane", does not despawn sometimes, Quick fix by despawning it with other Trait
 		For some reason the trait is not able to remove it, Same for KS1RS_Base.hx
*/	
class RSP1D_Base extends iron.Trait {

	@prop 
	var opticName: String = "LP";
	@prop 
	var ringName: String = "RSP1D_Ring";
	
	var scale: Vec4  = new Vec4(0.01,0.01,0.01,1);

	var ringAngle: Float;

	var ring: Object;
	var optic: Object;

	var movingObj: Object = null;
	var xyPlane: Object = null;
	var hitVec: Vec4 = null;
	var planegroup: Int = 2; //third square in Blender 2^(n); n=2 (first square is n=0)
	var visib: Bool =  false;
	var objectGroup: Int = 1;

	var objList: Array<Object> = [];
	var mouseRel: Bool = true;
	
	public function new() {
		super();
		
		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);
		notifyOnRemove(onRemove);
	};

	function onInit() {
		initProps(object);

		if (object.properties["spawned"]){
			visib = true;
			}
		//else{
		//	//object.remove();
		//	return;
		//}

		if (object.properties["ringAngle"] != null) allPropsToVariables(object);
		else allVariablesToProbs(object);

		if (object.properties["opticName"]!=null) opticName = object.properties["opticName"];

		if (ringAngle == null) ringAngle = 0;
		
		var mCR = object.transform.world;
		var mCW = object.getChild("C_optic_RSP1D_Base").transform.world;

		ring = spawnObject(ringName,false);
		ring.transform.setMatrix(mCR);
		ring.transform.scale = scale;
		ring.visible = visib;
		ring.transform.rotate(ring.transform.look().normalize(), ringAngle);
		rbSync(ring);
		
		optic = spawnObject(opticName,false);
		optic.transform.setMatrix(mCW);
		optic.transform.scale = scale;
		optic.visible = visib;
		optic.transform.rotate(ring.transform.look().normalize(), ringAngle);
		rbSync(optic);

		
		// Event added with object id as a mask, the postholder trait UPH2_Base will send this event to its componente object when moved
		Event.add("updateParts",updateParts,object.uid);

		//if (Scene.active.getChild("xyPlane") != null ) Scene.active.getChild("xyPlane").remove;

		

		objList.push(object);
		objList.push(ring);
		objList.push(optic);


		for (obj in objList){
			initProps(obj);
			if (obj != object) obj.properties.set("TraitObj",object);
			else obj.properties.set("TraitObj","self");
			obj.properties.set("TraitName","RSP1D"+"_Base");
			obj.properties.set("PauseResume",true);
		}
		pauseUpdate();
		
	}

	public function pauseUpdate():Bool{
		removeUpdate(onUpdate);
		return true;
	}

	public function resumeUpdate():Bool{
		notifyOnUpdate(onUpdate);
		return true;
	}

			
	function onUpdate(){
		//trace(Std.string(object.name) +Std.string(object.uid)+"_Active");
		var mouse = Input.getMouse();
		var rb = null;
		if (mouse.down("left") && mouseRel){
			var physics = armory.trait.physics.PhysicsWorld.active;	

			rb = physics.pickClosest(mouse.x, mouse.y);
			if (rb !=null) {
				movingObj = rb.object;
				if (movingObj.name == "xyPlane") movingObj.remove();
			}
			mouseRel = false;
		}

		if (mouse.released("left")||mouse.released("right")) {
			movingObj = null;
			if (xyPlane != null) xyPlane.remove();
			hitVec = null;
			mouseRel = true;
			updateParts();
			if (Scene.active.getChild("xyPlane") != null ) Scene.active.getChild("xyPlane").remove;
			pauseUpdate();
		}

		if (mouse.down("left") && movingObj == ring){
			
			if (hitVec == null){
				hitVec = mouseToPlaneHit(mouse.x,mouse.y,1,1<<objectGroup);
				if (hitVec!=null||xyPlane == null ){
					xyPlane = spawnXZPlane(ring.transform.loc, new Quat().fromTo(new Vec4(0,0,1,1), ring.transform.look().normalize()) );
					//rbSync(xyPlane);
				}
				else xyPlane.remove();
				
				hitVec = mouseToPlaneHit(mouse.x,mouse.y,planegroup+1,1<<planegroup);
			}
			var newHitVec = mouseToPlaneHit(mouse.x,mouse.y,planegroup+1,1<<planegroup);
			if (newHitVec!= null ) {
				var angleNew:Float;
				var angle: Float;
				
				var dirVec = new Vec4().setFrom(hitVec).sub(object.transform.loc);
				dirVec.normalize();
				var upAngle = angle3d(dirVec, object.transform.up().normalize());
				var rAngle = angle3d(dirVec, object.transform.right().normalize());
				

				var dirVecNew = new Vec4().setFrom(newHitVec).sub(object.transform.loc);
				dirVecNew.normalize();
				var upAngleNew = angle3d(dirVecNew, object.transform.up().normalize());
				var rAngleNew = angle3d(dirVecNew, object.transform.right().normalize());
				
				
				if (rAngleNew< Math.PI/2) angleNew = upAngleNew;
				else angleNew = Math.PI*2 - upAngleNew;

				if (rAngle< Math.PI/2) angle = upAngle;
				else angle = Math.PI*2 - upAngle;

				ringAngle = ringAngle + (angleNew-angle) ;
				hitVec = newHitVec;
				allVariablesToProbs(object);
				updateParts();
			}
			else trace("xyPlane not detected by rayCastmethod");
		
		}

	}

	function onRemove(){
		for (obj in objList){
			if (obj == object) continue;
			obj.remove();
		}
	}

	function updateParts() {

		allPropsToVariables(object);

		var mCR = object.transform.world;
		var mCW = object.getChild("C_optic_RSP1D_Base").transform.world;

		ring.transform.setMatrix(mCR);
		ring.transform.scale = scale;
		ring.transform.rotate(ring.transform.look().normalize(), ringAngle);
		rbSync(ring);
		
		optic.transform.setMatrix(mCW);
		optic.transform.scale = scale;
		optic.transform.rotate(ring.transform.look().normalize(), ringAngle);
		rbSync(optic);

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
		object.properties["ringAngle"] 	= ringAngle;

		if (object.properties.exists("SlotNum")){
			var angleArray =  iron.Scene.global.properties.get("inputAnglesArray");
			angleArray[object.properties.get("SlotNum")] = ringAngle * 180. /Math.PI;
			iron.Scene.global.properties.set("inputAnglesArray",angleArray);
		}

	}

	public function setAngle(newRingAngle: Float){
		ringAngle = (newRingAngle / 180.)*Math.PI;
		allVariablesToProbs(object);
		updateParts();
	}

	
	function spawnXZPlane(loc: Vec4, rot: Quat):Object{
		// helping function to spawn invisible plane in XY
		// used to project mouse from the screen coordinates to the world
		var object: Object;
		var matrix =   Mat4.identity();
		matrix.compose(loc,rot,new Vec4(1,1,1,1));
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
		
		//rbSync(object);

		
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

	public function getMeasurement(arrayDetectableBeams:Array<Map<String,Dynamic>>){

		return ringAngle;
		
	}

}