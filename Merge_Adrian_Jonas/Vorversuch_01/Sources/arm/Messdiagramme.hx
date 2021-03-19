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
import arm.ServerInterface.ServerInterface;
import arm.ServerInterface.CCJson;
import arm.ServerInterface.PDJson;
import arm.ServerInterface.REJson;

import zui.Canvas.Anchor;
import zui.Canvas;
import zui.*;

import zui.*;



class Messdiagramme extends iron.Trait {

    @prop
    var refreshRate: Float = 0.025;

    @prop 
    var exerciseString: String = "VorVersuch";
    @prop
    var yValMax: Float = 500;

	var canvas: CanvasScript;
	var globalObj: Object;
    var time:Float;

    var timeVals: Array<Float>;

    var currDataTimeTagger:CCJson;
    var currDataRotEncoder:REJson;
    var currPhotoDiode:PDJson;

    var saveMap01: Map<String,Dynamic>;
    var saveMap02: Map<String,Dynamic>;
    var saveMap03: Map<String,Dynamic>;
    var saveMap04: Map<String,Dynamic>;

    var currentMap: Map<String,Dynamic>;
    var currentStep: Int;

    var diagrammActive: Bool;

    var binwidth = 0.05; // in s
    var timediscretization = 0.05;
    var n_values = 200;

    var currXVal: Float;
    var currYVal1: Float;
    var currYVal2: Float;

    var serverInterface: ServerInterface;

    var arrPoints1: Array <TElement>;
    var arrPoints2: Array <TElement>;

    var diagram: TElement;
    var activeAlice: TElement;
    var activeBob: TElement;

    var measuredAlice: TElement;
    var measuredBob: TElement;

    var txtMessungen: TElement;
    var txtBob: TElement;
    var txtAlice: TElement;
    

	public function new() {
        super();

        notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);
	}

	function onInit() {
		globalObj = iron.Scene.global;
        initProps(globalObj);

        arrPoints1 = [];
        arrPoints2 = [];
        
        time = 0.; 
        timeVals = [0];
        
        for (i in 1...n_values){
            timeVals.push(timeVals[i-1]+ timediscretization);
        }

        var cname = cast Type.resolveClass(Main.projectPackage + "." + "ServerInterface");
        serverInterface = object.getTrait(cname);

        diagrammActive = false;
        
        setupSaveMaps();
        
        Event.add("messwertAdd",messwertAdd);
        Event.add("messwertDel",messwertDel);
        Event.add("messwertExp",messwertExp);
        Event.add("Diagram_aus",diagram_aus);
        Event.add("Diagram_an",diagram_an);
    }

	function onUpdate(){
        if (object == null) return;
        if (object.properties == null) return;

        currentStep = (object.properties.get("schritte"));
        if (currentStep == null) return;

        if (currentStep>=100 && currentStep<200){
            currentMap = saveMap01;
            currXVal = globalObj.properties.get("inputAngle1");
        }
        if (currentStep>= 200 && currentStep<300){
            currentMap = saveMap02;
            currXVal = globalObj.properties.get("inputAngle3");
        }
        if (currentStep>= 300 && currentStep<400){
            currentMap = saveMap03;
            currXVal = globalObj.properties.get("inputAngle2");
        }
        if (currentStep>= 400){
            currentMap = saveMap04;   
            currXVal = globalObj.properties.get("inputAngle2");
        }


        currYVal1 = globalObj.properties.get("inputVolt1");
        currYVal2 = globalObj.properties.get("inputVolt2");
    
        if (diagram == null){
            setupCanvasElements();
            return;
        }

        if (diagrammActive) updatePlot();
        else removePlot();
		
	}	

    function setupCanvasElements() {
        if(!Scene.active.ready) return;
		canvas = Scene.active.getTrait(CanvasScript);
		if (canvas == null) canvas = Scene.active.camera.getTrait(CanvasScript);
		if (canvas == null) return;
		if (!canvas.ready) return;

        activeAlice = canvas.getElement("messpunktalice");
        activeBob = canvas.getElement("messpunktbob");

        measuredAlice = canvas.getElement("100");
        measuredBob = canvas.getElement("200");

        txtMessungen = canvas.getElement("messungen");
        txtBob = canvas.getElement("detektoreingangbob");
        txtAlice = canvas.getElement("detektoreingangalice");

        diagram = canvas.getElement("diagram");
    }

    function setupSaveMaps(){
        saveMap01 = new Map();
        saveMap02 = new Map();
        saveMap03 = new Map();
        saveMap04 = new Map();

        var allMaps = [saveMap01,saveMap02,saveMap03,saveMap04];

        for (map in allMaps){
            map.set("Exercise", "VorVersuch");
            map.set("xAxis", []);
            map.set("yAxis1", []);
        }
        saveMap04.set("yAxis2",[]);

        saveMap01.set("Subexercise","Polarisationsprofil");
        saveMap02.set("Subexercise","MalusGesetz");
        saveMap03.set("Subexercise","Wellenplaetchen");
        saveMap04.set("Subexercise","Strahlteiler");
    }


    function messwertAdd() {
        if (currentMap["xAxis"]==null) return;
        currentMap["xAxis"].push(currXVal);
        currentMap["yAxis1"].push(currYVal1);
        if (currentMap["yAxis2"]!=null) currentMap["yAxis2"].push(currYVal2);
    }

    function messwertDel() {
        if (currentMap["xAxis"]==null) return;
        if (currentMap["xAxis"].length<1) return;
        currentMap["xAxis"].pop();
        currentMap["yAxis1"].pop();
        if (currentMap["yAxis2"]!=null) currentMap["yAxis2"].pop();
    }

    function messwertExp() {
        serverInterface.exportTMP(currentMap);
    }

    function diagram_aus() {
        diagrammActive = false;
    }
    
    function diagram_an() {
        diagrammActive = true;
    }

    function updatePlot() {
        activeAlice.x = diagram.x + diagram.height/4.*(1 + currYVal1/yValMax)*Math.cos(-1*currXVal/180.*Math.PI);
        activeAlice.y = diagram.y - diagram.height/4.*(1 + currYVal1/yValMax)*Math.sin(-1*currXVal/180.*Math.PI);
        activeAlice.visible = true;

        if (currentStep>= 400){
            activeBob.x = diagram.x + diagram.height/4.*(1 + currYVal2/yValMax)*Math.cos(-1*currXVal/180.*Math.PI);
            activeBob.y = diagram.y - diagram.height/4.*(1 + currYVal2/yValMax)*Math.sin(-1*currXVal/180.*Math.PI);
            activeBob.visible = true;
        }

        var xVals: Array<Float> = currentMap["xAxis"];
        var yVals1: Array<Float> = currentMap["yAxis1"];
        var yVals2: Array<Float> = currentMap["yAxis2"];

        if (arrPoints1.length < xVals.length){
            for (i in arrPoints1.length...xVals.length){
                arrPoints1.push(copyElement(measuredAlice));
            }
        }

        if (xVals.length < arrPoints1.length ){
            for (i in xVals.length...arrPoints1.length){
                arrPoints1[i].visible = false;
            }
        }

        if (currentStep>= 400){
            if (arrPoints2.length < xVals.length){
                for (i in arrPoints2.length...xVals.length){
                    arrPoints2.push(copyElement(measuredBob));
                }
            }
            if (xVals.length < arrPoints2.length ){
                for (i in xVals.length...arrPoints2.length){
                    arrPoints2[i].visible = false;
                }
            }
        }

        for (i in 0...xVals.length){
            var iAlice = arrPoints1[i];
            var iX = xVals[i];
            var iY1 =  yVals1[i];

            iAlice.x = diagram.x + diagram.height/4.*(1 + iY1/yValMax)*Math.cos(-1*iX/180.*Math.PI);
            iAlice.y = diagram.y - diagram.height/4.*(1 + iY1/yValMax)*Math.sin(-1*iX/180.*Math.PI);
            iAlice.visible = true;
            
            if (currentStep>= 400){
                var iBob = arrPoints2[i];
                var iY2 =  yVals2[i];

                iBob.x = diagram.x + diagram.height/4.*(1 + iY2/yValMax)*Math.cos(-1*iX/180.*Math.PI);
                iBob.y = diagram.y - diagram.height/4.*(1 + iY2/yValMax)*Math.sin(-1*iX/180.*Math.PI);
                iBob.visible = true;
                
            }
        }
        txtMessungen.text = Std.string(xVals.length);
        
        txtAlice.visible = true;
        txtAlice.text = Std.string(currYVal1);

        if(currentStep>= 400){
            txtBob.visible = true;
            txtBob.text = Std.string(currYVal2);
        }
        else {
            txtBob.visible = false;
        }

        
    }

    function removePlot() {
        if (activeAlice== null) return;
        if (activeBob== null) return;
        activeAlice.visible = false;
        activeBob.visible = false;

        for (point in arrPoints1){
            point.visible = false;
        }
        for (point in arrPoints2){
            point.visible = false;
        }

    }

    public function copyElement(element:TElement): TElement {
        var newElem: TElement;
        newElem = null;
        if(!Scene.active.ready) return newElem;
		canvas = Scene.active.getTrait(CanvasScript);
		if (canvas == null) canvas = Scene.active.camera.getTrait(CanvasScript);
		if(canvas == null) return newElem;
		if (!canvas.ready) return newElem;
        
		var newId = 0;
		var cve: Array <Dynamic>= canvas.getElements();
		for (e in cve){
			if (newId < e.id || newId == e.id) newId = e.id + 1;   
		}
		newElem =  Reflect.copy(element);
		newElem.id = newId;
        cve.push(newElem);
        return newElem;
    }

    private function setLoc(element:TElement, v:Vec4){
        element.x = v.x;
        element.y = v.y;
    }

	inline function initProps(object:Object){
		if (object == null) return;
		if (object.properties == null) object.properties = new Map();
    }
    


}


