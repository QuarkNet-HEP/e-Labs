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

import java.text.DecimalFormat;
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
	private ArrayList<Double> trigger, correctedTrigger, triggerGap;
	private ArrayList<Double> pressure, pressureDistinct;
	private ArrayList<Double> validTrigger, validTriggerGap;
	private ArrayList<Double> validPressure;
	private ArrayList<Double> allTriggerSinglePressure;
	private String filename, ratePressureFile, rateAvgPressureFile, rateCorrectionFile, ratePressureSteps;
	int[] frequency;
	TreeMap<Double, Double> pressureRate = new TreeMap<Double, Double>();
	TreeMap<Double, Double> pressureRate1 = new TreeMap<Double, Double>();
	TreeMap<Double, Double> pressureRateError = new TreeMap<Double, Double>();
	TreeMap<Double, Double> pressureRateError1 = new TreeMap<Double, Double>();
	TreeMap<Double, Double> rateCorrectionWithoutPressure = new TreeMap<Double, Double>();
	TreeMap<Double, Integer> triggerSinglePressureFrequency = new TreeMap<Double, Integer>();
	ElabMemory em;
	Long minXL, maxXL;
	Double binValue;
	Double minX, maxX, minY, maxY, nBins, maxBins;
	double medianKey, medianError;
	private int roundedBin;
	private ArrayList<String> defaultHistogramTrigger;
	private ArrayList<String> defaultHistogramCorrectedTrigger;
	private ArrayList<String> defaultHistogramPressure;
	private Double maxYaxis = -1.0;
	private Double maxError = -1.0;
	
	//EPeronja: calculate Rate vs Pressure from Flux Study and bless files
	public RatePressure(Elab elab, File[] file, Double bV, String[] filenames, String outputDir) throws Exception {
		seconds = new ArrayList<Long>();
		trigger = new ArrayList<Double>();
		correctedTrigger = new ArrayList<Double>();
		triggerGap = new ArrayList<Double>();
		pressure = new ArrayList<Double>();
		validTrigger = new ArrayList<Double>();
		validTriggerGap = new ArrayList<Double>();
		validPressure = new ArrayList<Double>();
		allTriggerSinglePressure = new ArrayList<Double>();
		//EPeronja: to get the data ready for the json files
		defaultHistogramTrigger = new ArrayList<String>();
		defaultHistogramCorrectedTrigger = new ArrayList<String>();
		defaultHistogramPressure = new ArrayList<String>();
		em = new ElabMemory();
		//EPeronja: output files
		filename = outputDir+"/RatePressureFlotPlot";
		ratePressureFile = outputDir+"/RatePressureValues";
		rateAvgPressureFile = outputDir+"/RateAvgOverPressureValues";
		rateCorrectionFile = outputDir+"/RateCorrectionTable";
		ratePressureSteps = outputDir+"/RatePressureSteps";
		minXL = maxXL = 0L;
		binValue = bV;
		
		JsonWriter writer = new JsonWriter(new FileWriter(filename));	
        BufferedWriter bw = new BufferedWriter(new FileWriter(ratePressureFile));
        BufferedWriter bw1 = new BufferedWriter(new FileWriter(rateAvgPressureFile));
        BufferedWriter bw2 = new BufferedWriter(new FileWriter(rateCorrectionFile));
        BufferedWriter bw3 = new BufferedWriter(new FileWriter(ratePressureSteps));
		try {
			for (int i = 0; i < file.length; i++) {
				try {
					// Read bless files
					BufferedReader br = new BufferedReader(new FileReader(file[i]));
					String line;
					String[] split; 
					Long ts; 
					//get startdate from filename
					Timestamp startDate;
					Long secs = 0L;
					try {
						//EPeronja: this code will figure out the date of these files so 
						//we can add the seconds from the bless files - needed for potting
						//several bless files concatenated
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
					//start reading lines from a single bless file
					while ((line = br.readLine()) != null) {
						if (line.startsWith("#")) {
							continue; // comment line
						}
						else {
							split = line.split("\t"); 
							if (split.length != 15) {
								throw new IOException(file[i].getName() + " has malformed data. "); 
							}
							//parse and store data for later use
							trigger.add(parseToDouble(split[9]));
							validTrigger.add(parseToDouble(split[9]));
							correctedTrigger.add(parseToDouble(split[9]));
							pressure.add(parseToDouble(split[11]));
							validPressure.add(parseToDouble(split[11]));
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
			validTrigger.add(0.0);
			correctedTrigger.add(0.0);
			pressure.add(0.0);
			validPressure.add(0.0);
			//get some values for the plot
			minX = minXL.doubleValue() - (binValue * DateUtils.MILLIS_PER_SECOND);
			maxX = maxXL.doubleValue() + (binValue * DateUtils.MILLIS_PER_SECOND * 2);
			nBins = (maxX - minX) / DateUtils.MILLIS_PER_SECOND / binValue;
			roundedBin = (int) Math.ceil(nBins);
			maxBins = maxX - minX;
	 		frequency = new int[roundedBin];
			prepareValidData(bw3);
			prepareDefaultHistogram("Trigger", validTrigger, defaultHistogramTrigger, true, bw3);
			prepareDefaultHistogram("Pressure", validPressure, defaultHistogramPressure, false, bw3);
			buildTriggerVsPressurePlot(bw3);
			buildAllTriggerSinglePressure(bw3);
			saveTriggerVsPressureValues(bw1);			
			buildRateCorrectionLookupTable(bw3);
			prepareDefaultHistogram("Corrected Trigger", correctedTrigger, defaultHistogramCorrectedTrigger, false, bw3);
			saveRatePressureValues(bw);
			saveRateCorrectionTable(bw2);
			saveTriggerPressureHistograms(writer);
			writer.close();
			bw.close();
			bw1.close();
			bw2.close();
			bw3.close();
		} catch (Exception e) {
			throw e;
		}
	}//end of Blessdata for concatenated files

	//analyze input data: determine valid trigger and pressure values by looking at the 
	//trigger rate that is not too low from the average
	//we also examine the time gap of the first record in a bin when the prior bin has zero entries
	public void prepareValidData(BufferedWriter bw3) throws ElabException { 
		try {
 			// calculate frequency of values per bin
	 		double[] values = new double[roundedBin]; 
	 		double secsToPartialDay = binValue.intValue() * DateUtils.MILLIS_PER_SECOND;
	 		Double[] timeGap = new Double[trigger.size()];
	 		Arrays.fill(timeGap, 0.0);
	 		double stTimeDiffAvg = 0.0;
 			bw3.write("1-Prepare valid data for histogram\n");
 			bw3.write("\tThis function examines the input data and determines whether entries are valid for the histogram.\n");
 			bw3.write("\ta-check that the trigger rate is not too low as compared to the average trigger rate\n");
 			bw3.write("\tb-examine the time gap of an entry when the prior bin has zero entries\n");
 			bw3.write("\tIf the trigger or time gap is not valid, zero out the entry so it is not included in the analysis\n");
 			bw3.write("\tValues in calculation - secsToPartialDay: "+String.valueOf(secsToPartialDay)+"\n");
 			triggerGap.add(0.0);
 			bw3.write("\tLoop through the seconds to determine which bin they belong to\n");
	 		if (trigger != null) {
	 			for (int i = 0; i < trigger.size()-1; i++) {
	 				Double bin = 0.0;
	 				Double nextBin = 0.0;
	 				bin = (seconds.get(i).doubleValue() - minX) / secsToPartialDay;
	 				nextBin = (seconds.get(i+1) - minX) / secsToPartialDay;
	 				// calculate the time gap between current and next value
	 				// the time gap is useful to determine valid data
	 				timeGap[i+1] = (seconds.get(i+1).doubleValue() - seconds.get(i).doubleValue()) / DateUtils.MILLIS_PER_SECOND;
	 				if (i == 0) {
	 					//fill the first record with an artificial time gap so we can use the first entry
	 			 		validTriggerGap.add(timeGap[i+1]);	 					
	 				}
	 				triggerGap.add(timeGap[i+1]);
	 				validTriggerGap.add(timeGap[i+1]);
	 				bw3.write(String.valueOf(i)+": "+seconds.get(i).doubleValue()+" min:"+String.valueOf(minX));
	 				bw3.write("bin = (seconds-minX)/secsToPartialDay : "+String.valueOf(bin)+"\n");
	 				bw3.write(String.valueOf(i)+" next: "+seconds.get(i+1).doubleValue()+" min:"+String.valueOf(minX));
	 				bw3.write("next bin = (next seconds-minX)/secsToPartialDay : "+String.valueOf(nextBin)+"\n");
	 				//to test intervals later
	 				if (stTimeDiffAvg == 0.0) {
	 					stTimeDiffAvg = timeGap[i+1];
	 				}
	 				bw3.write("Decide which bin it belongs to: \n");
	 				if (bin.intValue() < 0) {}
	 				else if (bin.intValue() >= roundedBin) {}
	 				else {
	 					bw3.write("incremented bin: "+String.valueOf(bin.intValue())+"\n");
	 					frequency[bin.intValue()] += 1;
	 				}
	 				bw3.write("Decide about next bin: \n");
	 				if ((nextBin.intValue() - bin.intValue()) > 1) {
	 					bw3.write("incremented bin: "+String.valueOf(bin.intValue())+" because nextBin - bin > 1\n");
	 					frequency[bin.intValue()] += 0;
	 				}
	 				if (i+1 == trigger.size()) {
	 					bw3.write("incremented bin: "+String.valueOf(bin.intValue())+" because it is the last record\n");
	 					frequency[bin.intValue()] += 1;	 					
	 				}
	 			}
	 		}
	 		bw3.write("Bins and entries for these histograms\n");
	 		for (int j = 0; j < frequency.length; j++) {
	 			bw3.write("Bin # "+String.valueOf(j)+" entries: "+String.valueOf(frequency[j])+"\n");
	 		}
			Double rateSum = 0.0;
			Double rateN = 0.0;
			for (int j = 0; j < trigger.size(); j++) {
				if (trigger.get(j) > 0.0 && isTriggerValid(rateSum, rateN, trigger.get(j))) {
					rateSum += trigger.get(j);
					rateN += 1.0;
				} else {
					//update if not valid
					validTrigger.set(j,0.0);
					validPressure.set(j,0.0);
					validTriggerGap.set(j,0.0);
				}
			}
			bw3.write("Original and valid data side by side\n");
			bw3.write("#Seconds\tTrigger\tValid Trigger\tTimeGap\tValid Time Gap\tPressure\tValid Pressure\n");
			for (int i = 0; i < trigger.size(); i++) {
				if (seconds.get(i) > 0L) {
					bw3.write(seconds.get(i).toString());
					bw3.write("\t");
					bw3.write(trigger.get(i).toString());
					bw3.write("\t");
					bw3.write(validTrigger.get(i).toString());
					bw3.write("\t");
					bw3.write(triggerGap.get(i).toString());
					bw3.write("\t");
					bw3.write(validTriggerGap.get(i).toString());
					bw3.write("\t");
					bw3.write(pressure.get(i).toString());
					bw3.write("\t");
					bw3.write(validPressure.get(i).toString());
					bw3.write("\n");
				}
			}	 		
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}
	}//end of prepareValidData

	boolean	isTriggerValid(double rateSum, double rateN, double trigger) {	
		//arbitrarily remove those trigger values that do not fall within
		//the 40% threshold (zero values or really small values)
		//also remove the corresponding pressure value
		boolean isValid = false;
		double averageSoFar = 0.0;
		double threshold = 0.4;
		if (rateN != 0) {
			averageSoFar = rateSum / rateN;
		}
		if (trigger/averageSoFar >= threshold) {
			isValid = true;
		}
		return isValid;
	}// end of isTriggerValid

	//prepare the default Histogram to be displayed
 	public void prepareDefaultHistogram(String label, ArrayList<Double> data, ArrayList<String> defaultHistogram, boolean calcError, BufferedWriter bw3) throws ElabException {
 		try {
 			bw3.write("\n2-Prepare histogram for "+label+"\n");
	 		Double[] binAverageRate = new Double[roundedBin];
	 		Arrays.fill(binAverageRate, 0.0);
	 		Double[] binAverageRateError = new Double[roundedBin];
	 		Arrays.fill(binAverageRateError, 0.0);
	 		Double[] binMillis = new Double[roundedBin];
			double halfBin = binValue * DateUtils.MILLIS_PER_SECOND / 2.0;
			bw3.write("Prepare bins by adding half bin to each: "+String.valueOf(halfBin)+"\n");
			int ndx = 0;
	 		for (Double i = Math.floor(minX); i < Math.ceil(maxX) && ndx < roundedBin; i+=(binValue * DateUtils.MILLIS_PER_SECOND)) {
				binMillis[ndx] = i+halfBin+0.00001;
				bw3.write("Bin: "+String.valueOf(i)+" new bin: "+String.valueOf(binMillis[ndx])+"\n");
				ndx += 1;
			}
 			//travel through frequency
 			int dataPointer = 0;
 			bw3.write("Loop through the frequency to collect data for the average per bin\n");
			bw3.write("Time\tBin Sum\tCount\tAverage\tPercentage error\tActual error\n");
	 		for (int i = 0; i < frequency.length; i++) {
	 			//travel through data to get averages
	 			double frequencySum = 0.0;
	 			double frequencyAvg = 0.0;
	 			double errorSum = 0.0;
	 			double errorN = 0;
	 			int sum = 0;
	 			if (frequency[i] > 0.0) {
		 			for (int j = 0; j < frequency[i]; j++) {
		 				frequencySum += data.get(j + dataPointer);
		 				if (data.get(j + dataPointer) > 0) {
		 					sum += 1;
		 				}
		 				//we collect the data for the error calculation
		 				if (validTriggerGap.get(j+dataPointer) > 0 ) {
		 					errorSum += (data.get(j + dataPointer) * validTriggerGap.get(j+dataPointer));
		 					errorN += 1.0;
		 				} else {
		 					errorSum += 0.0;
		 					errorN += 0.0;
		 				}
		 			}
	 				dataPointer += frequency[i];
	 				if (frequency[i] > 0) {
	 					frequencyAvg = frequencySum / sum;
	 				}
		 			binAverageRate[i] = frequencyAvg;
		 			if (errorSum != 0) {
		 				double percentError = 1 / Math.sqrt(errorSum);
		 				binAverageRateError[i] = binAverageRate[i] * percentError;
		 				if (calcError) {
		 					bw3.write(String.valueOf(binMillis[i])+"\t"+String.valueOf(frequencySum)+"\t"+String.valueOf(frequency[i])+"\t"+String.valueOf(binAverageRate[i])+"\t"+String.valueOf(percentError)+"\t"+String.valueOf(binAverageRateError[i])+"\n");
		 				} else {
		 					bw3.write(String.valueOf(binMillis[i])+"\t"+String.valueOf(frequencySum)+"\t"+String.valueOf(frequency[i])+"\t"+String.valueOf(binAverageRate[i])+"\n");		 					
		 				}
		 			}
	 			}
	 		}

	 		for (int i = 0; i < frequency.length; i++) {
	 			if (binMillis[i] > 0 && binAverageRate[i] > 0 && binValue > 0 && frequency[i] >= 1) {
	 				double xValue = binMillis[i];
		 			double yValue = binAverageRate[i];
		 			double error = 0.0;
		 			if (calcError) {
		 				error = binAverageRateError[i];	
		 			}
		 			defaultHistogram.add(String.valueOf(xValue)+","+String.valueOf(yValue)+","+String.valueOf(error));
	 			}
	 		}
 		} catch (Exception e) {
 			throw new ElabException("RatePressure: Exception in prepareDefaultHistogram: "+e.getMessage());
 		}
 	}//end of prepareDefaultHistogram

	void buildTriggerVsPressurePlot(BufferedWriter bw3) throws ElabException {
		ArrayList<Double> pressureDistinct = new ArrayList<Double>();
		//get distinct pressure values
		for (int i = 0; i < pressure.size(); i++) {
			if (!pressureDistinct.contains(pressure.get(i)) && pressure.get(i) > 0.0) {
				pressureDistinct.add(pressure.get(i));
			}		
		}		
		//loop through each
		try {
			bw3.write("\n3-Build Rate vs Pressure Plot\n");
			bw3.write("\ta-Get distinct pressure values\n");
			bw3.write("\tb-Loop through all values for each distinct pressure value and get the average rate for each\n");
			for (int i = 0; i < pressureDistinct.size(); i++) {
				Double rateSum = 0.0;
				Double rateN = 0.0;
	 			double N = 0.0;
				double pressureValue = pressureDistinct.get(i);
				double T = 0.0;
				bw3.write("Pressure: "+String.valueOf(pressureValue)+"\n");
				bw3.write("#Pressure\tTrigger\tGap\n");
				for (int j = 0; j < validPressure.size(); j++) {
					if (validPressure.get(j) == pressureValue) {
						if (validTrigger.get(j) > 0.0) {
							rateSum += validTrigger.get(j);
							N += (validTrigger.get(j) * validTriggerGap.get(j));
							T += validTriggerGap.get(j);
							rateN += 1.0;
							bw3.write(String.valueOf(pressureValue)+"\t"+String.valueOf(validTrigger.get(j))+"\t"+String.valueOf(validTriggerGap.get(j))+" Sums so far - N: "+String.valueOf(N)+"\tT: "+String.valueOf(T)+"\n");
						}
					}
				}
				if (rateN > 0) {
					pressureRate.put(pressureDistinct.get(i), rateSum / rateN);
				}
				if (T > 0) {
					pressureRate1.put(pressureDistinct.get(i), N / T);
				}
				double meanTriggerDiffSquared = 0.0;
 				double errorCalc = 0.0;
				for (int j = 0; j < validPressure.size(); j++) {
					if (validPressure.get(j) == pressureValue) {
						double mean = rateSum/rateN;
						if (validTrigger.get(j) > 0.0) {
							double diffSquared = Math.pow((validTrigger.get(j) - mean), 2);
							//errorCalc += (validTrigger.get(j) * percentError);
							meanTriggerDiffSquared += diffSquared;
						}
					}
				}
				double percentError = 1 / Math.sqrt(N);
 				bw3.write("Pressure\tN\tPercent Error\tT\n");
				bw3.write(String.valueOf(pressureValue)+"\t"+String.valueOf(N)+"\t"+String.valueOf(percentError)+"\t"+String.valueOf(T)+"\n");
				if (rateN > 1) {
					double ratio = meanTriggerDiffSquared / (rateN-1);
					pressureRateError.put(pressureDistinct.get(i), Math.sqrt(ratio));
	 				pressureRateError1.put(pressureDistinct.get(i), (N/T) * percentError);
				}
			}
			bw3.write("#Pressure\tRate Average\tError\tRate Option\tError Option\n");
			for(Map.Entry<Double,Double> entry : pressureRate.entrySet()) {
				double key = entry.getKey();
				bw3.write(String.valueOf(entry.getKey())+"\t"+String.valueOf(entry.getValue())+"\t"+pressureRateError.get(key)+"\t"+pressureRate1.get(key)+"\t"+pressureRateError1.get(key)+"\n");
			}			
		} catch (Exception e) {
			throw new ElabException(e.getMessage());			
		}
	}// end of buildPressureValuePlot

	void buildAllTriggerSinglePressure(BufferedWriter bw3) throws ElabException {
		try {
			bw3.write("\n4-Build All Triggers for median pressure point\n");
			Set<Double> keys = pressureRate.keySet();
			int setMidSize = (keys.size()/2) - 1;
			int i = 0;
			for (Map.Entry<Double,Double> entry : pressureRate.entrySet()) {
				if (i == setMidSize) {
					medianKey = entry.getKey();
					medianError = pressureRateError.get(entry.getKey());
				}
				i++;
			}
			double minRate = 0.0;
			double maxRate = 0.0;
			bw3.write("\tMedian key: "+String.valueOf(medianKey)+" Error: "+String.valueOf(medianError)+" - Trigger values:\n");
			for (int j = 0; j < validPressure.size(); j++) {
				if (validPressure.get(j) == medianKey) {
					allTriggerSinglePressure.add(validTrigger.get(j));
					bw3.write(String.valueOf(validTrigger.get(j))+"\n");
					double floorRate = Math.floor(validTrigger.get(j).doubleValue());
					double ceilRate = Math.ceil(validTrigger.get(j).doubleValue());
					if (minRate == 0.0) {
						minRate = floorRate;
					} else {
						if (floorRate < minRate) {
							minRate = floorRate;
						}
					}
					if (ceilRate > maxRate) {
						maxRate = ceilRate;
					}
				}//end if
			}//end for
			double numBins = Math.ceil((maxRate - minRate) / medianError);
			bw3.write("max rate: "+String.valueOf(maxRate)+ " min rate: "+String.valueOf(minRate)+" bins: "+String.valueOf(numBins)+"\n");
			//prepare the data in each bin
			//double binSize = (maxRate - minRate) / numBins;
			int[] result = new int[(int) numBins];
			for (double d : allTriggerSinglePressure) {
				int bin = (int) ((d - minRate) / medianError);
				if (bin < 0) {
					//do nothing
				} else if (bin >= numBins) {
					//also do nothing
				} else {
					result[bin] += 1;
				}
			}//end for
			double ndx = minRate;
			triggerSinglePressureFrequency.put(minRate - medianError, 0);
			for (int x = 0; x < (int) numBins; x++) {
				if (result[x] > 0) {
					triggerSinglePressureFrequency.put(ndx, result[x]);
					bw3.write("ndx: " + String.valueOf(ndx) + " value: "+String.valueOf(result[x])+"\n");
				}
				ndx += medianError;
			}
			triggerSinglePressureFrequency.put(ndx, 0);
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}
	}//end of buildAllTriggerSinglePressure
	
	public void saveTriggerVsPressureValues(BufferedWriter bw1) throws ElabException {
		try {
			bw1.write("#Pressure\tAverage Rate\tError\tError Option\n");
			for(Map.Entry<Double,Double> entry : pressureRate.entrySet()) {
				bw1.write(String.valueOf(entry.getKey()));
				bw1.write("\t");
				bw1.write(String.valueOf(entry.getValue()));
				bw1.write("\t");
				double key = entry.getKey();
				bw1.write(String.valueOf(pressureRateError.get(key)));
				bw1.write("\t");
				bw1.write(String.valueOf(pressureRateError1.get(key)));
				bw1.write("\n");
			}
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}
	}//end of saveRatePressureValues

	public void buildRateCorrectionLookupTable(BufferedWriter bw3) throws ElabException {
		//this function will calculate the correction rate for the trigger
		//when removing the pressure from the equation
		try {
			bw3.write("\n5-Build Rate Correction Lookup Table\n");
			Set<Double> keys = pressureRate.keySet();
			int setMidSize = (keys.size()/2) - 1;
			int i = 0;
			Double midKey = 0.0;
			Double middleRate = 0.0;
			for (Map.Entry<Double,Double> entry : pressureRate.entrySet()) {
				if (i == setMidSize) {
					midKey = entry.getKey();
					middleRate = entry.getValue();
				}
				i++;
			}
			bw3.write("\tRate correction without pressure\n");
			for (Map.Entry<Double,Double> entry : pressureRate.entrySet()) {
				rateCorrectionWithoutPressure.put(entry.getKey(),(entry.getValue()/middleRate));
				bw3.write(String.valueOf(entry.getKey())+"\t"+String.valueOf(entry.getValue()/middleRate)+"\n");
			}		
			bw3.write("Proceed to correct the Trigger value\n");
			for (Map.Entry<Double,Double> entry : rateCorrectionWithoutPressure.entrySet()) {
				Double localPressure = entry.getKey();
				Double correctionFactor = entry.getValue();
				if (correctionFactor > 0) {
					for (i = 0; i < pressure.size(); i++) {
						if (pressure.get(i).intValue() == localPressure.intValue()) {
							double fixedTrigger = correctedTrigger.get(i) / correctionFactor;
							correctedTrigger.set(i, fixedTrigger);
							bw3.write(String.valueOf(localPressure.intValue())+"\t"+String.valueOf(i)+"\t"+String.valueOf(fixedTrigger)+"\t"+correctedTrigger.get(i)+"\t"+correctionFactor+"\n");
						}
					}
				}
			}
		} catch (Exception e) {
			throw new ElabException(e.getMessage());						
		}
	}//end of buildRateCorrectionLookupTable

	public void saveRateCorrectionTable(BufferedWriter bw2) throws ElabException {
		try {
			bw2.write("#Pressure\tCorrection for Trigger\n");
			for (Map.Entry<Double,Double> entry : rateCorrectionWithoutPressure.entrySet()) {
				bw2.write(String.valueOf(entry.getKey()));
				bw2.write("\t");
				bw2.write(String.valueOf(entry.getValue()));
				bw2.write("\n");
			}
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}
	}//end of saveRateCorrectionTable
	
	public void saveRatePressureValues(BufferedWriter bw) throws ElabException {
		try {
			bw.write("#Seconds\tTrigger\tValid Trigger\tTimeGap\tValid Time Gap\tPressure\tValid Pressure\tCorrected Trigger\n");
			for (int i = 0; i < trigger.size(); i++) {
				if (seconds.get(i) > 0L) {
					bw.write(seconds.get(i).toString());
					bw.write("\t");
					bw.write(trigger.get(i).toString());
					bw.write("\t");
					bw.write(validTrigger.get(i).toString());
					bw.write("\t");
					bw.write(triggerGap.get(i).toString());
					bw.write("\t");
					bw.write(validTriggerGap.get(i).toString());
					bw.write("\t");
					bw.write(pressure.get(i).toString());
					bw.write("\t");
					bw.write(validPressure.get(i).toString());
					bw.write("\t");
					bw.write(correctedTrigger.get(i).toString());
					bw.write("\n");
				}
			}
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}
	}//end of saveRatePressureValues

	public void saveTriggerPressureHistograms(JsonWriter writer) throws ElabException {
		try {
			writer.beginObject();
			saveHistogram(writer, seconds, defaultHistogramTrigger, validTrigger, "magenta", "trigger", "Trigger", "circle", 0, false, true);
			saveHistogram(writer, seconds, defaultHistogramCorrectedTrigger, correctedTrigger, "green", "correctedtrigger", "Corrected Trigger", "square", 0, false, true);
			saveHistogram(writer, seconds, defaultHistogramPressure, validPressure, "black", "pressure", "Pressure", "circle", 0, true, false);
			saveRatePressureHistogram(writer);
			saveTriggerSinglePressure(writer);
			writer.endObject();
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}				
	}//end of saveTriggerPressureHistograms
		
	public void saveHistogram(JsonWriter writer, List<Long> seconds, ArrayList<String> defaultHistogram, List<Double> data, String color, String name, String label, String symbol, int ndx, boolean line, boolean errorCheck) throws ElabException {
		//add fixes for Corrected Trigger
		data.removeAll(Arrays.asList(Double.valueOf(0.0)));
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
			if (name.equals("correctedtrigger")) {
				writer.name("radius").value(3);				
			} else {
				writer.name("radius").value(1.5);
			}
			writer.name("yerr");
			writer.beginObject();
			writer.name("show").value(true);				
			writer.name("upperCap").value("-");
			writer.name("lowerCap").value("-");
			writer.name("color").value(color);
			writer.name("radius").value(5);
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
			writer.name("minY").value(Collections.min(data));
			writer.name("maxY").value(Collections.max(data));
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
	}//end of saveHistogram

	public void saveRatePressureHistogram(JsonWriter writer) throws ElabException {
		try {
			double minValue = 1000.0;
			double maxValue = -1.0;
			writer.name("ratepressure");
			writer.beginObject();
			writer.name("label").value("ratepressure");
			writer.name("data");
			writer.beginArray();
			for(Map.Entry<Double,Double> entry : pressureRate.entrySet()) {
				writer.beginArray();
				writer.value(entry.getKey());
				writer.value(entry.getValue());
				double key = entry.getKey();
				if ((entry.getValue() - pressureRateError.get(key)) < minValue) {
					minValue = entry.getValue() - pressureRateError.get(key);
				}
				if ((entry.getValue() + pressureRateError.get(key)) > maxValue) {
					maxValue = entry.getValue() + pressureRateError.get(key);
				}
				writer.value(pressureRateError.get(key));
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
			writer.name("errorbars").value("y");				
			writer.name("show").value(true);
			writer.name("symbol").value("triangle");
			writer.name("color").value("red");
			writer.name("radius").value(1.5);
			writer.name("yerr");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("upperCap").value("-");
			writer.name("lowerCap").value("-");
			writer.name("color").value("red");
			writer.name("radius").value(5);			
			writer.endObject();
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			writer.name("show").value(false);
			writer.endObject();
			writer.name("minY").value(minValue);
			writer.name("maxY").value(maxValue);
			writer.endObject();
			//writer.flush();			
			minValue = 1000.0;
			maxValue = -1.0;
			writer.name("ratepressurestat");
			writer.beginObject();
			writer.name("label").value("ratepressurestat");
			writer.name("data");
			writer.beginArray();
			for(Map.Entry<Double,Double> entry : pressureRate1.entrySet()) {
				writer.beginArray();
				writer.value(entry.getKey());
				writer.value(entry.getValue());
				double key = entry.getKey();
				if ((entry.getValue() - pressureRateError1.get(key)) < minValue) {
					minValue = entry.getValue() - pressureRateError1.get(key);
				}
				if ((entry.getValue() + pressureRateError1.get(key)) > maxValue) {
					maxValue = entry.getValue() + pressureRateError1.get(key);
				}
				writer.value(pressureRateError1.get(key));
				writer.endArray();
			}
			writer.endArray();
			writer.name("shadowSize").value(0);
			writer.name("color").value("green");
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
			writer.name("errorbars").value("y");				
			writer.name("show").value(true);
			writer.name("symbol").value("circle");
			writer.name("color").value("green");
			writer.name("radius").value(1.5);
			writer.name("yerr");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("upperCap").value("-");
			writer.name("lowerCap").value("-");
			writer.name("color").value("green");
			writer.name("radius").value(5);			
			writer.endObject();
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			writer.name("show").value(false);
			writer.endObject();
			writer.name("minY").value(minValue);
			writer.name("maxY").value(maxValue);
			writer.endObject();
			writer.flush();			
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}		
	}//end of saveRatePressureHistogram
	
	public void saveTriggerSinglePressure(JsonWriter writer) throws ElabException {
		//triggerSinglePressureFrequency
		try {
			double minValue = 1000.0;
			double maxValue = -1.0;
			writer.name("ratesinglepressure");
			writer.beginObject();
			writer.name("label").value("ratesinglepressure");
			writer.name("data");
			writer.beginArray();
			for(Map.Entry<Double,Integer> entry : triggerSinglePressureFrequency.entrySet()) {
				writer.beginArray();
				writer.value(entry.getKey());
				writer.value(entry.getValue());
				if (entry.getValue() < minValue) {
					minValue = entry.getValue();
				}
				if (entry.getValue() > maxValue) {
					maxValue = entry.getValue();
				}
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
			writer.name("symbol").value("circle");
			writer.name("color").value("red");
			writer.name("radius").value(1.5);
			writer.name("yerr");
			writer.beginObject();
			writer.name("show").value(false);
			writer.name("upperCap").value("-");
			writer.name("lowerCap").value("-");
			writer.name("color").value("red");
			writer.name("radius").value(5);			
			writer.endObject();
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			writer.name("show").value(true);
			writer.endObject();
			writer.name("minY").value(minValue);
			writer.name("maxY").value(maxValue);
			writer.name("medianKey").value(medianKey);
			writer.name("medianError").value(medianError);
			writer.endObject();
			writer.flush();			
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}		
	
	}//end of saveTriggerSinglePressure
	
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
