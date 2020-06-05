package arm;

import iron.math.Vec4;
import iron.object.Object;
import iron.math.Quat;

class Mirror_v4_wrong_coordinate_system extends iron.Trait {

	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "Mirror_v4_wrong_coordinate_system";
		
		@prop
		var changes_prop:Bool = false;
		
		@prop
		var blocksBeam: Bool = false;

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
	
	public function Get_Beam_Direction(in_dir:Vec4){
		var out_dir = new Vec4();
		var axis: Vec4 = new Vec4().setFrom(object.transform.world.up());

		if (in_dir == null || axis == null) return null;
		in_dir.normalize();
		axis.normalize();
		trace(axis); 
		trace(in_dir);
		// see https://en.wikipedia.org/wiki/Reflection_(mathematics) for details
		out_dir.subvecs(axis.mult(1.0/(axis.length()*axis.length())*2*in_dir.dot(axis)),in_dir); 
		out_dir.normalize();
		trace(out_dir);
		return out_dir;
	}
}
