package arm;

import iron.system.Time;
import iron.math.Vec4;

class TouchTrait extends iron.Trait {

	var touches = [false, false, false];

	public function new() {
		super();

		notifyOnInit(function() {
			var surface = kha.input.Surface.get();
			if (surface != null) surface.notify(touchStart, touchEnd, touchMove);
			trace("surface:"+ Std.string(surface));
			notifyOnUpdate(update);
		});
	}

	function update() {
		trace(touches);
		//if (touches[0]) trace("test");
	}

	function touchStart(index:Int, x:Int, y:Int) {
		if (index > 2) return;
		touches[index] = true;
	}

	function touchEnd(index:Int, x:Int, y:Int) {
		if (index > 2) return;
		touches[index] = false;
	}

	function touchMove(index:Int, x:Int, y:Int) {}
}
