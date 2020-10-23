package arm;

import kha.input.Keyboard;
import iron.Scene;
import iron.math.Vec4;
import iron.object.Object;
import iron.math.Quat;

import iron.system.Input;

class PhotoDiode extends iron.Trait {

	
	var	detectorEfficiency: Float = 0.85;
	@prop
	var String_Beam_Ray_Traits: String = "PhotoDiode";
	@prop
	var changes_prop:Bool = false;
	@prop
	var blocksBeam: Bool = true;
	@prop
	var nameDetektor: String = "SpannungPhotodiode1Sim";
	@prop
	var detectorSize: Float = 1.; // in mm
	
	
	public function new() {
		super();
		notifyOnInit(onInit);
		//notifyOnUpdate(onUpdate);
	}



	function onInit() {
		var globalObj: Object = iron.Scene.global;
		if (object == null) return;
		if (object.properties == null) object.properties = new Map();

		if (globalObj == null) return;
		if (globalObj.properties == null) globalObj.properties = new Map();

		if (!object.properties["spawned"]) return;

		object.properties.set("String_Beam_Ray_Traits", String_Beam_Ray_Traits);
		object.properties.set("changes_prop",changes_prop);
		object.properties.set("blocksBeam",blocksBeam);
		//object.properties.set("detectorSize",detectorSize);
		//object.properties.set("detectorEfficiency",detectorEfficiency);
		object.properties.set("nameDetektor", nameDetektor);
		trace(nameDetektor);

		if (globalObj.properties["detekorObjectsArray"] == null){
			globalObj.properties["detekorObjectsArray"] = [object];
		}
		else globalObj.properties["detekorObjectsArray"].push(object);
			
			
	}

	function onUpdate(){
		var keyboard = Input.getKeyboard();

		if (keyboard.down("space")){
			var globalObj: Object = iron.Scene.global;
			//trace(measureBeams(globalObj.properties.get("ArrayDetBeams")));
			trace(getMeasurement(globalObj.properties.get("ArrayDetBeams")));
		}
	}
	
	public function getMeasurement(arrayDetectableBeams:Array<Map<String,Dynamic>>){
		var signal: Float = 0.;
		var detectorSize = detectorSize;
		var dettEff =  detectorEfficiency;
		for (map in arrayDetectableBeams) {
			if (map["pos"] != null){
				var beamPos:Vec4 = map["pos"];
				var detPos:Vec4 = object.getChildren()[1].transform.world.getLoc();
				var beamDist = beamPos.distanceTo(detPos) * 100; //in mm
				var beamObject: Object = map["object"];
				var beamIntensity =  beamObject.properties["stokes_I"];
				var beamSize = beamObject.properties["beamsize_x"];
				
				var sigmaGaus = beamSize*beamSize+detectorSize*detectorSize;
				
				// signal is a gaussian of beamIntensity now only one Dimensional TODO: make 2D
				signal += beamIntensity * dettEff / (Math.sqrt(2*Math.PI)*Math.sqrt(sigmaGaus)) * Math.exp(-1*beamDist*beamDist/(2*sigmaGaus));
			}
		}
		return signal;
		
	}
}
