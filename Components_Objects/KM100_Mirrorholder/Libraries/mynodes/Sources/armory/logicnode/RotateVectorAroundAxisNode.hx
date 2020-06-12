package armory.logicnode;


import iron.math.Mat4;
import iron.math.Vec4;
import iron.math.Vec3;
import iron.math.Quat;

class RotateVectorAroundAxisNode extends LogicNode {
	

    
    public function new(tree: LogicTree) {
		super(tree);
	}
    
	override function get(from: Int): Dynamic {
		var vector: Vec4 = inputs[0].get();
		var axis: Vec4 = inputs[1].get();
		var angle: Float = inputs[2].get();
        var v = new Vec4();
        var t = new Vec4();
        var x = new Vec4(1,0,0,1);
        
        var q_xyz = new Vec4();
        var rot_quat = new Quat();
        var fin_quat = new Quat();
        
		if (vector == null || axis == null) return null;
        
        //normalize axis 
        axis.normalize();
        rot_quat.fromAxisAngle(axis,angle);
        q_xyz.set(rot_quat.x,rot_quat.y,rot_quat.z);
        
        t.crossvecs(q_xyz,vector);
        t.mult(2);
        v.crossvecs(q_xyz,t);
        v.add(t.mult(rot_quat.w));
        v.add(vector);
        
        fin_quat.fromTo(x,v);
        
		switch (from) {
			case 0:
				// euler angles
				return fin_quat.getEuler(); // YZX Euler
			case 1:
				// vector
                return v;
			case 2:
				//quaternion xyz
				return fin_quat;
		}
		return null;
	}
}