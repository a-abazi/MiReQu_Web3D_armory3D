package arm;

import arm.ZuiPlotLib;
import zui.*;
import kha.Color;
import haxe.Json;
import kha.System;
import iron.Scene;
import iron.object.Object;

typedef CCJson = { // Typedef for TimeTagger data, transmitted by simple "flask" python http server
    var C1:Array<Int>;
    var C2:Array<Int>;
    var CC12:Array<Int>;
    var CR12:Array<Int>;
  }

typedef RotJson = { // Typedef for TimeTagger data, transmitted by simple "flask" python http server
  var p00: Int;
}


class Plotter extends iron.Trait {

    var ui:ZuiPlotLib;
    var rt:kha.Image; // Render target for UI
    var uiWidth = 512;
    var uiHeight = 512;

    public var pos_x = 20;
    public var pos_y = 20;
    public var width = 300;
    public var height = 1200;

    var time:Float;
    
    var globalObject = iron.Scene.global;
    
    var xVals: Array<Float>;
    var yValsList: Array<Array<Dynamic>>;
    var yCCList: Array<Array<Dynamic>>;
    
    var binwidth = 0.05; // in s
    var timediscretization = 0.05;
    var n_values = 200;

    
    var currDataTimeTagger:CCJson;
    var currDataRotEncoder:RotJson;


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
        
        //notifyOnRender2D(render2D);
        notifyOnUpdate(onUpdate);

        initProps(globalObject);

        // for Rendering UI on Plane
        rt = kha.Image.createRenderTarget(uiWidth, uiHeight);
        var screen1 = Scene.active.getChild("Screen1");


        // We will use empty texture slot in attached material to render UI
        var mat:iron.data.MaterialData = cast(screen1, iron.object.MeshObject).materials[0];
        mat.contexts[0].textures[0] = rt; // Override diffuse texture
        notifyOnRender(renderScreens);
    }

    function onUpdate() {
        var keyboard = iron.system.Input.getKeyboard();

        if (keyboard.started("space")){
            setPropRot();

            //if(currDataRotEncoder!=null) trace((currDataRotEncoder.p00 * 2.766)%360.);
        }

    }


    function renderScreens(g:kha.graphics4.Graphics) {
        
        // Begin drawing UI
        ui.begin(rt.g2);
        
        var hwin = Id.handle();

        time += iron.system.Time.delta;
        if (time > timediscretization/2) {
            time = 0;
            hwin.redraws = 1;
            getCurrTimetagger();
            getCurrRotations();
            setPropRot();
            if (currDataTimeTagger!=null){
                yValsList = [currDataTimeTagger.C1,currDataTimeTagger.C2 ];
                yCCList = [currDataTimeTagger.CC12];
            }
            
        }
        else hwin.redraws = 0;
        // Make new window
        if (ui.window(hwin,  0, 0, 1600, 900, true)) {
                if (currDataTimeTagger!=null && yValsList!= null){
                    ui.coordinateSystem(xVals,yValsList,450,400,3);
                    //ui.coordinateSystem(xVals,yCCList,600,300,3);
                    //trace(yVals[1]);
                }
        }
        ui.end();
    }

    function render2D(g:kha.graphics2.Graphics) {
        g.end();
        ui.begin(g);
        var hwin = Id.handle();

        time += iron.system.Time.delta;
        if (time > timediscretization/2) {
            time = 0;
            hwin.redraws = 1;
            getCurrTimetagger();
            getCurrRotations();
            setPropRot();
            if (currDataTimeTagger!=null){
                yValsList = [currDataTimeTagger.C1,currDataTimeTagger.C2 ];
                yCCList = [currDataTimeTagger.CC12];
            }
            
        }
        else hwin.redraws = 0;

        // Start with UI
        // Make window
        if (ui.window(hwin, pos_x, pos_y, width, height, false)) {
            if (currDataTimeTagger!=null && yValsList!= null){
                ui.coordinateSystem(xVals,yValsList,250,200,3);
                //ui.coordinateSystem(xVals,yCCList,600,300,3);
                //trace(yVals[1]);
            }
            
        }
        ui.end();



        g.begin(false);
    }



    private function getCurrTimetagger():Void {
        urlCallBack("http://127.0.0.1:5000/datagettimetagger",function(response){
            currDataTimeTagger = haxe.Json.parse(response);
        });
    }

    private function setPropRot():Void {
        if(currDataRotEncoder!=null) globalObject.properties["rot01"] = (currDataRotEncoder.p00 * 2.766)%360.;
        
    }

    private function getCurrRotations():Void {
        urlCallBack("http://127.0.0.1:5000/datagetrotations",function(response){
            currDataRotEncoder = haxe.Json.parse(response);
        });
    }

    function urlCallBack(url,callback:String->Void):Void {
        var http = new haxe.Http(url);
        http.onData = function (data:String) {
        callback(data);
        }
        http.request();
    }

    inline function initProps(object:Object){
        if (object == null) return;
        if (object.properties == null) object.properties = new Map();
    }

}