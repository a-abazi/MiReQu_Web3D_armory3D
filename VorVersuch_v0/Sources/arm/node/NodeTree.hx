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
		var _MouseCoords = new armory.logicnode.MouseCoordsNode(this);
		_MouseCoords.addOutputs([new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0)]);
		_MouseCoords.addOutputs([new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0)]);
		_MouseCoords.addOutputs([new armory.logicnode.IntegerNode(this, 0)]);
		var _PickObject = new armory.logicnode.PickObjectNode(this);
		_PickObject.addInput(new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0), 0);
		_PickObject.addOutputs([new armory.logicnode.ObjectNode(this, "")]);
		_PickObject.addOutputs([new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0)]);
	}
}