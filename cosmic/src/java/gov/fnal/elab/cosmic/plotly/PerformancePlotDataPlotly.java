package gov.fnal.elab.cosmic.plotly;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.TreeMap;
import java.lang.Math;
import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;


public class PerformancePlotDataPlotly {

	private TreeMap<Integer, timePulseData> plotDataChannel1; 
	private TreeMap<Integer, timePulseData> plotDataChannel2; 
	private TreeMap<Integer, timePulseData> plotDataChannel3; 
	private TreeMap<Integer, timePulseData> plotDataChannel4; 
	
	public PerformancePlotDataPlotly(File[] files) throws IOException {
		for (int i= 0; i < files.length; i++) {
			BufferedReader br = new BufferedReader(new FileReader(files[i]));		
			timePulseData thisLineData = null;
			int ts=0; 
			if (i == 0) {
				plotDataChannel1 = new TreeMap<Integer, timePulseData>();
				plotDataChannel1 = saveLineData(br);
			}
			if (i == 1) {
				plotDataChannel2 = new TreeMap<Integer, timePulseData>();
				plotDataChannel2 = saveLineData(br);
			}
			if (i == 2) {
				plotDataChannel3 = new TreeMap<Integer, timePulseData>();
				plotDataChannel3 = saveLineData(br);
			}
			if (i == 3) {
				plotDataChannel4 = new TreeMap<Integer, timePulseData>();
				plotDataChannel4 = saveLineData(br);
			}
		}
	}

	public TreeMap<Integer, timePulseData> saveLineData(BufferedReader br) {
		timePulseData thisLineData = null;
		String[] split; 
		String line;
		TreeMap<Integer, timePulseData> plotData = new TreeMap<Integer, timePulseData>();
		int ts=0; 
		try {
			while ((line = br.readLine()) != null) {
				split = line.split("\t"); 
				if (split.length < 2) {
					return null;
				}
				thisLineData = new timePulseData(	
						parseToDouble(split[0]),
						parseToDouble(split[1])
				);				
				ts++;
				plotData.put(ts, thisLineData);				
			}
		} catch (Exception e) {
			return null;
		}
		return plotData;
	}
	
	public TreeMap<Integer, timePulseData> getTimePulseDataChannel1() {
		return plotDataChannel1;
	}
	public TreeMap<Integer, timePulseData> getTimePulseDataChannel2() {
		return plotDataChannel2;
	}
	public TreeMap<Integer, timePulseData> getTimePulseDataChannel3() {
		return plotDataChannel3;
	}
	public TreeMap<Integer, timePulseData> getTimePulseDataChannel4() {
		return plotDataChannel4;
	}
	
	public class timePulseData {
		private double timeOverThreshold;
		private double pulse;
		private double yError;
		
		private timePulseData(double timeOverThreshold,
						      double pulse) {
				this.timeOverThreshold = timeOverThreshold;
				this.pulse = pulse;
				this.yError = Math.sqrt((double) pulse);
		}

		public double getTimeOverThreshold() {
			return timeOverThreshold; 
		}
		public double getPulse() {
			return pulse; 
		}	
		public double getYError() {
			return yError; 
		}	
	}

	public double parseToDouble(String split)
	{
		double result = 0;
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of parseToDouble	
}
