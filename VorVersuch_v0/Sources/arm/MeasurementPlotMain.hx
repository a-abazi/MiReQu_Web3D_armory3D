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
    //var CR12:Array<Int>;
}


class MeasurementPlotMain extends iron.Trait {

    @prop
    var getDatafromServer = false;

    @prop
    var nameMeasurementObject: String = "MeasurementObject";

    var ui:ZuiPlotLib;


    public var pos_x = 250;
    public var pos_y = 20;
    public var width = 250;
    public var height = 200;

    var plots: Array<PlotInstance>;
    var plotsIndex = 0;

    var time:Float;
    var time2:Float;
    
    
    var xVals: Array<Float>;
    var yValsList: Array<Array<Dynamic>>;
    var yCCList: Array<Array<Dynamic>>;
    
    var binwidth = 0.05; // in s
    var timediscretization = 0.05;
    var n_values = 200;

    
    var currData:CCJson;


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
        time2 = 0.;
        xVals = [0];
        plots = [];

        for (i in 1...n_values){
            xVals.push(xVals[i-1]+ timediscretization);
        }

        var globalObj = Scene.global;
        if (globalObj.properties == null) globalObj.properties = new Map();
        globalObj.properties.set("timeArray",xVals);
        
		// Store references to cube and plane objects
        notifyOnRender2D(render2DMain);
        //notifyOnRender2D(render2DExamplePlot);
        //notifyOnUpdate(onUpdate);
		
    }

    function onUpdate() {
        var keyboard = iron.system.Input.getKeyboard();

        if (keyboard.started("space")){
            trace("Space Key");
            plotsIndex += 1;
            plots.push(new PlotInstance(pos_x + plotsIndex*50, pos_y, width, height));
            
        }

    }

    function render2DMain(g:kha.graphics2.Graphics) {
        g.end();

        // Start with UI
        ui.begin(g);
        // Make window
        if (ui.window(Id.handle(), pos_x, pos_y, width, height, false)) {
            // Make panel in this window
            if (ui.panel(Id.handle({selected: true}), "New Measurement")) {
                ui.indent();
                // Toggle buttons
                //ui.row([1/2, 1/2]);
                if (ui.button("Add New Measurement Window")) {
                    plotsIndex += 1;
                    plots.push(new PlotInstance(pos_x + plotsIndex*50, pos_y, 800, 600));
                }
                if (ui.button("Remove all Measurements Window")) {
                    for (plot in plots){
                        plots = [];
                    }
                }
              
            }
        }

        for (plot in plots){
            if (plot.checkTime) plot.timeUpdate();
            plot.plotWindow(ui);
        }

        ui.end();

        g.begin(false);
    }
    

    function render2DExamplePlot(g:kha.graphics2.Graphics) {
        g.end();
        ui.begin(g);
        var hwin = Id.handle();

        time += iron.system.Time.delta;
        time2 += iron.system.Time.delta;
        if (time > timediscretization/2) {
            
            time = 0;
            hwin.redraws = 1;
            if (getDatafromServer){
                getCurrData();
                if (currData!=null){
                    yValsList = [currData.C1,currData.C2 ];
                    yCCList = [currData.CC12];
                }
            }
            else{
                yValsList = [[],[]];
                for (x in xVals){
                    yValsList[0].push(Math.sin(x+time2)+1.);
                    yValsList[1].push(Math.cos(x+time2)+1.);
                }
            }
            
        }
        else hwin.redraws = 0;

        var hcombo = Id.handle();


        // Start with UI
        // Make window
        if (ui.window(hwin, pos_x, pos_y+500, 800, 600, true)) {
            //if (currData!=null && yValsList!= null){
            //    ui.coordinateSystem(xVals,yValsList,600,300,3);
            //    //ui.coordinateSystem(xVals,yCCList,600,300,3);
            //    //trace(yVals[1]);
            //}
        if (ui.panel(Id.handle({selected: true}), "Choose Data")) {    
            ui.row([1/2, 1/2]);
            ui.text("x Axis");
            ui.combo(hcombo, ["Item 1", "item 2"]);
            if (hcombo.changed) {
                trace("Combo value changed this frame");
                trace(hcombo.position);
            }
        }

            if(!getDatafromServer && yValsList!= null){
                ui.coordinateSystem(xVals,yValsList,600,300,3);
            }

        }
        ui.end();



        g.begin(false);
    }


    public function getCurrData():Void {
        urlCallBack(function(response){
            currData = haxe.Json.parse(response);
        });
    }

    function urlCallBack(callback:String->Void):Void {
        var url = "http://127.0.0.1:5000/dataget";
        var http = new haxe.Http(url);
        http.onData = function (data:String) {
        callback(data);
        }
        http.request();
    }

}

class PlotInstance{
    public var pos_x: Int;
    public var pos_y: Int;
    public var width: Int;
    public var height: Int;
    public var handle: Handle;
    public var comboXAxisHandle: Handle;
    public var comboYAxisHandle: Handle;
    public var panelHandle: Handle;

    
    var globalObj: Object = iron.Scene.global;
    
    var axisItemsObjects: Array<Dynamic>;
    var axisItemsNames: Array<String>;
    var message: String;
    var time: Float;
    var timeSteps: Float;
    public var checkTime:Bool;

    public function new(x,y,w,h) {
        pos_x = x;
        pos_y = y;
        width = w;
        height = h;
        handle = new Handle();
        comboXAxisHandle =  new Handle();
        comboYAxisHandle =  new Handle();
        panelHandle =  new Handle({selected: true});
        message = "hello world";
        time = 0; 
        checkTime = false;
        axisItemsNames = [];
        axisItemsObjects = [];
    }

    public function timeUpdate(){
        time += iron.system.Time.delta;
        if (time > timeSteps) {
            time = 0;

        }
    }

    public function plotWindow(ui: ZuiPlotLib){
        
        if (ui.window(handle,pos_x, pos_y, width,height ,true)) {

            ui.row([1/2, 1/2]);
            ui.text("Plot Window");
            ui.text(message);

            if (ui.panel(panelHandle, "Select Data")) {
                getAxisItems();
                ui.row([1/2, 1/2]);
                ui.text("x Axis");
                ui.combo(comboXAxisHandle, axisItemsNames);
                if (comboXAxisHandle.changed) {
                    trace("Combo value X changed this frame");
                    trace(comboXAxisHandle.position);
                }
                
                ui.row([1/2, 1/2]);
                ui.text("y Axis");
                ui.combo(comboYAxisHandle, axisItemsNames);
                if (comboYAxisHandle.changed) {
                    trace("Combo value Y changed this frame");
                    trace(comboYAxisHandle.position);
                }
            }
        }
    }

    

    private function getAxisItems(){
        var names: Array<String> = ["None","time (s)"];
        var objects: Array<Dynamic> = ["None","time (s)"];

        if (globalObj.properties!= null){
            if (globalObj.properties["detekorObjectsArray"]!= null){
                var detObjList: Array<Object> = globalObj.properties["detekorObjectsArray"];
                for (detObj in detObjList){
                    if (detObj.properties["nameDetektor"]!= null){
                        names.push(detObj.properties["nameDetektor"]);
                        objects.push(detObj);
                    } 
                }
                
            }
        }

        axisItemsObjects = objects;
        axisItemsNames = names;
    }

}
