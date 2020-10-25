package arm;

import arm.node.AA_Kamera_Bewegung;
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

    var gPropX: String;
    var gPropY: String;
    var indexY: Int;
    var indexX: Int;

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
        notifyOnUpdate(onUpdate);
		
    }

    function onUpdate() {
        if (plotActive) {
            var valX: Float = Scene.global.properties.get(gPropX)[indexX];
            var valY: Float = Scene.global.properties.get(gPropY)[indexY];
            if (Std.is(valX,Float)) plot.angles[plot.angles.length-1] = valX;
            if (Std.is(valY,Float)) plot.voltages[0][plot.angles.length-1] = valY;
        }
    }

    function render2DMain(g:kha.graphics2.Graphics) {
        g.end();
        ui.begin(g);

        if (plotActive) plot.plotWindow(ui);


        ui.end();
        g.begin(false);
    }
    
    public function plotThis(xlabel: String, ylabel: String, gPropX:String,gPropY:String,indexX:Int,indexY:Int){
        plot = new PlotInstanceAngle(pos_x,pos_y,width,height,xlabel,ylabel);
        plotActive = true;
        this.gPropY = gPropY;
        this.gPropX = gPropX;
        this.indexX = indexX;
        this.indexY = indexY;
        
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
    public var angles: Array<Float>;
    public var voltages: Array<Array <Float>>;
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

        angles = [null];
        voltages =  [[null]];
    }

    public function plotWindow(ui: ZuiPlotLib){
        
        handle.redraws = 1;
        if (ui.window(handle, pos_x, pos_y, width, height ,false)) {
            ui.tstAngleCS(angles, voltages, width*0.9, height*0.7,3, xlabel, ylabel);
            if (ui.button("Measure")){
                angles.push(null);
                voltages[0].push(null);

            }
         
        }
    }

    

}

