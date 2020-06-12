package armory.logicnode;


import iron.object.Object;
import iron.math.Vec4;
import iron.math.Quat;
import iron.math.Mat4;
import armory.trait.physics.RigidBody;

class DespawnBeams extends LogicNode {

    var arr_beams: Array<Dynamic>;

	public function new(tree: LogicTree) {
		super(tree);
	}

	override function run(from: Int) {
        var arr_beams: Array<Dynamic> = inputs[1].get();
        var arr_subobjectName: String  = inputs[2].get();
        
        if (arr_beams!= null ){
            while(0<arr_beams.length){
                var curr_beam: Object = arr_beams.pop();
                if (curr_beam.properties!= null && curr_beam.properties.get(arr_subobjectName)){
                    var arr_visobj: Array<Object> = curr_beam.properties.get(arr_subobjectName);
                    while (arr_visobj.length>0) arr_visobj.pop().remove();
                }
                curr_beam.remove();
            }
        }    
        runOutput(0);
    }
    
	override function get(from: Int): Dynamic {
        return "";}
        
	override function set(value: Dynamic) {
		inputs[1].set(arr_beams);
	}
}