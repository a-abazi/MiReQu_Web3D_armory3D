package arm;

import haxe.ds.Vector;
import iron.math.Vec4;
import iron.math.Mat4;
import iron.object.Object;
import iron.math.Quat;

//only works correctly for planar incomming beams

class LinearPolarizer extends iron.Trait {
	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "LinearPolarizer";
		
		@prop
		var changes_prop:Bool = true;
        
		@prop
        var blocksBeam: Bool = false;

        @prop
        var transmission: Float = 0.85;
        

		notifyOnInit(function() {

			if (object == null) return;
			if (object.properties == null) object.properties = new Map();
			object.properties.set("String_Beam_Ray_Traits", String_Beam_Ray_Traits);
            object.properties.set("changes_prop",changes_prop);
            object.properties.set("blocksBeam",blocksBeam);
            object.properties.set("transmission",transmission);
		});

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}
    


    public function GetChildProperties(parBeam:Object, pos:Vec4, dir:Vec4){
        var new_childprops:  Map<String,Dynamic> = parBeam.properties.copy();
        var normal_vec: Vec4 = object.transform.world.look().normalize(); // brauche ich später wahrscheinlich nochmal
        var up_vec: Vec4 = object.transform.world.up().normalize();
        var right_vec: Vec4 = object.transform.world.right().normalize();

        var I: Float    =     new_childprops["stokes_I"];
        var p: Float    =     new_childprops["stokes_p"];
        var psi2: Float = 2 * new_childprops["stokes_psi"];
        var chi2: Float = 2 * new_childprops["stokes_chi"];

        var stokes_vec: Vec4 = new Vec4( // https://en.wikipedia.org/wiki/Stokes_parameters
            I,
            I*p*Math.cos(psi2)*Math.cos(chi2),
            I*p*Math.sin(psi2)*Math.cos(chi2),
            I*p*Math.sin(chi2)
        );

        
        // calculate the angle of the polarizer (right vec)
        var vcross = new Vec4(0,0,1,1).cross(right_vec);
        var vb = new Vec4().setFrom(right_vec);
        var va = new Vec4(0,0,1,1);
        var theta = Math.atan2(vcross.dot(normal_vec),va.dot(vb));
        
        if (normal_vec.dot(parBeam.transform.world.right())<0) theta*=-1;
        


        //var transmission = object.properties.get("transmission");
        var transmission = 1.;
        var ct = Math.cos(2*theta);
        var st = Math.sin(2*theta);

        var m1 = new Mat4(
            1,0,0,0,
            0,ct,-1*st,0,
            0,st,ct,0,
            0,0,0,1
        );
        var m2 = new Mat4(
            1,1,0,0,
            1,1,0,0,
            0,0,0,0,
            0,0,0,0
        );
        var m3 = new Mat4(
            1,0,0,0,
            0,ct,st,0,
            0,-1*st,ct,0,
            0,0,0,1
        );
        
        m3.multmat(m2);
        m3.multmat(m1);

        m3.mult(transmission/2.);

        
        //trace("SV before "+stokes_vec.toString());
        //stokes_vec.applymat4(mMatrix);
        stokes_vec.applymat4(m3);

        new_childprops["stokes_I"]   = stokes_vec.x;
        new_childprops["stokes_p"]   = Math.sqrt(Math.pow(stokes_vec.y,2)+Math.pow(stokes_vec.z,2)+Math.pow(stokes_vec.w,2))/stokes_vec.x;
        
        new_childprops["stokes_psi"] = 1./2.*Math.atan2(stokes_vec.z,stokes_vec.y)-Math.atan2(0,1);
        new_childprops["stokes_chi"] = 1./2.*Math.atan2(stokes_vec.w,Math.sqrt(Math.pow(stokes_vec.z,2)+Math.pow(stokes_vec.y,2)))-Math.atan2(0,1);
        
        //trace("SV after "+stokes_vec.toString());
        //trace("Chi "+new_childprops["stokes_chi"].toString());
        //trace("Psi "+Std.string(new_childprops["stokes_psi"]*180/Math.PI));
        //trace("I "+new_childprops["stokes_I"]);
        //trace("p "+new_childprops["stokes_p"]);

        return  new_childprops;
    }

	public function GetBeamDirection(in_dir:Vec4){
        return in_dir;
	}
}