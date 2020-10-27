package arm.node;

@:keep class Genral_Object_properties_blocking_003 extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "Genral_Object_properties_blocking_003";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _SetObjectProperty = new armory.logicnode.SetPropertyNode(this);
		var _OnInit_001 = new armory.logicnode.OnInitNode(this);
		var _SetObjectProperty_001 = new armory.logicnode.SetPropertyNode(this);
		_SetObjectProperty_001.addInput(_OnInit_001, 0);
		var _SelfObject = new armory.logicnode.SelfNode(this);
		var _SetObjectProperty_002 = new armory.logicnode.SetPropertyNode(this);
		_SetObjectProperty_002.addInput(_OnInit_001, 0);
		_SetObjectProperty_002.addInput(_SelfObject, 0);
		_SetObjectProperty_002.addInput(new armory.logicnode.StringNode(this, "blocksBeam"), 0);
		var _Boolean_001 = new armory.logicnode.BooleanNode(this);
		_Boolean_001.addInput(new armory.logicnode.BooleanNode(this, true), 0);
		_Boolean_001.addOutputs([_SetObjectProperty_002]);
		_SetObjectProperty_002.addInput(_Boolean_001, 0);
		_SetObjectProperty_002.addOutputs([new armory.logicnode.NullNode(this)]);
		_SelfObject.addOutputs([_SetObjectProperty, _SetObjectProperty_001, _SetObjectProperty_002]);
		_SetObjectProperty_001.addInput(_SelfObject, 0);
		_SetObjectProperty_001.addInput(new armory.logicnode.StringNode(this, "movable"), 0);
		var _Boolean = new armory.logicnode.BooleanNode(this);
		_Boolean.addInput(new armory.logicnode.BooleanNode(this, true), 0);
		_Boolean.addOutputs([_SetObjectProperty_001]);
		_SetObjectProperty_001.addInput(_Boolean, 0);
		_SetObjectProperty_001.addOutputs([new armory.logicnode.NullNode(this)]);
		_OnInit_001.addOutputs([_SetObjectProperty, _SetObjectProperty_001, _SetObjectProperty_002]);
		_SetObjectProperty.addInput(_OnInit_001, 0);
		_SetObjectProperty.addInput(_SelfObject, 0);
		_SetObjectProperty.addInput(new armory.logicnode.StringNode(this, "size_xy"), 0);
		var _Float_001 = new armory.logicnode.FloatNode(this);
		_Float_001.addInput(new armory.logicnode.FloatNode(this, 2.0), 0);
		_Float_001.addOutputs([_SetObjectProperty]);
		_SetObjectProperty.addInput(_Float_001, 0);
		_SetObjectProperty.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}