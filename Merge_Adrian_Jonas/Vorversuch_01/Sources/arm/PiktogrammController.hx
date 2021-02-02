package arm;


import js.html.audio.ConstantSourceOptions;
import armory.logicnode.PickLocationNode;
import js.lib.Math;
import iron.Trait;
import js.lib.Object.ObjectPrototype;
import arm.node.AA_Kamera_Bewegung;
import haxe.Json;
import js.lib.webassembly.Global;
import iron.Scene;
import zui.Zui.Handle;
import iron.object.Object;
import armory.system.Event;
import armory.trait.internal.CanvasScript;
import iron.math.Vec4;
import iron.system.Input;

import armory.trait.internal.CanvasScript;
import iron.Scene;

import zui.Canvas.Anchor;
import zui.Canvas;
import zui.*;

import armory.system.Event;


/*
typedef TElement = {
	var id: Int;
	var type: ElementType;
	var name: String;
	var x: Float;
	var y: Float;
	var width: Int;
	var height: Int;
	@:optional var rotation: Null<kha.FastFloat>;
	@:optional var text: String;
	@:optional var event: String;
	// null = follow theme settings
	@:optional var color: Null<Int>;
	@:optional var color_text: Null<Int>;
	@:optional var color_hover: Null<Int>;
	@:optional var color_press: Null<Int>;
	@:optional var color_progress: Null<Int>;
	@:optional var progress_at: Null<Int>;
	@:optional var progress_total: Null<Int>;
	@:optional var strength: Null<Int>;
	@:optional var alignment: Null<Int>;
	@:optional var anchor: Null<Int>;
	@:optional var parent: Null<Int>; // id
	@:optional var children: Array<Int>; // ids
	@:optional var asset: String;
	@:optional var visible: Null<Bool>;
	@:optional var editable: Null<Bool>;
}
*/

enum PiktoTyp {
    Polarizer;
    Analyzer;
    LambdaHalf;
    Pbs;
}

class PiktogrammController extends iron.Trait {


    @prop
    var objectName1: String = "Polfilter_01";
    
    @prop
    var objectName2: String = "Polfilter_02";
    
    @prop
    var objectName3: String = "Polfilter_03";

    @prop
    var objectName4: String = "Polfilter_04";

	var canvas: CanvasScript;
    var globalObj: Object;
    var currentStep: Int;

    var picto1: Piktogramm;
    var picto2: Piktogramm;
    var picto3: Piktogramm;
    var picto4: Piktogramm;
    var picto5: Piktogramm;

    var arrPictos: Array<Piktogramm>;
    var initialized: Bool;

	public function new() {
		super();

		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);
	}

	function onInit() {
        initialized = false;
		globalObj = iron.Scene.active.root;
        initProps(globalObj);

        arrPictos = [];

        Event.add("pictogramGlobalOn",pictogramGlobalOn);
        Event.add("Profil_gemessen",profilMeasured);
	}

	function onUpdate(){

        // initialisierung, objekt spawn anbhängig, deswegen im onUpdate
        if (object == null) return;
        if (object.properties == null) return;

        currentStep = (object.properties.get("schritte"));
        if (currentStep == null) return;

        if (currentStep>=100 && !initialized){
            initPictogramms();
            initialized = true;
        } 

        if (!initialized) return;
        
        // Abfrage der Schritte, Piktogramme ein und ausschalten
        if (currentStep<100){
            picto1.active = false;
            picto2.active = false;
            picto3.active = false;
            picto4.active = false;
        }
        if (currentStep>=100){
            picto1.active = true;

            picto2.active = false;
            picto3.active = false;
            picto4.active = false;
        }
        if (currentStep>= 200){
            picto1.active = true;
            picto2.active = true;
            
            picto3.active = false;
            picto4.active = false;
            
            if (currentStep>= 203){
                picto3.active = true;
            }
        }
        if (currentStep>= 300){
            picto1.active = true;
            picto2.active = true;
            picto4.active = true;
            
            picto3.active = false;
        }
        if (currentStep>= 400){
            picto1.active = true;
            picto4.active = true;

            picto2.active = false;
            picto3.active = false;
        }

        // active piktogramme updaten
        for (picto in arrPictos){
            if (picto.active) picto.update();
            else picto.hide();
        }

    }
    
    function pictogramGlobalOn() {

    }

    function profilMeasured(){
        picto1.profilMessured = true;
    }

    function initPictogramms() {
        if(picto1 == null) {
            picto1 = new Piktogramm(globalObj.getChild(objectName1), PiktoTyp.Polarizer, 1);
            picto1.active = false;
            picto1.hide();
            arrPictos.push(picto1);
        } 
        if(picto2 == null){
            picto2 = new Piktogramm(globalObj.getChild(objectName2), PiktoTyp.Analyzer, 3);
            picto2.active = false;
            picto2.hide();
            arrPictos.push(picto2);
        } 
        if(picto3 == null){
            picto3 = new Piktogramm(globalObj.getChild(objectName3), PiktoTyp.Analyzer, 2);
            picto3.active = false;
            picto3.hide();
            arrPictos.push(picto3);
        } 
        if(picto4 == null){
            picto4 = new Piktogramm(globalObj.getChild(objectName4), PiktoTyp.LambdaHalf, 2);
            picto4.active = false;
            picto4.hide();
            arrPictos.push(picto4);
        }
    }

	inline function initProps(object:Object){
		if (object == null) return;
		if (object.properties == null) object.properties = new Map();
    }

}


class Piktogramm{
    public var pos_x: Int;
    public var pos_y: Int;
    public var posV: Vec4;
    public var size: Float;

    
    var globalObj = iron.Scene.active.root;
    var motherObj: Object;
    var prevBeam: Object;
    var nextBeam: Object;

    var slot: Int;

    var pType: PiktoTyp;


    var picIn: TElement;
    var picRand: TElement;

    var labelIn: TElement;
    var labelOut: TElement;
    var labelAx: TElement;

    var arrInLine: TElement;
    var arrInUp: TElement;
    var arrInDown: TElement;
    var arrOutLine: TElement;
    var arrOutUp: TElement;
    var arrOutDown: TElement;

    var cosIn: TElement;
    var cosOut: TElement;

    var profil: TElement;
    var angText: TElement;


    var elements: Array<TElement>;
    var canvas: CanvasScript;
    var testPoint: TElement;

    public var angles: Array<Float>;
    public var powers: Array<Float>;

    public var angleAxis: Float;
    
    public var active: Bool;
    public var profilMessured: Bool;

    public function new(motherObject: Object, type: PiktoTyp, slot: Int) {
        this.motherObj = motherObject;
        this.slot = slot;
        this.pType = type;

        if(!Scene.active.ready) return;
		canvas = Scene.active.getTrait(CanvasScript);
		if (canvas == null) canvas = Scene.active.camera.getTrait(CanvasScript);
		if (canvas == null) return;
		if (!canvas.ready) return;

        elements = [];
        createNewElements();

        profil.visible = false;
        arrInLine.height = 3;
        arrOutLine.height = 3;
        pos_x = 0;
        pos_y = 0;

        active = false;
        profilMessured = false;
    }

    public function update(){

        prevBeam = motherObj.properties.get("PrevBeam");
        nextBeam = motherObj.properties.get("NextBeam");

        if (prevBeam == null) return;
        if (nextBeam == null) return;

        angles = [prevBeam.properties.get("stokes_psi"),nextBeam.properties.get("stokes_psi")];
        var angleDiff = (angles[0] - angles[1]);

        // TODO find connection to laser Trait
        if (pType == Polarizer) powers = [prevBeam.properties.get("stokes_I")*Math.sqrt(0.85),nextBeam.properties.get("stokes_I")];
        else powers = [prevBeam.properties.get("stokes_I"),nextBeam.properties.get("stokes_I")];
        
        if (slot == 1) angleAxis = Scene.active.getChildren()[0].properties.get("Winkel_Stage_01");
        if (slot == 2){
            if (pType == LambdaHalf) angleAxis = Scene.active.getChildren()[0].properties.get("Winkel_Stage_04");
            if (pType == Analyzer) angleAxis = Scene.active.getChildren()[0].properties.get("Winkel_Stage_03");
            }
        if (slot == 3) angleAxis = Scene.active.getChildren()[0].properties.get("Winkel_Stage_02");
        angleAxis = (angleAxis + Math.PI ) %(2*Math.PI);

        posV = worldToScreenSpace(motherObj.transform.loc);
        posV.x = posV.x * 1920/2.;
        posV.y = posV.y * -1080/2  - 120;
        for (e in elements){
            setLoc(e,posV);
            e.visible = true;
        }

        angText.text = Std.string(Math.round(angleAxis*180./Math.PI));
        angText.y = angText.y - 85;

        if (pType != Polarizer || !profilMessured) profil.visible = false;
        if (profilMessured) profil.visible = true;
        
        cosIn.visible = false;
        cosOut.visible = false;


        labelAx.rotation = -1*angleAxis;

        if (pType == LambdaHalf){
            labelOut.rotation = -1*angles[1];
            arrOutLine.rotation = -1*angles[1];
        }
        else{
            labelOut.rotation = -1*angleAxis;
            arrOutLine.rotation = -1*angleAxis;
        }

        labelIn.rotation = -1*angles[0];
        arrInLine.rotation = -1*angles[0];

        
        arrInLine.width = Std.int(Math.sqrt(powers[0])*150);
        if (pType == Analyzer)  arrOutLine.width = Math.abs(Math.round(arrInLine.width * Math.cos(angleDiff))); 
        else arrOutLine.width = Std.int(Math.sqrt(powers[1])*150);

        arrInUp.width = Std.int(arrInLine.width*0.04 + 5);
        arrOutUp.width = Std.int(arrOutLine.width*0.04 + 5);
        arrInDown.width = Std.int(arrInLine.width*0.04  + 5);
        arrOutDown.width = Std.int(arrOutLine.width*0.04 + 5);

        arrInUp.height = Std.int(arrInLine.width *0.13);
        arrOutUp.height = Std.int(arrOutLine.width*0.13);
        arrInDown.height = Std.int(arrInLine.width *0.13);
        arrOutDown.height = Std.int(arrOutLine.width*0.13);
        
        if (pType == LambdaHalf){
            arrOutUp.x = posV.x + Math.cos(angles[1]) * arrOutLine.width /2.;
            arrOutUp.y = posV.y - Math.sin(angles[1]) * arrOutLine.width /2.;
            
            arrOutDown.x = posV.x - Math.cos(angles[1]) * arrOutLine.width /2.;
            arrOutDown.y = posV.y + Math.sin(angles[1]) * arrOutLine.width /2.;
            arrOutUp.rotation = -1*angles[1] +  Math.PI/2;
            arrOutDown.rotation = -1*angles[1] -  Math.PI/2;

        }
        else{
            arrOutUp.x = posV.x + Math.cos(angleAxis) * arrOutLine.width /2.;
            arrOutUp.y = posV.y - Math.sin(angleAxis) * arrOutLine.width /2.;
            
            arrOutDown.x = posV.x - Math.cos(angleAxis) * arrOutLine.width /2.;
            arrOutDown.y = posV.y + Math.sin(angleAxis) * arrOutLine.width /2.;
            arrOutUp.rotation = -1*angleAxis +  Math.PI/2;
            arrOutDown.rotation = -1*angleAxis -  Math.PI/2;
        }


        arrInUp.x = posV.x + Math.cos(angles[0]) * arrInLine.width /2.;
        arrInUp.y = posV.y - Math.sin(angles[0]) * arrInLine.width /2.;
        arrInUp.rotation = -1*angles[0] +  Math.PI/2;

        arrInDown.x = posV.x - Math.cos(angles[0]) * arrInLine.width /2.;
        arrInDown.y = posV.y + Math.sin(angles[0]) * arrInLine.width /2.;
        arrInDown.rotation = -1*angles[0] -  Math.PI/2;


        if (pType == Polarizer) {
            profil.rotation = -1*angles[0];
            arrInDown.visible = false;
            arrInLine.visible = false;
            arrInUp.visible = false;
        }
        if (pType == Analyzer){

            var alpha = Math.abs(angles[1] - angles[0]);
            var beta = Math.PI/2. - alpha;
            var phi = angles[1];

            cosIn.visible = true;
            cosOut.visible = true;

            cosIn.width   = Math.round(arrOutLine.width/2.);
            cosIn.height  = Math.round(cosIn.width/2 * Math.tan(alpha));
            cosOut.width  = Math.round(cosIn.width * Math.tan(alpha));
            cosOut.height = Math.round(cosOut.width/2. * Math.tan(beta));

            var sign = 1;
            if (angles[1]>angles[0]) sign = -1;

            cosIn.x = cosIn.x  + Math.round(cosIn.width/2 * Math.cos(phi) + cosIn.height/2. * Math.cos(phi + Math.PI/2*sign));
            cosIn.y = cosIn.y  - Math.round(cosIn.width/2 * Math.sin(phi) + cosIn.height/2. * Math.sin(phi + Math.PI/2*sign));

            cosOut.x = cosOut.x + Math.round((cosIn.width - cosOut.height/2) * Math.cos(phi) + cosOut.width/2. * Math.cos(phi + Math.PI/2*sign));
            cosOut.y = cosOut.y - Math.round((cosIn.width - cosOut.height/2) * Math.sin(phi) + cosOut.width/2. * Math.sin(phi + Math.PI/2*sign));

            if (angles[1]>angles[0]){
                cosIn.rotation = -1* (phi + Math.PI);
                cosOut.rotation = -1* (phi + Math.PI/2.);
            }
            else{
                cosIn.rotation = -1* (phi );
                cosOut.rotation = -1* (phi + Math.PI/2.);
            }
            

            

        }
    }

    public function hide(){
        for (e in elements){
            //setLoc(e,posV);
            e.visible = false;
        }
    }

    public function worldToScreenSpace(vInp: Vec4): Vec4 {
		var v1: Vec4 = new Vec4().setFrom(vInp);
		if (v1 == null) return null;
        var v = new Vec4();

		var cam = iron.Scene.active.camera;
		v.setFrom(v1);
		v.applyproj(cam.V);
		v.applyproj(cam.P);

		return v;
    }

    private function setLoc(element:TElement, v:Vec4){
        element.x = v.x;
        element.y = v.y;
    }
 
    private function createNewElements(){
        picIn = copyElement(canvas.getElement("pictograminnen") );
        elements.push(picIn);
        picRand= copyElement(canvas.getElement("pictogramrand") );
        elements.push(picRand);
        labelIn= copyElement(canvas.getElement("poleingang") );
        elements.push(labelIn);
        labelOut= copyElement(canvas.getElement("polausgang") );
        elements.push(labelOut);
        labelAx= copyElement(canvas.getElement("optischeachse") );
        elements.push(labelAx);
        arrInLine= copyElement(canvas.getElement("polpfeilvor") );
        elements.push(arrInLine);
        arrInUp= copyElement(canvas.getElement("polpfeilvorspitze") );
        elements.push(arrInUp);
        arrInDown= copyElement(canvas.getElement("polpfeilvorspitzea") );
        elements.push(arrInDown);
        arrOutLine= copyElement(canvas.getElement("polpfeilnach") );
        elements.push(arrOutLine);
        arrOutUp= copyElement(canvas.getElement("polpfeilnachspitze") );
        elements.push(arrOutUp);
        arrOutDown= copyElement(canvas.getElement("polpfeilnachspitzea") );
        elements.push(arrOutDown);
        cosIn= copyElement(canvas.getElement("cosinusinnen") );
        elements.push(cosIn);
        cosOut= copyElement(canvas.getElement("cosinusaussen") );
        elements.push(cosOut);
        angText = copyElement(canvas.getElement("stagewinkel") );
        elements.push(angText);
        profil= copyElement(canvas.getElement("profil") );
        elements.push(profil);
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
    
}


    


