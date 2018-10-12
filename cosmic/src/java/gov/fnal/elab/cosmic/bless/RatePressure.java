package gov.fnal.elab.cosmic.bless;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;
import java.util.TreeMap;

import org.apache.commons.lang.time.DateUtils;

import gov.fnal.elab.Elab;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.TreeSet;
import java.util.*;

import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabMemory;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.util.NanoDate;

import com.google.gson.*;
import com.google.gson.stream.JsonWriter;
import com.google.gson.stream.JsonReader;

public class RatePressure {
	private ArrayList<Long> seconds;
	private ArrayList<Double> trigger;
	private ArrayList<Double> triggerGap;
	private ArrayList<Double> pressure;
	private ArrayList<Double> pressureDistinct;
	private String filename = "";
	private String ratePressureFile = "";
	private String rateAvgPressureFile = "";
	TreeMap<Double, Double> pressureRate = new TreeMap<Double, Double>();
	ElabMemory em;
	Long minXL, maxXL;
	Double binValue;
	Double minX, maxX, nBins, maxBins;
	private int roundedBin;
	private ArrayList<String> defaultHistogramTrigger;
	private ArrayList<String> defaultHistogramPressure;
	private Double maxYaxis = -1.0;
	private Double maxError = -1.0;
	
	//EPeronja: attempt to concatenate a few days together
	public RatePressure(Elab elab, File[] file, Double bV, String[] filenames, String outputDir) throws Exception {
		seconds = new ArrayList<Long>();
		trigger = new ArrayList<Double>();
		triggerGap = new ArrayList<Double>();
		pressure = new ArrayList<Double>();
		defaultHistogramTrigger = new ArrayList<String>();
		defaultHistogramPressure = new ArrayList<String>();
		em = new ElabMemory();
		filename = outputDir+"/RatePressurePlot";
		ratePressureFile = outputDir+"/RatePressureValues";
		rateAvgPressureFile = outputDir+"/RateAvgOverPressureValues";
		minXL = maxXL = 0L;
		binValue = bV;
		
		JsonWriter writer = new JsonWriter(new FileWriter(filename));	
        BufferedWriter bw = new BufferedWriter(new FileWriter(ratePressureFile));
        BufferedWriter bw1 = new BufferedWriter(new FileWriter(rateAvgPressureFile));
		try {
			for (int i = 0; i < file.length; i++) {
				try {				
					BufferedReader br = new BufferedReader(new FileReader(file[i]));
					String line;
					String[] split; 
					Long ts; 
					//get startdate from database
					Timestamp startDate;
					Long secs = 0L;
					try {
						String[] nameParts = filenames[i].split("\\.");
						String filedate = nameParts[1]+nameParts[2];
						SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
						Date date = sdf.parse(filedate);
						sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
						String dateUTC = sdf.format(date);
						Date newDate = sdf.parse(dateUTC);
						secs = newDate.getTime();
					} catch (Exception e) {	
						String message = e.toString();
					}

					while ((line = br.readLine()) != null) {
						if (line.startsWith("#")) {
							continue; // comment line
						}
						else {
							split = line.split("\t"); 
							if (split.length != 15) {
								throw new IOException(file[i].getName() + " has malformed data. "); 
							}
							trigger.add(parseToDouble(split[9]));
							pressure.add(parseToDouble(split[11]));
							ts = secs + (parseToLong(split[0]) * 1000);
							seconds.add(ts);
							
							Long newminx = ts;
							if (minXL == 0L) {
								minXL = newminx;
							} else if (newminx < minXL) {
								minXL = newminx;
							}
							Long newmaxx = ts;
							if (maxXL == 0L) {
								maxXL = newmaxx;
							} else if (newmaxx > maxXL) {
								maxXL = newmaxx;
							}

						}
					}
					br.close();
				} catch (Exception ex) {
					throw ex;
				}
                em.refresh();
                if (em.isCritical()) {
                	String emailMessage = 	"The code stopped processing the bless files in Rate vs Pressure\n"+
                							"at: "+file[i]+"\n"+
                							em.getMemoryDetails();
                   	Exception e = new Exception("Heap memory left: "+String.valueOf(em.getFreeMemory())+"MB"+
                                   				"We stopped processing the bless files.<br/>" +
                                   				"Please select fewer files or files with fewer events.");
                	throw e;
                }
			}//end of for loop
			seconds.add(0L);
			trigger.add(0.0);
			pressure.add(0.0);
			minX = minXL.doubleValue() - (binValue * DateUtils.MILLIS_PER_SECOND);
			maxX = maxXL.doubleValue() + (binValue * DateUtils.MILLIS_PER_SECOND * 2);
			nBins = (maxX - minX) / DateUtils.MILLIS_PER_SECOND / binValue;
			roundedBin = (int) Math.ceil(nBins);
			maxBins = maxX - minX;
			prepareDefaultHistogram(trigger, defaultHistogramTrigger);
			prepareDefaultHistogram(pressure, defaultHistogramPressure);
			saveRatePressureValues(bw);
			buildPressureValuePlot();
			savePressureValuePlot(bw1);
			saveFluxRatePressure(writer);
			writer.close();
			bw.close();
			bw1.close();
		} catch (Exception e) {
			throw e;
		}
	}//end of Blessdata for concatenated files

	public void savePressureValuePlot(BufferedWriter bw1) throws ElabException {
		try {
			bw1.write("#Pressure\tAverage Rate\n");
			for(Map.Entry<Double,Double> entry : pressureRate.entrySet()) {
				bw1.write(String.valueOf(entry.getKey()));
				bw1.write("\t");
				bw1.write(String.valueOf(entry.getValue()));
				bw1.write("\n");
			}
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}
	}//end of saveRatePressureValues
	
	void buildPressureValuePlot() throws ElabException {
		ArrayList<Double> pressureDistinct = new ArrayList<Double>();
		for (int i = 0; i < pressure.size(); i++) {
			if (!pressureDistinct.contains(pressure.get(i)) && pressure.get(i) > 0.0) {
				pressureDistinct.add(pressure.get(i));
			}		
		}
		
		//loop through each
		for (int i = 0; i < pressureDistinct.size(); i++) {
			Double rateSum = 0.0;
			Double rateN = 0.0;
			for (int j = 0; j < pressure.size(); j++) {
				if (pressureDistinct.get(i) == pressure.get(j)) {
					rateSum += trigger.get(j);
					rateN += 1.0;
				}
			}
			if (rateN > 0) {
				pressureRate.put(pressureDistinct.get(i), rateSum / rateN);
			}
		}

	}// end of buildPressureValuePlot
	
	//prepare the default Histogram to be displayed
 	public void prepareDefaultHistogram(ArrayList<Double> data, ArrayList<String> defaultHistogram) throws ElabException {
 		try {
	        //BufferedWriter report = new BufferedWriter(new FileWriter("/users/eperonja/ep_home/ep_rate_vs_pressure/javaOutput.txt"));
	 		int[] frequency = new int[roundedBin];
	 		double[] values = new double[roundedBin]; 
	 		double secsToPartialDay = binValue.intValue() * DateUtils.MILLIS_PER_SECOND;
	 		Double[] timeGap = new Double[data.size()];
	 		Arrays.fill(timeGap, 0.0);
	 		double stTimeDiffAvg = 0.0;
	 		triggerGap.add(0.0);
	 		if (data != null) {
	 			for (int i = 0; i < data.size()-1; i++) {
	 				Double bin = 0.0;
	 				Double nextBin = 0.0;
 					bin = (seconds.get(i).doubleValue() - minX) / secsToPartialDay;
	 				nextBin = (seconds.get(i+1) - minX) / secsToPartialDay;
	 				timeGap[i+1] = (seconds.get(i+1).doubleValue() - seconds.get(i).doubleValue()) / DateUtils.MILLIS_PER_SECOND;
	 				triggerGap.add(timeGap[i+1]);
	 				//to test intervals later
	 				if (stTimeDiffAvg == 0.0) {
	 					stTimeDiffAvg = timeGap[i+1];
	 				}
	 				if (bin.intValue() < 0) {}
	 				else if (bin.intValue() >= roundedBin) {}
	 				else {
	 					frequency[bin.intValue()] += 1;
	 				}
	 				if ((nextBin.intValue() - bin.intValue()) > 1) {
	 					frequency[bin.intValue()] += 0;
	 				}
	 				if (i+1 == data.size()) {
	 					frequency[bin.intValue()] += 1;	 					
	 				}
	 			}
	 		}
	 		Double[] binAverageRate = new Double[roundedBin];
	 		Arrays.fill(binAverageRate, 0.0);
	 		Double[] binAverageRateError = new Double[roundedBin];
	 		Arrays.fill(binAverageRateError, 0.0);
	 		Double[] binMillis = new Double[roundedBin];
			double halfBin = binValue * DateUtils.MILLIS_PER_SECOND / 2.0;
	 		int ndx = 0;
	 		for (Double i = Math.floor(minX); i < Math.ceil(maxX) && ndx < roundedBin; i+=(binValue * DateUtils.MILLIS_PER_SECOND)) {
				binMillis[ndx] = i+halfBin+0.00001;
				ndx += 1;
			}

 			//travel through frequency
 			int dataPointer = 0;
	 		for (int i = 0; i < frequency.length; i++) {
	 			//travel through data to get averages
	 			double frequencySum = 0.0;
	 			double frequencyAvg = 0.0;
	 			double errorSum = 0.0;
	 			double errorN = 0;
	 			if (frequency[i] > 0.0) {
		 			for (int j = 0; j < frequency[i]; j++) {
		 				frequencySum += data.get(j + dataPointer);
		 				//we collect the data for the error calculation
		 				if (j == 0 && frequency[i-1] == 0.00) {
			 				//clear the first gap, it is meaningless
		 					timeGap[j+dataPointer] = 0.0;
		 				}
		 				if (timeGap[j+dataPointer] > 0 ) {
		 					errorSum += data.get(j + dataPointer);
		 					errorN += 1.0;
		 				} else {
		 					errorSum += 0.0;
		 					errorN += 0.0;
		 				}
		 			}
	 				dataPointer += frequency[i];
	 				if (frequency[i] > 0) {
	 					frequencyAvg = frequencySum / frequency[i];
	 				}
		 			binAverageRate[i] = frequencyAvg;
		 			//calculate error
		 			if (errorN > 0) {
		 				binAverageRateError[i] = Math.sqrt(errorSum) / errorN;
		 			} 
	 			}
	 			//report.write(String.valueOf(i)+","+String.valueOf(frequencyAvg)+","+String.valueOf(frequency[i])+"\n");
	 		}

	 		for (int i = 0; i < frequency.length; i++) {
	 			if (binMillis[i] > 0 && binAverageRate[i] > 0 && binValue > 0 && frequency[i] > 1) {
	 				double xValue = binMillis[i];
		 			double yValue = binAverageRate[i];
		 			double error = binAverageRateError[i];	
		 			defaultHistogram.add(String.valueOf(xValue)+","+String.valueOf(yValue)+","+String.valueOf(error));
//		 			defaultHistogram.add(String.valueOf(xValue)+","+String.valueOf(yValue));
	 			}
	 		}
	 		//report.close();
 		} catch (Exception e) {
 			throw new ElabException("RatePressure: Exception in prepareDefaultHistogram: "+e.getMessage());
 		}
 	}//end of prepareDefaultHistogram

	public void saveRatePressureValues(BufferedWriter bw) throws ElabException {
		try {
			bw.write("#Seconds\tTrigger\tTimeGap\tPressure\n");
			for (int i = 0; i < trigger.size(); i++) {
				if (seconds.get(i) > 0L) {
					bw.write(seconds.get(i).toString());
					bw.write("\t");
					bw.write(trigger.get(i).toString());
					bw.write("\t");
					bw.write(triggerGap.get(i).toString());
					bw.write("\t");
					bw.write(pressure.get(i).toString());
					bw.write("\n");
				}
			}
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}
	}//end of saveRatePressureValues
	
	public void saveFluxRatePressure(JsonWriter writer) throws ElabException {
		try {
			writer.beginObject();
			saveData(writer, seconds, defaultHistogramTrigger, trigger, "magenta", "trigger", "Trigger", "circle", 0, false, true);
			saveData(writer, seconds, defaultHistogramPressure, pressure, "black", "pressure", "Pressure", "circle", 0, true, false);
			saveRatePressure(writer);
			writer.endObject();
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}				
	}//end of saveFluxRatePressure
	
	public void saveRatePressure(JsonWriter writer) throws ElabException {
		try {
			writer.name("ratepressure");
			writer.beginObject();
			writer.name("label").value("ratepressure");
			writer.name("data");
			writer.beginArray();
			for(Map.Entry<Double,Double> entry : pressureRate.entrySet()) {
				writer.beginArray();
				writer.value(entry.getKey());
				writer.value(entry.getValue());
				writer.endArray();
			}
			writer.endArray();
			writer.name("shadowSize").value(0);
			writer.name("color").value("red");
			writer.name("idx").value(3);
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
			writer.name("points");
			writer.beginObject();
			writer.name("errorbars").value("n");				
			writer.name("show").value(true);
			writer.name("symbol").value("triangle");
			writer.name("color").value("red");
			writer.name("radius").value(1.5);
			writer.name("yerr");
			writer.beginObject();
			writer.name("show").value(false);
			writer.name("upperCap").value("-");
			writer.name("lowerCap").value("-");
			writer.name("color").value("red");
			writer.name("radius").value(1.5);			
			writer.endObject();
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			writer.name("show").value(false);
			writer.endObject();
			writer.endObject();
			writer.flush();			
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}		
		
	}
	
	public void saveData(JsonWriter writer, List<Long> seconds, ArrayList<String> defaultHistogram, List<Double> data, String color, String name, String label, String symbol, int ndx, boolean line, boolean errorCheck) throws ElabException {
		try {
			writer.name(name);
			writer.beginObject();
			writer.name("label").value(label);
			writer.name("data");
			writer.beginArray();
			for (int i = 0; i < defaultHistogram.size(); i++) {
				writer.beginArray();
				String[] value = defaultHistogram.get(i).split(",");
				Double x = Double.parseDouble(value[0]);
				Double y = Double.parseDouble(value[1]);
				Double e = 0.0;
				if (errorCheck) {
					e = Double.parseDouble(value[2]);
				}
				writer.value(x.longValue());
				if (y != 0) {
					writer.value(y);
					if (errorCheck) {
						writer.value(e);
					}
				} else {
					writer.nullValue();
					if (errorCheck) {
						writer.nullValue();
					}
				}				
				writer.endArray();
			}
			writer.endArray();
			writer.name("data_original");
			writer.beginArray();
			for (int i = 0; i < data.size(); i++) {
				writer.beginArray();
				writer.value(seconds.get(i));
				writer.value(data.get(i));
				if (errorCheck) {
					writer.value(triggerGap.get(i));
				}
				writer.endArray();
			}			
			writer.endArray();
			writer.name("shadowSize").value(0);
			writer.name("color").value(color);
			writer.name("idx").value(ndx);
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
			writer.name("points");
			writer.beginObject();
			if (errorCheck) {
				writer.name("errorbars").value("y");
				writer.name("show").value(true);
			} else {
				writer.name("errorbars").value("n");				
				writer.name("show").value(false);
			}
			writer.name("symbol").value(symbol);
			writer.name("color").value(color);
			writer.name("radius").value(1.5);
			writer.name("yerr");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("upperCap").value("-");
			writer.name("lowerCap").value("-");
			writer.name("color").value(color);
			writer.name("radius").value(1.5);			
			writer.endObject();
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			if (line) {
				writer.name("show").value(true);
			} else {
				writer.name("show").value(false);
			}
			writer.endObject();
			writer.name("binValue").value(binValue);
			writer.name("minX").value(minX);
			writer.name("maxX").value(maxX);
			writer.name("nBins").value(roundedBin);
			writer.name("maxBins").value(maxBins);
			writer.name("bins");
			writer.beginArray();
			for (Double i = Math.floor(minX); i < Math.floor(maxX+binValue); i+=binValue) {
				writer.value(i);
			}
			writer.endArray();				
			writer.endObject();
			writer.flush();			
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}		
	}//end of saveData
	
	//EPeronja-02/12/2013: Bug472- added to check for null values which will break the plotting code
	public int parseToInt(String split)
	{
		int result = 0;
		try{
			result = Integer.parseInt(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of parseToInt

	//EPeronja-02/12/2013: Bug472- added to check for null values which will break the plotting code
	public Long parseToLong(String split)
	{
		Long result = 0L;
		try{
			result = Long.parseLong(split);
		} catch (NumberFormatException e) {
			result = 0L;
		}
		return result;
	}//end of parseToLong
	
    //EPeronja-02/12/2013: Bug472- added to check for null values which will break the plotting code	
	public double parseToDouble(String split)
	{
		double result = 0;
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of partToDouble
	
}
