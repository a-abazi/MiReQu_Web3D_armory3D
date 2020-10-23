package arm.node;

@:keep class NodeTree_001 extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "NodeTree_001";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _Print = new armory.logicnode.PrintNode(this);
		var _Print_001 = new armory.logicnode.PrintNode(this);
		var _OnKeyboard = new armory.logicnode.OnKeyboardNode(this);
		_OnKeyboard.property0 = "Started";
		_OnKeyboard.property1 = "space";
		_OnKeyboard.addOutputs([_Print_001]);
		_Print_001.addInput(_OnKeyboard, 0);
		_Print_001.addInput(new armory.logicnode.StringNode(this, "PrevBeam: "), 0);
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
		_GetProperty_001.addOutputs([new armory.logicnode.NullNode(this)]);
		_GetProperty_001.addOutputs([_Print]);
		_Print.addInput(_GetProperty_001, 1);
		_Print.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}