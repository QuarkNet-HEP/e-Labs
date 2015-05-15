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
	
	public TimeOfFlightDataStream (String analysisDir) throws IOException {
		this.analysisDir = analysisDir;
		String message = "";
		try {
			String outputfile = analysisDir+"/timeOfFlightPlotData";
			String inputfile = analysisDir+"/eventCandidates";
			String rawdatafile = analysisDir+"/timeOfFlightRawData";
			String debuggingfile = analysisDir+"/timeOfFlightCalculations";
			JsonWriter writer = new JsonWriter(new FileWriter(outputfile));
			BufferedReader br = new BufferedReader(new FileReader(inputfile));
			BufferedWriter bw = new BufferedWriter(new FileWriter(debuggingfile));
			BufferedWriter bwraw = new BufferedWriter(new FileWriter(rawdatafile));
			addObjectsToArray();
			analyzeEventFile(br, bw, bwraw);
			calculateStats(bw);
			saveFileHistogramData(writer, bw);
			writer.close();
			br.close();
			bw.close();
			bwraw.close();
		} catch (Exception e) {
			message = e.getMessage();
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
	
	public void analyzeEventFile(BufferedReader br, BufferedWriter bw, BufferedWriter bwraw) {
		String[] split; 
		String line, message;
		try {
			while ((line = br.readLine()) != null) {
				if (line.startsWith("#")) {
					continue;
				}
				channelsHit = new TreeMap<String, String>();				
				split = line.split("\\s"); 
				String event = split[0];
				String hits = split[1];
				String nanos = split[2];
				bw.write(line+"\n");
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
                        bw.write(channelPlusId[1] + "jd: "+jd+" "+re+" converted time: "+millisecs+microsecs+nanosecs+"\n");	
                        channelsHit.put(channelPlusId[1], (millisecs+microsecs+nanosecs));
                    }
                }
                //populate time difference lists
                Long fh1 = 0L;
                Long fh2 = 0L;
                Long fh3 = 0L;
                Long fh4 = 0L;
                if (channelsHit.containsKey("1")) {
                	fh1 = parseToLong(channelsHit.get("1"));
                }
                if (channelsHit.containsKey("2")) {
                	fh2 = parseToLong(channelsHit.get("2"));
                }
                if (channelsHit.containsKey("3")) {
                	fh3 = parseToLong(channelsHit.get("3"));
                }
                if (channelsHit.containsKey("4")) {
                	fh4 = parseToLong(channelsHit.get("4"));
                }
                if (fh1 != 0L && fh2 != 0L) {
                	Long diff = fh2-fh1;
                	setValues(timedifference1, diff, "td1: ", bw);
                }
                if (fh1 != 0L && fh3 != 0L) {
                	Long diff = fh3-fh1;                	
                	setValues(timedifference2, diff, "td2: ", bw);
                }
                if (fh1 != 0L && fh4 != 0L) {
                	Long diff =fh4-fh1;                	
                	setValues(timedifference3, diff, "td3: ", bw);
                }
                if (fh2 != 0L && fh3 != 0L) {
                	Long diff = fh3-fh2;                	                	
                	setValues(timedifference4, diff, "td4: ", bw);
                }
                if (fh2 != 0L && fh4 != 0L) {
                	Long diff = fh4-fh2;                	                	
                   	setValues(timedifference5, diff, "td5: ", bw);
                }
                if (fh3 != 0L && fh4 != 0L) {
                	Long diff = fh4-fh3;                	                	
                   	setValues(timedifference6, diff, "td6: ", bw);
                }
    			for (Map.Entry<String, String> e: channelsHit.entrySet()) {
    				bwraw.write(e.getKey() + ": "+e.getValue()+"\n");
    			}
    			bwraw.write("\n");
			}//end of while
			
			for (int i = 0; i < tdGroup.size(); i++) {
				tdGroup.get(i).calculateNBins();
				tdGroup.get(i).calculateMaxBins();
			}
			
		} catch (Exception e) {
			message = e.getMessage();
		}
	}//end of analyzeEventFile
	
	public void setValues(TimeDiff td, Long diff, String label, BufferedWriter bw) {
		String message = "";
		try {
	    	bw.write(label+String.valueOf(diff)+"\n");
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
			message = e.getMessage();			
		}
	}//end of setValues
	
	public void calculateStats(BufferedWriter bw) {
		for (int i = 0; i < tdGroup.size(); i++) {
			tdGroup.get(i).calculateStats();
		}
	}//end of calculateStats

	public void saveFileHistogramData(JsonWriter writer, BufferedWriter bw) {
		try {
			writer.beginObject();
			for (int i = 0; i < tdGroup.size(); i++) {
				if (tdGroup.get(i).getSize() > 0) {
					saveTimeDifference(writer, tdGroup.get(i));
				}
			}
			writer.endObject();
		} catch (Exception e) {
			System.out.println("Time of Flight: "+e.getMessage());
		}		
		
	}//end of saveFileHistogramData	

	public void saveTimeDifference(JsonWriter writer, TimeDiff td) {
		try {
			writer.name("timediff"+td.getName());
			writer.beginObject();
			writer.name("label").value("Time Difference "+td.getLabel());
			writer.name("toggle").value(true);
			writer.name("idx").value(Integer.parseInt(td.getNdx()));
			writer.name("mean").value(td.getMean());
			writer.name("stddev").value(td.getStdDev());
			writer.name("data");			
			writer.beginArray();
			for (int i = 0; i < td.getTimeDifference().size(); i++) {
				writer.value(td.getTimeDifference().get(i));
			}
			writer.endArray();
			writer.name("data_original");			
			writer.beginArray();
			for (int i = 0; i < td.getTimeDifference().size(); i++) {
				writer.value(td.getTimeDifference().get(i));
			}
			writer.endArray();
			writer.name("numberOfEntries").value(td.getTimeDifference().size());
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
			for (Double i = Math.floor(td.getMinX()); i < Math.ceil(td.getMaxX()); i+=td.getBinValue()) {
				writer.value(i);
			}
			writer.endArray();				
			writer.endObject();
			writer.flush();			
		} catch (Exception e) {
			System.out.println("Time of Flight: "+e.getMessage());
		}		
	}//end of saveTimeDifference

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
		List<Long> timeDifference;
		Double binValue, minX, maxX, nBins, mean, stddev, maxBins, sumsquared, sum;
		String color, ndx, name, label, symbol;
		
		public TimeDiff(String color, String ndx, String name, String label, String symbol) {
			timeDifference = new ArrayList<Long>();
			minX = maxX = nBins = mean = stddev = maxBins = sum = sumsquared = 0.0;
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
		
		public void calculateStats() {
			for (int i = 0; i < timeDifference.size(); i++) {
				sum += timeDifference.get(i);
				sumsquared += (timeDifference.get(i)*timeDifference.get(i));
			}
			mean = sum/timeDifference.size();
			stddev = Math.sqrt(sumsquared/timeDifference.size() - mean*mean);
		}

		public void add(Long value) {
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
		
		public void setTimeDifference(List<Long> timeDifference) {
			this.timeDifference = timeDifference;
		}
		public List<Long> getTimeDifference() {
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
		
		public void setMean(Double mean) {
			this.mean = mean;
		}
		public Double getMean() {
			return mean;
		}
		
		public void setStdDev(Double stddev) {
			this.stddev = stddev;
		}
		public Double getStdDev() {
			return stddev;
		}
		
		public void setMaxBins(Double maxBins) {
			this.maxBins = maxBins;
		}
		public Double getMaxBins() {
			return maxBins;
		}
		
	}//end of TimeDiff class
	
}//end of class