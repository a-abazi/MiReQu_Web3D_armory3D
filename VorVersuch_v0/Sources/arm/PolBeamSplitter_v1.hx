package arm;

import iron.math.Vec4;
import iron.object.Object;
import iron.math.Quat;
import iron.math.Mat4;

class PolBeamSplitter_v1 extends iron.Trait {
	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "PolBeamSplitter_v1";
		
		@prop
		var changes_prop:Bool = true;
		
		@prop
        var blocksBeam: Bool = false;
        
        //@prop
		var spawnsRays: Int = 1;
		

		notifyOnInit(function() {

			if (object == null) return;
			if (object.properties == null) object.properties = new Map();
			object.properties.set("String_Beam_Ray_Traits", String_Beam_Ray_Traits);
			object.properties.set("changes_prop",changes_prop);
            object.properties.set("blocksBeam",blocksBeam);
			object.properties.set("spawnsRays",spawnsRays);
		});

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}
	
	public function GetBeamDirection(in_dir:Vec4){
        return in_dir;
    }

    public function GetNewBeamDirection(in_dir:Vec4, beamNumber:Int):Vec4{
        var spawnsRays: Int = object.properties.get("spawnsRays");
        
        if (beamNumber>=spawnsRays){
            trace("Error: tried to spawn more Beams from source than possible");
            return null;
        }        
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
 
    public function GetChildProperties(parBeam:Object, pos:Vec4, dir:Vec4){
        var new_childprops:  Map<String,Dynamic> = parBeam.properties.copy();
        var normal_vec: Vec4 = object.transform.world.look().normalize(); // brauche ich später wahrscheinlich nochmal
		var up_vec: Vec4 = object.transform.world.up().normalize();
        var right_vec: Vec4 = object.transform.world.right().normalize();


        var I: Float    =     new_childprops["stokes_I"];
        var p: Float    =     new_childprops["stokes_p"];
        var psi2: Float = 2 * new_childprops["stokes_psi"];
        var chi2: Float = 2 * new_childprops["stokes_chi"];

        if (new_childprops["stokes_I"] == 0){
            return new_childprops;
        }

        var stokes_vec: Vec4 = new Vec4( // https://en.wikipedia.org/wiki/Stokes_parameters
            I,
            I*p*Math.cos(psi2)*Math.cos(chi2),
            I*p*Math.sin(psi2)*Math.cos(chi2),
            I*p*Math.sin(chi2)
		);
		
        // calculate the angle of the polarizer (right vec)
        var vcross = new Vec4(0,0,1,1).cross(up_vec);
        var vb = new Vec4().setFrom(up_vec);
        var va = new Vec4(0,0,1,1);
        var theta = Math.atan2(vcross.dot(normal_vec),va.dot(vb));
        
        if (normal_vec.dot(parBeam.transform.world.right())<0) theta*=-1;
        
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
        m3.mult(1/2.);

        stokes_vec.applymat4(m3);
        new_childprops["stokes_I"]   = stokes_vec.x;
        new_childprops["stokes_p"]   = Math.sqrt(Math.pow(stokes_vec.y,2)+Math.pow(stokes_vec.z,2)+Math.pow(stokes_vec.w,2))/stokes_vec.x;
        
        new_childprops["stokes_psi"] = 1./2.*Math.atan2(stokes_vec.z,stokes_vec.y)-Math.atan2(0,1);
        new_childprops["stokes_chi"] = 1./2.*Math.atan2(stokes_vec.w,Math.sqrt(Math.pow(stokes_vec.z,2)+Math.pow(stokes_vec.y,2)))-Math.atan2(0,1);

		return  new_childprops;
    }	

    public function GetNewChildProperties(parBeam:Object, beamNumber:Int){
		var spawnsRays: Int = object.properties.get("spawnsRays");
		     
		var normal_vec: Vec4 = object.transform.world.look().normalize(); // brauche ich später wahrscheinlich nochmal
        var up_vec: Vec4 = object.transform.world.up().normalize();
        var right_vec: Vec4 = object.transform.world.right().normalize();
		
		if (beamNumber>=spawnsRays){
            trace("Error: tried to spawn more Beams from source than possible");
            return null;
        }
        var propMap = new  Map<String,Dynamic>();

        
		if (parBeam == null) return null;
        if (parBeam.properties == null) parBeam.properties = new Map();
        propMap = parBeam.properties;
		propMap.set("arr_sub_objects",[]);

        if (propMap["stokes_I"] == 0){
            return propMap;
        }

        var I: Float    =     propMap["stokes_I"];
        var p: Float    =     propMap["stokes_p"];
        var psi2: Float = 2 * propMap["stokes_psi"];
        var chi2: Float = 2 * propMap["stokes_chi"];



        var stokes_vec: Vec4 = new Vec4( // https://en.wikipedia.org/wiki/Stokes_parameters
            I,
            I*p*Math.cos(psi2)*Math.cos(chi2),
            I*p*Math.sin(psi2)*Math.cos(chi2),
            I*p*Math.sin(chi2)
		);
		
        // calculate the angle of the polarizer (right vec)
        var vcross = new Vec4(0,0,1,1).cross(up_vec);
        var vb = new Vec4().setFrom(up_vec);
        var va = new Vec4(0,0,1,1);
        var theta = Math.atan2(vcross.dot(normal_vec),va.dot(vb));
        
        if (normal_vec.dot(parBeam.transform.world.right())<0) theta*=-1;
        
        var ct = Math.cos(2*theta);
        var st = Math.sin(2*theta);

        var m1 = new Mat4(
            1,0,0,0,
            0,ct,-1*st,0,
            0,st,ct,0,
            0,0,0,1
        );
        var m2 = new Mat4(
            1,-1,0,0,
            -1,1,0,0,
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
        m3.mult(1/2.);

		stokes_vec.applymat4(m3);

        propMap["stokes_I"]   = stokes_vec.x;
        propMap["stokes_p"]   = Math.sqrt(Math.pow(stokes_vec.y,2)+Math.pow(stokes_vec.z,2)+Math.pow(stokes_vec.w,2))/stokes_vec.x;
        
        propMap["stokes_psi"] = 1./2.*Math.atan2(stokes_vec.z,stokes_vec.y)-Math.atan2(0,1);
        propMap["stokes_chi"] = 1./2.*Math.atan2(stokes_vec.w,Math.sqrt(Math.pow(stokes_vec.z,2)+Math.pow(stokes_vec.y,2)))-Math.atan2(0,1);

		
        return propMap;
	}
}
