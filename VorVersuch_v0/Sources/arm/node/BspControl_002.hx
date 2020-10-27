package arm.node;

@:keep class BspControl_002 extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "BspControl_002";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _Math_002 = new armory.logicnode.MathNode(this);
		_Math_002.property0 = "Subtract";
		_Math_002.property1 = "false";
		_Math_002.addInput(new armory.logicnode.FloatNode(this, 1.0), 0);
		_Math_002.addInput(new armory.logicnode.FloatNode(this, 1.0), 0);
		_Math_002.addOutputs([new armory.logicnode.FloatNode(this, 0.0)]);
		var _CallFunction_002 = new armory.logicnode.CallFunctionNode(this);
		var _SetObjectProperty = new armory.logicnode.SetPropertyNode(this);
		var _Keyboard_001 = new armory.logicnode.MergedKeyboardNode(this);
		_Keyboard_001.property0 = "Down";
		_Keyboard_001.property1 = "right";
		_Keyboard_001.addOutputs([_SetObjectProperty]);
		_Keyboard_001.addOutputs([new armory.logicnode.BooleanNode(this, false)]);
		_SetObjectProperty.addInput(_Keyboard_001, 0);
		var _SelfObject = new armory.logicnode.SelfNode(this);
		_SelfObject.addOutputs([_SetObjectProperty]);
		_SetObjectProperty.addInput(_SelfObject, 0);
		var _String_003 = new armory.logicnode.StringNode(this);
		_String_003.addInput(new armory.logicnode.StringNode(this, "baseAngle"), 0);
		var _SetObjectProperty_001 = new armory.logicnode.SetPropertyNode(this);
		var _Keyboard = new armory.logicnode.MergedKeyboardNode(this);
		_Keyboard.property0 = "Down";
		_Keyboard.property1 = "left";
		_Keyboard.addOutputs([_SetObjectProperty_001]);
		_Keyboard.addOutputs([new armory.logicnode.BooleanNode(this, false)]);
		_SetObjectProperty_001.addInput(_Keyboard, 0);
		var _SelfObject_001 = new armory.logicnode.SelfNode(this);
		_SelfObject_001.addOutputs([_SetObjectProperty_001]);
		_SetObjectProperty_001.addInput(_SelfObject_001, 0);
		_SetObjectProperty_001.addInput(_String_003, 0);
		var _Math = new armory.logicnode.MathNode(this);
		_Math.property0 = "Add";
		_Math.property1 = "false";
		var _GetObjectProperty = new armory.logicnode.GetPropertyNode(this);
		var _SelfObject_002 = new armory.logicnode.SelfNode(this);
		var _GetObjectTrait = new armory.logicnode.GetTraitNode(this);
		_GetObjectTrait.addInput(_SelfObject_002, 0);
		var _String_002 = new armory.logicnode.StringNode(this);
		_String_002.addInput(new armory.logicnode.StringNode(this, "UPH2_Base"), 0);
		_String_002.addOutputs([_GetObjectTrait]);
		_GetObjectTrait.addInput(_String_002, 0);
		var _CallFunction_001 = new armory.logicnode.CallFunctionNode(this);
		_CallFunction_001.addInput(_SetObjectProperty_001, 0);
		_CallFunction_001.addInput(_GetObjectTrait, 0);
		var _String = new armory.logicnode.StringNode(this);
		_String.addInput(new armory.logicnode.StringNode(this, "updateParts"), 0);
		_String.addOutputs([_CallFunction_002, _CallFunction_001]);
		_CallFunction_001.addInput(_String, 0);
		_CallFunction_001.addOutputs([new armory.logicnode.NullNode(this)]);
		_CallFunction_001.addOutputs([new armory.logicnode.NullNode(this)]);
		_GetObjectTrait.addOutputs([_CallFunction_002, _CallFunction_001]);
		_SelfObject_002.addOutputs([_GetObjectProperty, _GetObjectTrait]);
		_GetObjectProperty.addInput(_SelfObject_002, 0);
		_GetObjectProperty.addInput(_String_003, 0);
		var _Math_001 = new armory.logicnode.MathNode(this);
		_Math_001.property0 = "Subtract";
		_Math_001.property1 = "false";
		_Math_001.addInput(_GetObjectProperty, 0);
		_Math_001.addInput(new armory.logicnode.FloatNode(this, 0.05000000074505806), 0);
		_Math_001.addOutputs([_SetObjectProperty]);
		_GetObjectProperty.addOutputs([_Math, _Math_001]);
		_GetObjectProperty.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_Math.addInput(_GetObjectProperty, 0);
		_Math.addInput(new armory.logicnode.FloatNode(this, 0.05000000074505806), 0);
		_Math.addOutputs([_SetObjectProperty_001]);
		_SetObjectProperty_001.addInput(_Math, 0);
		_SetObjectProperty_001.addOutputs([_CallFunction_001]);
		_String_003.addOutputs([_SetObjectProperty, _SetObjectProperty_001, _GetObjectProperty]);
		_SetObjectProperty.addInput(_String_003, 0);
		_SetObjectProperty.addInput(_Math_001, 0);
		_SetObjectProperty.addOutputs([_CallFunction_002]);
		_CallFunction_002.addInput(_SetObjectProperty, 0);
		_CallFunction_002.addInput(_GetObjectTrait, 0);
		_CallFunction_002.addInput(_String, 0);
		_CallFunction_002.addOutputs([new armory.logicnode.NullNode(this)]);
		_CallFunction_002.addOutputs([new armory.logicnode.NullNode(this)]);
		var _Math_003 = new armory.logicnode.MathNode(this);
		_Math_003.property0 = "Add";
		_Math_003.property1 = "false";
		_Math_003.addInput(new armory.logicnode.FloatNode(this, 1.0), 0);
		_Math_003.addInput(new armory.logicnode.FloatNode(this, 1.0), 0);
		_Math_003.addOutputs([new armory.logicnode.FloatNode(this, 0.0)]);
	}
}