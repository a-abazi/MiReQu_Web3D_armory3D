package arm;

import iron.math.Vec4;
import iron.object.Object;
import iron.math.Quat;

class Mirror_v4 extends iron.Trait {
	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "Mirror_v4";
		
		@prop
		var changes_prop:Bool = false;
		
		@prop
		var blocksBeam: Bool = false;

		
        var spawnsRays: Int = 0;
		notifyOnInit(function() {

			if (object == null) return;
			if (object.properties == null) object.properties = new Map();
			object.properties.set("String_Beam_Ray_Traits", String_Beam_Ray_Traits);
			object.properties.set("changes_prop",changes_prop);
			object.properties.set("blocksBeam",blocksBeam);
		});

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}
	
	public function GetBeamDirection(in_dir:Vec4){
		var out_dir = new Vec4();
		var axis: Vec4 = object.transform.world.look();
		if (in_dir == null || axis == null) return null;
		var inv_in_dir: Vec4 = new Vec4().setFrom(in_dir);
		inv_in_dir.mult(-1);

		// see https://en.wikipedia.org/wiki/Reflection_(mathematics) for details
		out_dir.subvecs(axis.mult(1.0/(axis.length()*axis.length())*2*inv_in_dir.dot(axis)),inv_in_dir); 
		out_dir.normalize(); 
		
		return out_dir;
	}
}
