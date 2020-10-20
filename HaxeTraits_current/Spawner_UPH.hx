package arm;

import iron.Trait;
import iron.object.Object;
import iron.object.Transform;
import iron.math.Vec4;
import armory.trait.physics.RigidBody;




class Spawner_UPH extends iron.Trait {
	@prop // angle of the base rotation, relative to the x-axis, counter clockwise
	var baseAngleDegree: Float = 90;
	
	@prop // Distance from position for post from Screw, default should me 0.025m(base distance of holes)
	var basePosition: Float = 0.25;

	@prop //  angle of the post rotation, relative to the x-axis, counter clockwise, and importantly additive to the baseAngle 
	var postAngleDegree: Float = 90;

	@prop // height of the post
	var postHeight: Float = 0.75;

	@prop
	var objectName: String = "UPH_Base";
	
	@prop
	var postName: String = "UPH_TR30";

	@prop
	var topName: String = "UPH_Top40";



	var baseAngle: Float;
	var postAngle: Float;
	var postDist: Float;
	var baseDist: Float;

	var std_postHeight = 0.75;
	var std_basePosition = 0.25;

	var spawnedObject: Object;

	public function new() {
		super();

		notifyOnInit(function() {
			// compile a property map and assign it to the spawned object
			convertPropsToVars();
			var pMap = createPropMap();
			spawnedObject = spawnObject(objectName, true, object.transform.loc, pMap);
			rbSync(spawnedObject);
		});

	}

	function spawnObject(objectName: String, visible: Bool, loc: Vec4, props:Map<String,Dynamic> ):Object {
		// helping function to spawn an object
		var object: Object;
		var spawnChildren = true;

		iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
			object = o;
			object.visible = visible;
		}, spawnChildren);
		object.transform.loc = loc;
		if (object == null) return null;
		if (object.properties == null) object.properties = new Map();
		object.properties = props;
		return object;
	}

	private function createPropMap():Map<String,Dynamic>{
		var pMap: Map<String,Dynamic> = [];

		pMap["baseAngle"] = baseAngle ;
		pMap["postAngle"] = postAngle;
		pMap["baseDist"] = baseDist;
		pMap["postDist"] = postDist;
		pMap["spawned"] = true;

		pMap["postName"] = postName;
		pMap["topName"] = topName;
		pMap["sLoc"] = object.transform.world.getLoc();

		return pMap;
	}

	private function convertPropsToVars() {
		// convert property inputs to correct variable values
		baseAngle = (baseAngleDegree - 90 )* Math.PI / 180.;
		postAngle = postAngleDegree * Math.PI / 180.;
		baseDist = -1 * (basePosition - std_basePosition);
		postDist = postHeight - std_postHeight;
	}

	function rbSync(object:Object) { 
		// helping function for a rigid body object, 
		// is used to align the the rigid bodys of object and children to their new parent matrix (location and rotation)
		var rigidBody = object.getTrait(RigidBody);
		if (rigidBody != null) rigidBody.syncTransform();
	}
}
