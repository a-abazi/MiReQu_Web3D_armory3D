package arm;
import iron.Scene;
import kha.graphics4.hxsl.Types.Vec;
import iron.math.Quat;
import iron.system.Input;
import iron.object.Object;

import iron.Trait;


// This Trait resumes the traits of specifc objects when they, or some speficied children of them are clicked
class ResumeTraitSelector extends iron.Trait {
	public function new() {
		super();
		notifyOnUpdate(onUpdate);
	}

	function onUpdate(){
		var mouse = Input.getMouse();

		if (mouse.started("left")||mouse.started("right")){
			// object is picked, raytracing and rigidBody
			var physics = armory.trait.physics.PhysicsWorld.active;	
			var rb = physics.pickClosest(mouse.x, mouse.y);
			if (rb !=null) {
				var clickedObj = rb.object;
				var traitObj: Object;
				var traitName: String;

				// Checks if picked object needs to be Paused and calls correct Function of Object and trait
				if (clickedObj.properties != null) {
					if (clickedObj.properties["PauseResume"] !=null) {
						traitName = clickedObj.properties["TraitName"];
						if (clickedObj.properties["TraitObj"] == "self") traitObj = clickedObj;
						else traitObj = clickedObj.properties["TraitObj"];
						callTraitFunction(traitObj,traitName,"resumeUpdate",[]);
						}					
					}
				}
			} 
	}

	function callTraitFunction(object:Object, traitName:String, funName: String, funArguments:Array <Dynamic>):Dynamic{
		var result: Dynamic;
		// (Small helper) This function combines some dynamic haxe functions (especially Reflect) to call 
		//  correct instance of the trait of the object. In the beginning the traitname and such are calles

		// Call correct Trait of correct Object;
		var cname: Class<iron.Trait> = null; // call class name (trait), includes path and more
		if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + "." + traitName);
		if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + ".node." + traitName);
		var trait: Dynamic = object.getTrait(cname);
		// Call function of the correct instance of the trait, get new Direction
		var func = Reflect.field(trait, funName);

		if (func != null) {
			result = Reflect.callMethod(trait, func, funArguments);
		}
		else{
			trace("Error: dynamic function resulted in null value, Error in trait or function name");
			result = null;
		}

		return result;
	}
}
