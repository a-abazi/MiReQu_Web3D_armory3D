package arm;

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
    

    public function coordinateSystem(width: Float,height: Float, strength: Float ) {
        var x0 = 40.* SCALE();
        var y0 = 20.* SCALE();

        var xl = width * SCALE();
        var yl = height * SCALE();

        var xShift = 15. ;
        var yShift = 15. ;


        g.color = Color.Black;
        if (!enabled) fadeColor();
        
        drawAxis(_x+x0,_y+yl+y0, xl, strength,"X-axis", "h");
        drawAxis(_x+x0+xShift ,_y+yl+y0+yShift, xl, strength,"Y-axis", "v");

        
        
        
        g.color = 0xffffffff;
        }
        
    private function drawAxis(posX:Float, posY:Float, length:Float,strength:Float,label:String="",
        orient:String = "h",arrHeight = 12, arrWidth = 10, fontSize = 20  ): Bool {
        var oldFontsize = g.fontSize ;
        g.fontSize = fontSize;
        var fontShift = g.font.width(fontSize ,label) * 0.5;

        if (orient == "h"){
            g.fillRect( posX,posY, length,strength);
            g.fillTriangle( posX+length , posY+arrWidth/2+strength ,
                posX+length, posY-arrWidth/2,
                posX+length+arrHeight, posY+strength/2 );
            g.drawString(label,posX + length/2 - fontShift, posY+strength+fontSize);            
        }
        else {
            g.rotate(-Math.PI/2,posX,posY); 
            g.fillRect( posX,posY, length,strength);
            g.fillTriangle( posX+length , posY+arrWidth/2+strength ,
                posX+length, posY-arrWidth/2,
                posX+length+arrHeight, posY+strength/2 );
            g.drawString(label,posX + length/2 - fontShift, posY-strength-fontSize*2);     
            g.rotate(Math.PI/2,posX,posY);
        }
        g.fontSize = oldFontsize;
        
        return true;
    }
}