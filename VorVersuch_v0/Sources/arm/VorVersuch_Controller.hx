package arm;
import iron.Scene;
import iron.object.Object;

import iron.system.Input;

import iron.object.Transform;
import iron.math.Vec4;
import armory.trait.physics.RigidBody;

import arm.VorVersuch_Spawner.CompVV;

import armory.trait.internal.CanvasScript;


class VorVersuch_Controller extends iron.Trait {
	public function new() {
		super();
		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);
	}
	private function onInit(){
		var canvas: CanvasScript = Scene.active.getTrait(CanvasScript);
		if (canvas == null) canvas = Scene.active.camera.getTrait(CanvasScript);
		var element = canvas.getElement("ButtonGroup");
		if (element != null) element.visible = false;
	}

	private function onUpdate() {
		var keyb =  Input.getKeyboard();
		var mouse = Input.getMouse();

		
		
		if (keyb.started("1")){
			fillSlot(0,LinPol);
		}
		if (keyb.started("2")){
			fillSlot(1,WPHalf);
		}
		if (keyb.started("3")){
			fillSlot(1,WPQuart);
		}
		if (keyb.started("4")){
			fillSlot(2,Pbs);
		}
		
	}
	

	function fillSlot(slotNum: Int, whatComp: CompVV){
		callTraitFunction(object,"VorVersuch_Spawner","fillSlot",[slotNum,whatComp]);
	}
	
	function callTraitFunction(object:Object, traitName:String, funName: String, funArguments:Array <Dynamic>):Dynamic{
		var result: Dynamic;
		// (Small helper) This function combines some dynamic haxe functions (especially Reflect) to call 
		//  correct instance of the trait of the object. In the beginning the traitname and such are calles


		// Call correct Trait of correct Object
		var cname: Class<iron.Trait> = null; // call class name (trait), includes path and more
		if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + "." + traitName);
		if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + ".node." + traitName);
		var trait: iron.Trait = object.getTrait(cname);
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
