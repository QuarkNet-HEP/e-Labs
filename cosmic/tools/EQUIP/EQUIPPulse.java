//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//	  This file contains code for the Pulse class
//
public class EQUIPPulse {
    long counter_rising_edge;
    long counter_falling_edge;
    int time_rising_edge;
    int time_falling_edge;
    int channel;
    double bin_width=1.25;
    
    public EQUIPPulse() {
      channel = -1;
      counter_rising_edge = 0;
      counter_falling_edge = 0;
      time_rising_edge = 0;
      time_falling_edge = 0;
    }
    public EQUIPPulse(int i) {
      channel = i;
      counter_rising_edge = 0;
      counter_falling_edge = 0;
      time_rising_edge = 0;
      time_falling_edge = 0;
    }
    
    public int Channel() {
      return channel;
    }
    public boolean HasRisingEdge() {
      return ( counter_rising_edge > 0 && (time_rising_edge&0x1f) > 0 );
    }
    public boolean HasFallingEdge() {
      return ( counter_falling_edge > 0 && (time_falling_edge&0x1f) > 0 );
    }
    public boolean Valid() {
      return ( HasRisingEdge() && HasFallingEdge() );
    }
    public void SetRisingEdge(long c,int t) {
      counter_rising_edge = c;
      time_rising_edge = t;
    }
    public void SetFallingEdge(long c,int t) {
      counter_falling_edge = c;
      time_falling_edge = t;
    }
    public long RisingEdgeCounter() {
      return counter_rising_edge;
    }
    public int RisingEdgeTime() {
      return time_rising_edge;
    }
    public long FallingEdgeCounter() {
      return counter_falling_edge;
    }
    public int FallingEdgeTime() {
      return time_falling_edge;
    }
    public double TimeOverThreshold() {
      return 40.0*(counter_falling_edge-counter_rising_edge) +
    		  bin_width*((time_falling_edge&0x1f)-((time_rising_edge&0x1f)));
    }
    public double TimeBefore(EQUIPPulse other) {
      return 40.0*(counter_rising_edge-other.RisingEdgeCounter()) +
    		  bin_width*((time_rising_edge&0x1f)-(other.RisingEdgeTime()&0x1f));
    }
    public double TimeUntil(EQUIPPulse other) {
      return 40.0*(-counter_rising_edge+other.RisingEdgeCounter()) +
    		  bin_width*(-(time_rising_edge&0x1f)+(other.RisingEdgeTime()&0x1f));
    }
    public boolean equals(EQUIPPulse p) {
      return channel == p.Channel() &&
             counter_rising_edge == p.RisingEdgeCounter() &&
             counter_falling_edge == p.FallingEdgeCounter() &&
             time_rising_edge == p.RisingEdgeTime() &&
             time_falling_edge == p.FallingEdgeTime();
    }
    public void Dump() {
      System.out.println(" RE="+Long.toString(counter_rising_edge)+","+Integer.toString(time_rising_edge&0x1f)+
                 " FE="+Long.toString(counter_falling_edge)+","+Integer.toString(time_falling_edge&0x1f));
    }
    public String DumpThresholdValues() {
    	return "40.0*("+String.valueOf(counter_falling_edge)+"-"+String.valueOf(counter_rising_edge)+")+"+
      		  String.valueOf(bin_width)+"*("+String.valueOf(time_falling_edge&0x1f)+")-("+String.valueOf(time_rising_edge&0x1f)+")";
    }
    public String DumpREFE() {
    	return " RE="+Long.toString(counter_rising_edge)+","+Integer.toString(time_rising_edge&0x1f)+
                " FE="+Long.toString(counter_falling_edge)+","+Integer.toString(time_falling_edge&0x1f);
    }
}
