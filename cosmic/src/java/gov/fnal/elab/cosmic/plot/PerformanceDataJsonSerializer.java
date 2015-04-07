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
		JsonArray channel1  = new JsonArray();
		JsonArray channel2  = new JsonArray();
		JsonArray channel3  = new JsonArray();
		JsonArray channel4  = new JsonArray();
		Double binValue = src.getBinValue();
		Double minX = src.getMinX();
		Double maxX = src.getMaxX();
		Double nBins = src.getNBins();
		JsonArray bins = new JsonArray();
		JsonArray fakeBins = new JsonArray();
		for (Double i = Math.floor(minX); i < Math.ceil(maxX); i+=binValue) {
			bins.add(new JsonPrimitive(i));
			fakeBins.add(new JsonPrimitive(i+0.00001));
		}
		//prepare channel1
		JsonObject chan1 = new JsonObject();
		JsonObject chan1error = new JsonObject();
		if (src.getPerfDataChannel1() != null) {
			//for (int i = 0; i < tm1.size(); i++){
			//	channel1.add(new JsonPrimitive(tm1.get(i))); 
			//}
			channel1 = src.getPerfDataChannel1();

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
			chan1.addProperty("toggle",true);
			chan1.add("xaxis", xaxis1);
			chan1.add("yaxis", yaxis1);

			JsonObject yerr1 = new JsonObject();
			yerr1.addProperty("show", true);
			yerr1.addProperty("upperCap", "-");
			yerr1.addProperty("lowerCap", "-");
			yerr1.addProperty("radius", 3);
			yerr1.addProperty("color", "red");
			
			JsonObject point1 = new JsonObject();
			point1.addProperty("errorbars", "y");
			point1.add("yerr", yerr1);
			point1.addProperty("symbol", "square");
			point1.addProperty("show", 1);
			point1.addProperty("radius", 1);

			JsonObject lines1 = new JsonObject();
			lines1.addProperty("show", false);			
			chan1error.add("data", channel1);
			chan1error.add("data_original", channel1);
			chan1error.addProperty("label", " ");
			chan1error.addProperty("shadowSize", 0);
			chan1error.addProperty("color", "red");
			chan1error.addProperty("toggle",false);
			chan1error.add("points", point1);
			chan1error.add("lines", lines1);
		}
		//prepare channel2
		JsonObject chan2 = new JsonObject();
		JsonObject chan2error = new JsonObject();		
		if (src.getPerfDataChannel2() != null) {
			//for (int i = 0; i < tm2.size(); i++){
			//	channel2.add(new JsonPrimitive(tm2.get(i))); 
			//}
			channel2 = src.getPerfDataChannel2();
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
			chan2.addProperty("toggle",true);
			chan2.add("xaxis", xaxis2);
			chan2.add("yaxis", yaxis2);

			JsonObject yerr2 = new JsonObject();
			yerr2.addProperty("show", true);
			yerr2.addProperty("upperCap", "-");
			yerr2.addProperty("lowerCap", "-");
			yerr2.addProperty("radius", 3);
			yerr2.addProperty("color", "#00ff00");
			
			JsonObject point2 = new JsonObject();
			point2.addProperty("errorbars", "y");
			point2.add("yerr", yerr2);
			point2.addProperty("symbol", "diamond");
			point2.addProperty("show", 1);
			point2.addProperty("radius", 1);

			JsonObject lines2 = new JsonObject();
			lines2.addProperty("show", false);			
			chan2error.add("data", channel2);
			chan2error.add("data_original", channel2);
			chan2error.addProperty("label", " ");
			chan2error.addProperty("shadowSize", 0);
			chan2error.addProperty("color", "#00ff00");
			chan2error.addProperty("toggle",false);
			chan2error.add("points", point2);
			chan2error.add("lines", lines2);	
		}
		//prepare channel3
		JsonObject chan3 = new JsonObject();
		JsonObject chan3error = new JsonObject();
		if (src.getPerfDataChannel3() != null) {
			//for (int i = 0; i < tm3.size(); i++){
			//	channel3.add(new JsonPrimitive(tm3.get(i))); 
			//}
			channel3 = src.getPerfDataChannel3();
			
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
			chan3.addProperty("toggle",true);
			chan3.add("xaxis", xaxis3);
			chan3.add("yaxis", yaxis3);

			JsonObject yerr3 = new JsonObject();
			yerr3.addProperty("show", true);
			yerr3.addProperty("upperCap", "-");
			yerr3.addProperty("lowerCap", "-");
			yerr3.addProperty("radius", 3);
			yerr3.addProperty("color", "blue");
			
			JsonObject point3 = new JsonObject();
			point3.addProperty("errorbars", "y");
			point3.add("yerr", yerr3);
			point3.addProperty("symbol", "triangle");
			point3.addProperty("show", 1);
			point3.addProperty("radius", 1);

			JsonObject lines3 = new JsonObject();
			lines3.addProperty("show", false);			
			chan3error.add("data", channel3);
			chan3error.add("data_original", channel3);
			chan3error.addProperty("label", " ");
			chan3error.addProperty("shadowSize", 0);
			chan3error.addProperty("color", "blue");
			chan3error.addProperty("toggle",false);
			chan3error.add("points", point3);
			chan3error.add("lines", lines3);	
		}
		//prepare channel4
		JsonObject chan4 = new JsonObject();
		JsonObject chan4error = new JsonObject();		
		if (src.getPerfDataChannel4() != null) {
			//for (int i = 0; i < tm4.size(); i++){
			//	channel4.add(new JsonPrimitive(tm4.get(i))); 
			//}
			channel4 = src.getPerfDataChannel4();
			
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
			chan4.addProperty("toggle",true);
			chan4.add("xaxis", xaxis4);
			chan4.add("yaxis", yaxis4);
			
			JsonObject yerr4 = new JsonObject();
			yerr4.addProperty("show", true);
			yerr4.addProperty("upperCap", "-");
			yerr4.addProperty("lowerCap", "-");
			yerr4.addProperty("radius", 3);
			yerr4.addProperty("color", "cyan");
			
			JsonObject point4 = new JsonObject();
			point4.addProperty("errorbars", "y");
			point4.add("yerr", yerr4);
			point4.addProperty("symbol", "circle");
			point4.addProperty("show", 1);
			point4.addProperty("radius", 1);

			JsonObject lines4 = new JsonObject();
			lines4.addProperty("show", false);			
			chan4error.add("data", channel4);
			chan4error.add("data_original", channel4);
			chan4error.addProperty("label", " ");
			chan4error.addProperty("shadowSize", 0);
			chan4error.addProperty("color", "cyan");
			chan4error.addProperty("toggle",false);
			chan4error.add("points", point4);
			chan4error.add("lines", lines4);			
		}
		JsonObject complete = new JsonObject(); 
		complete.add("channel1", chan1);
		complete.add("channel2", chan2);
		complete.add("channel3", chan3);
		complete.add("channel4", chan4);		
		complete.add("channel1Error", chan1error);		
		complete.add("channel2Error", chan2error);		
		complete.add("channel3Error", chan3error);		
		complete.add("channel4Error", chan4error);		
		complete.addProperty("binValue", binValue);
		complete.addProperty("minX", minX);
		complete.addProperty("maxX", maxX);
		complete.addProperty("nBins", nBins);
		complete.add("bins", bins);
		complete.add("fakeBins", fakeBins);

		return complete; 
	}//end of serialize
	
	
}//end of PerformanceDataJsonSerializer
