package armory.logicnode;


import iron.math.Mat4;
import iron.math.Vec4;
import iron.math.Vec3;
import iron.math.Quat;

class VectorAngles2D extends LogicNode {
	

    
    public function new(tree: LogicTree) {
		super(tree);
	}
    
	override function get(from: Int): Dynamic {
		var v1: Vec4 = inputs[0].get();
		var v2: Vec4 = inputs[1].get();
        var det:Float;
        var dot:Float;
        var alpha:Float;
        
		if (v1 == null || v1 == null) return null;
        
        dot = v1.x * v2.x + v1.y * v2.y;
        det = v1.x * v2.y - v1.y * v2.x;

        alpha = Math.atan2(det,dot);
            
		switch (from) {
			case 0:
				// rad
                return alpha; 
			case 1:
				// deg        
                return alpha*(180/Math.PI);
		}
        
        return null;
	}
}