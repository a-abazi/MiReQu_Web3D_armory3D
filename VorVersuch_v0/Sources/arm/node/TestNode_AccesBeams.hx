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
		var _Print_003 = new armory.logicnode.PrintNode(this);
		var _Print_004 = new armory.logicnode.PrintNode(this);
		var _Print_001 = new armory.logicnode.PrintNode(this);
		var _Print_002 = new armory.logicnode.PrintNode(this);
		var _Keyboard = new armory.logicnode.MergedKeyboardNode(this);
		_Keyboard.property0 = "Down";
		_Keyboard.property1 = "space";
		_Keyboard.addOutputs([_Print_002]);
		_Keyboard.addOutputs([new armory.logicnode.BooleanNode(this, false)]);
		_Print_002.addInput(_Keyboard, 0);
		_Print_002.addInput(new armory.logicnode.StringNode(this, "PrevBeam:"), 0);
		_Print_002.addOutputs([_Print_001]);
		_Print_001.addInput(_Print_002, 0);
		var _GetObjectProperty_003 = new armory.logicnode.GetPropertyNode(this);
		var _GetObjectProperty_002 = new armory.logicnode.GetPropertyNode(this);
		var _SelfObject_001 = new armory.logicnode.SelfNode(this);
		_SelfObject_001.addOutputs([_GetObjectProperty_002]);
		_GetObjectProperty_002.addInput(_SelfObject_001, 0);
		_GetObjectProperty_002.addInput(new armory.logicnode.StringNode(this, "PrevBeam"), 0);
		_GetObjectProperty_002.addOutputs([_GetObjectProperty_003]);
		_GetObjectProperty_002.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_GetObjectProperty_003.addInput(_GetObjectProperty_002, 0);
		_GetObjectProperty_003.addInput(new armory.logicnode.StringNode(this, "stokes_psi"), 0);
		_GetObjectProperty_003.addOutputs([_Print_001]);
		_GetObjectProperty_003.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_Print_001.addInput(_GetObjectProperty_003, 0);
		_Print_001.addOutputs([_Print_004]);
		_Print_004.addInput(_Print_001, 0);
		_Print_004.addInput(new armory.logicnode.StringNode(this, "NextBeam"), 0);
		_Print_004.addOutputs([_Print_003]);
		_Print_003.addInput(_Print_004, 0);
		var _GetObjectProperty = new armory.logicnode.GetPropertyNode(this);
		var _GetObjectProperty_001 = new armory.logicnode.GetPropertyNode(this);
		var _SelfObject = new armory.logicnode.SelfNode(this);
		_SelfObject.addOutputs([_GetObjectProperty_001]);
		_GetObjectProperty_001.addInput(_SelfObject, 0);
		_GetObjectProperty_001.addInput(new armory.logicnode.StringNode(this, "NextBeam"), 0);
		_GetObjectProperty_001.addOutputs([_GetObjectProperty]);
		_GetObjectProperty_001.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_GetObjectProperty.addInput(_GetObjectProperty_001, 0);
		_GetObjectProperty.addInput(new armory.logicnode.StringNode(this, "stokes_psi"), 0);
		_GetObjectProperty.addOutputs([_Print_003]);
		_GetObjectProperty.addOutputs([new armory.logicnode.StringNode(this, "")]);
		_Print_003.addInput(_GetObjectProperty, 0);
		_Print_003.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}