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
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.lang.Math;
import java.lang.Object;

import com.google.gson.*;
import com.google.gson.stream.JsonWriter;
import com.google.gson.stream.JsonReader;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;

public class PerformancePlotDataStream {
	private List<Double> perfDataChannel1;
	private List<Double> perfDataChannel2;
	private List<Double> perfDataChannel3;
	private List<Double> perfDataChannel4;
	private Double binValue;
	private Double minX = 0.0;
	private Double maxX = -1.0;
	private Double nBins = -1.0;
	public PerformancePlotDataStream(File[] files, Double binValue, String outputDir) throws IOException {
		String message = "";
		this.binValue = binValue;
		try {
			String filename = outputDir+"/PerformancePlotFlot";
			JsonWriter writer = new JsonWriter(new FileWriter(filename));
			for (int i= 0; i < files.length; i++) {
				BufferedReader br = new BufferedReader(new FileReader(files[i]));
				if (files[i].toString().endsWith("singleOut1")) {
					perfDataChannel1 = new ArrayList<Double>();
					perfDataChannel1 = saveLineData(br);
				}				
				if (files[i].toString().endsWith("singleOut2")) {
					perfDataChannel2 = new ArrayList<Double>();
					perfDataChannel2 = saveLineData(br);
				}
				if (files[i].toString().endsWith("singleOut3")) {
					perfDataChannel3 = new ArrayList<Double>();
					perfDataChannel3 = saveLineData(br);
				}
				if (files[i].toString().endsWith("singleOut4")) {
					perfDataChannel4 = new ArrayList<Double>();
					perfDataChannel4 = saveLineData(br);
				}
			}//end of for loop
			minX = 0.0;
			nBins = (maxX- minX) / binValue;
			saveFileHistogramData(writer);
			writer.close();
		} catch (Exception e) {
			message = e.getMessage();
		}
	}//end of constructor

	public List<Double> saveLineData(BufferedReader br) {
		String[] split; 
		String line;
		List<Double> plotData = new ArrayList<Double>();
		int ts=0; 
		try {
			while ((line = br.readLine()) != null) {
				split = line.split("\t"); 
				if (split.length < 7) {
					return null;
				}
				double thresh = parseToDouble(split[4]);
				plotData.add(thresh);
				//get the max value of the whole set
				if (thresh > maxX) {
					maxX = thresh;
				}
			}
		} catch (Exception e) {
			return null;
		}
		return plotData;
	}

	public void saveFileHistogramData(JsonWriter writer) {
		try {
			writer.beginObject();
			if (perfDataChannel1 != null) {
				saveFileChannel(writer, perfDataChannel1, "red", "1", 0);
			}
			if (perfDataChannel2 != null) {
				saveFileChannel(writer, perfDataChannel2, "#00ff00", "2", 1);
			}
			if (perfDataChannel3 != null) {
				saveFileChannel(writer, perfDataChannel3, "blue", "3", 2);
			}
			if (perfDataChannel4 != null) {
				saveFileChannel(writer, perfDataChannel4, "cyan", "4", 3);
			}
			if (perfDataChannel1 != null) {
				saveFileChannelError(writer, perfDataChannel1, "red", "channel1error", "square", 4);
			}
			if (perfDataChannel2 != null) {
				saveFileChannelError(writer, perfDataChannel2, "#00ff00", "channel2error", "diamond", 5);
			}
			if (perfDataChannel3 != null) {
				saveFileChannelError(writer, perfDataChannel3, "blue", "channel3error", "triangle", 6);
			}
			if (perfDataChannel4 != null) {
				saveFileChannelError(writer, perfDataChannel4, "cyan", "channel4error", "circle", 7);
			}
			writer.name("binValue").value(getBinValue());
			writer.name("minX").value(getMinX());
			writer.name("maxX").value(getMaxX());
			writer.name("nBins").value(getNBins());
			writer.name("bins");
			writer.beginArray();
			for (Double i = Math.floor(minX); i < Math.ceil(maxX); i+=binValue) {
				writer.value(i);
			}
			writer.endArray();
			writer.name("fakeBins");
			writer.beginArray();
			for (Double i = Math.floor(minX); i < Math.ceil(maxX); i+=binValue) {
				writer.value(i+0.00001);
			}
			writer.endArray();
			writer.endObject();
		} catch (Exception e) {
			System.out.println("Performance Serializer: "+e.getMessage());
		}		
		
	}//end of saveFileHistogramData
	
	public void saveFileChannel(JsonWriter writer, List<Double> channel, String color, String name, int ndx) {
		try {
			writer.name("channel"+name);
			writer.beginObject();
			writer.name("label").value("Channel "+name);
			writer.name("data");
			writer.beginArray();
			for (int i = 0; i < channel.size(); i++) {
				writer.value(channel.get(i));
			}			
			writer.endArray();
			writer.name("data_original");
			writer.beginArray();
			for (int i = 0; i < channel.size(); i++) {
				writer.value(channel.get(i));
			}			
			writer.endArray();
			writer.name("shadowSize").value(0);
			writer.name("color").value(color);
			writer.name("xunits").value("nanosecs");
			writer.name("yunits").value("pulses");
			writer.name("idx").value(ndx);
			writer.name("toggle").value(true);
			writer.name("yaxis");
			writer.beginObject();
			writer.name("n").value(1);
			writer.name("position").value("left");
			writer.endObject();
			writer.name("xaxis");
			writer.beginObject();
			writer.name("n").value(1);
			writer.name("position").value("bottom");
			writer.endObject();
			writer.endObject();
			writer.flush();
		} catch (Exception e) {
			System.out.println("Performance Serializer: "+e.getMessage());
		}		
	}//end of saveFileChannel

	public void saveFileChannelError(JsonWriter writer, List<Double> channel, String color, String name, String symbol, int ndx) {
		try {
			writer.name(name);
			writer.beginObject();
			writer.name("label").value(" ");
			writer.name("data");
			writer.beginArray();
			writer.value(0);
			writer.endArray();		
			writer.name("shadowSize").value(0);
			writer.name("color").value(color);
			writer.name("xunits").value("nanosecs");
			writer.name("yunits").value("pulses");
			writer.name("idx").value(ndx);
			writer.name("toggle").value(false);
			writer.name("points");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("errorbars").value("y");
			writer.name("symbol").value(symbol);
			writer.name("color").value(color);
			writer.name("radius").value(0.5);
			writer.name("yerr");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("upperCap").value("-");
			writer.name("lowerCap").value("-");
			writer.name("color").value(color);
			writer.name("radius").value(3);			
			writer.endObject();
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			writer.name("show").value(false);
			writer.endObject();
			writer.endObject();
			writer.flush();
		} catch (Exception e) {
			System.out.println("Performance Stream: "+e.getMessage());
		}		
	}//end of saveFileChannelError
	
	public String getGsonFromJson(String outputDir) {
		String result = "";
		StringBuilder filevalues = new StringBuilder();
		String filename = outputDir+"/PerformancePlotFlot";		
		try {
	        BufferedReader br = new BufferedReader(new FileReader(filename));
	        String line = br.readLine();
	        while (line != null) {
	        	filevalues.append(line);
	        	line = br.readLine();
	        }
			br.close();
		} catch (Exception e) {
			System.out.println("Performance Stream: "+e.getMessage());
		}			
		result = filevalues.toString();
		return result;
	}//end getGsonFromJson
	
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

	public Double getBinValue() {
		return binValue;
	}//end of getBinValue
	
	public Double getMinX() {
		return minX;
	}//end of getMinX
	
	public Double getMaxX() {
		return maxX;
	}//end of getMaxX
	
	public Double getNBins() {
		return nBins;
	}//end of getNBins


}//end of PerformancePlotData
