/*
 * EPeronja-05/10/2013: Added this for today's gps time calculation.
 */
package gov.fnal.elab.ligo.data.json;

public class ConvertUnixToGPS {

	public ConvertUnixToGPS() {		
	}
	
	public double convert(double unixTime) {
		double gpsTime = 0;
		int isLeap = 0;
		if (unixTime % 1 != 0) {
			unixTime -= 0.5;
			isLeap = 1;
		}
		gpsTime = unixTime - 315964800;
		int leaps = countLeaps(gpsTime);
		gpsTime = gpsTime + leaps + isLeap;
		return gpsTime;
	}
	
	protected int countLeaps(double gpsTime) {
		int nleaps = 0;
		int[] leaps = new int[]{46828800, 78364801, 109900802, 173059203, 252028804, 315187205, 346723206, 393984007, 425520008, 457056009, 504489610, 551750411, 599184012, 820108813, 914803214, 1025136015};
	    for (int i = 0; i < leaps.length; i++) {
	    	if (gpsTime >= leaps[i]) {
	    		nleaps++;
	    	}
	    }
	    return nleaps;
	}
	
}