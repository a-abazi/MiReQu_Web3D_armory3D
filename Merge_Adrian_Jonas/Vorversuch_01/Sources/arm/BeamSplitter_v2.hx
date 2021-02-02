package arm;

import iron.math.Vec4;
import iron.object.Object;
import iron.math.Quat;

class BeamSplitter_v2 extends iron.Trait {
	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "BeamSplitter_v2";
		
		@prop
		var changes_prop:Bool = true;
		
		@prop
        var blocksBeam: Bool = false;
        
        //@prop
		var spawnsRays: Int = 1;
		
		@prop
		var ratio: Float = .7;

		notifyOnInit(function() {

			if (object == null) return;
			if (object.properties == null) object.properties = new Map();
			object.properties.set("String_Beam_Ray_Traits", String_Beam_Ray_Traits);
			object.properties.set("changes_prop",changes_prop);
            object.properties.set("blocksBeam",blocksBeam);
			object.properties.set("spawnsRays",spawnsRays);
			object.properties.set("ratio",ratio);
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
		var ratio: Float = object.properties.get("ratio");
        new_childprops["stokes_I"]*=ratio;
		
		return  new_childprops;
    }	

    public function GetNewChildProperties(parBeam:Object, beamNumber:Int){
        var spawnsRays: Int = object.properties.get("spawnsRays");
		var ratio: Float = object.properties.get("ratio");
		
        if (beamNumber>=spawnsRays){
            trace("Error: tried to spawn more Beams from source than possible");
            return null;
        }
        var propMap = new  Map<String,Dynamic>();

        
		if (parBeam == null) return null;
        if (parBeam.properties == null) parBeam.properties = new Map();
        propMap = parBeam.properties;
		propMap.set("arr_sub_objects",[]);

		propMap["stokes_I"] *=(1-ratio);
		
        return propMap;
	}
}
