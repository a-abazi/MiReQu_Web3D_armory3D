package armory.logicnode;


import iron.object.Object;
import iron.math.Vec4;
import iron.math.Quat;
import iron.math.Mat4;
import armory.trait.physics.RigidBody;

class SpawnBeams extends LogicNode {

    var res_arr_beams: Array<Dynamic>;
    var res_arr_pos: Array<Dynamic>;
    var res_arr_dir: Array<Dynamic>;
    var res_arr_sor: Array<Dynamic>;

	public function new(tree: LogicTree) {
		super(tree);
	}

	override function run(from: Int) {
        var arr_pos: Array<Dynamic> = inputs[1].get();
        var arr_dir: Array<Dynamic> = inputs[2].get();
        var arr_sor: Array<Dynamic> = inputs[3].get();
        var arr_beams: Array<Dynamic> = inputs[4].get();
        
        var objectName: String  = inputs[5].get();
        var arrName_subobjects: String  = inputs[6].get();
        var Proptraitname: String = inputs[7].get(); // Trait name of the OBject get Beam direction Function
        var funName: String = inputs[8].get();//"Get_Beam_Properties";
        var blocked: Bool = inputs[9].get();
        var beamdiameter: Float = inputs[10].get(); //0.025;

        var childprops_names: Array<String> = []; 

        // loop all previosly calculated position entries and spawn beams with correct properties
        for (i in 0...arr_pos.length) {
            var matrix: Mat4 = Mat4.identity(); 
            var spawnChildren: Bool = false;
            var loc = arr_pos[i];
            var rot = new Vec4();
		    var scale = new Vec4(1,beamdiameter,beamdiameter,1);
            var q = new Quat();
            var x = new Vec4(1,0,0,1);

            //var childprops        :   Array<Dynamic> = glob_childprops.copy();
            //var childprops_names  :   Array<String> = glob_childprops_names.copy();
            //var childprops_values :   Array<Dynamic> = glob_childprops_values.copy();
            // setup transformation Matrix
            if (i==0){
                 var vec = new Vec4();
                 vec.setFrom(arr_pos[i]);
                 if (arr_pos.length==1) scale.x = 1000.;
                 else scale.x = vec.distanceTo(arr_pos[i+1]);
            }
            else if (i==arr_pos.length-1){
                    if (blocked) {
                        while(arr_pos.length-1<arr_beams.length){
                            arr_beams.pop().remove();
                        }
                        break;
                    }
                    scale.x = 1000.;
            }
            else {
                var vec = new Vec4();
                vec.setFrom(arr_pos[i]);
                scale.x = vec.distanceTo(arr_pos[i+1]);
            }
            rot.add(arr_dir[i]);
            rot.normalize();
            q.fromTo(x,rot);
            matrix.compose(loc, q, scale);

            // Beam needs to be Spawned
            if (arr_beams[i] == null ){
                var object: Object;
		        iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
		        	object = o;
		        	if (matrix != null) {
		        		object.transform.setMatrix(matrix);
                    
		        		var rigidBody = object.getTrait(RigidBody);
		        		if (rigidBody != null) {
		        			object.transform.buildMatrix();
		        			rigidBody.syncTransform();
		        		}
		        	}
		        	object.visible = true;
                }, spawnChildren);

                var arr_subobjects: Array<Object> = [];
                if (object == null) return;
			    if (object.properties == null) object.properties = new Map();
                object.properties.set(arrName_subobjects,arr_subobjects);
                arr_beams.push(object);
            }
            // Beam needs to be transformed
            else {
                var object: Object = arr_beams[i];
                object.transform.setMatrix(matrix);

                var rigidBody = object.getTrait(RigidBody);
                if (rigidBody != null) rigidBody.syncTransform();
                
            }

            // Call trait of the source object
            var source_object: Object = arr_sor[i];
            var traitname: String = source_object.properties.get(Proptraitname);
            var cname: Class<iron.Trait> = null;
            var trait: Dynamic = null;
            if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + "." + traitname);
            if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + ".node." + traitname);
            trait = source_object.getTrait(cname);

            var childprops : Array <Dynamic> = [];
            var childprops_values : Array <Dynamic> = [];
            // setup inital properties and call the Laser
            if (i==0){
                var func = Reflect.field(trait, funName);
                if (func != null) {
                    childprops = Reflect.callMethod(trait, func, [arr_beams[i],arr_pos[i],arr_dir[i] ] );
                    childprops_names = childprops[0];
                    childprops_values = childprops[1];
                }
            }
            // get new properties from optical component, else properties remain unchanged
            if (i>0){
                for (name in childprops_names){
                    var parBeam : Object = arr_beams[i-1];
                    childprops_values.push(parBeam.properties.get(name));
                }
                if (source_object.properties.get("changes_prop")){
                    var new_childprops_names: Array<String> = [];
                    var new_childprops_values: Array<Dynamic> = [];
                
                    var func = Reflect.field(trait, funName);
                    if (func != null) {
                        var new_childprops = Reflect.callMethod(trait, func, [arr_beams[i-1],arr_pos[i],arr_dir[i] ] );
                        new_childprops_names  = new_childprops[0];
                        new_childprops_values = new_childprops[1];
                        for (name in new_childprops_names){
                            var index_mainArray = childprops_names.indexOf(name);
                            var index_ofnew = new_childprops_names.indexOf(name);
                
                            if (new_childprops_values[index_ofnew] != null) childprops_values[index_mainArray] = new_childprops_values[index_ofnew];
                            else trace("child property was null, funtction GetChildProperties not working");
                        }
                    }
                } 
            } 

            // write new properties to new Beam
            for (j in 0...childprops_names.length){
                var object: Object = arr_beams[i];
                var value: Dynamic;
                if (Std.string(Type.typeof(new Vec4())) == Std.string(Type.typeof(childprops_values[j]))){

                value = new Vec4().setFrom(childprops_values[j]);
                object.properties.set(childprops_names[j],value);
                }
                else object.properties.set(childprops_names[j],childprops_values[j]);

            }

        }

        // remove unwanted beams and sub objects e.g. Polarization arrows
        while(arr_pos.length<arr_beams.length){
            var curr_beam: Object = arr_beams.pop();
            if (curr_beam.properties!= null && curr_beam.properties.get(arrName_subobjects)){
                var arr_subobjects: Array<Object> = curr_beam.properties.get(arrName_subobjects);
                while (arr_subobjects.length>0) arr_subobjects.pop().remove();
            }
            curr_beam.remove();
        }
            res_arr_beams = arr_beams;
        runOutput(0);
    }
    
	override function get(from: Int): Dynamic {
        if (from == 1) return res_arr_beams;
        else return null;
    }
	override function set(value: Dynamic) {
		inputs[4].set(res_arr_beams);
	}
}