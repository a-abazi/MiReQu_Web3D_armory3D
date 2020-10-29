package arm;



import kha.graphics2.VerTextAlignment;
import kha.graphics2.HorTextAlignment;
import haxe.display.Position.Range;
import kha.Color;
import zui.Zui.ZuiOptions;
import zui.*;

import kha.graphics2.Graphics;
import kha.graphics4.Graphics2.TextShaderPainter;
import kha.graphics2.GraphicsExtension;

import arm.NiceScale;

class ZuiPlotLib extends Zui {
    public function new(ops:ZuiOptions) {
        super(ops);
    }


    
    public function testLine(x1:Float,y1:Float,x2:Float,y2:Float,color: kha.Color
                                ,strength:Float =1.0) {
        g.color = color;
		if (!enabled) fadeColor();
        g.drawLine(_x + x1 * SCALE(),_y + y1* SCALE(),_x + x2* SCALE(),_y + y2* SCALE(),strength);
        g.color = 0xffffffff;
    }

    public function polarCoordinateSystem(phiVals : Array<Float>, rValsList: Array<Array<Dynamic>> ,size: Float, strength: Float, xlabel :String, ylabel:String) {
        var gE = GraphicsExtension;

        var x0 = 80.* SCALE();
        var y0 = 40.* SCALE();

        var r0 = 40.* SCALE();

        //var xl = size * SCALE() - x0;
        //var yl = size * SCALE() - y0;
        var factorRZ = 0.5;

        var rl = (1-factorRZ)*Math.sqrt(2)*size/2* SCALE() - r0;
        var zeroDist = (factorRZ)*Math.sqrt(2)*size/2* SCALE() - r0;


        var fontSize = 30;

        var origin_x = _x+x0+rl+zeroDist;
        var origin_y = _y+y0+rl+zeroDist;

        var colorsPlot = [Color.Red, Color.Blue, Color.Green];
        var orange = Color.fromBytes(226,151,50);
        var beige = Color.fromBytes(232,187,120);
        var grey = Color.fromBytes(144,143,143);
        var blue = Color.fromBytes(153,181,169);

        var colorsAxes: Array<Color> = [orange,blue,grey,beige,];
        

        g.color = Color.White;
        if (!enabled) fadeColor();
        
        //calculate scaling, pixel to data
        var xDmin = 0;
        var xDmax = 360;

        var yDmin = 0;
        var yDmax = 0.9;
        
        for (rVals in rValsList){
            for (value in rVals){
                if (yDmax< value) yDmax = value; 
            }
        }

        
        var rScale = rl  / (yDmax - yDmin);
        
        //calc ticks
        var phiTicks:Array<Float> = [0,45,90,135,180,225,270,315,360];
        var phiTickMap = new Map<String, Float>();
        var rTickMap = new Map<String, Float>();
        for (tick in phiTicks){
            phiTickMap[Std.string(tick)] = tick/180.*Math.PI;
        }

        var maxN_rTicks = 6;//Math.floor((yl - 2*yA)/ (fontSize));
        var rScaleTicks = new NiceScale(yDmin,yDmax);
        rScaleTicks.setMaxTicks(maxN_rTicks);
        var rTicks = rScaleTicks.getTicks();
        for (tick in rTicks){
            if ((rScale * tick)< (rl)){ 
                rTickMap[Std.string(tick)] = (rScale * tick);
            }
        }
        var rTicksDistance = (rScale * Math.abs(rTicks[0] - rTicks[1]));
        var rMaxTickValue = rTicks[rTicks.length-1]*rScale;
        //trace(yTicksDistance);

        drawAxesPolar(origin_x,origin_y,rl,zeroDist,strength, rTickMap,phiTickMap,rTicksDistance,rMaxTickValue,rTicks,colorsAxes,xlabel, ylabel);


        //draw measurement points
        var endI = phiVals.length;
        var colorI = 0;
        for (yVals in rValsList){
            g.color = colorsPlot[colorI];
            for (i in 0...endI){
                //var posX = _x + x0 + xA +  (xScale * xVals[i]);
                var posX = origin_x + Math.cos(-1*phiVals[i]*Math.PI/180.)*(zeroDist+(rScale * yVals[i]));
                //var posY = _y + y0 - yA + yl - (yScale * yVals[i]);
                var posY = origin_y + Math.sin(-1*phiVals[i]*Math.PI/180.)*(zeroDist+(rScale * yVals[i])) ;

                drawMarker(posX , posY  ,3,"point");
            }
            colorI +=1;
        }
        g.color = 0xffffffff;
        
        _y += y0+ size + fontSize * 2.5 ;
        
    }
    

    public function tstAngleCS(xVals : Array<Float>, yValsList: Array<Array<Dynamic>> ,width: Float,height: Float, strength: Float, xlabel :String, ylabel:String ) {
        var x0 = 80.* SCALE();
        var y0 = 40.* SCALE();

        var xl = width * SCALE() - x0;
        var yl = height * SCALE() - y0;

        var fontSize = 30;

        var origin_x = _x+x0;
        var origin_y = _y+y0+yl;

        var colors = [Color.Red, Color.Blue, Color.Green];

        

        g.color = Color.White;
        if (!enabled) fadeColor();
        
        //calculate scaling, pixel to data
        var xDmin = 0;
        var xDmax = 360;

        var yDmin = 0;
        var yDmax = 0.3;
        
        for (yVals in yValsList){
            for (value in yVals){
                if (yDmax< value) yDmax = value; 
            }
        }

        var xA = xl * 0.05; //distance from lines to min Value and Max Value
        var yA = yl * 0.05;

        var xScale = (xl - 2*xA) * 1 / (xDmax - xDmin);
        var yScale = (yl - 2*yA) * 1 / (yDmax - yDmin);
        
        //calc ticks
        var xTicks:Array<Float> = [0,45,90,135,180,225,270,315,360];
        var xTickMap = new Map<String, Float>();
        var yTickMap = new Map<String, Float>();
        for (tick in xTicks){
            xTickMap[Std.string(tick)] = _x + x0 + xA +  (xScale * tick);
        }

        var maxNYTicks = Math.floor((yl - 2*yA)/ (fontSize));
        var yScaleTicks = new NiceScale(yDmin,yDmax);
        yScaleTicks.setMaxTicks(maxNYTicks);
        var yTicks = yScaleTicks.getTicks();
        for (tick in yTicks){
            if ((yScale * tick)< (yl-2*yA)){ 
                yTickMap[Std.string(tick)] = _x + x0+ yA +  (yScale * tick);
            }
        }

        // TODO: CALC MAX Ticks
        drawAxes(origin_x,origin_y,xl,yl,strength,xTickMap, yTickMap,xlabel, ylabel);

        //draw measurement points
        var endI = xVals.length;
        var colorI = 0;
        for (yVals in yValsList){
            g.color = colors[colorI];
            for (i in 0...endI){
                var posX = _x + x0 + xA +  (xScale * xVals[i]);
                var posY = _y + y0 - yA + yl - (yScale * yVals[i]);

                drawMarker(posX, posY ,5);
            }
            colorI +=1;
        }
        g.color = 0xffffffff;
        
        _y += y0+yl + fontSize * 2.5 ;


        }


    public function coordinateSystem(xVals : Array<Float>, yValsList: Array<Array<Dynamic>> ,width: Float,height: Float, strength: Float ) {
        var x0 = 80.* SCALE();
        var y0 = 40.* SCALE();
        var gE = GraphicsExtension;
        
        var xl = width * SCALE() - x0;
        var yl = height * SCALE() - y0;

        var fontSize = 30;

        var origin_x = _x+x0;
        var origin_y = _y+y0+yl;

        var colors = [Color.Red, Color.Blue, Color.Green];

        g.color = Color.White;
        if (!enabled) fadeColor();
        
        //calculate scaling, pixel to data
        var xDmin = 0;
        var xDmax = 10;

        var yDmin = 0;
        var yDmax = 0.3;
        
        for (yVals in yValsList){
            for (value in yVals){
                if (yDmax< value) yDmax = value; 
            }
        }

        var xA = xl * 0.05; //distance from lines to min Value and Max Value
        var yA = yl * 0.05;

        var xScale = (xl - 2*xA) * 1 / (xDmax - xDmin);
        var yScale = (yl - 2*yA) * 1 / (yDmax - yDmin);
        
        //calc ticks
        var xTicks:Array<Float> = [0,2,4,6,8,10];
        var xTickMap = new Map<String, Float>();
        var yTickMap = new Map<String, Float>();
        for (tick in xTicks){
            xTickMap[Std.string(tick)] = _x + x0 + xA +  (xScale * tick);
        }

        var maxNYTicks = Math.floor((yl - 2*yA)/ (fontSize));
        var yScaleTicks = new NiceScale(yDmin,yDmax);
        yScaleTicks.setMaxTicks(maxNYTicks);
        var yTicks = yScaleTicks.getTicks();
        for (tick in yTicks){
            if ((yScale * tick)< (yl-2*yA)){ 
                yTickMap[Std.string(tick)] = _x + x0+ yA +  (yScale * tick);
            }
        }

        // TODO: CALC MAX Ticks
        drawAxes(origin_x,origin_y,xl,yl,strength,xTickMap, yTickMap,"Time (s)", "Countrate (kHz)");

        //draw measurement points
        var endI = xVals.length;
        var colorI = 0;
        for (yVals in yValsList){
            g.color = colors[colorI];
            for (i in 0...endI){
                var posX = _x + x0 + xA +  (xScale * xVals[i]);
                var posY = _y + y0 - yA + yl - (yScale * yVals[i]);

                drawMarker(posX, posY ,5);
            }
            colorI +=1;
        }
        g.color = 0xffffffff;

        g.set_opacity(0.3);
        gE.fillCircle(g,x0,y0,100);
        g.set_opacity(1.);

        _y += y0+yl + fontSize * 2.5 ;


        }

    private function drawAxesPolar(oX:Float, oY:Float, rl:Float, zeroDist:Float, strength:Float, rTickMap: Map<String,Float>, phiTickMap: Map<String,Float>, rTicksDistance: Float,rMaxTickValue:Float, rTicks:Array<Float>,
        colors:Array<Color>, labelPhi:String="",labelR:String="", fontSize = 20 ): Bool {
        var gE = GraphicsExtension;
        //save old Fontsize of graphics2
        var oldFontsize = g.fontSize ;
        var oldColor = g.color;
        g.font = ops.font;
        g.fontSize = fontSize;
        var fontShiftPhi = ops.font.width(fontSize ,labelPhi) * 0.5;
        var fontShiftR = ops.font.width(fontSize ,labelR) * 0.5;
        var dynFontsize = Std.int(rTicksDistance*0.75);
        
        
        g.color = Color.fromBytes(144,143,143);
        g.drawLine(oX,oY,oX+zeroDist+rMaxTickValue,oY,2);

        var c = 0;
        var segments = 64;
        for (tickLabel in rTickMap.keys()){
            g.fontSize = dynFontsize;
            
            g.set_opacity(1.);
            g.color = Color.White;
            g.drawString(tickLabel,oX+zeroDist+rTickMap[tickLabel] + ops.font.width(g.fontSize," ")  ,oY);//- ops.font.width(g.fontSize,tickLabel)

            //g.color  = Color.fromBytes(144,143,143);
            //gE.drawCircle(g,oX,oY,zeroDist+rTickMap[tickLabel]);

            g.set_opacity(1. - c*0.75/rTicks.length );
            var cc = 0;
            for (color in colors){
                g.color = color;
                gE.drawArc(g, oX, oY, zeroDist + rMaxTickValue - rTicksDistance*(c+1./2.), -Math.PI/4*(cc+1),-Math.PI/4*(cc)  ,rTicksDistance , false,segments);
                gE.drawArc(g, oX, oY, zeroDist + rMaxTickValue - rTicksDistance*(c+1./2.), -Math.PI/4*(cc+5),-Math.PI/4*(cc+4),rTicksDistance, false,segments);
                cc++;
            }
            g.set_opacity(1.);
            //if (c!=0){
            //}
            c++;
        }

        var rot  = [-45.,-90.,45.,0 ,-45.,90. ,45.,0 ,0 ];
        var addx = [1,  1, 0  ,0 ,0   ,1,1  ,0 ,0 ];
        var vaTop = [true,true,false,false,false,true,true,false,false];
        c = 0; 
        for (tickLabel in phiTickMap.keys()){
            if (tickLabel == "0" || tickLabel =="360") continue;
            g.color = Color.White;
            var posX = oX + Math.cos(-1*phiTickMap[tickLabel])*(zeroDist+rMaxTickValue);
            var posY = oY + Math.sin(-1*phiTickMap[tickLabel])*(zeroDist+rMaxTickValue);
            var tx = Math.cos(-1*phiTickMap[tickLabel])*(ops.font.width(Std.int(dynFontsize),tickLabel)*(0.55 + 0.2* addx[c]));
            var ty = Math.sin(-1*phiTickMap[tickLabel])*(ops.font.width(Std.int(dynFontsize),tickLabel)*(0.55 + 0.2* addx[c]));
            

            g.set_opacity(0.9);
            g.rotate(rot[c]/180.*Math.PI, posX,posY);
            g.translate(-tx,-ty );
            g.fontSize = Std.int(dynFontsize);
            if (vaTop[c]) gE.drawAlignedString(g,tickLabel ,posX,posY,HorTextAlignment.TextCenter,VerTextAlignment.TextTop);
            else gE.drawAlignedString(g,tickLabel ,posX,posY,HorTextAlignment.TextCenter,VerTextAlignment.TextBottom);
            g.fontSize = Std.int(g.fontSize*0.5);
            if (vaTop[c]) gE.drawAlignedString(g,"o",posX+ ops.font.width(Std.int(dynFontsize),tickLabel)*0.5 ,posY ,HorTextAlignment.TextLeft,VerTextAlignment.TextTop );
            else gE.drawAlignedString(g,"o",posX+ ops.font.width(Std.int(dynFontsize),tickLabel)*0.5 ,posY - ops.font.height(Std.int(dynFontsize))*0.5 ,HorTextAlignment.TextLeft,VerTextAlignment.TextBottom );
            g.translate(tx,ty);
            g.rotate(-rot[c]/180.*Math.PI, posX,posY);
            g.set_opacity(1);
            c++;
        }

        g.fontSize = fontSize;
        g.color = Color.White;
        g.drawString(labelR,oX -fontShiftR*0.75 ,oY);

        
        
        g.color = oldColor;
        g.fontSize = oldFontsize;
        return true;
    }

    private function drawAxes(oX:Float, oY:Float, xl:Float, yl:Float, strength:Float, xTickMap: Map<String,Float>, yTickMap: Map<String,Float>, labelx:String="",labely:String="",
        fontSize = 30 ): Bool {
        
        //save old Fontsize of graphics2
        var oldFontsize = g.fontSize ;
        g.font = ops.font;
        g.fontSize = fontSize;
        var fontShiftx = ops.font.width(fontSize ,labelx) * 0.5;
        var fontShifty = ops.font.width(fontSize ,labely) * 0.5;

        //Draw hor lines
        g.fillRect( oX- strength/2,oY-strength/2, xl,strength);
        g.fillRect( oX- strength/2,oY-strength/2 - yl + strength, xl,strength);
        for (tickLabel in xTickMap.keys()){
            drawTick(tickLabel, xTickMap[tickLabel], oY-strength/2, strength*.5 );
        }

        g.pipeline = rtTextPipeline;
        g.drawString(labelx,oX + xl/2 - fontShiftx, oY+strength+fontSize *1.25);
        g.pipeline = null;
        
        

        g.rotate(-Math.PI/2,oX,oY); 
        g.fillRect( oX- strength/2,oY-strength/2, yl,strength);
        g.fillRect( oX- strength/2,oY-strength/2 + xl -strength, yl,strength);
        for (tickLabel in yTickMap.keys()){
            drawTick(tickLabel, yTickMap[tickLabel], oY-strength/2, strength*.5,  30, "Y" );
        }
        g.pipeline = rtTextPipeline;
        g.drawString(labely,oX + yl/2 - fontShifty, oY-strength-fontSize*2.5);    
        g.pipeline = null;
        g.rotate(Math.PI/2,oX,oY);

        g.fontSize = oldFontsize;
        return true;
    }

    private function drawTick(tLabel:String ,posX:Float, posY:Float,strength:Float, fontSize = 30, axis="X" ) {
        var labelSize = Std.int(fontSize*0.75);
        g.fillRect(posX, posY - labelSize/2 + strength/2 , strength, labelSize);     
        var oldFontsize = g.fontSize ;
		g.font = ops.font;
        g.fontSize = labelSize; // Define Labelsize
        var fontShift = ops.font.width(labelSize ,tLabel) * 0.5;
        g.pipeline = rtTextPipeline;
        if (axis =="X") g.drawString(tLabel,posX -fontShift , posY+strength+labelSize);
        else g.drawString(tLabel,posX -fontShift , posY-strength-labelSize*2);
        g.pipeline = null;
        g.fontSize = oldFontsize;
    }

    private function drawMarker(posX:Float, posY:Float, size = 10., style="square" ){
        if (style =="square"){
            g.fillRect(posX - size/2, posY - size/2, size,size);
        }
        if (style =="triangle") {
            var a = size;
            var ri = a/ (2 * Math.sqrt(3));
            g.fillTriangle(posX - a/2, posY + ri, posX + a/2, posY+ri, posX, posY-(ri*2) );
        }
        if (style =="point"){
            var gE = GraphicsExtension;
            gE.fillCircle(g,posX,posY,size);
        }
    }

}


@:enum abstract State(Int) from Int {
    var Idle = 0;
    var Started = 1;
    var Down = 2;
    var Released = 3;
    var Hovered = 4;
}