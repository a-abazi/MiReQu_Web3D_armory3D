package arm;

import iron.object.Object;
import zui.*;
import armory.system.Event;
import armory.logicnode.LogicTree;

class NewUI extends iron.Trait {

    var ui:Zui;

    var maxBeams: Int;
    var updateInterval: Float;

    public function new() {
        super();

        // Load font for UI labels
        iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
            ui = new Zui({font: f});
            iron.Scene.active.notifyOnInit(sceneInit);
        });
    }

    function sceneInit() {
        // Store references to cube and plane objects
        //cube = iron.Scene.active.getChild("Cube");
        //plane = iron.Scene.active.getChild("Plane");
        notifyOnRender2D(render2D);
        notifyOnUpdate(update);
    }

	function onEventCB() {
        var name: String = "Calc_Beams";
        for (e in Event.get(name)) e.onEvent();
	}


    function render2D(g:kha.graphics2.Graphics) {
        g.end();

        // Start with UI
        ui.begin(g);
        // Make window
        if (ui.window(Id.handle(), 20, 20, 230, 600, true)) {
            // Make panel in this window
            if (ui.panel(Id.handle({selected: true}), "Menu")) {
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

                //var traitname: String = "Spawn_Beams_Control_v3";
                //var cname: Class<iron.Trait> = null;
                //var trait: Dynamic = null;
                //if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + "." + traitname);
                //if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + ".node." + traitname);
                //trait = iron.Scene.global.getTrait(cname);
                //
		        //if (trait == null || !Std.is(trait, LogicTree)) return;
                //cast(trait, LogicTree).pause();
                
                iron.Scene.global.properties.set("beamNumber", Std.int(beamNumber));
                iron.Scene.global.properties.set("updateTime", updateTime/1000.);
                
                //cast(trait, LogicTree).pause();
            }
        }
        ui.end();

        g.begin(false);
    }

    function update() {
        // Translate cube location over time
        //if (move) {
        //    cube.transform.loc.x = Math.sin(iron.system.Time.time() * 2);
        //    cube.transform.dirty = true;
        //}
    }

}