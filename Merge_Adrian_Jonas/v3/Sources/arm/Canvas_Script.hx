package arm;

import iron.Scene;
import iron.App;
import iron.system.Time;
import iron.object.Object;
import armory.system.Event;
import armory.trait.internal.CanvasScript;

import iron.math.Mat4;
import armory.trait.physics.RigidBody;


class Canvas_Script extends iron.Trait {
	
	var canvas:CanvasScript;
	var clicks_on_off = 0;
    var clicks_pol = 0;

	public function new() {
		super();

		notifyOnInit(function() {
			// Get canvas attached to scene
			canvas = Scene.active.getTrait(CanvasScript);

			// Notify on button click
			Event.add("buttonEventPol", onEventPol);
            Event.add("buttonEventLaser", onEventLaser);
            Event.add("buttonEventCB", onEventCB);
			Event.add("toggleMenu", onToggleMenu);
			Event.add("SM1", spawn1);
			//Event.add("sliderEventUpdate",onEventUT);
			//Event.add("sliderEventBN",onEventBN);
			//Event.add("SM2", spawn2);
			//Event.add("SM3", spawn3);
			


			canvas.notifyOnReady(function() {
				notifyOnUpdate(update);
			});
		});
	}

	function onEventLaser() {
		// Set butotn text
        //var object: Object = iron.Scene.global;
        var object: Object = iron.Scene.global;
		var property: String = "Laser_on";
		if (clicks_on_off%2==0) object.properties.set(property, true);
		if (clicks_on_off%2==1) object.properties.set(property, false);
        clicks_on_off++;
        onEventCB();
	}

	function onEventPol() {
		// Set butotn text
        //var object: Object = iron.Scene.global;
        var object: Object = iron.Scene.global;
		var property: String = "Pol_on";
		if (clicks_pol%2==0) object.properties.set(property, true);
		if (clicks_pol%2==1) object.properties.set(property, false);
        clicks_pol++;
        onEventCB();
	}

	function onEventCB() {
        var name: String = "Calc_Beams";
		for (e in Event.get(name)) e.onEvent();

		//trace(canvas.getHandle("sliderEventUT").value);
		//trace(canvas.getHandle("sliderEventBN").value);
	}

	function onToggleMenu() {
		var shape = canvas.getElement("Components");
		shape.visible = !shape.visible;
	}
	
	function onEventBN(){
		trace("Beamnumber");
	}
	
	function onEventUT(){
		trace("Update Time");
	}
	
    function spawn1(){
        var objectName = "";
       // var object: Object = iron.Scene.active.getChild("Mirror Round");
        var matrices: Array<Mat4> = [];
        
        //trace("Check");
        //objectName = object.name;
        
        //iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
		//	object = o;
		//	var matrix = matrices.pop(); // Async spawn in a loop, order is non-stable
		//	if (matrix != null) {
		//		object.transform.setMatrix(matrix);
		//		#if arm_physics
		//		var rigidBody = object.getTrait(RigidBody);
		//		if (rigidBody != null) {
		////			object.transform.buildMatrix();
		//			rigidBody.syncTransform();
		//		}
		//		#end
		//	}
		//	object.visible = true;
		//}, true);
        
    }
    

    
    
	function update() {
		// Canvas may be still being loaded
		if (!canvas.ready) return;
		//trace(canvas.getHandle("Slider_Beam_num").value);
		// Set text
		//canvas.getElement("MyText").text = "Hello world";

	}
}
