package arm.node;

@:keep class Children_Test extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _TranslateObject_001 = new armory.logicnode.TranslateObjectNode(this);
		var _OnKeyboard_001 = new armory.logicnode.OnKeyboardNode(this);
		_OnKeyboard_001.property0 = "Down";
		_OnKeyboard_001.property1 = "right";
		_OnKeyboard_001.addOutputs([_TranslateObject_001]);
		_TranslateObject_001.addInput(_OnKeyboard_001, 0);
		var _Self = new armory.logicnode.SelfNode(this);
		var _TranslateObject = new armory.logicnode.TranslateObjectNode(this);
		var _OnKeyboard = new armory.logicnode.OnKeyboardNode(this);
		_OnKeyboard.property0 = "Down";
		_OnKeyboard.property1 = "left";
		var _Print = new armory.logicnode.PrintNode(this);
		_Print.addInput(_OnKeyboard, 0);
		_Print.addInput(new armory.logicnode.StringNode(this, "restrts"), 0);
		_Print.addOutputs([new armory.logicnode.NullNode(this)]);
		_OnKeyboard.addOutputs([_TranslateObject, _Print]);
		_TranslateObject.addInput(_OnKeyboard, 0);
		_TranslateObject.addInput(_Self, 0);
		_TranslateObject.addInput(new armory.logicnode.VectorNode(this, 1.0, 0.0, 0.0), 0);
		_TranslateObject.addInput(new armory.logicnode.BooleanNode(this, false), 0);
		_TranslateObject.addOutputs([new armory.logicnode.NullNode(this)]);
		_Self.addOutputs([_TranslateObject_001, _TranslateObject]);
		_TranslateObject_001.addInput(_Self, 0);
		_TranslateObject_001.addInput(new armory.logicnode.VectorNode(this, 1.0, 0.0, 0.0), 0);
		_TranslateObject_001.addInput(new armory.logicnode.BooleanNode(this, false), 0);
		_TranslateObject_001.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}