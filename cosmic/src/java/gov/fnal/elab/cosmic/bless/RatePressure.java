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
import gov.fnal.elab.Elab;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.ArrayList;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabMemory;

import com.google.gson.*;
import com.google.gson.stream.JsonWriter;
import com.google.gson.stream.JsonReader;

public class RatePressure {
	//private ArrayList<Long> seconds;
	private ArrayList<Double> trigger;
	private ArrayList<Double> pressure;
	private ArrayList<Double> seconds;
	private String filename = "";
	private String ratePressureFile = "";
	ElabMemory em;
	double minX, maxX, nBins, maxBins;
	double binValue;
	//Long minX, maxX, nBins, maxBins, binValue;
	double dayCounter;

	//EPeronja: attempt to concatenate a few days together
	public RatePressure(Elab elab, File[] file, String[] filenames, String outputDir) throws Exception {
		//seconds = new ArrayList<Long>();
		seconds = new ArrayList<Double>();
		trigger = new ArrayList<Double>();
		pressure = new ArrayList<Double>();
		em = new ElabMemory();
		filename = outputDir+"/RatePressure";
		ratePressureFile = outputDir+"/RatePressureValues";
		minX = maxX = 0L;
		dayCounter = 0;	
		
		JsonWriter writer = new JsonWriter(new FileWriter(filename));	
        BufferedWriter bw = new BufferedWriter(new FileWriter(ratePressureFile));
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
					if (i == 0) {
						dayCounter = 0;
					} else {
						dayCounter += 86400;
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
							//ts = secs + (parseToLong(split[0]) * 1000);
							//seconds.add(parseToLong(split[0]) + dayCounter);
							seconds.add(parseToDouble(split[0]) + dayCounter);
							//seconds.add(parseToLong(split[0]));
							double newminx = parseToDouble(split[0]) + dayCounter ;
							//Long newminx = ts;
							if (minX == 0.0) {
								minX = newminx;
							} else if (newminx < minX) {
								minX = newminx;
							}
							double newmaxx = parseToDouble(split[0]) + dayCounter;
							//Long newmaxx = ts;
							if (maxX == 0.0) {
								maxX = newmaxx;
							} else if (newmaxx > maxX) {
								maxX = newmaxx;
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
			//binValue = (maxX - minX) * 0.1;
			binValue = (maxX - minX) * 0.1;
			nBins = (maxX - minX) / binValue;
			maxBins = maxX - minX;	
			saveFluxRatePressure(writer);
			saveRatePressureValues(bw);
			writer.close();
			bw.close();
		} catch (Exception e) {
			throw e;
		}
	}//end of Blessdata for concatenated files
	
	public void saveRatePressureValues(BufferedWriter bw) throws ElabException {
		try {
			bw.write("#Seconds\tTrigger\tPressure\n");
			for (int i = 0; i < trigger.size(); i++) {
				bw.write(seconds.get(i).toString());
				bw.write("\t");
				bw.write(trigger.get(i).toString());
				bw.write("\t");
				bw.write(pressure.get(i).toString());
				bw.write("\n");
			}
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}
	}//end of saveRatePressureValues
	
	public void saveFluxRatePressure(JsonWriter writer) throws ElabException {
		try {
			writer.beginObject();
			saveData(writer, seconds, trigger, "magenta", "trigger", "Trigger", "circle", 0);
			saveData(writer, seconds, pressure, "black", "pressure", "Pressure", "circle", 0);
			writer.endObject();
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}				
	}//end of saveFluxRatePressure
	
	public void saveData(JsonWriter writer, List<Double> seconds, List<Double> data, String color, String name, String label, String symbol, int ndx) throws ElabException {
		try {
			writer.name(name);
			writer.beginObject();
			writer.name("label").value(label);
			writer.name("data");
			writer.beginArray();
			writer.endArray();
			writer.name("data_original");
			writer.beginArray();
			for (int i = 0; i < data.size(); i++) {
				writer.beginArray();
				writer.value(seconds.get(i));
				//writer.value(data.get(i));
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
			writer.name("errorbars").value("n");
			writer.name("show").value(true);
			writer.name("symbol").value(symbol);
			writer.name("color").value(color);
			writer.name("radius").value(1.5);
			writer.name("yerr");
			writer.beginObject();
			writer.name("show").value(false);
			writer.name("upperCap").value("-");
			writer.name("lowerCap").value("-");
			writer.name("color").value(color);
			writer.name("radius").value(1.5);			
			writer.endObject();
			writer.endObject();
			writer.name("lines");
			writer.beginObject();
			writer.name("show").value(true);
			writer.endObject();
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
