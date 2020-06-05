package arm.node;

@:keep class Kamera_Bewegung extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _TranslateObject_001 = new armory.logicnode.TranslateObjectNode(this);
		var _Gate_005 = new armory.logicnode.GateNode(this);
		_Gate_005.property0 = "Equal";
		_Gate_005.property1 = 9.999999747378752e-05;
		var _OnUpdate_001 = new armory.logicnode.OnUpdateNode(this);
		_OnUpdate_001.property0 = "Update";
		_OnUpdate_001.addOutputs([_Gate_005]);
		_Gate_005.addInput(_OnUpdate_001, 0);
		var _Object_003 = new armory.logicnode.ObjectNode(this);
		_Object_003.addInput(new armory.logicnode.ObjectNode(this, "Platte"), 0);
		var _Gate_004 = new armory.logicnode.GateNode(this);
		_Gate_004.property0 = "Equal";
		_Gate_004.property1 = 9.999999747378752e-05;
		var _OnMouse = new armory.logicnode.OnMouseNode(this);
		_OnMouse.property0 = "Down";
		_OnMouse.property1 = "middle";
		_OnMouse.addOutputs([_Gate_004]);
		_Gate_004.addInput(_OnMouse, 0);
		_Gate_004.addInput(_Object_003, 0);
		var _PickObject_002 = new armory.logicnode.PickObjectNode(this);
		var _MouseCoords_002 = new armory.logicnode.MouseCoordsNode(this);
		_MouseCoords_002.addOutputs([_PickObject_002]);
		var _VectorMath = new armory.logicnode.VectorMathNode(this);
		_VectorMath.property0 = "Multiply";
		_VectorMath.addInput(_MouseCoords_002, 1);
		_VectorMath.addInput(new armory.logicnode.VectorNode(this, 0.05000000074505806, 0.0, 0.0), 0);
		var _TranslateObject = new armory.logicnode.TranslateObjectNode(this);
		_TranslateObject.addInput(_Gate_004, 0);
		var _Object = new armory.logicnode.ObjectNode(this);
		_Object.addInput(new armory.logicnode.ObjectNode(this, "Camera"), 0);
		_Object.addOutputs([_TranslateObject, _TranslateObject_001]);
		_TranslateObject.addInput(_Object, 0);
		_TranslateObject.addInput(_VectorMath, 0);
		_TranslateObject.addInput(new armory.logicnode.BooleanNode(this, false), 0);
		_TranslateObject.addOutputs([new armory.logicnode.NullNode(this)]);
		_VectorMath.addOutputs([_TranslateObject]);
		_VectorMath.addOutputs([new armory.logicnode.FloatNode(this, 0.0)]);
		_MouseCoords_002.addOutputs([_VectorMath]);
		var _Vector_003 = new armory.logicnode.VectorNode(this);
		_Vector_003.addInput(new armory.logicnode.FloatNode(this, 0.0), 0);
		_Vector_003.addInput(new armory.logicnode.FloatNode(this, 0.0), 0);
		_Vector_003.addInput(_MouseCoords_002, 2);
		var _VectorMath_001 = new armory.logicnode.VectorMathNode(this);
		_VectorMath_001.property0 = "Multiply";
		_VectorMath_001.addInput(_Vector_003, 0);
		_VectorMath_001.addInput(new armory.logicnode.VectorNode(this, 0.0, 0.0, 2.0), 0);
		_VectorMath_001.addOutputs([_TranslateObject_001]);
		_VectorMath_001.addOutputs([new armory.logicnode.FloatNode(this, 0.0)]);
		_Vector_003.addOutputs([_VectorMath_001]);
		_MouseCoords_002.addOutputs([_Vector_003]);
		_PickObject_002.addInput(_MouseCoords_002, 0);
		_PickObject_002.addOutputs([_Gate_004, _Gate_005]);
		_PickObject_002.addOutputs([new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0)]);
		_Gate_004.addInput(_PickObject_002, 0);
		_Gate_004.addOutputs([_TranslateObject]);
		_Object_003.addOutputs([_Gate_004, _Gate_005]);
		_Gate_005.addInput(_Object_003, 0);
		_Gate_005.addInput(_PickObject_002, 0);
		_Gate_005.addOutputs([_TranslateObject_001]);
		_TranslateObject_001.addInput(_Gate_005, 0);
		_TranslateObject_001.addInput(_Object, 0);
		_TranslateObject_001.addInput(_VectorMath_001, 0);
		_TranslateObject_001.addInput(new armory.logicnode.BooleanNode(this, true), 0);
		_TranslateObject_001.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}