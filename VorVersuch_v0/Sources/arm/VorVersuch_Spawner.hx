package arm;

import haxe.io.Input;
import armory.logicnode.ActiveSceneNode;
import iron.Scene;
import iron.object.Object;

import iron.system.Input;

import iron.object.Transform;
import iron.math.Vec4;
import armory.trait.physics.RigidBody;

enum CompVV {
	Empty;
	LinPol;
	WPHalf;
	WPQuart;
	Pbs;
}


class VorVersuch_Spawner extends iron.Trait {
	@prop
	var nameSlot0: String = "SpawnerSlot00";
	@prop
	var nameSlot1: String = "SpawnerSlot01";
	@prop
	var nameSlot2: String = "SpawnerSlot02";

	var slots: Array <Object> = [];

	public function new() {
		super();
		notifyOnInit(onInit);
		//notifyOnUpdate(onUpdate);
	}

	private function onInit(){
		slots.push(Scene.active.getChild(nameSlot0));
		slots.push(Scene.active.getChild(nameSlot1));
		slots.push(Scene.active.getChild(nameSlot2));

		for (slot in slots){
			initProps(slot);
		}

		if (Scene.global.properties == null) initProps(Scene.global);
		Scene.global.properties["slots"] = slots;


		fillSlot(0,Empty);
		fillSlot(1,Empty);
		fillSlot(2,Empty);
	}

	private function onUpdate() {
		var keyb =  Input.getKeyboard();

		if (keyb.started("1")){
			fillSlot(0,LinPol);
		}
		if (keyb.started("2")){
			fillSlot(1,WPHalf);
		}
		if (keyb.started("3")){
			fillSlot(1,WPQuart);
		}

		if (keyb.started("4")){
			fillSlot(2,Pbs);
		}

	}

	public function fillSlot(slotNum: Int, whatComp: CompVV){
		var slotMarkObj: Object = Scene.global.properties["slots"][slotNum];
		
		if (slotMarkObj.properties.exists("currComponentObj")) {
			if (slotMarkObj.properties.exists("currComponentType")){
				if (slotMarkObj.properties["currComponentType"] == whatComp) return;
				else removeCompFromSlot(slotNum);
			}
		}

		switch (whatComp){

			case Empty:{
				var pMap = createPropMapPost("UPH_TR75","UPH_Top40",slotMarkObj.transform.loc,90.,180,0.25,0.87);
				pMap["emptySlot"] = true;
				pMap["compType"] = whatComp;
				var spawnedObject = spawnObject("UPH_Base", true, slotMarkObj.transform.loc, pMap);
				rbSync(spawnedObject);
				slotMarkObj.properties["currComponentObj"] = spawnedObject;
			}	
			case LinPol: {
				var pMap = createPropMapPost("UPH_TR75","UPH_Top40",slotMarkObj.transform.loc,90.,180,0.25,0.87);
				var cMap: Map<String,Dynamic> = [];
	
				cMap["spawned"] = true;
				cMap["ringAngle"] = 0.;
				cMap["opticName"] = "LP";

				pMap["componentObjectName"] = "RSP1D_Base";
				pMap["Component_corrV"] = calcCorrV_RSP1D();
				pMap["Component_map"] = cMap;
	
				var spawnedObject = spawnObject("UPH_Base", true, slotMarkObj.transform.loc, pMap);
				rbSync(spawnedObject);
				slotMarkObj.properties["currComponentObj"] = spawnedObject;
			}
			case Pbs:{
				var pMap = createPropMapPost("UPH_TR75","UPH_Top40",slotMarkObj.transform.loc.sub(new Vec4(0,0.25,0,1)),90.,180,0.425,0.896);
				var cMap: Map<String,Dynamic> = [];
	
				cMap["spawned"] = true;

				pMap["componentObjectName"] = "KM100PM_Base";
				pMap["Component_map"] = cMap;
	
				var spawnedObject = spawnObject("UPH_Base", true, slotMarkObj.transform.loc, pMap);
				rbSync(spawnedObject);
				slotMarkObj.properties["currComponentObj"] = spawnedObject;
			}
			case WPHalf:{		
				var pMap = createPropMapPost("UPH_TR75","UPH_Top40",slotMarkObj.transform.loc,90.,180,0.25,0.87);
				var cMap: Map<String,Dynamic> = [];
	
				cMap["spawned"] = true;
				cMap["ringAngle"] = 0.;
				cMap["opticName"] = "WPH";

				pMap["componentObjectName"] = "RSP1D_Base";
				pMap["Component_corrV"] = calcCorrV_RSP1D();
				pMap["Component_map"] = cMap;
	
				var spawnedObject = spawnObject("UPH_Base", true, slotMarkObj.transform.loc, pMap);
				rbSync(spawnedObject);
				slotMarkObj.properties["currComponentObj"] = spawnedObject;
			}
			case WPQuart:{				
				var pMap = createPropMapPost("UPH_TR75","UPH_Top40",slotMarkObj.transform.loc,90.,180,0.25,0.87);
				var cMap: Map<String,Dynamic> = [];
	
				cMap["spawned"] = true;
				cMap["ringAngle"] = 0.;
				cMap["opticName"] = "WPQ";

				pMap["componentObjectName"] = "RSP1D_Base";
				pMap["Component_corrV"] = calcCorrV_RSP1D();
				pMap["Component_map"] = cMap;
	
				var spawnedObject = spawnObject("UPH_Base", true, slotMarkObj.transform.loc, pMap);
				rbSync(spawnedObject);
				slotMarkObj.properties["currComponentObj"] = spawnedObject;
			}
		}
		slotMarkObj.properties["currComponentType"] = whatComp;

	}


	function removeCompFromSlot(slotNum: Int){
		var slots: Array <Object> = Scene.global.properties["slots"];
		var slotObj: Object = slots[slotNum];
		if (slotObj.properties.exists("currComponentObj")){
			var slotComp:Object = slotObj.properties["currComponentObj"];
			slotComp.remove();
			slotObj.properties.remove("currComponentObj"); 
		}
	};





	function spawnObject(objectName: String, visible: Bool, loc: Vec4, props:Map<String,Dynamic> ):Object {
		// helping function to spawn an object
		var object: Object;
		var spawnChildren = true;

		iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
			object = o;
			object.visible = visible;
		}, spawnChildren);
		object.transform.loc = loc;
		if (object == null) return null;
		if (object.properties == null) object.properties = new Map();
		object.properties = props;
		return object;
	}


	private function createPropMapPost(postName: String,topName: String,loc: Vec4,baseAngleDegree:Float,postAngleDegree:Float,basePosition:Float,postHeight:Float):Map<String,Dynamic>{
		var pMap: Map<String,Dynamic> = [];

		var std_basePosition = 0.25;
		pMap["baseAngle"] = (baseAngleDegree - 90 )* Math.PI / 180.; 
		pMap["postAngle"] = postAngleDegree * Math.PI / 180.;
		pMap["baseDist"] = -1 * (basePosition - std_basePosition);
		//pMap["postDist"] = postDist;
		pMap["spawned"] = true;

		
		
		pMap["postHeight"] = postHeight;
		
		pMap["postName"] = postName;
		pMap["topName"] = topName;
		pMap["sLoc"] = loc;

		return pMap;
	}


	private function calcCorrV_RSP1D(): Vec4 {
		var corrObj = Scene.active.getChild("RSP1D_Base");
		var corrV = new Vec4().setFrom( corrObj.transform.world.getLoc());
		corrV.sub(corrObj.getChild("C_Post_RSP1D_Base").transform.world.getLoc());

		return corrV;
	}


	function rbSync(object:Object) { 
		// helping function for a rigid body object, 
		// is used to align the the rigid bodys of object and children to their new parent matrix (location and rotation)
		var rigidBody = object.getTrait(RigidBody);
		if (rigidBody != null) rigidBody.syncTransform();
	}

	inline function initProps(object:Object){
		if (object == null) return;
		if (object.properties == null) object.properties = new Map();
	}


}

