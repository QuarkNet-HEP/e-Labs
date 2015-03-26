package gov.fnal.elab.cosmic.plot;
/*
 * 	EPeronja: 03/26/2015-Interactive Plots.
 * 						 Create object from the analysis file: singleOut (Performance).
 * 						 The threshold value will be used for the histogram
 */
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


public class PerformancePlotData {
	private TreeMap<Integer, singleOutData> perfDataChannel1; 
	private TreeMap<Integer, singleOutData> perfDataChannel2; 
	private TreeMap<Integer, singleOutData> perfDataChannel3; 
	private TreeMap<Integer, singleOutData> perfDataChannel4; 
	
	public PerformancePlotData(File[] files) throws IOException {
		for (int i= 0; i < files.length; i++) {
			BufferedReader br = new BufferedReader(new FileReader(files[i]));		
			singleOutData thisLineData = null;
			int ts=0; 
			if (i == 0) {
				perfDataChannel1 = new TreeMap<Integer, singleOutData>();
				perfDataChannel1 = saveLineData(br);
			}
			if (i == 1) {
				perfDataChannel2 = new TreeMap<Integer, singleOutData>();
				perfDataChannel2 = saveLineData(br);
			}
			if (i == 2) {
				perfDataChannel3 = new TreeMap<Integer, singleOutData>();
				perfDataChannel3 = saveLineData(br);
			}
			if (i == 3) {
				perfDataChannel4 = new TreeMap<Integer, singleOutData>();
				perfDataChannel4 = saveLineData(br);
			}
		}
	}

	public TreeMap<Integer, singleOutData> saveLineData(BufferedReader br) {
		singleOutData thisLineData = null;
		String[] split; 
		String line;
		TreeMap<Integer, singleOutData> plotData = new TreeMap<Integer, singleOutData>();
		int ts=0; 
		try {
			while ((line = br.readLine()) != null) {
				split = line.split("\t"); 
				if (split.length < 7) {
					return null;
				}
				thisLineData = new singleOutData(
						parseToDouble(split[4])
				);				
				ts++;
				plotData.put(ts, thisLineData);				
			}
		} catch (Exception e) {
			return null;
		}
		return plotData;
	}
	
	public TreeMap<Integer, singleOutData> getPerfDataChannel1() {
		return perfDataChannel1;
	}
	public TreeMap<Integer, singleOutData> getPerfDataChannel2() {
		return perfDataChannel2;
	}
	public TreeMap<Integer, singleOutData> getPerfDataChannel3() {
		return perfDataChannel3;
	}
	public TreeMap<Integer, singleOutData> getPerfDataChannel4() {
		return perfDataChannel4;
	}
	
	public class singleOutData {
		private double thresh;
		
		private singleOutData(double thresh) {
				this.thresh = thresh;
		}
		public double getThresh() {
			return thresh;
		}
	}//end of class singleOutData

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
