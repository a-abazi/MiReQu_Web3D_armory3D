package arm.node;

@:keep class Kamera_Bewegung extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "Kamera_Bewegung";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
	}
}