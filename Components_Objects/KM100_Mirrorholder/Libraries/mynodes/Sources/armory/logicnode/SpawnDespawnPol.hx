package armory.logicnode;

import iron.object.Object;
import iron.math.Vec4;
import iron.math.Quat;
import iron.math.Mat4;
import armory.trait.physics.RigidBody;

class SpawnDespawnPol extends LogicNode {

	public function new(tree: LogicTree) {
		super(tree);
	}

    var res_arr_all_arrows:Array<Object>;

	override function run(from: Int) {
        var arr_pos: Array<Dynamic> = inputs[1].get();
        var arr_dir: Array<Dynamic> = inputs[2].get();
        var arr_beams: Array<Dynamic> = inputs[3].get();
        var arr_all_arrows: Array<Object> = inputs[4].get();
        var objectName: String  = inputs[5].get();
        var arrName_subobjects: String  = inputs[6].get();
        var arrow_diameter: Float = inputs[7].get(); 
        var arrow_length: Float = inputs[8].get(); 
        var arrow_dist: Float = inputs[9].get(); 
        var max_arrows: Int = inputs[10].get(); 
        var pol_on: Bool = inputs[11].get(); 

        var arrow_num_total: Int = 0; 

        if (pol_on==false){
            while (arr_all_arrows.length>0){
                var arrow = arr_all_arrows.pop();
                var parent: Object = arrow.properties.get("parent");
                if (parent.properties == null) parent.properties = new Map();
                var arrayofBeam: Array<Object> = parent.properties.get(arrName_subobjects);
                arrayofBeam.remove(arrow);
                arrow.remove();

            }
            
            runOutput(0);
        }
        else{
            // loop all previosly calculated position entries and spawn beams with correct properties
            for (i in 0...arr_pos.length) {
                //if (i>=arr_beams.length && blocked) break;
                var beam: Object = arr_beams[i];
                var beam_length: Float;
                var numArrows: Int;

                if (beam == null) continue;
                if (beam.properties == null) beam.properties = new Map();
                var arrayofBeam: Array<Object> = beam.properties.get(arrName_subobjects);
                var pol_amp: Vec4 = beam.properties.get("pol_jones_vec_amp");
                pol_amp.normalize();

                // Determine Beam Length
                if (i == arr_pos.length - 1){
                    beam_length = 1000;
                }
                else{ 
                    var v1 = new Vec4().add(arr_pos[i]) ;
                    var v2 = new Vec4().add(arr_pos[i+1]) ;
                    beam_length = Vec4.distance(v1,v2);
                }

                // Determine Arrow number
                numArrows = (beam_length/arrow_dist < max_arrows) ? Std.int(beam_length/arrow_dist) : max_arrows;


                // Define Transform for Array
                var scale = new Vec4(arrow_diameter,arrow_diameter,arrow_length,1);
                var q = new Quat();
                var q2 = new Quat();
                var x = new Vec4(1,0,0,1); //new Vec4().add(arr_dir[i]); //
                var beam_dir = new Vec4().add(arr_dir[i]);

                q.fromTo(x,beam_dir);
                q2.fromTo(x,pol_amp);
                q.multquats(q,q2);

                for (k in 0...(arrayofBeam.length-numArrows)) {
                    if (arrayofBeam[arrayofBeam.length-k]!= null ) arrayofBeam.pop().remove();
                    else arrayofBeam.pop();
                }
            

                // Define Transform for individual Objects
                for (j in 0...numArrows){
                    arrow_num_total++;
                    var matrix: Mat4 = Mat4.identity(); 
                    var spawnChildren: Bool = false;
                    var loc = new Vec4().add(arr_dir[i]);
                    loc.normalize();
                    loc.mult((j+1)*arrow_dist);
                    loc.add(arr_pos[i]);
                    matrix.compose(loc, q, scale);

                    //if (arrayofBeam[j] == null ) arrayofBeam[j].remove();
                    // Spawn object
                    if (arrayofBeam[j] == null ){
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

                        if (object == null) return;
                        if (object.properties == null) object.properties = new Map();
                        object.properties.set("parent",beam);
                        arr_all_arrows.push(object);
                        arrayofBeam.push(object);
                    }
                    else{
                        var object: Object = arrayofBeam[j];
                        object.transform.setMatrix(matrix);

                        var rigidBody = object.getTrait(RigidBody);
                        if (rigidBody != null){rigidBody.syncTransform();
                        }
                    }
                }

                beam.properties.set(arrName_subobjects,arrayofBeam);   
            }
            //while(arr_all_arrows.length > arrow_num_total)arr_all_arrows.pop().remove();

            // Error Correction


            while (arr_all_arrows.length>arrow_num_total){
                for (arrow in arr_all_arrows){
                    var parent: Object = arrow.properties.get("parent");
                    if (arr_beams.indexOf(parent) == -1){
                        arrow.remove();
                        arr_all_arrows.remove(arrow);
                    }
                    else if (parent == null) {
                        arrow.remove();
                        arr_all_arrows.remove(arrow);
                    }
                    else {
                        if (parent.properties == null) parent.properties = new Map();
                        var arrayofBeam: Array<Object> = parent.properties.get(arrName_subobjects);
                        if (arrayofBeam.indexOf(arrow) == -1){
                            arrow.remove();
                            arr_all_arrows.remove(arrow);
                        }
                    }
                } 
            }
            runOutput(0);
        }    
    }        
    override function get(from: Int): Dynamic {
        if (from == 1) return null;
        else return null;
    }
    override function set(value: Dynamic) {
	inputs[4].set(res_arr_all_arrows);
    }
}