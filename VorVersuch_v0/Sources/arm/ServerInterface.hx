package arm;


import haxe.Json;
import js.lib.webassembly.Global;
import iron.Scene;
import zui.Zui.Handle;
import iron.object.Object;
import armory.system.Event;
import armory.trait.internal.CanvasScript;
import iron.math.Vec4;
import iron.system.Input;


import zui.*;


typedef CCJson = { // Typedef for TimeTagger data, transmitted by simple "flask" python http server
    var C1:Array<Int>;
    var C2:Array<Int>;
    var CC12:Array<Int>;
}

typedef REJson = { // Typedef for TimeTagger data, transmitted by simple "flask" python http server
  var p00:Int;
  var p01:Int;
  var p02:Int;
}

typedef PDJson = { // Typedef for TimeTagger data, transmitted by simple "flask" python http server
  var s01:Int;
  var s02:Int;
}



class ServerInterface extends iron.Trait {

    @prop
    var connectToServer: Bool = false;
    @prop
    var serverIP: String = "127.0.0.1:5000";

    @prop
    var virtualInput: Bool = true;
    
    @prop
    var timeTagger: Bool = true;
    
    @prop
    var photoDiodes: Bool = true;

    @prop
    var pos_x_VI: Int = 20;
    
    @prop
    var pos_y_VI: Int = 20;

    @prop
    var refreshRate: Float = 0.025;

	var ui:Zui;

	public var width = 230;
	public var height = 1200;
    
    public var pos_x: Int; 
    public var pos_y: Int; 
    

	var handleSlot1 = new Handle({value: 0.});
	var handleSlot2 = new Handle({value: 0.});
	var handleSlot3 = new Handle({value: 0.});

	var canvas: CanvasScript;
	var globalObj: Object;
    var time:Float;

    var timeVals: Array<Float>;

    var currDataTimeTagger:CCJson;
    var currDataRotEncoder:REJson;
    var currPhotoDiode:PDJson;

    var binwidth = 0.05; // in s
    var timediscretization = 0.05;
    var n_values = 200;

	public function new() {
		super();
		//// Load font for UI labels
		iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
			ui = new Zui({font: f});
		});

		notifyOnInit(onInit);
		if (virtualInput) notifyOnRender2D(onRender2D);
		notifyOnUpdate(onUpdate);
	}

	function onInit() {
        pos_x = pos_x_VI;
        pos_y = pos_y_VI;
		globalObj = iron.Scene.global;
        initProps(globalObj);
        
        globalObj.properties.set("inputAngle1",0.);
        globalObj.properties.set("inputAngle2",0.);
        globalObj.properties.set("inputAngle3",0.);

        globalObj.properties.set("inputVolt1",0.);
        globalObj.properties.set("inputVolt2",0.);
        
        globalObj.properties.set("inputC1",[0,0]);
        globalObj.properties.set("inputC2",[0,0]);
        globalObj.properties.set("inputCC",[0,0]);
        
        globalObj.properties.set("Exercise","Test");
        globalObj.properties.set("Subexercise","SubTest");
        globalObj.properties.set("FileName","TestName");
        
        globalObj.properties.set("xAxis",[]);
        globalObj.properties.set("ArrayYAxis",[[],[]]);
        
        time = 0.; 
        timeVals = [0];
        
        for (i in 1...n_values){
            timeVals.push(timeVals[i-1]+ timediscretization);
        }
	}

	function onUpdate(){
		
		if (!virtualInput){

            time += iron.system.Time.delta;
            if (time > refreshRate) {
                time = 0;

                //getCurrRotations();
                if (currDataRotEncoder != null) {
                    globalObj.properties.set("inputAngle1", currDataRotEncoder.p00);
                    globalObj.properties.set("inputAngle2", currDataRotEncoder.p01);
                    globalObj.properties.set("inputAngle3", currDataRotEncoder.p02);
                }
                
                if (photoDiodes){
                    //getCurrPhotodiodes();
                    if (currPhotoDiode != null){
                        globalObj.properties.set("inputVolt1", currPhotoDiode.s01);
                        globalObj.properties.set("inputVolt2", currPhotoDiode.s02);
                    }
                }

                if (timeTagger){
                    //getCurrTimetagger();
                    if (currDataTimeTagger != null){
                        globalObj.properties.set("inputC1", currDataTimeTagger.C1);
                        globalObj.properties.set("inputC2", currDataTimeTagger.C2);
                        globalObj.properties.set("inputCC", currDataTimeTagger.CC12);
                    }
                }
            }
        }

        //var keyboard = Input.getKeyboard();
        //if (keyboard.started("space")){
        //    exportData_EXP(globalObj.properties.get("xAxis"),[
        //        globalObj.properties.get("yAxis1"),globalObj.properties.get("yAxis2")
        //    ],"testFileName");
//
        //    saveTMP_EXP(globalObj.properties.get("xAxis"),[
        //        globalObj.properties.get("yAxis1"),globalObj.properties.get("yAxis2")
        //    ]);
        //}
		
	}	

	function onRender2D(g:kha.graphics2.Graphics) {
		g.end();
		ui.begin(g);
        if (virtualInput){
            if (ui.window(Id.handle(), pos_x, pos_y, width, height, true)) {

                if (ui.panel(Id.handle({selected: false}), "Virtual Input Angles")) {
                    var angleSlot1:Float = ui.slider(handleSlot1, "Angle Slot 1", 0., 360., true);
                    var angleSlot2:Float = ui.slider(handleSlot2, "Angle Slot 2", 0., 360., true);
                    var angleSlot3:Float = ui.slider(handleSlot3, "Angle Slot 3", 0., 360., true);
    
                    var angleArray =  [angleSlot1,angleSlot2,angleSlot3];
                    iron.Scene.global.properties.set("inputAnglesArray",angleArray);
                    if (handleSlot1.changed) globalObj.properties.set("inputAngle1",angleSlot1);
                    if (handleSlot2.changed) globalObj.properties.set("inputAngle2",angleSlot2);
                    if (handleSlot3.changed) globalObj.properties.set("inputAngle3",angleSlot3);
                }
                    
                
    
                if (ui.panel(Id.handle({selected: false}), "Virtual Input Voltage")) {
                    var voltage1:Float = ui.slider(Id.handle({value: 2.5}), "Voltage Diode 1", 0., 5., true);
                    var voltage2:Float = ui.slider(Id.handle({value: 2.5}), "Voltage Diode 2", 0., 5., true);
                    
                    globalObj.properties.set("inputVolt1",voltage1);
                    globalObj.properties.set("inputVolt2",voltage2);   
                }
            }
        }
        
		ui.end();
	
		g.begin(false);
	}
	
    private function getCurrTimetagger():Void {
        urlCallBack("http://"+serverIP +"/datagettimetagger",function(response){
            currDataTimeTagger = haxe.Json.parse(response);
        });
    }

    private function getCurrRotations():Void {
        urlCallBack("http://"+ serverIP+"/datagetrotations",function(response){
            currDataRotEncoder = haxe.Json.parse(response);
        });
    }

    private function getCurrPhotodiodes():Void {
        urlCallBack("http://"+serverIP +"/datagetsensors",function(response){
            currPhotoDiode = haxe.Json.parse(response);
        });
    }

    function exportData_EXP( xValues: Array<Dynamic>,arrayYValues: Array<Array<Dynamic>>,filename: String):Void{
        var expData = new Map();
        expData.set("Exercise", globalObj.properties.get("Exercise"));
        expData.set("Subexercise",globalObj.properties.get("Subexercise"));
        expData.set("FileName",filename);
        expData.set("xAxis", xValues);
        
        var c = 1;
        for (yValues in arrayYValues){
            expData.set("yAxis"+Std.string(c), yValues);
            c++;
        }
        var expDataString = Json.stringify(expData);
        var http = new haxe.Http("http://"+serverIP +"/datapostexport");
        //http.addParameter("Content-Type","application/json"); // nicht klar ob das benötigt wird
        http.setPostData((expDataString));
        
        http.request(true);
    }

    function saveTMP_EXP(xValues: Array<Dynamic>,arrayYValues: Array<Array<Dynamic>>, filename: String = "None"):Void{
        var expData = new Map();
        expData.set("Exercise", globalObj.properties.get("Exercise"));
        expData.set("Subexercise",globalObj.properties.get("Subexercise"));
        expData.set("xAxis", xValues);
        
        var c = 1;
        for (yValues in arrayYValues){
            expData.set("yAxis"+Std.string(c), yValues);
            c++;
        }
        
        var expDataString = Json.stringify(expData);
        var http = new haxe.Http("http://"+serverIP +"/dataposttmp");
        //http.addParameter("Content-Type","application/json"); // nicht klar ob das benötigt wird
        http.setPostData((expDataString));
        
        http.request(true);
    }

    public function exportData():Void{
        var expData = new Map();
        expData.set("Exercise", globalObj.properties.get("Exercise"));
        expData.set("Subexercise",globalObj.properties.get("Subexercise"));
        expData.set("FileName",globalObj.properties.get("FileName"));
        expData.set("xAxis", globalObj.properties.get("xAxis"));
        
        var arrayYValues: Array<Array<Dynamic>> = globalObj.properties.get("ArrayYAxis");
        var c = 1;
        for (yValues in arrayYValues){
            expData.set("yAxis"+Std.string(c), yValues);
            c++;
        }

        var expDataString = Json.stringify(expData);
        var http = new haxe.Http("http://"+serverIP +"/datapostexport");
        http.setPostData((expDataString));
        
        http.request(true);
    }

    public function saveTMP():Void{
        var expData = new Map();
        expData.set("Exercise", globalObj.properties.get("Exercise"));
        expData.set("Subexercise",globalObj.properties.get("Subexercise"));
        expData.set("xAxis", globalObj.properties.get("xAxis"));
        
        var arrayYValues: Array<Array<Dynamic>> = globalObj.properties.get("ArrayYAxis");
        var c = 1;
        for (yValues in arrayYValues){
            expData.set("yAxis"+Std.string(c), yValues);
            c++;
        }
        
        var expDataString = Json.stringify(expData);
        var http = new haxe.Http("http://"+serverIP +"/dataposttmp");
        http.setPostData((expDataString));
        
        http.request(true);
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
