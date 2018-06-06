
/*
 * Created on Jan 1, 2018
 * 		Code to prepare the json delta T object for the chart
 * Edit Peronja: June 5, 2018:
 * 		Updated code based on feedback
 */
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
	DecimalFormat f = new DecimalFormat("##.00");
	List<String> deltaTvalue = new ArrayList<String>();
	double minX, maxX, nBins, maxBins;
	double binValue;
	
	public DeltaTDataStream (String analysisDir) throws Exception {
		long starttime = System.currentTimeMillis();
		this.analysisDir = analysisDir;
		outputfile = analysisDir+"/deltaTHistogram";
		inputfile = analysisDir+"/deltaT";
		minX = maxX = nBins = maxBins = 0.0;
		binValue = 2.0;

		try {
			JsonWriter writer = new JsonWriter(new FileWriter(outputfile));
			BufferedReader br = new BufferedReader(new FileReader(inputfile));
			analyzeInputFile(br);
			saveFileHistogramData(writer);
			writer.close();
			br.close();
			long estimatedtime = System.currentTimeMillis() - starttime;
			System.out.println("Delta T took: " + String.valueOf(estimatedtime)+"\n");
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
				if (!split[4].equals("0,0")) {
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
			}//end of while	
			binValue = (maxX - minX) * 0.05;
			nBins = (maxX - minX) / binValue;
			maxBins = maxX - minX;			
		} catch (Exception e) {
			throw new ElabException("Delta T: analyzeInputFile - "+e.getMessage());
		}
	}//end of analyzeInputFile
	
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
	
}//end of class