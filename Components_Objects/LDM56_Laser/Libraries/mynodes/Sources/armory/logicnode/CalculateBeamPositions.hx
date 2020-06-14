package armory.logicnode;


import iron.object.Object;
import iron.math.Vec4;

class CalculateBeamPositions extends LogicNode {
    var res_arr_pos: Array<Dynamic>;
    var res_arr_dir: Array<Dynamic>;
    var res_arr_sor: Array<Dynamic>;
    var blocked: Bool;
	public function new(tree: LogicTree) {
		super(tree);
	}

	override function run(from: Int) {
        var arr_pos: Array<Dynamic> = inputs[1].get();
        var arr_dir: Array<Dynamic> = inputs[2].get();
        var arr_sor: Array<Dynamic> = inputs[3].get();
        var s_obj: Object = inputs[4].get();
        var Proptraitname: String = inputs[5].get(); // Trait name of the OBject get Beam direction Function
        var funName: String = inputs[6].get(); //"Get_Beam_Direction";
        var mask: Int = inputs[7].get();
        var maxBeams: Int = inputs[8].get() + 1;
        var l_obj: Object = null;
        blocked = true;

        if (arr_pos == null) res_arr_pos = null;
        if (s_obj == null) res_arr_pos = null;

        arr_pos = []; //Reset Array
        arr_pos.push(s_obj.transform.world.getLoc());//add first position
        arr_dir = [];
        arr_dir.push(s_obj.transform.world.right());
        arr_sor = [];
        arr_sor.push(s_obj);

        var vfrom = new Vec4();
        var vto = new Vec4();
        var v_dir_push = new Vec4();
        for (i in 0...maxBeams-1) {
                if (i==0){
                        vfrom = new Vec4().add(s_obj.transform.world.getLoc());
                        vto = new Vec4().add(s_obj.transform.world.right());
                        vto.x *= 1000;
                        vto.y *= 1000;
                        vto.z *= 1000;
                        vto.add(vfrom);

                }
                if (i>0){                       
                        var v_last = new Vec4().add(arr_pos[arr_pos.length - 1]);
                        var v_dir = new Vec4().add(arr_dir[arr_dir.length-1]);
                        v_dir = v_dir.mult(-1.);

                        // Call correct Trait
                        if (l_obj.properties==null) break;
                        var traitname: String = l_obj.properties.get(Proptraitname);
                        var cname: Class<iron.Trait> = null;
                        var trait: Dynamic = null;
                        if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + "." + traitname);
                        if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + ".node." + traitname);
                        trait = l_obj.getTrait(cname);

                        // get new Direction, Call hitted object trait
                        var func = Reflect.field(trait, funName);
                        if (func != null) {
                        	    	v_dir = Reflect.callMethod(trait, func, [v_dir]);
                        }
                        
                        v_dir_push = new Vec4().add(v_dir);
                        // Set Vectors for Raycasting
                        vfrom = v_last;
                        v_dir.x *= 1000;
                        v_dir.y *= 1000;
                        v_dir.z *= 1000;
                        vto = v_dir.add(vfrom);
                        arr_dir.push(v_dir_push);
                }
                 // perform RayCast
                var physics = armory.trait.physics.PhysicsWorld.active;
                var v_hit = new Vec4();
                var rb: Dynamic;
                var hit = physics.rayCast(vfrom, vto, 1, mask);
                rb = (hit != null) ? hit.rb : null;

                if (hit == null) break;
                l_obj = (hit != null) ? rb.object : null;
                
                // obtain hit vector, add new position
                var hitPointWorld: Vec4 = rb != null ? physics.hitPointWorld : null;
                if (hitPointWorld != null) {
                    v_hit.set(hitPointWorld.x, hitPointWorld.y, hitPointWorld.z, 1);
                }
                else v_hit = null;

                arr_pos.push(v_hit);        
                arr_sor.push(l_obj);

                blocked = l_obj.properties.get("blocksBeam");
                if (i == maxBeams-2) blocked = true;
                if (blocked) break;

        }       
        res_arr_pos = arr_pos;
        res_arr_dir = arr_dir;
        res_arr_sor = arr_sor;
        runOutput(0);
    }
    
    override function get(from: Int): Dynamic {
                if (from ==1) return res_arr_pos;
                else if  (from ==2) return res_arr_dir; 
                else if  (from ==3) return res_arr_sor; 
                else return blocked;
        }
}