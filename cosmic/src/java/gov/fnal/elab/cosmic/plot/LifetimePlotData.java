package gov.fnal.elab.cosmic.plot;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TreeMap;
import java.lang.Math;
import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;


public class LifetimePlotData {

	private TreeMap<Integer, decayLengthData> plotLifetimeData; 
	
	public LifetimePlotData(File file) throws IOException {
			BufferedReader br = new BufferedReader(new FileReader(file));		
			decayLengthData thisLineData = null;
			plotLifetimeData = new TreeMap<Integer, decayLengthData>();
			plotLifetimeData = saveLineData(br);
	}

	public TreeMap<Integer, decayLengthData> saveLineData(BufferedReader br) {
		decayLengthData thisLineData = null;
		String[] split; 
		String line;
		TreeMap<Integer, decayLengthData> plotData = new TreeMap<Integer, decayLengthData>();
		int ts=0; 
		try {
			while ((line = br.readLine()) != null) {
				if (!line.startsWith("#")) {
					split = line.split("\\s");
					if (split.length < 3) {
						return null;
					}
					thisLineData = new decayLengthData(parseToDouble(split[0]),	
													  parseToDouble(split[1]),
													  parseToDouble(split[2])
					);				
					ts++;
					plotData.put(ts, thisLineData);				
				}
			}
		} catch (Exception e) {
			return null;
		}
		return plotData;
	}
	
	public TreeMap<Integer, decayLengthData> getDecayLength() {
		return plotLifetimeData;
	}
	
	public class decayLengthData {
		private double length;
		private double decay;
		private double files;
		private double yError;
		
		private decayLengthData(double length,
						      double decay,
						      double files) {
				this.length = length;
				this.decay = decay;
				this.files = files;
				this.yError = Math.sqrt(decay);
		}

		public double getLength() {
			return length; 
		}
		public double getDecay() {
			return decay; 
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
