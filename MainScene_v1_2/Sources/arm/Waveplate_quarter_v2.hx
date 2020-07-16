package arm;

import haxe.ds.Vector;
import iron.math.Vec4;
import iron.math.Mat4;
import iron.object.Object;
import iron.math.Quat;

//only works correctly for planar incomming beams

class Waveplate_quarter_v2 extends iron.Trait {
	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "Waveplate_quarter_v2";
		
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
        var new_childprops:  Map<String,Dynamic> = parBeam.properties.copy();
        var normal_vec: Vec4 = object.transform.world.look().normalize(); // brauche ich später wahrscheinlich nochmal
        var up_vec: Vec4 = object.transform.world.up().normalize();
        


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

        // https://en.wikipedia.org/wiki/Mueller_calculus
        var delta = Math.PI/2.0; // lambda/4
        //var delta = Math.PI; //lambda/2
        
        // calculate the angle of the fast axis (up vec)
        var vcross = new Vec4(0,0,1,1).cross(up_vec);
        var vb = new Vec4().setFrom(up_vec);
        var va = new Vec4(0,0,1,1);
        var theta = Math.atan2(vcross.dot(normal_vec),va.dot(vb));
        
        var ct = Math.cos(2*theta);
        var st = Math.sin(2*theta);
        var cd = Math.cos(delta);
        var sd = Math.sin(delta);

        var mMatrix = new Mat4(1, 0 ,0 ,0,
            0, ct*ct + st*st*cd, ct*st*(1.-cd), st*sd,
            0, ct*st*(1-cd), ct*ct*cd+st*st, -1*ct*sd,
            0, -1*st*sd, ct*sd, cd
        );

        //trace(mMatrix);
        stokes_vec.applymat4(mMatrix);

        new_childprops["stokes_I"]   = stokes_vec.x;
        new_childprops["stokes_p"]   = Math.sqrt(Math.pow(stokes_vec.y,2)+Math.pow(stokes_vec.z,2)+Math.pow(stokes_vec.w,2))/stokes_vec.x;
        
        new_childprops["stokes_psi"] = 1./2.*Math.atan2(stokes_vec.z,stokes_vec.y)-Math.atan2(0,1);
        new_childprops["stokes_chi"] = 1./2.*Math.atan2(stokes_vec.w,Math.sqrt(Math.pow(stokes_vec.z,2)+Math.pow(stokes_vec.y,2)))-Math.atan2(0,1);

        //trace(new_childprops["stokes_chi"]);
        //trace(stokes_vec);
        return  new_childprops;
    }

	public function GetBeamDirection(in_dir:Vec4){
        return in_dir;
	}
}