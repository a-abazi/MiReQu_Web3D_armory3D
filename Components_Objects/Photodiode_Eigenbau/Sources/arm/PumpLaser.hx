package arm;

import iron.math.Vec4;
import iron.object.Object;
import iron.math.Mat4;


class PumpLaser extends iron.Trait {

	@prop
	var String_Beam_Ray_Traits: String = "PumpLaser";

	@prop
	var wl: Float = 405.; // linewidth of 160 MHz

	//@prop
	//var pol_jones_vec_amp: Vec4 = new Vec4(0,0,1,1) ;
//
	//@prop
	//var pol_jones_vec_phase: Vec4 = new Vec4(0,0,0,1);


	// Stokes Parameter https://en.wikipedia.org/wiki/Stokes_parameters  
	// specified for Ondax diode
	@prop
	var stokes_I: Float = 1.0; // 40mW divided by beamsize

	@prop
	var stokes_p: Float = .99;

	@prop
	var stokes_psi: Float = 0; // in degrees

	@prop
	var stokes_chi: Float = 0; // in degrees

	@prop
	var beamsize_x: Float = 0.8; // in mm

	@prop
	var beamsize_y: Float = 0.4; // in mm


	@prop
	var changes_prop:Bool = true;

	@prop
	var blocksBeam: Bool = true;

	var childprops = new  Map<String,Dynamic>();


	public function new() {
		super();

		 notifyOnInit(function() {
			if (object == null) return;
			if (object.properties == null) object.properties = new Map();

			object.properties.set("blocksBeam",blocksBeam);
			object.properties.set("String_Beam_Ray_Traits", String_Beam_Ray_Traits);
			object.properties.set("changes_prop",changes_prop);


			childprops.set("wl"        ,wl        );
			childprops.set("stokes_I"  ,stokes_I  );
			childprops.set("stokes_p"  ,stokes_p  );
			childprops.set("stokes_psi",stokes_psi/180. * Math.PI);
			childprops.set("stokes_chi",stokes_chi/180. * Math.PI);
			childprops.set("beamsize_x",beamsize_x);
			childprops.set("beamsize_y",beamsize_y);


		 });

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}

	public function GetChildProperties(Beam:Object, pos:Vec4, dir:Vec4){

		return childprops;
	}
}
