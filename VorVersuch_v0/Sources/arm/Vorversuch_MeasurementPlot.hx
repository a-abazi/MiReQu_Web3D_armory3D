package arm;

import iron.Scene;
import iron.object.DecalObject;
import zui.Zui.Handle;
import arm.ZuiPlotLib;
import zui.*;
import kha.Color;
import haxe.Json;
import kha.System;


import iron.object.Object;

typedef CCJson = {
    var C1:Array<Int>;
    var C2:Array<Int>;
    var CC12:Array<Int>;
    var CR12:Array<Int>;
}


class Vorversuch_MeasurementPlot extends iron.Trait {

    var ui:ZuiPlotLib;


    public var pos_x = 250;
    public var pos_y = 20;
    public var width = 500;
    public var height = 400;

    var plot: PlotInstanceAngle;
    var plotActive: Bool = false;


    public function new() {
        super();
        
        // Load font for UI labels
        iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
            ui = new ZuiPlotLib({font: f});
            iron.Scene.active.notifyOnInit(sceneInit);
        });
    }

    function sceneInit() {

        var globalObj = Scene.global;
        if (globalObj.properties == null) globalObj.properties = new Map();

        notifyOnRender2D(render2DMain);
		
    }

    function render2DMain(g:kha.graphics2.Graphics) {
        g.end();
        ui.begin(g);

        if (plotActive) plot.plotWindow(ui);


        ui.end();
        g.begin(false);
    }
    
    public function plotThis(xlabel: String, ylabel: String){
        plot = new PlotInstanceAngle(pos_x,pos_y,width,height,xlabel,ylabel);
        plotActive = true;
    }

    public function closePlots() {
        plotActive = false;
    }

}

class PlotInstanceAngle{
    public var pos_x: Int;
    public var pos_y: Int;
    public var width: Int;
    public var height: Int;
    public var handle: Handle;

    
    var globalObj: Object = iron.Scene.global;
    
    var message: String;
    var angles: Array<Float>;
    var voltages: Array<Array <Float>>;
    var xlabel: String;
    var ylabel: String;

    public function new(x,y,w,h,xlabel,ylabel) {
        pos_x = x;
        pos_y = y;
        width = w;
        height = h;
        this.xlabel = xlabel;
        this.ylabel = ylabel;
        handle = new Handle();
        message = "hello world";

        angles = [0,20,60,80];
        voltages =  [[0,.1,.2,.1,.1]];
    }

    public function plotWindow(ui: ZuiPlotLib){
        
        if (ui.window(handle, pos_x, pos_y, width, height ,false)) {
            ui.tstAngleCS(angles, voltages, width*0.9, height*0.8,3, xlabel, ylabel);

         
        }
    }

    

}
