package arm;

import arm.ZuiPlotLib;
import zui.*;
import kha.Color;


class Plotter extends iron.Trait {

    var ui:ZuiPlotLib;


    public var pos_x = 20;
    public var pos_y = 20;
    public var width = 400;
    public var height = 1200;




    //var canvas: CanvasScript;

    public function new() {
        super();

        // Load font for UI labels
        iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
            ui = new ZuiPlotLib({font: f});
            iron.Scene.active.notifyOnInit(sceneInit);
        });
    }

    function sceneInit() {
        
		// Store references to cube and plane objects
		notifyOnRender2D(render2D);
		
    }


    function render2D(g:kha.graphics2.Graphics) {
        g.end();

        // Start with UI
        ui.begin(g);
        // Make window
        if (ui.window(Id.handle(), pos_x, pos_y, width, height, false)) {
            // Make panel in this window
            ui.text("Coordinate System");
            //ui.rect(10,10,50,50,Color.Black,2);
            
            ui.coordinateSystem(300,300,2);
        }
        ui.end();

        g.begin(false);
    }




}