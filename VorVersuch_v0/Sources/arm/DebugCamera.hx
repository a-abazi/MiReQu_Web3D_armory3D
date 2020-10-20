package arm;

import iron.math.Vec4;
import iron.Scene;
import iron.system.Input;

import iron.object.Object;
import iron.object.Transform;

class DebugCamera extends iron.Trait {
	public function new() {
		super();

		@prop
		var speedKey: Float = 1. ;
		
		@prop
		var speedMouse: Float = 1. ;
		// notifyOnInit(function() {
		// });

		notifyOnUpdate(function() {
			var mouse = Input.getMouse();
			var keyboard = Input.getKeyboard();
			var cam = Scene.active.camera;
			var mousMult = 0.001;
			var camMult = 0.1;
			//var speed = 1.;

			if (keyboard.down("w")) cam.transform.move(cam.transform.up().normalize(),-speedKey*camMult);
			if (keyboard.down("s")) cam.transform.move(cam.transform.up().normalize(),speedKey*camMult);
			if (keyboard.down("a")) cam.transform.move(cam.transform.right().normalize(),-speedKey*camMult);
			if (keyboard.down("d")) cam.transform.move(cam.transform.right().normalize(),speedKey*camMult);

			if (mouse.down("middle")){
				mouse.lock();
				mouse.hide();
				cam.transform.rotate(new Vec4(0,0,1,1),-1*mouse.movementX * speedMouse*mousMult);
				cam.transform.rotate(cam.transform.right().normalize(), -1*mouse.movementY * speedMouse * mousMult);
			}
			if (mouse.released("middle")){
				mouse.unlock();
				mouse.show();
			}




		});

		// notifyOnRemove(function() {
		// });
	}
}
