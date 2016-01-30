package gov.fnal.elab.cosmic.bless;

import java.io.BufferedReader;
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

public class BlessDataRange {
	private ArrayList<Long> seconds;
	private ArrayList<Double> channel1;
	private ArrayList<Double> channel2;
	private ArrayList<Double> channel3;
	private ArrayList<Double> channel4;
	private ArrayList<Double> channel1error;
	private ArrayList<Double> channel2error;
	private ArrayList<Double> channel3error;
	private ArrayList<Double> channel4error;
	private ArrayList<Double> trigger;
	private ArrayList<Double> triggererror;
	private ArrayList<Double> pressure;
	private ArrayList<Double> temperature;
	private ArrayList<Double> voltage;
	private ArrayList<Double> satellites;
	private String filename = "";
	ElabMemory em;
	
	//EPeronja: attempt to concatenate a few days together
	public BlessDataRange(Elab elab, File[] file, String[] filenames, String outputDir) throws Exception {
		seconds = new ArrayList<Long>();
		channel1 = new ArrayList<Double>();
		channel2 = new ArrayList<Double>();
		channel3 = new ArrayList<Double>();
		channel4 = new ArrayList<Double>();
		channel1error = new ArrayList<Double>();
		channel2error = new ArrayList<Double>();
		channel3error = new ArrayList<Double>();
		channel4error = new ArrayList<Double>();
		trigger = new ArrayList<Double>();
		triggererror = new ArrayList<Double>();
		pressure = new ArrayList<Double>();
		temperature = new ArrayList<Double>();
		voltage = new ArrayList<Double>();
		satellites = new ArrayList<Double>();
		em = new ElabMemory();
		filename = outputDir+"/FluxBlessRange";
		JsonWriter writer = new JsonWriter(new FileWriter(filename));	
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
							channel1.add(parseToDouble(split[1]));
							channel1error.add(parseToDouble(split[2]));
							channel2.add(parseToDouble(split[3]));
							channel2error.add(parseToDouble(split[4]));
							channel3.add(parseToDouble(split[5]));
							channel3error.add(parseToDouble(split[6]));
							channel4.add(parseToDouble(split[7]));
							channel4error.add(parseToDouble(split[8]));
							trigger.add(parseToDouble(split[9]));
							triggererror.add(parseToDouble(split[10]));
							pressure.add(parseToDouble(split[11]));
							temperature.add(parseToDouble(split[12]));
							voltage.add(parseToDouble(split[13]));
							satellites.add(parseToDouble(split[14]));
							ts = secs + (parseToLong(split[0]) * 1000);
							seconds.add(ts);
						}
					}
					br.close();
				} catch (Exception ex) {
					throw ex;
				}
                em.refresh();
                if (em.isCritical()) {
                	String emailMessage = 	"The code stopped processing the bless files in Flux Data Range\n"+
                							"at: "+file[i]+"\n"+
                							em.getMemoryDetails();
                   	Exception e = new Exception("Heap memory left: "+String.valueOf(em.getFreeMemory())+"MB"+
                                   				"We stopped processing the bless files.<br/>" +
                                   				"Please select fewer files or files with fewer events.");
                	throw e;
                }
			}//end of for loop
			saveFluxBlessRangeData(writer);
			writer.close();
		} catch (Exception e) {
			throw e;
		}
	}//end of Blessdata for concatenated files
	
	public void saveFluxBlessRangeData(JsonWriter writer) throws ElabException {
		try {
			writer.beginObject();
			saveData(writer, seconds, channel1, "red", "channel1", "Channel 1", "square", 0);
			saveData(writer, seconds, channel2, "#00ff00", "channel2", "Channel 2", "diamond", 1);
			saveData(writer, seconds, channel3, "blue", "channel3", "Channel 3", "triangle", 2);
			saveData(writer, seconds, channel4, "cyan", "channel4", "Channel 4", "circle", 3);
			saveData(writer, seconds, channel1error, "red", "channel1error", " ", "square", 4);
			saveData(writer, seconds, channel2error, "#00ff00", "channel2error", " ", "diamond", 5);
			saveData(writer, seconds, channel3error, "blue", "channel3error", " ", "triangle", 6);
			saveData(writer, seconds, channel4error, "cyan", "channel4error", " ", "circle", 7);
			saveData(writer, seconds, trigger, "magenta", "trigger", "Trigger", "circle", 0);
			saveData(writer, seconds, triggererror, "magenta", "triggererror", " ", "circle", 1);
			saveData(writer, seconds, satellites, "black", "satellites", "GPS Satellites", "circle", 0);
			saveData(writer, seconds, voltage, "black", "voltage", "Volts", "circle", 0);
			saveData(writer, seconds, temperature, "black", "temperature", "Temperature", "circle", 0);
			saveData(writer, seconds, pressure, "black", "pressure", "Pressure", "circle", 0);
			writer.endObject();
		} catch (Exception e) {
			throw new ElabException(e.getMessage());
		}				
	}//end of saveFluxBlessRangeData
	
	public void saveData(JsonWriter writer, List<Long> seconds, List<Double> data, String color, String name, String label, String symbol, int ndx) throws ElabException {
		try {
			writer.name(name);
			writer.beginObject();
			writer.name("label").value(label);
			writer.name("data");
			writer.beginArray();
			for (int i = 0; i < data.size(); i++) {
				writer.beginArray();
				writer.value(seconds.get(i));
				writer.value(data.get(i));
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
			writer.name("show").value(false);
			writer.endObject();
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
