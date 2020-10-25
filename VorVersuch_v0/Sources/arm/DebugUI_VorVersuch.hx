package arm;


import js.lib.webassembly.Global;
import iron.Scene;
import zui.Zui.Handle;
import iron.object.Object;
import armory.system.Event;
import armory.trait.internal.CanvasScript;
import iron.math.Vec4;

import arm.VorVersuch_Spawner.VorVersuch_Spawner;
import arm.ResumeTraitSelector.ResumeTraitSelector;
import arm.Vorversuch_MeasurementPlot.Vorversuch_MeasurementPlot;
import arm.PhotoDiode.PhotoDiode;
import zui.*;



class DebugUI_VorVersuch extends iron.Trait {

	var ui:Zui;

	public var pos_x = 20;
	public var pos_y = 20;
	public var width = 230;
	public var height = 1200;
	


	var vivComboHandle = new Handle();
	var vivItemNames = ["Virtual Input", "Simulated", "Real"];

	var handleSlot1 = new Handle({value: 90.});
	var handleSlot2 = new Handle({value: 90.});
	var handleSlot3 = new Handle({value: 90.});


	var canvas: CanvasScript;
	var virtInptBool: Bool = false;
	var globalObj: Object;

	public var spawner = new VorVersuch_Spawner.VorVersuch_Spawner();
	public var traitResumer = new ResumeTraitSelector.ResumeTraitSelector();
	public var plotter = new Vorversuch_MeasurementPlot.Vorversuch_MeasurementPlot();


	public function new() {
		super();
		//// Load font for UI labels
		iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
			ui = new Zui({font: f});
		});

		notifyOnInit(onInit);
		notifyOnRender2D(onRender2D);
		notifyOnUpdate(onUpdate);
	}

	function onInit() {
		globalObj = iron.Scene.global;
		initProps(globalObj);
		var angleArray =  [0,0,0];
		globalObj.properties.set("inputAnglesArray",angleArray);
		var voltArray =  [0,0];
		globalObj.properties.set("inputVoltArray",voltArray);
	}

	function onUpdate(){
		//if (virtInptBool) updateRings();
		
		if (vivComboHandle.position == 1){
			var det1: Object = globalObj.properties.get("Detektor1");
			var det2: Object = globalObj.properties.get("Detektor1");

			var voltArray =  [callTraitFunction(det1,"PhotoDiode","getMeasurement",[globalObj.properties.get("ArrayDetBeams")]),
								callTraitFunction(det2,"PhotoDiode","getMeasurement",[globalObj.properties.get("ArrayDetBeams")])];
			globalObj.properties.set("inputVoltArray",voltArray);

		}
	}	

	function onRender2D(g:kha.graphics2.Graphics) {
		g.end();
		ui.begin(g);

		if (ui.window(Id.handle(), pos_x, pos_y, width, height, false)) {
			if (ui.panel(Id.handle({selected: true}), "Measurement Steps")) {
				
				ui.row([1/2, 1/2]);
				if (ui.button("Reset")) mReset();
				if (ui.button("Step 1")) mStep1();
				
				ui.row([1/2, 1/2]);
				if (ui.button("Step 2")) mStep2();
				if (ui.button("Step 3")) mStep3();

				ui.row([1/2, 1/2]);
				if (ui.button("Step 4")) mStep4();
				if (ui.button("Step 5")) mStep5();

			}
			if (ui.panel(Id.handle({selected: true}), "Virtual Input Angles")) {
				virtInptBool = ui.check(Id.handle(), "Virtual Input");
				var angleSlot1:Float = ui.slider(handleSlot1, "Angle Slot 1", 0., 360., true);
                var angleSlot2:Float = ui.slider(handleSlot2, "Angle Slot 2", 0., 360., true);
				var angleSlot3:Float = ui.slider(handleSlot3, "Angle Slot 3", 0., 360., true);

				if (virtInptBool){
					var angleArray =  [angleSlot1,angleSlot2,angleSlot3];
					iron.Scene.global.properties.set("inputAnglesArray",angleArray);
					if (handleSlot1.changed) updateRing(0,angleSlot1);
					if (handleSlot2.changed) updateRing(1,angleSlot2);
					if (handleSlot3.changed) updateRing(2,angleSlot3);
				}
				
			}

			if (ui.panel(Id.handle({selected: true}), "Virtual Input Voltage")) {
				ui.combo(vivComboHandle, vivItemNames);
				if (vivComboHandle.position == 0){
					var voltage1:Float = ui.slider(Id.handle({value: 2.5}), "Voltage Diode 1", 0., 5., true);
					var voltage2:Float = ui.slider(Id.handle({value: 2.5}), "Voltage Diode 2", 0., 5., true);
					
					var voltArray =  [voltage1,voltage2];
					iron.Scene.global.properties.set("inputVoltArray",voltArray);
				}
			}
		}
		ui.end();
	
		g.begin(false);
	}
	

	function updateRing(slotNum: Int, newAngle):Bool{
		var slots = iron.Scene.global.properties.get("slots");
		var slotMarkObj: Object = slots[slotNum];
		if (slotMarkObj == null) return false;
		if (slotMarkObj.properties.exists("currComponentObj")) {
			var currUPH: Object = slotMarkObj.properties.get("currComponentObj");
			if (currUPH.properties.exists("componentObject")){
				var currObj: Object = currUPH.properties.get("componentObject");
				if (currObj == null) return false;
				if (currObj.name == "RSP1D_Base"){
					callTraitFunction(currObj,"RSP1D_Base","setAngle",[newAngle]);
				}
			}
		}
	return true;
	}
	
	function mReset(){
		spawner.fillSlot(0,Empty);
		spawner.fillSlot(1,Empty);
		spawner.fillSlot(2,Empty);
		plotter.closePlots();
	}

	function mStep1() {
		spawner.fillSlot(0,LinPol);
		spawner.fillSlot(1,Empty);
		spawner.fillSlot(2,Empty);
		plotter.plotThis("Winkel Polfilter (deg)", "Spannung Photodiode (V)","inputAnglesArray","inputVoltArray",0,0);
	}
	
	function mStep2() {
		spawner.fillSlot(0,LinPol);
		spawner.fillSlot(1,Empty);
		spawner.fillSlot(2,LinPol);
	}
	function mStep3() {
		spawner.fillSlot(0,LinPol);
		spawner.fillSlot(1,LinPol);
		spawner.fillSlot(2,LinPol);
	}
	function mStep4() {
		spawner.fillSlot(0,LinPol);
		spawner.fillSlot(1,WPHalf);
		spawner.fillSlot(2,LinPol);
	}
	function mStep5() {
		spawner.fillSlot(0,LinPol);
		spawner.fillSlot(1,WPHalf);
		spawner.fillSlot(2,Pbs);
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

	inline function initProps(object:Object){
		if (object == null) return;
		if (object.properties == null) object.properties = new Map();
	}

}
