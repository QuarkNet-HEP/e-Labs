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
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.lang.Math;

import com.google.gson.*;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;


public class PerformancePlotData {
	private JsonArray perfDataChannel1;
	private JsonArray perfDataChannel2;
	private JsonArray perfDataChannel3;
	private JsonArray perfDataChannel4;
	private Double binValue;
	private Double minX = 0.0;
	private Double maxX = -1.0;
	private Double nBins = -1.0;
	
	public PerformancePlotData(File[] files, Double binValue) throws IOException {
		String message = "";
		this.binValue = binValue;
		try {
			for (int i= 0; i < files.length; i++) {
				BufferedReader br = new BufferedReader(new FileReader(files[i]));		
				if (i == 0) {
					perfDataChannel1 = new JsonArray();
					perfDataChannel1 = saveLineData(br);
				}				
				if (i == 1) {
					perfDataChannel2 = new JsonArray();
					perfDataChannel2 = saveLineData(br);
				}
				if (i == 2) {
					perfDataChannel3 = new JsonArray();
					perfDataChannel3 = saveLineData(br);
				}
				if (i == 3) {
					perfDataChannel4 = new JsonArray();
					perfDataChannel4 = saveLineData(br);
				}
			}//end of for loop
			
			minX = 0.0;
			nBins = (maxX- minX) / binValue;
		} catch (Exception e) {
			message = e.getMessage();
		}
	}//end of constructor

	public JsonArray saveLineData(BufferedReader br) {
		String[] split; 
		String line;
		JsonArray plotData = new JsonArray();
		int ts=0; 
		try {
			while ((line = br.readLine()) != null) {
				split = line.split("\t"); 
				if (split.length < 7) {
					return null;
				}
				Double thresh = parseToDouble(split[4]);
				plotData.add(new JsonPrimitive(thresh));
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
	
	public JsonArray getPerfDataChannel1() {
		return perfDataChannel1;
	}
	public JsonArray getPerfDataChannel2() {
		return perfDataChannel2;
	}
	public JsonArray getPerfDataChannel3() {
		return perfDataChannel3;
	}
	public JsonArray getPerfDataChannel4() {
		return perfDataChannel4;
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
