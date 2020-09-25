package arm;


import zui.Zui.Align;
import arm.ZuiPlotLib;
import zui.*;
import kha.Color;
import haxe.Json;
import kha.System;



import iron.object.Object;

class MeasurementPlotNew extends iron.Trait {

    var ui:ZuiPlotLib;


    var pos_x = 1320;
    var pos_y = 300;
    var width = 650;
    var height = 1200;

    var time:Float;
    var time2:Float;
    
    
    var xVals: Array<Float>;
    var yValsList: Array<Array<Dynamic>>;
    var yCCList: Array<Array<Dynamic>>;
    
    var binwidth = 0.05; // in s
    var timediscretization = 0.05;
    var n_values = 200;

	public function new() {
		super();
		// Load font for UI labels

		notifyOnInit(onInit);
		notifyOnRemove(onRemove);
	}

	function onInit() {   
		iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
			ui = new ZuiPlotLib({font: f});
		});
		pos_x+= (object.uid *200) %500;
		pos_y+= (object.uid *200) %500;

		trace(pos_x);
		time = 0.; 
        time2 = 0.;
        xVals = [0];
        
        for (i in 1...n_values){
            xVals.push(xVals[i-1]+ timediscretization);
        }
		notifyOnRender2D(render2D);
	}
	
	function onRemove() {
		//removeRender2D(render2D);
		trace("remove Tests");
	}

	function render2D(g:kha.graphics2.Graphics) {
		g.end();
		ui.begin(g);
		var hwin = Id.handle();
	
		time += iron.system.Time.delta;
		time2 += iron.system.Time.delta;
		if (time > timediscretization/2) {
			
			time = 0;
			hwin.redraws = 1;
			yValsList = [[],[]];
			for (x in xVals){
				yValsList[0].push(Math.sin(x+time2)+1.);
				yValsList[1].push(Math.cos(x+time2)+1.);
			}
		
			
		}
		else hwin.redraws = 0;
	
		var hcombo = Id.handle();
	
	
		// Start with UI
		// Make window
		if (ui.window(hwin, pos_x, pos_y, width, height, true)) {
			
		ui.row([1/2, 1/2]);
		if (ui.button("Take Measurement", Align.Right)) {
			trace(ui.ops.khaWindowId);
			trace(object.uid);
			measureNow();	
		}
		if (ui.button("Close Window", Align.Right)){
			object.remove();
		}

		

		if (ui.panel(Id.handle({selected: true}), "Choose Data")) {    
			ui.row([1/2, 1/2]);
			ui.text("x Axis");
			ui.combo(hcombo, ["Item 1", "item 2"]);
			if (hcombo.changed) {
				trace("Combo value changed this frame");
				trace(hcombo.position);
			}
		}
	
			if( yValsList!= null){
				ui.coordinateSystem(xVals,yValsList,600,300,3);
			}
		}

		ui.end();
		g.begin(false);
	}

	function measureNow(){
		trace("measureNow Dummy");
	}

	
}
