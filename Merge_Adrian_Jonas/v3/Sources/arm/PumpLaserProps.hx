package arm;

import iron.math.Vec4;
import iron.object.Object;
import iron.math.Mat4;


class PumpLaserProps extends iron.Trait {

	@prop
	var String_Beam_Ray_Traits: String = "PumpLaserProps";

	@prop
	var wl: Float = 410.;

	@prop
	var pol_jones_vec_amp: Vec4 = new Vec4(1,0,0,1) ;

	@prop
	var pol_jones_vec_phase: Vec4 = new Vec4(0,0,0,1);

	@prop
	var changes_prop:Bool = true;

	@prop
	var blocksBeam: Bool = true;

	var arr_childProps_names: Array<String> = [];
	var arr_childProps_values: Array<Dynamic> = [];

	public function new() {
		super();

		 notifyOnInit(function() {

			if (object == null) return;
			if (object.properties == null) object.properties = new Map();

			object.properties.set("blocksBeam",blocksBeam);
			object.properties.set("String_Beam_Ray_Traits", String_Beam_Ray_Traits);
			object.properties.set("changes_prop",changes_prop);

			arr_childProps_names.push("wl");
			arr_childProps_names.push("pol_jones_vec_amp");
			arr_childProps_names.push("pol_jones_vec_phase");

			arr_childProps_values.push(wl);
			arr_childProps_values.push(pol_jones_vec_amp);
			arr_childProps_values.push(pol_jones_vec_phase);

			//trace(GetChildProperties(null,null,null));
		 });

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}

	public function GetChildProperties(Beam:Object, pos:Vec4, dir:Vec4){
		var childprops:Array<Dynamic> = [arr_childProps_names,arr_childProps_values];
		return childprops;
	}
}
