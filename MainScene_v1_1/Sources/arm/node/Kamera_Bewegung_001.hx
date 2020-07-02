package arm.node;

@:keep class Kamera_Bewegung_001 extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _TranslateObject = new armory.logicnode.TranslateObjectNode(this);
		var _OnMouse = new armory.logicnode.OnMouseNode(this);
		_OnMouse.property0 = "Down";
		_OnMouse.property1 = "middle";
		_OnMouse.addOutputs([_TranslateObject]);
		_TranslateObject.addInput(_OnMouse, 0);
		var _ActiveCamera = new armory.logicnode.ActiveCameraNode(this);
		var _TranslateObject_001 = new armory.logicnode.TranslateObjectNode(this);
		var _OnUpdate_001 = new armory.logicnode.OnUpdateNode(this);
		_OnUpdate_001.property0 = "Update";
		_OnUpdate_001.addOutputs([_TranslateObject_001]);
		_TranslateObject_001.addInput(_OnUpdate_001, 0);
		_TranslateObject_001.addInput(_ActiveCamera, 0);
		var _VectorMath_001 = new armory.logicnode.VectorMathNode(this);
		_VectorMath_001.property0 = "Multiply";
		var _Vector_003 = new armory.logicnode.VectorNode(this);
		_Vector_003.addInput(new armory.logicnode.FloatNode(this, 0.0), 0);
		_Vector_003.addInput(new armory.logicnode.FloatNode(this, 0.0), 0);
		var _MouseCoords_002 = new armory.logicnode.MouseCoordsNode(this);
		_MouseCoords_002.addOutputs([new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0)]);
		var _VectorMath = new armory.logicnode.VectorMathNode(this);
		_VectorMath.property0 = "Multiply";
		_VectorMath.addInput(_MouseCoords_002, 1);
		_VectorMath.addInput(new armory.logicnode.VectorNode(this, 0.05000000074505806, 0.0, 0.0), 0);
		_VectorMath.addOutputs([_TranslateObject]);
		_VectorMath.addOutputs([new armory.logicnode.FloatNode(this, 0.0)]);
		_MouseCoords_002.addOutputs([_VectorMath]);
		_MouseCoords_002.addOutputs([_Vector_003]);
		_Vector_003.addInput(_MouseCoords_002, 2);
		_Vector_003.addOutputs([_VectorMath_001]);
		_VectorMath_001.addInput(_Vector_003, 0);
		_VectorMath_001.addInput(new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.9999997615814209), 0);
		_VectorMath_001.addOutputs([_TranslateObject_001]);
		_VectorMath_001.addOutputs([new armory.logicnode.FloatNode(this, 0.0)]);
		_TranslateObject_001.addInput(_VectorMath_001, 0);
		_TranslateObject_001.addInput(new armory.logicnode.BooleanNode(this, true), 0);
		_TranslateObject_001.addOutputs([new armory.logicnode.NullNode(this)]);
		_ActiveCamera.addOutputs([_TranslateObject_001, _TranslateObject]);
		_TranslateObject.addInput(_ActiveCamera, 0);
		_TranslateObject.addInput(_VectorMath, 0);
		_TranslateObject.addInput(new armory.logicnode.BooleanNode(this, false), 0);
		_TranslateObject.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}