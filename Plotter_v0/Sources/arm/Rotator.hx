package arm;

import iron.object.Object;

class Rotator extends iron.Trait {
	var globalObject = iron.Scene.global;
	var rot:Float; 

	public function new() {
		super();


		notifyOnInit(function() {
			rot = 0;
		 });

		notifyOnUpdate(function() {
			
			if (globalObject.properties != null){
				if (globalObject.properties["rot01"] != null){
					if (rot != globalObject.properties["rot01"]){
						rot = globalObject.properties["rot01"];
						object.transform.setRotation(0,rot/180.*Math.PI,0);
					}
				}
			}


		});

		// notifyOnRemove(function() {
		// });
	}
}
