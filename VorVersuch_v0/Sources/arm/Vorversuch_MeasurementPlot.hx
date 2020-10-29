package arm;

import haxe.io.Input;
import arm.node.AA_Kamera_Bewegung;
import iron.Scene;
import iron.object.DecalObject;
import zui.Zui.Handle;
import arm.ZuiPlotLib;
import zui.*;
import kha.Color;
import haxe.Json;
import kha.System;

import iron.system.Input;

import iron.object.Object;

typedef CCJson = {
    var C1:Array<Int>;
    var C2:Array<Int>;
    var CC12:Array<Int>;
    var CR12:Array<Int>;
}


class Vorversuch_MeasurementPlot extends iron.Trait {

    var ui:ZuiPlotLib;


    public var pos_x = 1920-600;
    public var pos_y = 20;
    public var width = 500;
    public var height = 500;

    var plot: PlotInstanceAngle;
    var plotActive: Bool = false;

    var gPropX: String;
    var gPropY: String;
    var indexY: Int;
    var indexX: Int;
    var bothY: Bool;

    public function new() {
        super();
        
        // Load font for UI labels
        iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
            ui = new ZuiPlotLib({font: f});
			ui.ops.theme.WINDOW_BG_COL = 0;
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
        var keyBoard = Input.getKeyboard();
        if (plotActive) {
            if (bothY){
                var valX: Float = Scene.global.properties.get(gPropX)[indexX];
                var valY: Float = Scene.global.properties.get(gPropY)[indexY];
                var valY2: Float = Scene.global.properties.get(gPropY)[indexY+1];
                if (Std.is(valX,Float)) plot.angles[plot.angles.length-1] = valX;
                if (Std.is(valY,Float)) plot.voltages[0][plot.angles.length-1] = valY;
                if (Std.is(valY2,Float)) plot.voltages[1][plot.angles.length-1] = valY2;
            }
            else{
                var valX: Float = Scene.global.properties.get(gPropX)[indexX];
                var valY: Float = Scene.global.properties.get(gPropY)[indexY];
                if (Std.is(valX,Float)) plot.angles[plot.angles.length-1] = valX;
                if (Std.is(valY,Float)) plot.voltages[0][plot.angles.length-1] = valY;
            }
            
            if (keyBoard.started("m")){
                plot.angles.push(null);
                plot.voltages[0].push(null);
                if (bothY) plot.voltages[1].push(null);
            }
        }

    }

    function render2DMain(g:kha.graphics2.Graphics) {
        g.end();
        ui.begin(g);

        if (plotActive) plot.plotWindow(ui);


        ui.end();
        g.begin(false);
    }
    
    public function plotThis(xlabel: String, ylabel: String, gPropX:String,gPropY:String,indexX:Int,indexY:Int,bothY:Bool=false){
        plot = new PlotInstanceAngle(pos_x,pos_y,width,height,xlabel,ylabel,bothY);
        plotActive = true;
        this.gPropY = gPropY;
        this.gPropX = gPropX;
        this.indexX = indexX;
        this.indexY = indexY;
        this.bothY = bothY;
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
    public var bothY:Bool;
    
    var globalObj: Object = iron.Scene.global;
    
    var message: String;
    public var angles: Array<Float>;
    public var voltages: Array<Array <Float>>;
    var xlabel: String;
    var ylabel: String;

    public function new(x,y,w,h,xlabel,ylabel,bothY) {
        pos_x = x;
        pos_y = y;
        width = w;
        height = h;
        this.xlabel = xlabel;
        this.ylabel = ylabel;
        handle = new Handle();
        message = "hello world";
        this.bothY = bothY;
        angles = [null];
        if (bothY) voltages =  [[null],[null]];
        else voltages =  [[null]];
    }

    public function plotWindow(ui: ZuiPlotLib){
        
        handle.redraws = 1;
        if (ui.window(handle, pos_x, pos_y, width, height ,false)) {
            //ui.tstAngleCS(angles, voltages, width*0.9, height*0.7,3, xlabel, ylabel);
            ui.polarCoordinateSystem(angles,voltages, Math.sqrt(width*width+height*height)/2.,3,"","Spannung [V]" );
            if (ui.button("Measure")){
                angles.push(null);
                voltages[0].push(null);
                if (bothY) voltages[1].push(null);

            }
         
        }
    }

    

}

