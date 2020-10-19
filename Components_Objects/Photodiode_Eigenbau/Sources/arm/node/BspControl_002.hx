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
		var _CallFunction_001 = new armory.logicnode.CallFunctionNode(this);
		var _SetProperty = new armory.logicnode.SetPropertyNode(this);
		var _OnKeyboard_001 = new armory.logicnode.OnKeyboardNode(this);
		_OnKeyboard_001.property0 = "Down";
		_OnKeyboard_001.property1 = "right";
		_OnKeyboard_001.addOutputs([_SetProperty]);
		_SetProperty.addInput(_OnKeyboard_001, 0);
		var _Self_002 = new armory.logicnode.SelfNode(this);
		_Self_002.addOutputs([_SetProperty]);
		_SetProperty.addInput(_Self_002, 0);
		var _String = new armory.logicnode.StringNode(this);
		_String.addInput(new armory.logicnode.StringNode(this, "baseAngle"), 0);
		var _GetProperty = new armory.logicnode.GetPropertyNode(this);
		var _Self = new armory.logicnode.SelfNode(this);
		var _GetTrait = new armory.logicnode.GetTraitNode(this);
		_GetTrait.addInput(_Self, 0);
		var _String_001 = new armory.logicnode.StringNode(this);
		_String_001.addInput(new armory.logicnode.StringNode(this, "UPH2_Base"), 0);
		_String_001.addOutputs([_GetTrait]);
		_GetTrait.addInput(_String_001, 0);
		var _CallFunction = new armory.logicnode.CallFunctionNode(this);
		var _SetProperty_001 = new armory.logicnode.SetPropertyNode(this);
		var _OnKeyboard = new armory.logicnode.OnKeyboardNode(this);
		_OnKeyboard.property0 = "Down";
		_OnKeyboard.property1 = "left";
		_OnKeyboard.addOutputs([_SetProperty_001]);
		_SetProperty_001.addInput(_OnKeyboard, 0);
		var _Self_001 = new armory.logicnode.SelfNode(this);
		_Self_001.addOutputs([_SetProperty_001]);
		_SetProperty_001.addInput(_Self_001, 0);
		_SetProperty_001.addInput(_String, 0);
		var _Math = new armory.logicnode.MathNode(this);
		_Math.property0 = "Add";
		_Math.property1 = "false";
		_Math.addInput(_GetProperty, 0);
		_Math.addInput(new armory.logicnode.FloatNode(this, 0.05000000074505806), 0);
		_Math.addOutputs([_SetProperty_001]);
		_SetProperty_001.addInput(_Math, 0);
		_SetProperty_001.addOutputs([_CallFunction]);
		_CallFunction.addInput(_SetProperty_001, 0);
		_CallFunction.addInput(_GetTrait, 0);
		var _String_002 = new armory.logicnode.StringNode(this);
		_String_002.addInput(new armory.logicnode.StringNode(this, "updateParts"), 0);
		_String_002.addOutputs([_CallFunction, _CallFunction_001]);
		_CallFunction.addInput(_String_002, 0);
		_CallFunction.addOutputs([new armory.logicnode.NullNode(this)]);
		_CallFunction.addOutputs([new armory.logicnode.NullNode(this)]);
		_GetTrait.addOutputs([_CallFunction_001, _CallFunction]);
		_Self.addOutputs([_GetProperty, _GetTrait]);
		_GetProperty.addInput(_Self, 0);
		_GetProperty.addInput(_String, 0);
		var _Math_001 = new armory.logicnode.MathNode(this);
		_Math_001.property0 = "Subtract";
		_Math_001.property1 = "false";
		_Math_001.addInput(_GetProperty, 0);
		_Math_001.addInput(new armory.logicnode.FloatNode(this, 0.05000000074505806), 0);
		_Math_001.addOutputs([_SetProperty]);
		_GetProperty.addOutputs([_Math, _Math_001]);
		_GetProperty.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_String.addOutputs([_GetProperty, _SetProperty_001, _SetProperty]);
		_SetProperty.addInput(_String, 0);
		_SetProperty.addInput(_Math_001, 0);
		_SetProperty.addOutputs([_CallFunction_001]);
		_CallFunction_001.addInput(_SetProperty, 0);
		_CallFunction_001.addInput(_GetTrait, 0);
		_CallFunction_001.addInput(_String_002, 0);
		_CallFunction_001.addOutputs([new armory.logicnode.NullNode(this)]);
		_CallFunction_001.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}