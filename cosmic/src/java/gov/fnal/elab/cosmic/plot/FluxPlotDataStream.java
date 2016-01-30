package gov.fnal.elab.cosmic.plot;

import gov.fnal.elab.*;
import gov.fnal.elab.util.*;
import gov.fnal.elab.cosmic.*;
import gov.fnal.elab.cosmic.beans.*;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

import org.apache.commons.lang.time.DateUtils;

import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.gson.stream.JsonWriter;

public class FluxPlotDataStream {
 	Elab elab;
	private ArrayList<String> defaultHistogram;
	private ArrayList<String> fluxDataArea;
	private Double binValue;
	private Double minX = -1.0;
	private Double maxX = -1.0;
	private Double nBins = -1.0;
	private Double maxYaxis = -1.0;
	private Double maxError = -1.0;
	private Long minMillis = 0L;
	private long maxMillis = 0L;
 	Geometries geometries;
 	Geometry geometry;
 	GeoEntryBean geb;
 	String channelArea = "";
	private ArrayList<Long> seconds;
	private ArrayList<Double> pressure;
	private ArrayList<Double> temperature;
	private ArrayList<Double> voltage;
	private ArrayList<Double> satellites;
	ElabMemory em;
	public int eventThreshold = 1000000;
	DateFormat df = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss");
    private String filename = "";
 
 	public FluxPlotDataStream(Elab elab, File file, Double binValue, String outputDir, File[] files, String[] filenames) throws Exception {
		String message = "";
		this.binValue = binValue;
		this.elab = elab;
		fluxDataArea = new ArrayList<String>();
		defaultHistogram = new ArrayList<String>();
		seconds = new ArrayList<Long>();
		pressure = new ArrayList<Double>();
		temperature = new ArrayList<Double>();
		voltage = new ArrayList<Double>();
		satellites = new ArrayList<Double>();
        em = new ElabMemory();
		filename = outputDir+"/FluxPlotFlot";

		try {
			//work with the sort.out
			BufferedReader br = new BufferedReader(new FileReader(file));
			//read input file and get data ready for the json file
			parseSortOutFile(br);
			br.close();
			//prepare the default histogram in the server so as to save time on the client side
			prepareDefaultHistogram();
			//get the data from the bless files
			buildDataFromBlessFiles(files, filenames);
			//save json file
			saveJsonFile(filename);
		} catch (Exception e) {
			throw e;
		}
	}//end of constructor

 	//read Flux sort.out file and save the data for the histogram
	public void parseSortOutFile(BufferedReader br) throws ElabException {
		String[] split; 
		String line;
		String channelAreaTemp = "";
		String currentDetectorId = "";
		SortedMap currentGeos = null;
		int i=0; 
		try {
			while ((line = br.readLine()) != null) {
				split = line.split("\t"); 
				if (split.length < 5) {
        			ElabException e = new ElabException("FluxPlotDataStream: There has been an error reading the input file sort.out\n");
        			throw e;
				}
				String[] parts = split[0].split("\\.");
				String detectorid = parts[0];
				int channel = Integer.parseInt(parts[1]);
				String jd = split[1];
				String re = split[2];
				//check if there is a geometry for this detector's data line: we need to get the channel area
				if (!detectorid.equals(currentDetectorId)) {
					geometries = new Geometries(elab, Integer.parseInt(detectorid));
	        		geometry = geometries.getGeometry(Integer.parseInt(detectorid));
	        		currentDetectorId = detectorid;
	        		if (geometries == null || geometry == null) {
	        			ElabException e = new ElabException("FluxPlotDataStream: No geometry information returned for detector: "+detectorid+"\n");
	        			throw e;
	        		}
				}
        		if (geometry != null) {
        			SortedMap geos = geometry.getGeoEntriesBefore(jd);
        			if (geos.isEmpty()) {
            			ElabException e = new ElabException("FluxPlotDataStream: No geometry information information for detector: "+detectorid+" for "+
            							"when this data was taken.\n");
            			throw e;
        			}
        			if (currentGeos == null || currentGeos != geos) {
	        			geb = (GeoEntryBean) geos.get(geos.lastKey()); 
	        			if (geb == null) {
	            			ElabException e = new ElabException("FluxPlotDataStream: No geometry entry for julian day: "+jd+"\n");  
	            			throw e;
	        			}
	        			switch (channel) {
	        				case 1:
	        					channelAreaTemp = geb.getChan1Area();
	        					break;
	        				case 2:
	        					channelAreaTemp = geb.getChan2Area();
	        					break;
	        				case 3:
	        					channelAreaTemp = geb.getChan3Area();
	        					break;
	        				case 4:
	        					channelAreaTemp = geb.getChan4Area();
	        					break;
	        				default:
	        					channelAreaTemp = "0.0";
	        					break;
	        			}
	        			currentGeos = geos;
        			}
        		}
                NanoDate nd = ElabUtil.julianToGregorianCST(Integer
                        .parseInt(jd), parseToDouble(re));   	
                Long timeinmillis = nd.getTime();
           		fluxDataArea.add(String.valueOf(timeinmillis)+","+String.valueOf(Double.parseDouble(channelAreaTemp) / 100 / 100));
				i += 1;
				//get the max value of the whole set
				double newmax = timeinmillis.doubleValue();
				if (newmax > maxX) {
					maxX = newmax;
				}
				double newmin = timeinmillis.doubleValue();
				if (i == 1) {
					minX = timeinmillis.doubleValue();
				}
				if (newmin < minX) {
					minX = newmin;
				}
				if (i > eventThreshold) {
	                em.refresh();
	                if (em.isCritical()) {
	                	String emailMessage = 	"The code stopped processing the sort.out file in FluxPlotDataStream\n"+
	                							"at line: "+String.valueOf(i)+"\n"+
	                							em.getMemoryDetails();
	                   	Exception e = new Exception("Heap memory left: "+String.valueOf(em.getFreeMemory())+"MB"+
	                                   				"We stopped processing the sort.out file at line: <br />"+String.valueOf(i)+".<br/>" +
	                                   				"Please select fewer files or files with fewer events.");
	                	throw e;
	                }
				}
			}
			minX = minX - (binValue * DateUtils.MILLIS_PER_SECOND);
			maxX = maxX + (binValue * DateUtils.MILLIS_PER_SECOND * 2);
			nBins = (maxX - minX) / DateUtils.MILLIS_PER_SECOND / binValue;			
		} catch (Exception e) {
			throw new ElabException("FluxPlotDataStream: Exception in saveLineData: "+e.getMessage());
		}
	}// end of parseSortOutFile

	//prepare the default Histogram to be displayed
 	public void prepareDefaultHistogram() throws ElabException {
 		try {
	        //BufferedWriter report = new BufferedWriter(new FileWriter("/users/edit/ep_home/ep_cosmic/ep_flux/javaOutput.txt"));
	 		int[] frequency = new int[getNBins().intValue()];
	 		int[] area = new int[getNBins().intValue()];
	 		double secsToPartialDay = getBinValue()* DateUtils.MILLIS_PER_SECOND;
 	 		if (fluxDataArea != null) {
	 			for (int i = 0; i < fluxDataArea.size()-1; i++) {
	 				String[] parts = fluxDataArea.get(i).split(",");
	 				String[] nextParts = fluxDataArea.get(i+1).split(",");
	 				Long value = Long.valueOf(parts[0]);
	 				Long nextValue = Long.valueOf(nextParts[0]);
	 				Double bin = (value - minX) / secsToPartialDay;
	 				Double nextBin = (nextValue - minX) / secsToPartialDay;
	 				if (bin.intValue() < 0) {}
	 				else if (bin.intValue() >= getNBins().intValue()) {}
	 				else {
	 					frequency[bin.intValue()] += 1;
	 				}
	 				//if the next signal that would go into the next batch of analysis is farther than one binwidth away we know that 
	 	            //the last bin of this analysis might not be full and we need to not display it 
	 				if ((nextBin.intValue() - bin.intValue()) > 1) {
	 					frequency[bin.intValue()] = 0;
	 				}
	 			}
	 			//clear last one
	 			frequency[frequency.length-1] = 0;
	 		}
	 		Double[] binMillis = new Double[getNBins().intValue()];
	 		Double[] binArea = new Double[getNBins().intValue()];
			double halfBin = binValue * DateUtils.MILLIS_PER_SECOND / 2.0;
	 		Arrays.fill(binArea, 0.0);
	 		int ndx = 0;
	 		for (Double i = Math.floor(minX); i < Math.ceil(maxX) && ndx < getNBins().intValue(); i+=(binValue * DateUtils.MILLIS_PER_SECOND)) {
				binMillis[ndx] = i+halfBin+0.00001;
				long longI = i.longValue();
				long l = longI;
				for (int x = 0; x < fluxDataArea.size(); x++) {
					String[] parts = fluxDataArea.get(x).split(",");
					if (i.longValue() >= Long.valueOf(parts[0])) {
						binArea[ndx] = Double.valueOf(parts[1]);
						break;
					}
				}
				ndx += 1;
			}
	 		for (int i = 0; i < frequency.length; i++) {
	 			if (binMillis[i] > 0 && binArea[i] > 0 && getBinValue() > 0 && frequency[i] > 1) {
	 				double xValue = binMillis[i];
		 			double yValue = frequency[i]/(getBinValue()/60.0)/binArea[i];
		 			double error = Math.sqrt(frequency[i])/(getBinValue()/60.0)/binArea[i];
		 			if ((yValue + (yValue * 0.3)) > maxYaxis) {
		 				maxYaxis = yValue + (yValue * 0.3);
		 			}
		 			if (error > maxError) {
		 				maxError = error;
		 			}
		 			//report.write(String.valueOf(xValue)+","+String.valueOf(yValue)+","+String.valueOf(error)+"\n");
		 			defaultHistogram.add(String.valueOf(xValue)+","+String.valueOf(yValue)+","+String.valueOf(error));
	 			}
	 		}
	 		//report.close();
 		} catch (Exception e) {
 			throw new ElabException("FluxPlotDataStream: Exception in prepareDefaultHistogram: "+e.getMessage());
 		}
 	}//end of prepareDefaultHistogram
 	
 	//read blessfile and prepare data for superimposing
	public void buildDataFromBlessFiles( File[] files, String[] filenames) throws ElabException {
		for (int i = 0; i < files.length; i++) {
			try {				
				BufferedReader br = new BufferedReader(new FileReader(files[i]));
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
							throw new IOException(files[i].getName() + " has malformed data. "); 
						}
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
				throw new ElabException("FluxPlotDataStream: Exception in buildDataFromBlessFiles "+ex.getMessage());
			}
            em.refresh();
            if (em.isCritical()) {
            	String emailMessage = 	"The code stopped processing the bless files in FluxPlotDataStream\n"+
            							"at line: "+String.valueOf(i)+"\n"+
            							em.getMemoryDetails();
               	ElabException e = new ElabException("Heap memory left: "+String.valueOf(em.getFreeMemory())+"MB"+
                               				"We stopped processing the bless files at: <br />"+files[i]+".<br/>" +
                               				"Please select fewer files or files with fewer events.");
            	throw e;
            }			
		}//end of for loop 		
 	}//end of buildDataFromBlessFiles
	
	//save json data
	public void saveJsonFile(String filename) throws ElabException {
		try {
			JsonWriter writer = new JsonWriter(new FileWriter(filename));
			writer.beginObject();
			if (fluxDataArea != null) {
				saveFluxHistogram(writer, "#00ff00", "fluxdata", "cross", "#00cc00", 0);
				writer.name("binValue").value(getBinValue());
				writer.name("minX").value(getMinX());
				writer.name("maxX").value(getMaxX());
				writer.name("nBins").value(getNBins());
				writer.name("maxYaxis").value(maxYaxis);
				writer.name("maxError").value(maxError);
				writer.name("bins");
				writer.beginArray();
				for (Double i = Math.floor(minX); i < Math.ceil(maxX); i+=(binValue * DateUtils.MILLIS_PER_SECOND)) {
					writer.value(i);
				}
				writer.endArray();
				writer.name("fakeBins");
				writer.beginArray();
				for (Double i = Math.floor(minX); i < Math.ceil(maxX); i+=(binValue * DateUtils.MILLIS_PER_SECOND)) {
					writer.value(i+0.00001);
				}
				writer.endArray();
			}
			saveFluxBlessData(writer);
			writer.endObject();
			writer.close();
		} catch (Exception e) {
			throw new ElabException("FluxPlotDataStream: Exception in saveFileHistogramData "+e.getMessage());
		}				
	}//end of saveJsonFile
	
	public void saveFluxHistogram(JsonWriter writer, String color, String name, String symbol, String crossColor, int ndx) throws ElabException {
		try {
			writer.name("fluxdata");
			writer.beginObject();
			writer.name("label").value("Events");
			writer.name("data");
			writer.beginArray();
			for (int i = 0; i < defaultHistogram.size(); i++) {
				writer.beginArray();
				String[] value = defaultHistogram.get(i).split(",");
				Double x = Double.parseDouble(value[0]);
				Double y = Double.parseDouble(value[1]);
				Double e = Double.parseDouble(value[2]);
				writer.value(x.longValue());
				if (y != 0) {
					writer.value(y);
					writer.value(e);
				} else {
					writer.nullValue();
					writer.nullValue();
				}				
				writer.endArray();
			}
			writer.endArray();
			writer.name("data_original");
			writer.beginArray();
			for (int i = 0; i < fluxDataArea.size(); i++) {
				String[] parts = fluxDataArea.get(i).split(",");
				writer.value(Long.valueOf(parts[0]));
			}
			writer.endArray();
			writer.name("area");
			writer.beginArray();
			for (int i = 0; i < fluxDataArea.size(); i++) {
				writer.beginArray();
				String[] parts = fluxDataArea.get(i).split(",");
				writer.value(Long.valueOf(parts[0]));
				writer.value(Double.parseDouble(parts[1]));
				writer.endArray();
			}
			writer.endArray();
			writer.name("shadowSize").value(0);
			writer.name("color").value(crossColor);
			writer.name("xunits").value("time");
			writer.name("yunits").value("events");
			writer.name("idx").value(ndx);
			writer.name("toggle").value(true);
			writer.name("points");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("errorbars").value("y");
			writer.name("symbol").value(symbol);
			writer.name("color").value(crossColor);
			writer.name("radius").value(3);
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
			throw new ElabException("FluxPlotDataStream: Exception in saveFile "+e.getMessage());
		}		
	}//end of saveFluxHistogram

	//add bless data in json format
	public void saveFluxBlessData(JsonWriter writer) throws ElabException {
		try {
			saveBlessData(writer, seconds, pressure, "magenta", "pressure", "Pressure", "time", "mb", "circle", 2);
			saveBlessData(writer, seconds, temperature, "orange", "temperature", "Temperature", "time", "&deg; C", "circle", 3);
			saveBlessData(writer, seconds, satellites, "purple", "satellites", "GPS Satellites", "time", "# Satellites in view", "circle", 4);
			saveBlessData(writer, seconds, voltage, "black", "voltage", "Volts", "time", "Vcc", "circle", 5);
		} catch (Exception e) {
			throw new ElabException("FluxPlotDataStream: Exception in saveFluxBlessRangeData "+e.getMessage());
		}				
	}//end of saveFluxBlessData

	//save individual bless data items
	public void saveBlessData(JsonWriter writer, List<Long> seconds, List<Double> data, String color, String name, String label, String xunits, String yunits, String symbol, int ndx) throws ElabException{
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
			writer.name("toggle").value(true);
			writer.name("xunits").value(xunits);
			writer.name("yunits").value(yunits);
			writer.name("yaxis");
			writer.beginObject();
			writer.name("n").value(ndx);
			writer.name("position").value("left");
			writer.endObject();
			writer.name("xaxis");
			writer.beginObject();
			writer.name("n").value(2);
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
			throw new ElabException("FluxPlotDataStream: Exception in saveData "+e.getMessage());
		}		
	}//end of saveBlessData
		
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

	public Long parseToLong(String split)
	{
		Long result = 0L;
		try{
			result = Long.parseLong(split);
		} catch (NumberFormatException e) {
			result = 0L;
		}
		return result;
	}	
	
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
	
}//end of FluxPlotDataStream