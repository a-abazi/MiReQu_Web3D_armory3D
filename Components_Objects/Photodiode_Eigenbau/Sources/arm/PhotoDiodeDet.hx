package arm;

import iron.Scene;
import iron.math.Vec4;
import iron.object.Object;
import iron.math.Quat;

class PhotoDiodeDet extends iron.Trait {
	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "PhotoDiodeDet";
		
		@prop
		var changes_prop:Bool = false;
		
		@prop
		var blocksBeam: Bool = true;

		
        var spawnsRays: Int = 0;
		notifyOnInit(function() {

			if (object == null) return;
			if (object.properties == null) object.properties = new Map();
			object.properties.set("String_Beam_Ray_Traits", String_Beam_Ray_Traits);
			object.properties.set("changes_prop",changes_prop);
			object.properties.set("blocksBeam",blocksBeam);
		});

		notifyOnUpdate(function() {
			var globalObj: Object = iron.Scene.global;
			measureBeams(globalObj.properties.get("ArrayDetBeams"));
		});

		// notifyOnRemove(function() {
		// });
	}
	
	public function measureBeams(arrayDetectableBeams:Array<Map<String,Dynamic>>){
		for (map in arrayDetectableBeams) {
			if (map["pos"] != null){
				var beamPos:Vec4 = map["pos"];
				var detPos:Vec4 = object.getChild("detektor_Photodiode").transform.world.getLoc();
				trace(beamPos.distanceTo(detPos));
			}

			
		}
		
	}
}
