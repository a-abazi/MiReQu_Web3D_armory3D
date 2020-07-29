package arm;

import arm.ZuiPlotLib;
import zui.*;
import kha.Color;


class Plotter extends iron.Trait {

    var ui:ZuiPlotLib;


    public var pos_x = 20;
    public var pos_y = 20;
    public var width = 650;
    public var height = 1200;

    var time:Float;
    var timedicretization = 0.1;
    var maxPoints = 200;
    var xVals: Array<Float>;
    var yVals: Array<Float>;

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
        time = 0.; 
        xVals = [0.];
        yVals = [];
        yVals.push(Math.sin(xVals[xVals.length-1]));
		// Store references to cube and plane objects
		notifyOnRender2D(render2D);
		
    }


    function render2D(g:kha.graphics2.Graphics) {
        g.end();
        ui.begin(g);
        var hwin = Id.handle();

        time += iron.system.Time.delta;
        if (time > timedicretization) {
            time = 0;
            hwin.redraws = 1;
            xVals.push(xVals[xVals.length-1] + timedicretization);
            yVals.push(Math.sin(xVals[xVals.length-1]));
            if (xVals.length>maxPoints){
                xVals.splice(0,1);
                yVals.splice(0,1);
            }
        }
        else hwin.redraws = 0;

        // Start with UI
        // Make window
        if (ui.window(hwin, pos_x, pos_y, width, height, false)) {
            ui.coordinateSystem(xVals,yVals,600,600,2);
        }
        ui.end();



        g.begin(false);
    }




}