package arm;

import iron.object.Object;
import zui.*;
import armory.system.Event;
import armory.logicnode.LogicTree;
import iron.math.Vec4;

import armory.trait.physics.RigidBody;

import armory.trait.internal.CanvasScript;


class DebugUIv1 extends iron.Trait {

    var ui:Zui;

    var maxBeams: Int;
    var updateInterval: Float;
    
    var objName: String = "None"; 
    var objActive: Object; 
    

    var vec_x = new Vec4(1,0,0,1);
    var vec_y = new Vec4(0,1,0,1);
    var vec_z = new Vec4(0,0,1,1);

    var rotValue = 5./180.*Math.PI;

    public var pos_x = 20;
    public var pos_y = 20;
    public var width = 230;
    public var height = 1200;




    var canvas: CanvasScript;

    public function new() {
        super();

        //// Load font for UI labels
        iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
            ui = new Zui({font: f});
        });
        notifyOnRender2D(render2D);
        notifyOnUpdate(update);
    }


	function onEventCB() {
        var name: String = "Calc_Beams";
        for (e in Event.get(name)) e.onEvent();
    }
    
    function onRotate(object,axis,angle){
        if (object == null || axis == null ) return;
        object.transform.rotate(axis, angle);
        
        var rigidBody = object.getTrait(RigidBody);
        if (rigidBody != null) rigidBody.syncTransform();
        onEventCB();
    }


    function render2D(g:kha.graphics2.Graphics) {
        g.end();

        // Start with UI
        ui.begin(g);
        // Make window
        if (ui.window(Id.handle(), pos_x, pos_y, width, height, false)) {
            // Make panel in this window
            if (ui.panel(Id.handle({selected: true}), "Laser Control")) {
                ui.indent();

                // Toggle buttons
                ui.row([1/2, 1/2]);
                if (ui.button("Laser On/Off")) {
                    var object: Object = iron.Scene.global;
                    var property: String = "Laser_on";

                    if (object == null) return;
                    if (object.properties == null) object.properties = new Map();
                    var current: Bool = object.properties.get(property);
                    if (current) object.properties.set(property, false);
                    else object.properties.set(property, true);

                    onEventCB();
                }
                if (ui.button("Polarization On/Off")) {
                    var object: Object = iron.Scene.global;
                    var property: String = "Pol_on";

                    if (object == null) return;
                    if (object.properties == null) object.properties = new Map();
                    var current: Bool = object.properties.get(property);
                    if (current) object.properties.set(property, false);
                    else object.properties.set(property, true);
                    
                    onEventCB();
                }

                // Scale sliders
                ui.text("Max Beam segments");
                var beamNumber = ui.slider(Id.handle({value: 25}), "X", 0, 100, true);

                ui.text("Update Interval (ms)");
                var updateTime = ui.slider(Id.handle({value: 20}), "X", 0, 1000, true);
                
                ui.unindent();

                iron.Scene.global.properties.set("beamNumber", Std.int(beamNumber));
                iron.Scene.global.properties.set("updateTime", updateTime/1000.);
                

            }

            if (ui.panel(Id.handle({selected: true}), "Object Control")) {
            
                ui.row([1/2, 1/2]);
                ui.text("Active Object");
                ui.text(objName);

                var angleInput = ui.textInput(Id.handle({text: "5"}), "Rotation Angle (deg)");
                rotValue = Std.parseFloat(angleInput) * Math.PI / 180.0;

                ui.row([3/5, 1/5, 1/5]);
                ui.text("Rotate Z");
                if (ui.button("+")) onRotate(objActive,vec_z, rotValue);
                if (ui.button("-")) onRotate(objActive,vec_z,-1*rotValue);


                ui.row([3/5, 1/5, 1/5]);
                ui.text("Rotate Y");
                if (ui.button("+")) onRotate(objActive,vec_y,rotValue);
                if (ui.button("-")) onRotate(objActive,vec_y,-rotValue);

                ui.row([3/5, 1/5, 1/5]);
                ui.text("Rotate X");
                if (ui.button("+")) onRotate(objActive,vec_x,rotValue);
                if (ui.button("-")) onRotate(objActive,vec_x,-1*rotValue);
            
            }
        }
        ui.end();

        g.begin(false);
    }




    function onstartedLMB(){
        var mouse = iron.system.Input.getMouse();
        var coords = new Vec4(mouse.x, mouse.y,0,1);
		var physics = armory.trait.physics.PhysicsWorld.active;

        var onWindow = false;
        var mx: Float = coords.x;
        var my: Float = coords.y;

        if (pos_x<mx && mx< pos_x+width &&
            pos_y<my && my< pos_y+height ) onWindow = true;

        if (!onWindow){
            var rb = physics.pickClosest(coords.x, coords.y);
            if (rb == null) objName = "None";
            else if (rb.object.name == "xy_plane") return;
            else{
                objName = rb.object.name;
                objActive = rb.object;
            }
        }

        
    }

    function update() {
        var mouse = iron.system.Input.getMouse();
        var startedLMB = false;

        startedLMB = mouse.started("left");
        if(startedLMB) onstartedLMB();
        

        


    }

}