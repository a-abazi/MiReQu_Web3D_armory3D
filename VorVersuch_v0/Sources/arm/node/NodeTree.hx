package arm.node;

@:keep class NodeTree extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "NodeTree";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _PickRB = new armory.logicnode.PickObjectNode(this);
		_PickRB.addInput(new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0), 0);
		_PickRB.addOutputs([new armory.logicnode.ObjectNode(this, "")]);
		_PickRB.addOutputs([new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0)]);
	}
}