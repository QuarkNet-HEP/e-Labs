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

public class TimeOfFlightDataStream {
	String analysisDir;
	double chan1FirstHit, chan2FirstHit, chan3FirstHit, chan4FirstHit;
	TimeDiff timedifference1 = new TimeDiff("red", "0", "1", "ch2-ch1", "circle");
	TimeDiff timedifference2 = new TimeDiff("green", "1", "2", "ch3-ch1", "triangle");
	TimeDiff timedifference3 = new TimeDiff("blue", "2", "3", "ch4-ch1", "square");
	TimeDiff timedifference4 = new TimeDiff("cyan", "3", "4", "ch3-ch2", "diamond");
	TimeDiff timedifference5 = new TimeDiff("black", "4", "5", "ch4-ch2", "cross");
	TimeDiff timedifference6 = new TimeDiff("magenta", "5", "6", "ch4-ch3", "circle");
	List<TimeDiff> tdGroup = new ArrayList<TimeDiff>();
	TreeMap<String, String> channelsHit;
	String outputfile = "";
	String of1, of2, of3, of4, of5, of6;
	String inputfile = "";
	String outputdata = "";
	boolean useLogicModule = false;
	ArrayList<String> channelRequire = new ArrayList<String>();
	ArrayList<String> channelVeto = new ArrayList<String>();
	DecimalFormat f = new DecimalFormat("##.00");
	Integer customIndex = 0;
	
	public TimeOfFlightDataStream (String analysisDir, String chanRequire, String chanVeto) throws Exception {
		long starttime = System.currentTimeMillis();
		this.analysisDir = analysisDir;
		outputfile = analysisDir+"/timeOfFlightPlotData";
		of1 = analysisDir+"/timeOfFlightPlotData1";
		of2 = analysisDir+"/timeOfFlightPlotData2";
		of3 = analysisDir+"/timeOfFlightPlotData3";
		of4 = analysisDir+"/timeOfFlightPlotData4";
		of5 = analysisDir+"/timeOfFlightPlotData5";
		of6 = analysisDir+"/timeOfFlightPlotData6";
		inputfile = analysisDir+"/eventCandidates";
		outputdata = analysisDir+"/timeOfFlightRawData";
		String[] cr = chanRequire.split("\\s");
		String[] cv = chanVeto.split("\\s");
		if ((cr != null && cr.length > 0) || (cv != null && cv.length > 0)) {
			for (int i = 0; i < cr.length; i++) {
				if (!cr[i].trim().equals("")) {
					channelRequire.add(cr[i]);
					useLogicModule = true;
				}
			}
			for (int i = 0; i < cv.length; i++) {
				if (!cv[i].trim().equals("")) {
					channelVeto.add(cv[i]);
					useLogicModule = true;
				}
			}
		}
		try {
			//String debuggingfile = analysisDir+"/timeOfFlightCalculations";
			JsonWriter writer = new JsonWriter(new FileWriter(outputfile));
			JsonWriter wr1 = new JsonWriter(new FileWriter(of1));
			JsonWriter wr2 = new JsonWriter(new FileWriter(of2));
			JsonWriter wr3 = new JsonWriter(new FileWriter(of3));
			JsonWriter wr4 = new JsonWriter(new FileWriter(of4));
			JsonWriter wr5 = new JsonWriter(new FileWriter(of5));
			JsonWriter wr6 = new JsonWriter(new FileWriter(of6));
			BufferedReader br = new BufferedReader(new FileReader(inputfile));
			BufferedWriter bw = new BufferedWriter(new FileWriter(outputdata));
			//BufferedWriter bw = new BufferedWriter(new FileWriter(debuggingfile));
			addObjectsToArray();
			analyzeEventFile(br);
			customIndex = 0;
			saveFileHistogramData(writer);
			customIndex = 0;
			saveIndividualFileHistogramData(wr1,0);
			saveIndividualFileHistogramData(wr2,1);
			saveIndividualFileHistogramData(wr3,2);
			saveIndividualFileHistogramData(wr4,3);
			saveIndividualFileHistogramData(wr5,4);
			saveIndividualFileHistogramData(wr6,5);
			writer.close();
			wr1.close();
			wr2.close();
			wr3.close();
			wr4.close();
			wr5.close();
			wr6.close();
			br.close();
			saveOutputData(bw);
			bw.close();
			long estimatedtime = System.currentTimeMillis() - starttime;
			System.out.println("TOF took: " + String.valueOf(estimatedtime)+"\n");
			//bwraw.close();
		} catch (Exception e) {
			throw e;
		}
	}//end of constructor

	public void addObjectsToArray() {
		tdGroup.add(timedifference1);
		tdGroup.add(timedifference2);
		tdGroup.add(timedifference3);
		tdGroup.add(timedifference4);
		tdGroup.add(timedifference5);
		tdGroup.add(timedifference6);
	}//end of addObjectsToArray

	public List<TimeDiff> getArrays() {
		return tdGroup;
	}//end of getArrays
	
	public void analyzeEventFile(BufferedReader br) throws ElabException {
		String[] split; 
		String line, message;
		String detectorId = "";
		try {
			while ((line = br.readLine()) != null) {
				if (line.startsWith("#")) {
					continue;
				}
				channelsHit = new TreeMap<String, String>();				
				split = line.split("\\s"); 
				if (detectorId.equals("")) {
					String[] parts = split[3].split("\\.");
					detectorId = parts[0];
				}
				String event = split[0];
				String hits = split[1];
				String nanos = split[2];
				//bw.write(line+"\n");
				//get channel values per event
                for (int i = 3; i < split.length; i += 3) {
                    String[] channelPlusId = split[i].split("\\.");
                    if (!channelsHit.containsKey(channelPlusId[1])) {
                    	String jd = split[i+1];
                    	String re = split[i+2];
                        NanoDate nd = ElabUtil.julianToGregorian(Integer
                                .parseInt(jd), parseToDouble(re));   		            
                        String millisecs = String.format("%03d",nd.getMilliSeconds());
                        String microsecs = String.format("%03d",nd.getMicroSeconds());
                        String nanosecs = String.format("%03d",nd.getNanoSeconds());
                        String nanosecsfraction = String.format("%01d", nd.getNanoSecondsFraction());
                        //bw.write(channelPlusId[1] + "jd: "+jd+" "+re+" converted time: "+millisecs+microsecs+nanosecs+"."+nanosecsfraction+"\n");	
                        channelsHit.put(channelPlusId[1], (millisecs+microsecs+nanosecs+"."+nanosecsfraction));
                    }
                }
                //populate time difference lists
                Double fh1 = 0.0;
                Double fh2 = 0.0;
                Double fh3 = 0.0;
                Double fh4 = 0.0;
                //we need to check require/veto for channels
            	boolean validRecord = true;
                if (useLogicModule) {
                	for (int i = 0; i < channelRequire.size(); i++) {
                		if (!channelsHit.containsKey(channelRequire.get(i))) {
                			validRecord = false;
                		}
                	}
                	for (int i = 0; i < channelVeto.size(); i++) {
                		if (channelsHit.containsKey(channelVeto.get(i))) {
                			validRecord = false;
                		}
                	}
                } 
                if (validRecord) {
	                if (channelsHit.containsKey("1")) {
	                	fh1 = parseToDouble(channelsHit.get("1"));
	                }
	                if (channelsHit.containsKey("2")) {
	                	fh2 = parseToDouble(channelsHit.get("2"));
	                }
	                if (channelsHit.containsKey("3")) {
	                	fh3 = parseToDouble(channelsHit.get("3"));
	                }
	                if (channelsHit.containsKey("4")) {
	                	fh4 = parseToDouble(channelsHit.get("4"));
	                }
	                if (fh1 != 0L && fh2 != 0L) {
	                	Double diff = fh2-fh1;
	                	setValues(timedifference1, Double.valueOf(f.format(diff)), "td1: ");
	                }
	                if (fh1 != 0L && fh3 != 0L) {
	                	Double diff = fh3-fh1;                	
	                	setValues(timedifference2, Double.valueOf(f.format(diff)), "td2: ");
	                }
	                if (fh1 != 0L && fh4 != 0L) {
	                	Double diff =fh4-fh1;                	
	                	setValues(timedifference3, Double.valueOf(f.format(diff)), "td3: ");
	                }
	                if (fh2 != 0L && fh3 != 0L) {
	                	Double diff = fh3-fh2;                	                	
	                	setValues(timedifference4, Double.valueOf(f.format(diff)), "td4: ");
	                }
	                if (fh2 != 0L && fh4 != 0L) {
	                	Double diff = fh4-fh2;                	                	
	                   	setValues(timedifference5, Double.valueOf(f.format(diff)), "td5: ");
	                }
	                if (fh3 != 0L && fh4 != 0L) {
	                	Double diff = fh4-fh3;                	                	
	                   	setValues(timedifference6, Double.valueOf(f.format(diff)), "td6: ");
	                }
                }
    			//for (Map.Entry<String, String> e: channelsHit.entrySet()) {
    				//bwraw.write(e.getKey() + ": "+e.getValue()+"\n");
    			//}
    			//bwraw.write("\n");
			}//end of while
			
			int DAQ = Integer.valueOf(detectorId);
			for (int i = 0; i < tdGroup.size(); i++) {
				tdGroup.get(i).calculateNBins();
				tdGroup.get(i).calculateMaxBins();
				if (DAQ < 6000) {
					tdGroup.get(i).setBinValue(0.75);
				} else {
					tdGroup.get(i).setBinValue(1.25);
				}
			}
			
		} catch (Exception e) {
			throw new ElabException("Time Of Flight: analyzeEventFile - "+e.getMessage());
		}
	}//end of analyzeEventFile
	
	public void setValues(TimeDiff td, Double diff, String label) throws ElabException {
		try {
	    	//bw.write(label+String.valueOf(diff)+"\n");
	    	td.add(diff);
			double newminx = diff * 1.0;
			if (newminx < td.getMinX()) {
				td.setMinX(newminx);
			}
			double newmax = diff * 1.0;
			if (newmax > td.getMaxX()) {
				td.setMaxX(newmax);
			}
		} catch (Exception e) {
			throw new ElabException("Time Of Flight: setValues - "+e.getMessage());
		}
	}//end of setValues
	
	public void saveFileHistogramData(JsonWriter writer) throws ElabException {
		try {
			writer.beginObject();
			for (int i = 0; i < tdGroup.size(); i++) {
				if (tdGroup.get(i).getSize() > 0) {
					saveTimeDifference(writer, tdGroup.get(i));
					customIndex++;
				}
			}
			writer.endObject();
		} catch (Exception e) {
			throw new ElabException("Time Of Flight: saveFileHistogramData - "+e.getMessage());
		}				
	}//end of saveFileHistogramData	
	
	public void saveIndividualFileHistogramData(JsonWriter writer, int ndx) throws ElabException {
		try {
			writer.beginObject();
			if (tdGroup.get(ndx).getSize() > 0) {
				saveTimeDifference(writer, tdGroup.get(ndx));
			}
			writer.endObject();
		} catch (Exception e) {
			throw new ElabException("Time Of Flight: saveIndividualFileHistogramData - "+e.getMessage());
		}				
	}//end of saveFileHistogramData	
	
	public void saveTimeDifference(JsonWriter writer, TimeDiff td) throws ElabException {
		try {
			writer.name("td"+td.getName());
			writer.beginObject();
			writer.name("label").value("Time Difference "+td.getLabel());
			writer.name("toggle").value(true);
			if (String.valueOf(customIndex).equals(td.getNdx())) {
				writer.name("idx").value(Integer.parseInt(td.getNdx()));
			} else {
				writer.name("idx").value(String.valueOf(customIndex));				
			}
			writer.name("data");			
			writer.beginArray();
			//for (int i = 0; i < td.getTimeDifference().size(); i++) {
			//	writer.value(td.getTimeDifference().get(i));
			//}
			writer.endArray();
			writer.name("data_original");			
			writer.beginArray();
			for (int i = 0; i < td.getTimeDifference().size(); i++) {
				writer.value(td.getTimeDifference().get(i));
			}
			writer.endArray();
			writer.name("points");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("symbol").value(td.getSymbol());
			writer.name("color").value(td.getColor());
			writer.name("radius").value(1.5);
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			writer.name("show").value(true);
			writer.endObject();			
			writer.name("color").value(td.getColor());
			writer.name("binValue").value(td.getBinValue());
			writer.name("minX").value(td.getMinX());
			writer.name("maxX").value(td.getMaxX());
			writer.name("nBins").value(td.getNBins());
			writer.name("maxBins").value(td.getMaxBins());
			writer.name("bins");
			writer.beginArray();
			for (Double i = Math.floor(td.getMinX()); i < Math.floor(td.getMaxX()+td.getBinValue()); i+=td.getBinValue()) {
				writer.value(i);
			}
			writer.endArray();				
			writer.endObject();
			writer.flush();			
		} catch (Exception e) {
			throw new ElabException("Time Of Flight: saveTimeDifference - "+e.getMessage());
		}		
	}//end of saveTimeDifference

	public void saveOutputData(BufferedWriter bw) throws ElabException {
		try {
			bw.write("Time Difference ch2-ch1,");
			bw.write("Time Difference ch3-ch1,");
			bw.write("Time Difference ch4-ch1,");
			bw.write("Time Difference ch3-ch2,");
			bw.write("Time Difference ch4-ch2,");
			bw.write("Time Difference ch4-ch3\n");
			int largest = 0;
			for (int i = 0; i < tdGroup.size(); i++) {
				if (tdGroup.get(i).getSize() > largest) {
					largest = tdGroup.get(i).getSize();
				}
			}
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
				bw.write("\n");						
			}
		} catch (Exception e) {
			throw new ElabException("Time Of Flight: saveOutputData - "+e.getMessage());
		}
	}//end of saveOutputData
	
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
	
}//end of class