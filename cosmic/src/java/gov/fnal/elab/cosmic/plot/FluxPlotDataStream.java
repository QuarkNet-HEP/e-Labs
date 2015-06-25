package gov.fnal.elab.cosmic.plot;

import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.util.NanoDate;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;
import java.util.TreeMap;
import java.util.Map;
import java.util.Calendar;

import org.apache.commons.lang.time.DateUtils;

import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.gson.stream.JsonWriter;

public class FluxPlotDataStream {
	private TreeMap<Integer, String> fluxData;
	private Double binValue;
	private Double minX = -1.0;
	private Double maxX = -1.0;
	private Double nBins = -1.0;
	private Long minMillis = 0L;
	private long maxMillis = 0L;
    DateFormat df = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss");
 	
	public FluxPlotDataStream(File file, Double binValue, String outputDir) throws IOException {
		String message = "";
		this.binValue = binValue;
		try {
			String filename = outputDir+"/FluxPlotFlot";
			JsonWriter writer = new JsonWriter(new FileWriter(filename));
			BufferedReader br = new BufferedReader(new FileReader(file));
			fluxData = new TreeMap<Integer, String>();
			fluxData = saveLineData(br);
			minX = minX - (binValue * DateUtils.MILLIS_PER_SECOND);
			maxX = maxX + (binValue * DateUtils.MILLIS_PER_SECOND);
			nBins = (maxX - minX) / DateUtils.MILLIS_PER_SECOND / binValue;
			saveFileHistogramData(writer);
			writer.close();
		} catch (Exception e) {
			message = e.getMessage();
		}
	}

	public TreeMap<Integer, String> saveLineData(BufferedReader br) {
		String[] split; 
		String line;
		TreeMap<Integer, String> plotData = new TreeMap<Integer, String>();
		int i=0; 
		try {
			while ((line = br.readLine()) != null) {
				split = line.split("\t"); 
				if (split.length < 5) {
					return null;
				}
				
            	String jd = split[1];
            	String re = split[2];
                NanoDate nd = ElabUtil.julianToGregorianCST(Integer
                        .parseInt(jd), parseToDouble(re));   	
				Long timeinmillis = nd.getTime();
				double thresh = parseToDouble(split[4]);
				String concatTimeThresh = String.valueOf(timeinmillis)+","+String.valueOf(thresh);
				plotData.put(i, concatTimeThresh);
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
		} catch (Exception e) {
			return null;
		}
		return plotData;
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
	
	public void saveFileHistogramData(JsonWriter writer) {
		try {
			writer.beginObject();
			if (fluxData != null) {
				saveFile(writer, "green", "1", 0);
				saveFileError(writer, "green", "error", "cross", 1);
			}
			writer.name("binValue").value(getBinValue());
			writer.name("minX").value(getMinX());
			writer.name("maxX").value(getMaxX());
			writer.name("nBins").value(getNBins());
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
			writer.endObject();
		} catch (Exception e) {
			System.out.println("Flux Serializer: "+e.getMessage());
		}		
		
	}//end of saveFileHistogramData
	
	public void saveFile(JsonWriter writer, String color, String name, int ndx) {
		try {
			writer.name("fluxdata");
			writer.beginObject();
			writer.name("label").value("Events");
			writer.name("data");
			writer.beginArray();
			for (Map.Entry<Integer,String> entry: fluxData.entrySet()) {
				String[] value = entry.getValue().split(",");
				//writer.beginArray();
				writer.value(Long.parseLong(value[0]));
				//writer.value(Double.parseDouble(value[1]));
				//writer.endArray();
			}
			writer.endArray();
			writer.name("data_original");
			writer.beginArray();
			for (Map.Entry<Integer,String> entry: fluxData.entrySet()) {
				String[] value = entry.getValue().split(",");
				//writer.beginArray();
				writer.value(Long.parseLong(value[0]));
				//writer.value(Double.parseDouble(value[1]));
				//writer.endArray();
			}
			writer.endArray();
			writer.name("shadowSize").value(0);
			writer.name("color").value(color);
			writer.name("xunits").value("time");
			writer.name("yunits").value("events");
			writer.name("idx").value(ndx);
			writer.name("toggle").value(true);
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
			System.out.println("Flux Serializer: "+e.getMessage());
		}		
	}//end of saveFileChannel

	public void saveFileError(JsonWriter writer, String color, String name, String symbol, int ndx) {
		try {			
			writer.name(name);
			writer.beginObject();
			writer.name("label").value(" ");
			writer.name("data");
			writer.beginArray();
			writer.value(0);
			writer.endArray();		
			writer.name("shadowSize").value(0);
			writer.name("color").value(color);
			writer.name("xunits").value("time");
			writer.name("yunits").value("events");
			writer.name("idx").value(ndx);
			writer.name("toggle").value(false);
			writer.name("points");
			writer.beginObject();
			writer.name("show").value(true);
			writer.name("errorbars").value("y");
			writer.name("symbol").value(symbol);
			writer.name("color").value(color);
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
			writer.endObject();
			writer.flush();
		} catch (Exception e) {
			System.out.println("Flux Stream: "+e.getMessage());
		}		
	}//end of saveFileChannelError
	
	public String getGsonFromJson(String outputDir) {
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
			System.out.println("Flux Stream: "+e.getMessage());
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