/*
 * This code builds the json object for the scatter plots
 * 
 */
package gov.fnal.elab.cosmic.plot;

import java.lang.reflect.Type;
import java.util.TreeMap;

import com.google.gson.*;

public class PerformanceDataJsonSerializer implements JsonSerializer<PerformancePlotData> {

	@Override
	public JsonElement serialize(PerformancePlotData src, Type typeOfSrc,
			JsonSerializationContext context) {
		
		TreeMap<Integer, PerformancePlotData.timePulseData> tm1 = src.getTimePulseDataChannel1(); 				
		TreeMap<Integer, PerformancePlotData.timePulseData> tm2 = src.getTimePulseDataChannel2(); 				
		TreeMap<Integer, PerformancePlotData.timePulseData> tm3 = src.getTimePulseDataChannel3(); 				
		TreeMap<Integer, PerformancePlotData.timePulseData> tm4 = src.getTimePulseDataChannel4(); 				
		JsonArray channel1  = new JsonArray();
		JsonArray channel2  = new JsonArray();
		JsonArray channel3  = new JsonArray();
		JsonArray channel4  = new JsonArray();
		JsonArray tmp; 
		for (int i : tm1.keySet()) {
			PerformancePlotData.timePulseData tpd = tm1.get(i);
			tmp = new JsonArray();
			//tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(tpd.getTimeOverThreshold()));
			tmp.add(new JsonPrimitive(tpd.getPulse()));
			tmp.add(new JsonPrimitive(tpd.getYError()));
			channel1.add(tmp); 
		}
		JsonObject yerr1 = new JsonObject();
		yerr1.addProperty("show", true);
		yerr1.addProperty("upperCap", "-");
		yerr1.addProperty("lowerCap", "-");
		yerr1.addProperty("radius", 5);
		yerr1.addProperty("color", "red");
		
		JsonObject point1 = new JsonObject();
		point1.addProperty("errorbars", "y");
		point1.add("yerr", yerr1);
		point1.addProperty("symbol", "square");
		point1.addProperty("show", 1);
		point1.addProperty("radius", 1.5);
		
		JsonObject chan1 = new JsonObject();
		chan1.addProperty("label", "Channel 1");
		chan1.add("data", channel1);
		chan1.addProperty("unit", "counts/min");
		chan1.addProperty("shadowSize", 0);
		chan1.addProperty("color", "red");
		chan1.addProperty("idx", 0);
		chan1.add("points", point1);

		for (int i : tm2.keySet()) {
			PerformancePlotData.timePulseData tpd = tm2.get(i);
			tmp = new JsonArray();
			//tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(tpd.getTimeOverThreshold()));
			tmp.add(new JsonPrimitive(tpd.getPulse()));
			tmp.add(new JsonPrimitive(tpd.getYError()));
			channel2.add(tmp); 
		}
		JsonObject yerr2 = new JsonObject();
		yerr2.addProperty("show", true);
		yerr2.addProperty("upperCap", "-");
		yerr2.addProperty("lowerCap", "-");
		yerr2.addProperty("radius", 5);
		yerr2.addProperty("color", "green");
				
		JsonObject point2 = new JsonObject();
		point2.addProperty("errorbars", "y");
		point2.add("yerr", yerr2);
		point2.addProperty("symbol", "diamond");
		point2.addProperty("show", 1);
		point2.addProperty("radius", 1.5);
		
		JsonObject chan2 = new JsonObject();
		chan2.addProperty("label", "Channel 2");
		chan2.add("data", channel2);
		chan2.addProperty("unit", "counts/min");
		chan2.addProperty("shadowSize", 0);
		chan2.addProperty("color", "green");
		chan2.addProperty("idx", 1);
		chan2.add("points", point2);
		
		for (int i : tm3.keySet()) {
			PerformancePlotData.timePulseData tpd = tm3.get(i);
			tmp = new JsonArray();
			//tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(tpd.getTimeOverThreshold()));
			tmp.add(new JsonPrimitive(tpd.getPulse()));
			tmp.add(new JsonPrimitive(tpd.getYError()));
			channel3.add(tmp); 
		}
		JsonObject yerr3 = new JsonObject();
		yerr3.addProperty("show", true);
		yerr3.addProperty("upperCap", "-");
		yerr3.addProperty("lowerCap", "-");
		yerr3.addProperty("radius", 5);
		yerr3.addProperty("color", "blue");
				
		JsonObject point3 = new JsonObject();
		point3.addProperty("errorbars", "y");
		point3.add("yerr", yerr3);
		point3.addProperty("symbol", "triangle");
		point3.addProperty("show", 1);
		point3.addProperty("radius", 1.5);
		
		JsonObject chan3 = new JsonObject();
		chan3.addProperty("label", "Channel 3");
		chan3.add("data", channel3);
		chan3.addProperty("unit", "counts/min");
		chan3.addProperty("shadowSize", 0);
		chan3.addProperty("color", "blue");
		chan3.addProperty("idx", 2);
		chan3.add("points", point3);

		for (int i : tm4.keySet()) {
			PerformancePlotData.timePulseData tpd = tm4.get(i);
			tmp = new JsonArray();
			//tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(tpd.getTimeOverThreshold()));
			tmp.add(new JsonPrimitive(tpd.getPulse()));
			tmp.add(new JsonPrimitive(tpd.getYError()));
			channel4.add(tmp); 
		}
		JsonObject yerr4 = new JsonObject();
		yerr4.addProperty("show", true);
		yerr4.addProperty("upperCap", "-");
		yerr4.addProperty("lowerCap", "-");
		yerr4.addProperty("radius", 5);
		yerr4.addProperty("color", "cyan");
		
		JsonObject point4 = new JsonObject();
		point4.addProperty("errorbars", "y");
		point4.add("yerr", yerr4);
		point4.addProperty("symbol", "circle");
		point4.addProperty("show", 1);
		point4.addProperty("radius", 1.5);
		
		JsonObject chan4 = new JsonObject();
		chan4.addProperty("label", "Channel 4");
		chan4.add("data", channel4);
		chan4.addProperty("unit", "counts/min");
		chan4.addProperty("shadowSize", 0);
		chan4.addProperty("color", "cyan");
		chan4.addProperty("idx", 3);
		chan4.add("points", point4);		
		
		JsonObject complete = new JsonObject(); 
		complete.add("channel1", chan1);
		complete.add("channel2", chan2);
		complete.add("channel3", chan3);
		complete.add("channel4", chan4);
		
		return complete; 
	}

}
