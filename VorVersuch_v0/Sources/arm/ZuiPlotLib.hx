package arm;



import haxe.display.Position.Range;
import kha.Color;
import zui.Zui.ZuiOptions;
import zui.*;

import kha.graphics2.Graphics;
import kha.graphics4.Graphics2.TextShaderPainter;

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
        
        _y += y0+yl + fontSize * 2.5 ;


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
    }

}


@:enum abstract State(Int) from Int {
    var Idle = 0;
    var Started = 1;
    var Down = 2;
    var Released = 3;
    var Hovered = 4;
}