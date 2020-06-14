package arm;

import iron.object.Object;
import iron.object.Transform;
import iron.math.Vec4;
import armory.trait.physics.RigidBody;




class Spawner_KM100CP extends iron.Trait {
	@prop // angle of the base rotation, relative to the x-axis? counter clockwise? :TODO: Findout!
	var baseAngleDegree: Float = 90;
	
	@prop // Distance from position for post from Screw, default should me 0.025m(base distance of holes)
	var basePosition: Float = 0.25;

	@prop //  angle of the post rotation, relative to the x-axis? counter clockwise? :TODO: Findout! 
	var postAngleDegree: Float = 90;

	@prop // height of the post
	var postHeight: Float = 0.75;

	@prop
	var objectName_PostHolder: String = "UPH2_Base";

	@prop
	var objectName_Component: String = "KM100CP_Base";
	
	var baseAngle: Float;
	var postAngle: Float;
	var postDist: Float;
	var baseDist: Float;

	var std_postHeight = 0.75;
	var std_basePosition = 0.25;

	var spawnedObjectPost: Object;
	var spawnedObjectComponent: Object;

	var once: Bool = true;

	public function new() {
		super();

		notifyOnInit(function() {
			// compile a property map and assign it to the spawned object

			var loc = object.transform.loc;
			convertPropsToVars();
			var pMap = createPropMapPost();
			pMap["componentObjectName"] = objectName_Component;
			spawnedObjectPost = spawnObject(objectName_PostHolder, true, loc , pMap);
			rbSync(spawnedObjectPost);
			
			
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

	private function createPropMapPost():Map<String,Dynamic>{
		var pMap: Map<String,Dynamic> = [];

		pMap["baseAngle"] = baseAngle ;
		pMap["postAngle"] = postAngle;
		pMap["baseDist"] = baseDist;
		pMap["postDist"] = postDist;
		pMap["spawned"] = true;

		return pMap;
	}

	private function createPropMapComp(postObject: Object):Map<String,Dynamic>{
		var cMap: Map<String,Dynamic> = [];

		cMap["postObject"] = postObject;
		cMap["spawned"] = true;

		return cMap;
	}

	private function convertPropsToVars() {
		// convert property inputs to correct variable values
		baseAngle = baseAngleDegree * Math.PI / 180.;
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
