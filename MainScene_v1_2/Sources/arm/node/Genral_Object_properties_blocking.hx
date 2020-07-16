package arm.node;

@:keep class Genral_Object_properties_blocking extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "Genral_Object_properties_blocking";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _SetProperty_001 = new armory.logicnode.SetPropertyNode(this);
		var _OnInit = new armory.logicnode.OnInitNode(this);
		var _SetProperty_003 = new armory.logicnode.SetPropertyNode(this);
		_SetProperty_003.addInput(_OnInit, 0);
		var _Self_002 = new armory.logicnode.SelfNode(this);
		var _SetProperty_002 = new armory.logicnode.SetPropertyNode(this);
		_SetProperty_002.addInput(_OnInit, 0);
		_SetProperty_002.addInput(_Self_002, 0);
		_SetProperty_002.addInput(new armory.logicnode.StringNode(this, "blocksBeam"), 0);
		var _Boolean_002 = new armory.logicnode.BooleanNode(this);
		_Boolean_002.addInput(new armory.logicnode.BooleanNode(this, true), 0);
		_Boolean_002.addOutputs([_SetProperty_002]);
		_SetProperty_002.addInput(_Boolean_002, 0);
		_SetProperty_002.addOutputs([new armory.logicnode.NullNode(this)]);
		_Self_002.addOutputs([_SetProperty_003, _SetProperty_001, _SetProperty_002]);
		_SetProperty_003.addInput(_Self_002, 0);
		_SetProperty_003.addInput(new armory.logicnode.StringNode(this, "movable"), 0);
		var _Boolean_001 = new armory.logicnode.BooleanNode(this);
		_Boolean_001.addInput(new armory.logicnode.BooleanNode(this, true), 0);
		_Boolean_001.addOutputs([_SetProperty_003]);
		_SetProperty_003.addInput(_Boolean_001, 0);
		_SetProperty_003.addOutputs([new armory.logicnode.NullNode(this)]);
		_OnInit.addOutputs([_SetProperty_003, _SetProperty_001, _SetProperty_002]);
		_SetProperty_001.addInput(_OnInit, 0);
		_SetProperty_001.addInput(_Self_002, 0);
		_SetProperty_001.addInput(new armory.logicnode.StringNode(this, "size_xy"), 0);
		var _Float = new armory.logicnode.FloatNode(this);
		_Float.addInput(new armory.logicnode.FloatNode(this, 2.0), 0);
		_Float.addOutputs([_SetProperty_001]);
		_SetProperty_001.addInput(_Float, 0);
		_SetProperty_001.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}