package arm;

import kha.Color;
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
			Uniforms.externalVec3Links.push(vec3LinkColor);
			Uniforms.externalFloatLinks.push(floatLinkStrength);
			//Uniforms.externalFloatLinks.push(floatLink);
			//Uniforms.externalTextureLinks.push(textureLink);
		});

	}

	function vec3LinkColor(object:Object, mat:MaterialData, link:String):iron.math.Vec4 {
		// object - currently bound object
		// mat - currently bound material
		// link - material node name
		//trace(link);
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
			if (wl == 532) g = 0.5;
			if (wl == 810) r = 0.5;
			
			var color = new Vec4(r,g,b,1);

			//return new Vec4(Math.sin(t) * 0.5 + 0.5, Math.cos(t) * 0.5 + 0.5, Math.sin(t + 0.5) * 0.5 + 0.5);
			return color;
		}

		return null;
	}

	function floatLinkStrength(object:Object, mat:MaterialData, link:String):Float {
		// object - currently bound object
		// mat - currently bound material
		// link - material node name
		//trace(mat);
		if (object == null ) return null;
		if (link == "BeamInputStokes_I" && object.name == "Beam" ) {
			var t = Time.time();
			
			if (object == null) return null;
			if (object.properties == null) object.properties = new Map();
			var intensity = object.properties.get("stokes_I");
			if (intensity == null) return null;
			
			return intensity;
		}

		return null;
	}
}
