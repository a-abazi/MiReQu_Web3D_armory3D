package arm.node;

@:keep class TestNode_AccesBeams extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "TestNode_AccesBeams";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _Print_002 = new armory.logicnode.PrintNode(this);
		var _Print_003 = new armory.logicnode.PrintNode(this);
		var _Print = new armory.logicnode.PrintNode(this);
		var _Print_001 = new armory.logicnode.PrintNode(this);
		var _OnKeyboard = new armory.logicnode.OnKeyboardNode(this);
		_OnKeyboard.property0 = "Down";
		_OnKeyboard.property1 = "space";
		_OnKeyboard.addOutputs([_Print_001]);
		_Print_001.addInput(_OnKeyboard, 0);
		_Print_001.addInput(new armory.logicnode.StringNode(this, "PrevBeam:"), 0);
		_Print_001.addOutputs([_Print]);
		_Print.addInput(_Print_001, 0);
		var _GetProperty_001 = new armory.logicnode.GetPropertyNode(this);
		var _GetProperty = new armory.logicnode.GetPropertyNode(this);
		var _Self = new armory.logicnode.SelfNode(this);
		_Self.addOutputs([_GetProperty]);
		_GetProperty.addInput(_Self, 0);
		_GetProperty.addInput(new armory.logicnode.StringNode(this, "PrevBeam"), 0);
		_GetProperty.addOutputs([_GetProperty_001]);
		_GetProperty.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_GetProperty_001.addInput(_GetProperty, 0);
		_GetProperty_001.addInput(new armory.logicnode.StringNode(this, "stokes_psi"), 0);
		_GetProperty_001.addOutputs([_Print]);
		_GetProperty_001.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_Print.addInput(_GetProperty_001, 0);
		_Print.addOutputs([_Print_003]);
		_Print_003.addInput(_Print, 0);
		_Print_003.addInput(new armory.logicnode.StringNode(this, "NextBeam"), 0);
		_Print_003.addOutputs([_Print_002]);
		_Print_002.addInput(_Print_003, 0);
		var _GetProperty_003 = new armory.logicnode.GetPropertyNode(this);
		var _GetProperty_002 = new armory.logicnode.GetPropertyNode(this);
		var _Self_001 = new armory.logicnode.SelfNode(this);
		_Self_001.addOutputs([_GetProperty_002]);
		_GetProperty_002.addInput(_Self_001, 0);
		_GetProperty_002.addInput(new armory.logicnode.StringNode(this, "NextBeam"), 0);
		_GetProperty_002.addOutputs([_GetProperty_003]);
		_GetProperty_002.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_GetProperty_003.addInput(_GetProperty_002, 0);
		_GetProperty_003.addInput(new armory.logicnode.StringNode(this, "stokes_psi"), 0);
		_GetProperty_003.addOutputs([_Print_002]);
		_GetProperty_003.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_Print_002.addInput(_GetProperty_003, 0);
		_Print_002.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}