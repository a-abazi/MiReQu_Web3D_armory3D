package arm;

class NiceScale{
    public var minPoint:Float;
    public var maxPoint:Float;
    public var maxTicks:Float = 10;
    public var tickSpacing:Float;
    public var range:Float;
    public var niceMin:Float;
    public var niceMax:Float;

     /**
    * Instantiates a new instance of the NiceScale class.
    *
    * @param min the minimum data point on the axis
    * @param max the maximum data point on the axis
    */
    public function new(min:Float, max:Float) {
      this.minPoint = min;
      this.maxPoint = max;
      calculate();
    }
    
    /**
    * Calculate and update values for tick spacing and nice
    * minimum and maximum data points on the axis.
    */
    private function calculate(){
        this.range = niceNum(maxPoint-minPoint,false);
        this.tickSpacing = niceNum(range/ (maxTicks-1), true );
        this.niceMin = Math.ffloor(minPoint / tickSpacing) * tickSpacing;
        this.niceMax = Math.fceil(maxPoint / tickSpacing) * tickSpacing;
    }

    /**
    * Returns a "nice" number approximately equal to range Rounds
    * the number if round = true Takes the ceiling if round = false.
    *
    * @param range the data range
    * @param round whether to round the result
    * @return a "nice" number to be used for the data range
    */
    private function niceNum(range:Float, round:Bool):Float {
        var exponent:Float;/** exponent of range */
        var fraction: Float;/** fractional part of range */
        var niceFraction: Float; /** nice, rounded fraction */
        
        exponent = Math.ffloor(Math.log(range)/Math.log(10));
        fraction = range/ Math.pow(10, exponent);

        if (round){
            if (fraction < 1.5)
              niceFraction = 1;
            else if (fraction < 3)
              niceFraction = 2;
            else if (fraction < 7)
              niceFraction = 5;
            else
              niceFraction = 10;
        }
        else{
            if (fraction <= 1)
                niceFraction = 1;
              else if (fraction <= 2)
                niceFraction = 2;
              else if (fraction <= 5)
                niceFraction = 5;
              else
                niceFraction = 10;
        } 

        
        return niceFraction * Math.pow(10, exponent);
    }

    /**
     * Sets the minimum and maximum data points for the axis.
     *
     * @param minPoint the minimum data point on the axis
     * @param maxPoint the maximum data point on the axis
     */
     public function setMinMaxPoints(minPoint: Float, maxPoint: Float):Void {
      this.minPoint = minPoint;
      this.maxPoint = maxPoint;
      calculate();
    }

    /**
     * Sets maximum number of tick marks we're comfortable with
     *
     * @param maxTicks the maximum number of tick marks for the axis
     */
    public function  setMaxTicks(maxTicks:Float):Void {
      this.maxTicks = maxTicks;
      calculate();
    }

        /**
     * Sets maximum number of tick marks we're comfortable with
     *
     * @param maxTicks the maximum number of tick marks for the axis
     */
    public function  getTicks():Array<Float> {
      var precision = precision(this.tickSpacing);
      if (precision>3) precision = 4;
      var ticks:Array<Float> = [this.niceMin];
      var tickNum = Math.ceil((this.niceMax - this.niceMin)/this.tickSpacing);
      
      for (i in 1...tickNum+1){
          ticks[i] = round2(ticks[i-1] + this.tickSpacing, precision);
      }

      return ticks;
      }


     public function round2( number : Float, precision : Int): Float {
       var num = number;
       num = num * Math.pow(10, precision);
       num = Math.round( num ) / Math.pow(10, precision);
       return num;
       }


     public function precision(a:Float):Int {
        //if (!isFinite(a)) return 0;
        var e = 1, p = 0;
        while (Math.round(a * e) / e != a){ e *= 10; p++; }
        return p;
      }

  }
