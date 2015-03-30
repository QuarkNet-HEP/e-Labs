package gov.fnal.elab.cosmic.plot;
/*
 * 	EPeronja: 03/26/2015-Interactive Plots.
 * 						 Create JSON object from PerformancePlotData
 */
import java.lang.reflect.Type;
import java.util.Arrays;
import java.util.TreeMap;
import java.lang.Object;
import java.util.*;
import com.google.gson.*;

public class PerformanceDataJsonSerializer implements JsonSerializer<PerformancePlotData> {

	@Override
	public JsonElement serialize(PerformancePlotData src, Type typeOfSrc,
			JsonSerializationContext context) {
		TreeMap<Integer, PerformancePlotData.singleOutData> tm1 = src.getPerfDataChannel1(); 				
		TreeMap<Integer, PerformancePlotData.singleOutData> tm2 = src.getPerfDataChannel2(); 				
		TreeMap<Integer, PerformancePlotData.singleOutData> tm3 = src.getPerfDataChannel3(); 				
		TreeMap<Integer, PerformancePlotData.singleOutData> tm4 = src.getPerfDataChannel4(); 				
		JsonArray channel1  = new JsonArray();
		JsonArray channel2  = new JsonArray();
		JsonArray channel3  = new JsonArray();
		JsonArray channel4  = new JsonArray();
		int radius = 3;
		Double binValue = src.getBinValue();
		Double minX = src.getMinX();
		Double maxX = src.getMaxX();
		Double nBins = src.getNBins();
		JsonArray bins = new JsonArray();
		for (Double i = Math.floor(minX); i < Math.ceil(maxX); i+=binValue) {
			bins.add(new JsonPrimitive(i));
		}
		//prepare channel1
		JsonObject chan1 = new JsonObject();
		if (tm1 != null) {
			for (int i : tm1.keySet()) {
				PerformancePlotData.singleOutData ppd = tm1.get(i);
				channel1.add(new JsonPrimitive(ppd.getThresh())); 
			}
	
			JsonObject xaxis1 = new JsonObject();
			xaxis1.add("n", new JsonPrimitive(1));
			xaxis1.addProperty("position", "bottom");
	
			JsonObject yaxis1 = new JsonObject();
			yaxis1.add("n", new JsonPrimitive(1));
			yaxis1.addProperty("position", "left");
	
			chan1.addProperty("label", "Channel 1");
			chan1.add("data", channel1);
			chan1.add("data_original", channel1);
			chan1.addProperty("shadowSize", 0);
			chan1.addProperty("color", "red");
			chan1.addProperty("xunits", "nanosecs");
			chan1.addProperty("yunits", "pulses");
			chan1.addProperty("idx", 0);
			chan1.add("xaxis", xaxis1);
			chan1.add("yaxis", yaxis1);
		}
		//prepare channel2
		JsonObject chan2 = new JsonObject();
		if (tm2 != null) {
			for (int i : tm2.keySet()) {
				PerformancePlotData.singleOutData ppd = tm2.get(i);
				channel2.add(new JsonPrimitive(ppd.getThresh())); 
			}
			
			JsonObject xaxis2 = new JsonObject();
			xaxis2.add("n", new JsonPrimitive(1));
			xaxis2.addProperty("position", "bottom");
	
			JsonObject yaxis2 = new JsonObject();
			yaxis2.add("n", new JsonPrimitive(1));
			yaxis2.addProperty("position", "left");
	
			chan2.addProperty("label", "Channel 2");
			chan2.add("data", channel2);
			chan2.add("data_original", channel2);
			chan2.addProperty("shadowSize", 0);
			chan2.addProperty("color", "#00ff00");
			chan2.addProperty("xunits", "nanosecs");
			chan2.addProperty("yunits", "pulses");
			chan2.addProperty("idx", 1);
			chan2.add("xaxis", xaxis2);
			chan2.add("yaxis", yaxis2);
		}
		//prepare channel3
		JsonObject chan3 = new JsonObject();
		if (tm3 != null) {
			for (int i : tm3.keySet()) {
				PerformancePlotData.singleOutData ppd = tm3.get(i);
				channel3.add(new JsonPrimitive(ppd.getThresh())); 
			}
			
			JsonObject xaxis3 = new JsonObject();
			xaxis3.add("n", new JsonPrimitive(1));
			xaxis3.addProperty("position", "bottom");
	
			JsonObject yaxis3 = new JsonObject();
			yaxis3.add("n", new JsonPrimitive(1));
			yaxis3.addProperty("position", "left");
	
			chan3.addProperty("label", "Channel 3");
			chan3.add("data", channel3);
			chan3.add("data_original", channel3);
			chan3.addProperty("shadowSize", 0);
			chan3.addProperty("color", "blue");
			chan3.addProperty("xunits", "nanosecs");
			chan3.addProperty("yunits", "pulses");
			chan3.addProperty("idx", 2);
			chan3.add("xaxis", xaxis3);
			chan3.add("yaxis", yaxis3);
		}
		//prepare channel4
		JsonObject chan4 = new JsonObject();
		if (tm4 != null) {
			for (int i : tm4.keySet()) {
				PerformancePlotData.singleOutData ppd = tm4.get(i);
				channel4.add(new JsonPrimitive(ppd.getThresh())); 
			}
			
			JsonObject xaxis4 = new JsonObject();
			xaxis4.add("n", new JsonPrimitive(1));
			xaxis4.addProperty("position", "bottom");
		
			JsonObject yaxis4 = new JsonObject();
			yaxis4.add("n", new JsonPrimitive(1));
			yaxis4.addProperty("position", "left");
	
			chan4.addProperty("label", "Channel 4");
			chan4.add("data", channel4);
			chan4.add("data_original", channel4);
			chan4.addProperty("shadowSize", 0);
			chan4.addProperty("color", "cyan");
			chan4.addProperty("xunits", "nanosecs");
			chan4.addProperty("yunits", "pulses");
			chan4.addProperty("idx", 3);
			chan4.add("xaxis", xaxis4);
			chan4.add("yaxis", yaxis4);
		}
		JsonObject complete = new JsonObject(); 
		complete.add("channel1", chan1);
		complete.add("channel2", chan2);
		complete.add("channel3", chan3);
		complete.add("channel4", chan4);		
		complete.addProperty("binValue", binValue);
		complete.addProperty("minX", minX);
		complete.addProperty("maxX", maxX);
		complete.addProperty("nBins", nBins);
		complete.add("bins", bins);

		return complete; 
	}//end of serialize
	
	
}//end of PerformanceDataJsonSerializer
