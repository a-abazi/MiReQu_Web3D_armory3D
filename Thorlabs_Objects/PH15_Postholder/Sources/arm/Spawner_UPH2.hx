package arm;

import iron.object.Object;
import iron.object.Transform;
import iron.math.Vec4;
import armory.trait.physics.RigidBody;

class Spawner_UPH2 extends iron.Trait {
	public function new() {
		super();

		@prop 
		var baseAngleDegree: Float = 90;
		
		@prop
		var baseTranslation: Float = 0;

		@prop
		var postAngleDegree: Float = 90;

		@prop
		var postTranslation: Float = 0;

		@prop
		var objectName: String = "UPH2_Base";
		
		var baseAngle;
		var postAngle;

		var spawnedObject: Object;

		//TODO: define parameters as Properites in Base Trait, so they can be adjusted

		notifyOnInit(function() {
			baseAngle = baseAngleDegree * Math.PI / 180.;
			postAngle = postAngleDegree * Math.PI / 180.;

			spawnedObject = spawnObject(objectName, true, object.transform.loc);
			rbSync(spawnedObject);
			trace(spawnedObject.getChild("C_Screw_Pos").transform.loc);
			// getChild("C_Screw_Pos").transform.translate(0,multiplier*baseTrans,0)
		});

	}

	function spawnObject(objectName: String, visible: Bool, loc: Vec4):Object {
		// helping function to spawn an object
		var object: Object;
		var spawnChildren = true;

		iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
			object = o;
			object.visible = visible;
		}, spawnChildren);
		object.transform.loc = loc;
		return object;
	}
	
	function rbSync(object:Object) { 
		// helping function for a rigid body object, 
		// is used to align the the rigid bodys of object and children to their new parent matrix (location and rotation)
		var rigidBody = object.getTrait(RigidBody);
		if (rigidBody != null) rigidBody.syncTransform();
	}
}
