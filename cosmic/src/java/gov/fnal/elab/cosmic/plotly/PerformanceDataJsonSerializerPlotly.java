package gov.fnal.elab.cosmic.plotly;
/*
 * This code builds the json object for the scatter plots
 * 
 */

import java.lang.reflect.Type;
import java.util.TreeMap;

import com.google.gson.*;

public class PerformanceDataJsonSerializerPlotly implements JsonSerializer<PerformancePlotDataPlotly> {

	@Override
	public JsonElement serialize(PerformancePlotDataPlotly src, Type typeOfSrc,
			JsonSerializationContext context) {
		
		TreeMap<Integer, PerformancePlotDataPlotly.timePulseData> tm1 = src.getTimePulseDataChannel1(); 				
		TreeMap<Integer, PerformancePlotDataPlotly.timePulseData> tm2 = src.getTimePulseDataChannel2(); 				
		TreeMap<Integer, PerformancePlotDataPlotly.timePulseData> tm3 = src.getTimePulseDataChannel3(); 				
		TreeMap<Integer, PerformancePlotDataPlotly.timePulseData> tm4 = src.getTimePulseDataChannel4(); 				
		JsonArray tmpx, tmpy, tmperror;
		tmpx = new JsonArray();
		tmpy = new JsonArray();
		tmperror = new JsonArray();
		
		for (int i : tm1.keySet()) {
			PerformancePlotDataPlotly.timePulseData tpd = tm1.get(i);
			tmpx.add(new JsonPrimitive(tpd.getTimeOverThreshold()));
			tmpy.add(new JsonPrimitive(tpd.getPulse()));
			tmperror.add(new JsonPrimitive(tpd.getYError()));
		}

		JsonObject chan1 = new JsonObject();
		chan1.add("x", tmpx);
		chan1.add("y", tmpy);
		JsonObject yerr1 = new JsonObject();
		yerr1.addProperty("visible", true);
		yerr1.addProperty("type", "data");
		yerr1.add("array", tmperror);
		chan1.add("error_y", yerr1);
		chan1.addProperty("type", "scatter");
		chan1.addProperty("name", "Channel 1");
		JsonObject marker1 = new JsonObject();
		marker1.addProperty("color", "red");
		marker1.addProperty("size",5);
		JsonObject line1 = new JsonObject();
		line1.addProperty("color", "red");
		line1.addProperty("size", 0.5);
		marker1.add("line", line1);
		chan1.add("marker", marker1);
		
		tmpx = new JsonArray();
		tmpy = new JsonArray();
		tmperror = new JsonArray();
		for (int i : tm2.keySet()) {
			PerformancePlotDataPlotly.timePulseData tpd = tm2.get(i);
			tmpx.add(new JsonPrimitive(tpd.getTimeOverThreshold()));
			tmpy.add(new JsonPrimitive(tpd.getPulse()));
			tmperror.add(new JsonPrimitive(tpd.getYError()));
		}

		JsonObject chan2 = new JsonObject();
		chan2.add("x", tmpx);
		chan2.add("y", tmpy);
		JsonObject yerr2 = new JsonObject();
		yerr2.addProperty("visible", true);
		yerr2.addProperty("type", "data");
		yerr2.add("array", tmperror);
		chan2.add("error_y", yerr2);
		chan2.addProperty("type", "scatter");
		chan2.addProperty("name", "Channel 2");
		JsonObject marker2 = new JsonObject();
		marker2.addProperty("color", "green");
		marker2.addProperty("size",5);
		JsonObject line2 = new JsonObject();
		line2.addProperty("color", "green");
		line2.addProperty("size", 0.5);
		marker2.add("line", line2);
		chan2.add("marker", marker2);
		
		tmpx = new JsonArray();
		tmpy = new JsonArray();
		tmperror = new JsonArray();
		for (int i : tm3.keySet()) {
			PerformancePlotDataPlotly.timePulseData tpd = tm3.get(i);
			tmpx.add(new JsonPrimitive(tpd.getTimeOverThreshold()));
			tmpy.add(new JsonPrimitive(tpd.getPulse()));
			tmperror.add(new JsonPrimitive(tpd.getYError()));
		}

		JsonObject chan3 = new JsonObject();
		chan3.add("x", tmpx);
		chan3.add("y", tmpy);
		JsonObject yerr3 = new JsonObject();
		yerr3.addProperty("visible", true);
		yerr3.addProperty("type", "data");
		yerr3.add("array", tmperror);
		chan3.add("error_y", yerr3);
		chan3.addProperty("type", "scatter");
		chan3.addProperty("name", "Channel 3");
		JsonObject marker3 = new JsonObject();
		marker3.addProperty("color", "blue");
		marker3.addProperty("size",5);
		JsonObject line3 = new JsonObject();
		line3.addProperty("color", "blue");
		line3.addProperty("size", 0.5);
		marker3.add("line", line3);
		chan3.add("marker", marker3);

		tmpx = new JsonArray();
		tmpy = new JsonArray();
		tmperror = new JsonArray();
		for (int i : tm4.keySet()) {
			PerformancePlotDataPlotly.timePulseData tpd = tm4.get(i);
			tmpx.add(new JsonPrimitive(tpd.getTimeOverThreshold()));
			tmpy.add(new JsonPrimitive(tpd.getPulse()));
			tmperror.add(new JsonPrimitive(tpd.getYError()));
		}

		JsonObject chan4 = new JsonObject();
		chan4.add("x", tmpx);
		chan4.add("y", tmpy);
		JsonObject yerr4 = new JsonObject();
		yerr4.addProperty("visible", true);
		yerr4.addProperty("type", "data");
		yerr4.add("array", tmperror);
		chan4.add("error_y", yerr4);
		chan4.addProperty("type", "scatter");
		chan4.addProperty("name", "Channel 4");
		JsonObject marker4 = new JsonObject();
		marker4.addProperty("color", "cyan");
		marker4.addProperty("size",5);
		JsonObject line4 = new JsonObject();
		line4.addProperty("color", "cyan");
		line4.addProperty("size", 0.5);
		marker4.add("line", line4);
		chan4.add("marker", marker4);
		
		JsonObject complete = new JsonObject(); 
		complete.add("channel1", chan1);
		complete.add("channel2", chan2);
		complete.add("channel3", chan3);
		complete.add("channel4", chan4);
		return complete; 
	}
}
