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
	private TreeMap<Integer, String> fluxData;
	public TreeMap<Long, Double> fluxArea;
	public TreeMap<Integer, String> defaultHistogram = new TreeMap<Integer, String>();
	private Double binValue;
	private Double minX = -1.0;
	private Double maxX = -1.0;
	private Double nBins = -1.0;
	private Double maxYaxis = -1.0;
	private Double maxError = -1.0;
	private Long minMillis = 0L;
	private long maxMillis = 0L;
    DateFormat df = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss");
 	Geometries geometries;
 	Geometry geometry;
 	GeoEntryBean geb;
 	String channelArea = "";
	private List<Long> seconds;
	private List<Double> pressure;
	private List<Double> temperature;
	private List<Double> voltage;
	private List<Double> satellites;
 
 	public FluxPlotDataStream(Elab elab, File file, Double binValue, String outputDir, File[] files, String[] filenames) throws Exception {
		String message = "";
		this.binValue = binValue;
		this.elab = elab;
		fluxData = new TreeMap<Integer, String>();
		fluxArea = new TreeMap<Long, Double>();
		seconds = new ArrayList<Long>();
		pressure = new ArrayList<Double>();
		temperature = new ArrayList<Double>();
		voltage = new ArrayList<Double>();
		satellites = new ArrayList<Double>();
		try {
			//work with the sort.out
			String filename = outputDir+"/FluxPlotFlot";
			JsonWriter writer = new JsonWriter(new FileWriter(filename));
			BufferedReader br = new BufferedReader(new FileReader(file));
			//read input file and get data ready for the json file
			saveLineData(br);
			br.close();
			//prepare the default histogram in the server so as to save time on the client side
			prepareDefaultHistogram();
			//save json file
			writer.beginObject();
			saveFileHistogramData(writer);
			//get the data from the bless files
			buildDataFromBlessFiles(files, filenames);
			saveFluxBlessRangeData(writer);
			writer.endObject();
			writer.close();
		} catch (Exception e) {
			throw e;
		}
	}//end of constructor

	public void saveLineData(BufferedReader br) throws ElabException {
		String[] split; 
		String line;
		String channelAreaTemp = "";
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
        		geometries = new Geometries(elab, Integer.parseInt(detectorid));
        		geometry = geometries.getGeometry(Integer.parseInt(detectorid));
        		if (geometries == null || geometry == null) {
        			ElabException e = new ElabException("FluxPlotDataStream: No geometry information returned for detector: "+detectorid+"\n");
        			throw e;
        		}
        		if (geometry != null) {
        			SortedMap geos = geometry.getGeoEntriesBefore(jd);
        			if (geos.isEmpty()) {
            			ElabException e = new ElabException("FluxPlotDataStream: No geometry information information for detector: "+detectorid+" for "+
            							"when this data was taken.\n");
            			throw e;
        			}
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
        		}
                NanoDate nd = ElabUtil.julianToGregorianCST(Integer
                        .parseInt(jd), parseToDouble(re));   	
				Long timeinmillis = nd.getTime();
				double thresh = parseToDouble(split[4]);
				String concatTimeThresh = String.valueOf(timeinmillis)+","+channelAreaTemp;
				fluxData.put(i, concatTimeThresh);					
           		fluxArea.put(timeinmillis, Double.parseDouble(channelAreaTemp) / 100 / 100);	
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
			}
			minX = minX - (binValue * DateUtils.MILLIS_PER_SECOND);
			maxX = maxX + (binValue * DateUtils.MILLIS_PER_SECOND * 2);
			nBins = (maxX - minX) / DateUtils.MILLIS_PER_SECOND / binValue;			
		} catch (Exception e) {
			throw new ElabException("FluxPlotDataStream: Exception in saveLineData: "+e.getMessage());
		}
	}// end of saveLineData

 	public void prepareDefaultHistogram() throws ElabException {
 		try {
	        //BufferedWriter report = new BufferedWriter(new FileWriter("/users/edit/ep_home/ep_cosmic/ep_flux/javaOutput.txt"));
	 		TreeMap<Integer,ArrayList> histData = new TreeMap<Integer,ArrayList>();
	 		int[] frequency = new int[getNBins().intValue()];
	 		int[] area = new int[getNBins().intValue()];
	 		double secsToPartialDay = getBinValue()* DateUtils.MILLIS_PER_SECOND;
 	 		if (fluxData != null) {
	 			for (int i = 0; i < fluxData.size()-1; i++) {
					String[] value = fluxData.get(i).split(",");
					String[] nextValue = fluxData.get(i+1).split(",");
	 				Double bin = (Long.parseLong(value[0]) - minX) / secsToPartialDay;
	 				Double nextBin = (Long.parseLong(nextValue[0]) - minX) / secsToPartialDay;
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
				for (Map.Entry<Long, Double> e: fluxArea.entrySet()) {
					if (i.longValue() >= e.getKey()) {
						binArea[ndx] = e.getValue();
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
		 			defaultHistogram.put(i, String.valueOf(xValue)+","+String.valueOf(yValue)+","+String.valueOf(error));
	 			}
	 		}
	 		//report.close();
 		} catch (Exception e) {
 			throw new ElabException("FluxPlotDataStream: Exception in prepareDefaultHistogram: "+e.getMessage());
 		}
 	}//end of prepareDefaultHistogram
 	
	
	public void saveFileHistogramData(JsonWriter writer) throws ElabException {
		try {
			if (fluxData != null) {
				saveFile(writer, "00ff00", "fluxdata", "cross", "green", 0);
			}
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
		} catch (Exception e) {
			throw new ElabException("FluxPlotDataStream: Exception in saveFileHistogramData "+e.getMessage());
		}		
		
	}//end of saveFileHistogramData
	
	public void saveFile(JsonWriter writer, String color, String name, String symbol, String crossColor, int ndx) throws ElabException {
		try {
			writer.name("fluxdata");
			writer.beginObject();
			writer.name("label").value("Events");
			writer.name("data");
			writer.beginArray();
			for (Map.Entry<Integer,String> entry: defaultHistogram.entrySet()) {
				writer.beginArray();
				String[] value = entry.getValue().split(",");
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
			for (Map.Entry<Integer,String> entry: fluxData.entrySet()) {
				String[] value = entry.getValue().split(",");
				writer.value(Long.parseLong(value[0]));
			}
			writer.endArray();
			writer.name("area");
			writer.beginArray();
			for (Map.Entry<Long,Double> entry: fluxArea.entrySet()) {
				writer.beginArray();
				writer.value(entry.getKey());
				writer.value(entry.getValue());
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
	}//end of saveFileChannel

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
						ts = secs + parseToLong(split[0]);
						seconds.add(ts);
					}
				}
				br.close();
			} catch (Exception ex) {
				throw new ElabException("FluxPlotDataStream: Exception in buildDataFromBlessFiles "+ex.getMessage());
			}
		}//end of for loop
 		
 	}//end of buildDataFromBlessFiles
 
	public void saveFluxBlessRangeData(JsonWriter writer) throws ElabException {
		try {
			saveData(writer, seconds, pressure, "magenta", "pressure", "Pressure", "time", "mb", "circle", 2);
			saveData(writer, seconds, temperature, "orange", "temperature", "Temperature", "time", "&deg; C", "circle", 3);
			saveData(writer, seconds, satellites, "purple", "satellites", "GPS Satellites", "time", "# Satellites in view", "circle", 4);
			saveData(writer, seconds, voltage, "black", "voltage", "Volts", "time", "Vcc", "circle", 5);
		} catch (Exception e) {
			throw new ElabException("FluxPlotDataStream: Exception in saveFluxBlessRangeData "+e.getMessage());
		}				
	}//end of saveFluxBlessRangeData

	public void saveData(JsonWriter writer, List<Long> seconds, List<Double> data, String color, String name, String label, String xunits, String yunits, String symbol, int ndx) throws ElabException{
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
	}//end of saveData
		
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
		return result * 1000;
	}	
	
	public String getGsonFromJson(String outputDir) throws ElabException {
		String result = "";
		StringBuilder filevalues = new StringBuilder();
		String filename = outputDir+"/FluxPlotFlot";		
		try {
	        BufferedReader br = new BufferedReader(new FileReader(filename));
	        String line = br.readLine();
	        while (line != null) {
	        	filevalues.append(line);
	        	line = br.readLine();
	        }
			br.close();
		} catch (Exception e) {
			throw new ElabException("FluxPlotDataStream: Exception in getGsonFromJson "+e.getMessage());
		}			
		result = filevalues.toString();
		return result;
	}//end getGsonFromJson
	
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