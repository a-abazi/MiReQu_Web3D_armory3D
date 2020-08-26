package arm;

import arm.ZuiPlotLib;
import zui.*;
import kha.Color;
import haxe.Json;
import kha.System;

typedef CCJson = {
    var C1:Array<Int>;
    var C2:Array<Int>;
    var CC12:Array<Int>;
    var CR12:Array<Int>;
  }


class Plotter extends iron.Trait {

    var ui:ZuiPlotLib;


    public var pos_x = 420;
    public var pos_y = 20;
    public var width = 650;
    public var height = 1200;

    var time:Float;
    
    
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
        xVals = [0];
        
        for (i in 1...n_values){
            xVals.push(xVals[i-1]+ timediscretization);
        }
        //trace(xVals);
        //trace(xVals.length);
		// Store references to cube and plane objects
        notifyOnRender2D(render2D);
        //notifyOnUpdate(onUpdate);
		
    }

    function onUpdate() {
        var keyboard = iron.system.Input.getKeyboard();

        if (keyboard.started("space")){
            getCurrData();
        }
    }

    function render2D(g:kha.graphics2.Graphics) {
        g.end();
        ui.begin(g);
        var hwin = Id.handle();

        time += iron.system.Time.delta;
        if (time > timediscretization/2) {
            time = 0;
            hwin.redraws = 1;
            getCurrData();
            if (currData!=null){
                yValsList = [currData.C1,currData.C2 ];
                yCCList = [currData.CC12];
            }
            
        }
        else hwin.redraws = 0;

        // Start with UI
        // Make window
        if (ui.window(hwin, pos_x, pos_y, width, height, false)) {
            if (currData!=null && yValsList!= null){
                ui.coordinateSystem(xVals,yValsList,600,300,3);
                ui.coordinateSystem(xVals,yCCList,600,300,3);
                //trace(yVals[1]);
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