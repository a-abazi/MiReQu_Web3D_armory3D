package arm;


import zui.Zui.Align;
import arm.ZuiPlotLib;
import zui.*;
import kha.Color;
import haxe.Json;
import kha.System;



import iron.object.Object;

class NicePlots extends iron.Trait {

    var ui:ZuiPlotLib;


    var pos_x = 200;
    var pos_y = 200;
    var width = 650;
    var height = 1200;

    var time:Float;
    var time2:Float;
    
    
    var xVals: Array<Float>;
    var yValsList: Array<Array<Dynamic>>;
    var yCCList: Array<Array<Dynamic>>;
    
    var binwidth = 0.05; // in s
    var timediscretization = .05;
    var n_values = 360;

	public function new() {
		super();
		// Load font for UI labels

		notifyOnInit(onInit);
		notifyOnRemove(onRemove);
	}

	function onInit() {   
		iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
			ui = new ZuiPlotLib({font: f});
			ui.ops.theme.WINDOW_BG_COL = 0;
		});

		time = 0.; 
        time2 = 0.;
        xVals = [0];
        
        for (i in 1...n_values){
            xVals.push(xVals[i-1]+ 1.);
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
				yValsList[0].push(Math.sin(x/180.*Math.PI+time2)+1.);
				yValsList[1].push(Math.cos(x/180.*Math.PI+time2)+1.);
			}
		
			
		}
		else hwin.redraws = 0;
	
		var hcombo = Id.handle();
	
	
		// Start with UI
		// Make window
		if (ui.window(hwin, pos_x, pos_y, width, height, false)) {
			
	
		if( yValsList!= null){
			//ui.coordinateSystem(xVals,yValsList,600,300,3);
			ui.polarCoordinateSystem(xVals,yValsList,600,300,3,"TestLabelX","TestLabelY");
			
		}
		}

		
		ui.end();
		g.begin(false);
	}

	function measureNow(){
		trace("measureNow Dummy");
	}

	
}
