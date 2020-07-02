package arm;

import iron.math.Vec4;
import iron.object.Object;
import iron.math.Quat;
import Math;

class BBO_v1 extends iron.Trait {
	public function new() {
		super();

		@prop
		var String_Beam_Ray_Traits: String = "BBO_v1";
		
		@prop
		var changes_prop:Bool = false;
		
		@prop
        var blocksBeam: Bool = false;
        
        //@prop
        var spawnsRays: Int = 2;

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


	public function ConfrimSpawnCondition(parBeam:Object):Bool{

		return true;
	}



    public function GetNewBeamDirection(in_dir:Vec4, beamNumber:Int):Vec4{
		var spawnsRays: Int = object.properties.get("spawnsRays");
		var angle: Float = 5.0;
		var PI: Float = Math.PI;
		
		angle = PI / 180.0 * angle;


        if (beamNumber>=spawnsRays){
            trace("Error: tried to spawn more Beams from source than possible");
            return null;
        }        
        var out_dir = new Vec4().setFrom(in_dir);
		var axis: Vec4 = object.transform.world.up();
		axis.normalize();
		
		if (beamNumber == 1) angle = angle * -1;
		
		out_dir.applyAxisAngle(axis,angle);

		

        return out_dir;
    }
    
    public function GetNewChildProperties(parBeam:Object, beamNumber:Int){
        var spawnsRays: Int = object.properties.get("spawnsRays");
		var emptyArray: Array <Object> = new Array();
		
        if (beamNumber>=spawnsRays){
            trace("Error: tried to spawn more Beams from source than possible");
            return null;
        }
        var propMap = new  Map<String,Dynamic>();

        
		if (parBeam == null) return null;
        if (parBeam.properties == null) parBeam.properties = new Map();
		propMap = parBeam.properties.copy();
		
		propMap["wl"] = 810;
		if (beamNumber == 0) propMap["stokes_psi"] = 0;
		if (beamNumber == 1) propMap["stokes_psi"] = Math.PI/2;


		propMap.set("arr_sub_objects",emptyArray);
		
        return propMap;
	}
}
