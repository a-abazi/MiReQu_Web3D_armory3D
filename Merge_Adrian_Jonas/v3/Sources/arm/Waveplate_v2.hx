package arm;

import haxe.ds.Vector;
import iron.math.Vec4;
import iron.object.Object;
import iron.math.Quat;

//only works correctly for planar incomming beams

class Waveplate_v2 extends iron.Trait {
	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "Waveplate_v2";
		
		@prop
		var changes_prop:Bool = true;
        
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
    
    public function GetChildProperties(parBeam:Object, pos:Vec4, dir:Vec4){
        var new_arr_childProps_names: Array<String> = [];
        var new_arr_childProps_values: Array<Dynamic> = [];
        var new_childprops:Array<Dynamic> = [new_arr_childProps_names,new_arr_childProps_values];
        var normal_vec: Vec4 = object.transform.world.look().normalize(); // brauche ich später wahrscheinlich nochmal
        var up_vec: Vec4 = object.transform.world.up().normalize();
        var pol_vec: Vec4;
        var pol_amp: Vec4 = new Vec4().setFrom(parBeam.properties.get("pol_jones_vec_amp")).normalize();
        
        // calculate the correct spatial vector of the polarization
        var q = new Quat(); // Describes the rotation to the beam direction
        var q2 = new Quat(); // Describes the rotation to the Pol direction
        var x = new Vec4(1,0,0,1);

        q.fromTo(x,dir);
        q2.fromTo(x,pol_amp);
        q.multquats(q,q2);
        pol_vec = x.applyQuat(q); // correct spatial vector of the polarization in the world coordinates
        
        // calculate the angle between the vectors
        var vcross = new Vec4().setFrom(pol_vec).cross(up_vec);
        var vb = new Vec4().setFrom(up_vec);
        var va = new Vec4().setFrom(pol_vec);
        var angle = Math.atan2(vcross.dot(normal_vec),va.dot(vb))*2;
        
        //trace (Std.string(angle)+" ;"+ Std.string(vcross)+ "; "+ Std.string(up_vec)+"; "+ Std.string(pol_vec));
        //angle = (2*angle)% (Math.PI*2);

        x = new Vec4(1,0,0,1);
        
        pol_amp.applyAxisAngle(x,angle);
        //trace(pol_amp);
		new_arr_childProps_names.push("pol_jones_vec_amp");
		//new_arr_childProps_names.push("pol_jones_vec_phase");
        new_arr_childProps_values.push(pol_amp);
        //new_arr_childProps_values.push(new Vec4());

        
        return  new_childprops;
    }

	public function Get_Beam_Direction(in_dir:Vec4){
        var out_dir = new Vec4().add(in_dir);
        out_dir.mult(-1);
        return out_dir;
	}
}