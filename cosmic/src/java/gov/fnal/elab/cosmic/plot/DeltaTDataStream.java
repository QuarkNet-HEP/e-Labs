package gov.fnal.elab.cosmic.plot;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.TreeMap;
import java.lang.Math;
import java.lang.Object;

import org.apache.commons.lang.time.DateFormatUtils;

import com.google.gson.*;
import com.google.gson.stream.JsonWriter;
import com.google.gson.stream.JsonReader;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.util.NanoDate;

public class DeltaTDataStream {
	String analysisDir;
	String outputfile = "";
	String inputfile = "";
	//String outputdata = "";
	DecimalFormat f = new DecimalFormat("##.00");
	List<String> deltaTvalue = new ArrayList<String>();
	double minX, maxX, nBins, maxBins;
	double binValue;
	
	public DeltaTDataStream (String analysisDir) throws Exception {
		long starttime = System.currentTimeMillis();
		this.analysisDir = analysisDir;
		outputfile = analysisDir+"/deltaTHistogram";
		inputfile = analysisDir+"/deltaT";
		//outputdata = analysisDir+"/deltaTRawData";
		minX = maxX = nBins = maxBins = 0.0;
		binValue = 2.0;

		try {
			//String debuggingfile = analysisDir+"/timeOfFlightCalculations";
			JsonWriter writer = new JsonWriter(new FileWriter(outputfile));
			BufferedReader br = new BufferedReader(new FileReader(inputfile));
			//BufferedWriter bw = new BufferedWriter(new FileWriter(outputdata));
			//BufferedWriter bw = new BufferedWriter(new FileWriter(debuggingfile));
			analyzeInputFile(br);
			saveFileHistogramData(writer);
			writer.close();
			br.close();
			//saveOutputData(bw);
			//bw.close();
			long estimatedtime = System.currentTimeMillis() - starttime;
			System.out.println("Delta T took: " + String.valueOf(estimatedtime)+"\n");
			//bwraw.close();
		} catch (Exception e) {
			throw e;
		}
	}//end of constructor

	public void analyzeInputFile(BufferedReader br) throws ElabException {
		String[] split; 
		String line, message;
		try {
			while ((line = br.readLine()) != null) {
				if (line.startsWith("#")) {
					continue;
				}
				split = line.split(","); 
				if (!split[4].equals("0.0")) {
					deltaTvalue.add(split[4]);
					double newminx = Double.parseDouble(split[4]) * 1.0;
					if (minX == 0.0) {
						minX = newminx;
					} else if (newminx < minX) {
						minX = newminx;
					}
					double newmaxx = Double.parseDouble(split[4]) * 1.0;
					if (maxX == 0.0 ) {
						maxX = newmaxx;
					} else if (newmaxx > maxX) {
						maxX = newmaxx;
					}
				}
				//bw.write(line+"\n");
    			//bwraw.write("\n");
			}//end of while	
			binValue = (maxX - minX) * 0.03;
			nBins = (maxX - minX) / binValue;
			maxBins = maxX - minX;			
		} catch (Exception e) {
			throw new ElabException("Delta T: analyzeInputFile - "+e.getMessage());
		}
	}//end of analyzeEventFile
	
	public void saveFileHistogramData(JsonWriter writer) throws ElabException {
		try {
			writer.beginObject();
			writer.name("tdDeltaT");
			writer.beginObject();
			writer.name("label").value("Delta T Histogram");
			writer.name("toggle").value(true);
			writer.name("idx").value(String.valueOf(0));				
			writer.name("data");			
			writer.beginArray();
			writer.endArray();
			writer.name("data_original");			
			writer.beginArray();
			for (int i = 0; i < deltaTvalue.size(); i++) {
				writer.value(deltaTvalue.get(i));
			}
			writer.endArray();
			writer.name("points");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("symbol").value("circle");
			writer.name("color").value("blue");
			writer.name("radius").value(1.5);
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			writer.name("show").value(true);
			writer.endObject();			
			writer.name("color").value("blue");
			writer.name("binValue").value(binValue);
			writer.name("minX").value(minX);
			writer.name("maxX").value(maxX);
			writer.name("nBins").value(nBins);
			writer.name("maxBins").value(maxBins);
			writer.name("bins");
			writer.beginArray();
			for (Double i = Math.floor(minX); i < Math.floor(maxX+binValue); i+=binValue) {
				writer.value(i);
			}
			writer.endArray();				
			writer.endObject();
			writer.flush();			
			writer.endObject();
		} catch (Exception e) {
			throw new ElabException("Delta T: saveFileHistogramData - "+e.getMessage());
		}				
	}//end of saveFileHistogramData	
	
	//public void saveOutputData(BufferedWriter bw) throws ElabException {
	//	try {
	//		bw.write("Delta T");
			/*
			int largest = 0;
			for (int x = 0; x < largest; x++) {
				for (int y = 0; y < tdGroup.size(); y++) {
					if (y < tdGroup.size()-1) {
						if (x < tdGroup.get(y).getSize()) {
							bw.write(String.valueOf(tdGroup.get(y).getTimeDifference().get(x))+",");						
						} else {
							bw.write(",");						
						}
					} else {
						if (x < tdGroup.get(y).getSize()) {
							bw.write(String.valueOf(tdGroup.get(y).getTimeDifference().get(x)));						
						} 
					}
				}
			}
			*/						
	//		bw.write("\n");
	//	} catch (Exception e) {
	//		throw new ElabException("Delta T: saveOutputData - "+e.getMessage());
	//	}
	//}//end of saveOutputData

	/*
	public Long parseToLong(String longvalue)
	{
		Long result = 0L;
		try{
			result = Long.valueOf(longvalue);
		} catch (NumberFormatException e) {
			result = 0L;
		}
		return result;
	}//end of parseToInt	
	public double parseToDouble(String doubleValue)
	{
		double result = 0;
		try {
			result = Double.parseDouble(doubleValue);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of parseToDouble	

	public class TimeDiff {
		List<Double> timeDifference;
		Double binValue, minX, maxX, nBins, maxBins;
		String color, ndx, name, label, symbol;
		
		public TimeDiff(String color, String ndx, String name, String label, String symbol) {
			timeDifference = new ArrayList<Double>();
			minX = maxX = nBins = maxBins = 0.0;
			binValue = 2.0;
			this.color = color;
			this.ndx = ndx;
			this.name = name;
			this.label = label;
			this.symbol = symbol;
		}//end of constructor
	
		public int getSize() {
			return timeDifference.size();
		}
		public void calculateNBins() {
			nBins = (maxX - minX) / binValue;
		}
		
		public void calculateMaxBins() {
			maxBins = maxX - minX;
		}
		
		public void add(Double value) {
			timeDifference.add(value);
		}
		
		public void setColor(String color) {
			this.color = color;
		}
		public String getColor() {
			return color;
		}
		
		public void setNdx(String ndx) {
			this.ndx = ndx;
		}
		public String getNdx() {
			return ndx;
		}
		
		public void setName(String name) {
			this.name = name;
		}
		public String getName() {
			return name;
		}

		public void setLabel(String label) {
			this.label = label;
		}
		public String getLabel() {
			return label;
		}
		
		public void setSymbol(String symbol) {
			this.symbol = symbol;
		}
		public String getSymbol() {
			return symbol;
		}
		
		public void setTimeDifference(List<Double> timeDifference) {
			this.timeDifference = timeDifference;
		}
		public List<Double> getTimeDifference() {
			return timeDifference;
		}
		
		public void setBinValue(Double binValue) {
			this.binValue = binValue;
		}
		public Double getBinValue() {
			return binValue;
		}
	
		public void setMinX(Double minX) {
			this.minX = minX;
		}
		public Double getMinX() {
			return minX;
		}
	
		public void setMaxX(Double maxX) {
			this.maxX = maxX;
		}
		public Double getMaxX() {
			return maxX;
		}
		
		public void setNBins(Double nBins) {
			this.nBins = nBins;
		}
		public Double getNBins() {
			return nBins;
		}
			
		public void setMaxBins(Double maxBins) {
			this.maxBins = maxBins;
		}
		public Double getMaxBins() {
			return maxBins;
		}
		
	}//end of TimeDiff class
	*/
}//end of class