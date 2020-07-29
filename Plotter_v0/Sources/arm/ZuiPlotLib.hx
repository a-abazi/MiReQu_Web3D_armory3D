package arm;

import haxe.display.Position.Range;
import kha.Color;
import zui.Zui.ZuiOptions;
import zui.*;

import kha.graphics2.Graphics;
import kha.graphics4.Graphics2.TextShaderPainter;

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
    

    public function coordinateSystem(xVals : Array<Float>, yVals: Array<Float> ,width: Float,height: Float, strength: Float ) {
        
        var x0 = 40.* SCALE();
        var y0 = 20.* SCALE();

        var xl = width * SCALE();
        var yl = height * SCALE();

        var xShift = 15. ;
        var yShift = 15. ;

        var xScale = 50;
        var yScale = 50;

        g.color = Color.Black;
        if (!enabled) fadeColor();
        
        drawAxis(_x+x0,_y+yl+y0, xl, strength,"X-axis", "h");
        drawAxis(_x+x0+xShift ,_y+yl+y0+yShift, xl, strength,"Y-axis", "v");
        //drawMarker(_x+x0+xShift + 30, _y+yl+y0 - 30);
        //drawMarker( _x+x0+xShift + 30 + 60,  _y+yl+y0 - 30 , 20,"triangle");
        var endI = Std.int(xVals.length) -1;
        for (i in 0...endI){
            var posX = _x+x0+xShift+30 + xScale * xVals[i];
            drawMarker(posX, _y+yl+y0 - yScale * yVals[i], 3);
        }

        g.color = 0xffffffff;
        
        }
        
    private function drawAxis(posX:Float, posY:Float, length:Float,strength:Float,label:String="",
        orient:String = "h",arrHeight = 12, arrWidth = 10, fontSize = 30, axShfit = 15.  ): Bool {
        var oldFontsize = g.fontSize ;
		g.font = ops.font;
		g.fontSize = fontSize;
        var fontShift = ops.font.width(fontSize ,label) * 0.5;

        if (orient == "h"){
            g.fillRect( posX,posY, length,strength);
            g.fillTriangle( posX+length , posY+arrWidth/2+strength ,
                posX+length, posY-arrWidth/2,
                posX+length+arrHeight, posY+strength/2 );
            g.pipeline = rtTextPipeline;
            g.drawString(label,posX + length/2 - fontShift, posY+strength+fontSize);
            g.pipeline = null;
            for (i in 1...(Std.int((length-axShfit)/fontSize)) ){
                drawTick(Std.string(i-1),posX + axShfit  + i * fontSize, posY, strength, fontSize,"X" );
            }
        }
        else {
            g.rotate(-Math.PI/2,posX,posY); 
            g.fillRect( posX,posY, length,strength);
            g.fillTriangle( posX+length , posY+arrWidth/2+strength ,
                posX+length, posY-arrWidth/2,
                posX+length+arrHeight, posY+strength/2 );
            g.pipeline = rtTextPipeline;
            g.drawString(label,posX + length/2 - fontShift, posY-strength-fontSize*2);    
            g.pipeline = null;
            for (i in 1...(Std.int((length-axShfit)/fontSize)) ){
                drawTick( Std.string(i-1), posX + axShfit  + i * fontSize, posY, strength, fontSize, "Y" );
            } 
            g.rotate(Math.PI/2,posX,posY);
        }
        
        //g.fillRect( posX,posY, length,strength);
        g.fontSize = oldFontsize;
        
        return true;
    }


    private function drawTick(tLabel:String ,posX:Float, posY:Float,strength:Float, fontSize = 20, axis="X" ) {
        var labelSize = Std.int(fontSize/2);
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
            g.fillRect(posX - size/2, posY - size/2,size,size);
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