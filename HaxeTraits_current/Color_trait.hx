package arm;

import iron.math.Vec4;
import iron.object.Object;
import iron.object.Uniforms;
import iron.data.MaterialData;
import iron.system.Time;

class Color_trait extends iron.Trait {


	public function new() {
		super();

		notifyOnInit(function() {
			// Register link callbacks
			Uniforms.externalVec3Links.push(vec3Link);
			//Uniforms.externalFloatLinks.push(floatLink);
			//Uniforms.externalTextureLinks.push(textureLink);
		});

	}

	function vec3Link(object:Object, mat:MaterialData, link:String):iron.math.Vec4 {
		// object - currently bound object
		// mat - currently bound material
		// link - material node name
		
		if (object == null ) return null;
		if (link == "RGB" && object.name == "Beam" ) {
			var t = Time.time();
			
			if (object == null) return null;
			if (object.properties == null) object.properties = new Map();
			var wl = object.properties.get("wl");
			if (wl == null) return null;

			var r:Float = 0;
			var g:Float = 0;
			var b:Float = 0;


			if (wl == 405) b = 0.5;
			if (wl == 810) r = 0.5;

			var color = new Vec4(r,g,b,1);

			//return new Vec4(Math.sin(t) * 0.5 + 0.5, Math.cos(t) * 0.5 + 0.5, Math.sin(t + 0.5) * 0.5 + 0.5);
			return color;
		}

		return null;
	}

	
}
