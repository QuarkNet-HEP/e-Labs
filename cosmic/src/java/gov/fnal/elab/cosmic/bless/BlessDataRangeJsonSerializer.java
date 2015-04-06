/*
 * This code builds the json object for the scatter plots
 * 
 * Edit Peronja: 01/23/2013 - Bug 472: code updates, see below
 */
package gov.fnal.elab.cosmic.bless;

import java.lang.reflect.Type;
import java.util.TreeMap;

import com.google.gson.*;

public class BlessDataRangeJsonSerializer implements JsonSerializer<BlessData> {

	@Override
	public JsonElement serialize(BlessData src, Type typeOfSrc,
			JsonSerializationContext context) {
		
		TreeMap<Long, BlessData.valueData> tm = src.timeValueDataRange(); 
		JsonArray channel1Data  = new JsonArray();
		JsonArray channel2Data  = new JsonArray();
		JsonArray channel3Data  = new JsonArray();
		JsonArray channel4Data  = new JsonArray();
		JsonArray triggerData  = new JsonArray();
		JsonArray pressureData = new JsonArray();
		JsonArray tempData = new JsonArray(); 
		JsonArray voltData = new JsonArray();
		JsonArray satData  = new JsonArray();
		boolean isBenchmarked = false;
		JsonArray tmp; 
		
		for (Long i : tm.keySet()) {
			BlessData.valueData vd = tm.get(i);	
			isBenchmarked = vd.isBenchmarked();
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel1Rate()));
			channel1Data.add(tmp); 
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel2Rate()));
			channel2Data.add(tmp);
					
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel3Rate()));
			channel3Data.add(tmp);
							
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel4Rate()));
			channel4Data.add(tmp);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getTriggerRate()));
			triggerData.add(tmp);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getGpsSatellitesVisible())); 
			satData.add(tmp);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getVoltage()));  
			voltData.add(tmp);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getTemperature())); 
			tempData.add(tmp);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getPressure())); 
			pressureData.add(tmp);
		}
		
		//EPeronja-01/18/2013: Bug472-Added a custom point to channel1 to be able to choose a symbol
		JsonObject point1 = new JsonObject();
		point1.addProperty("errorbars", "n");
		point1.addProperty("symbol", "square");
		point1.addProperty("show", 1);
		point1.addProperty("radius", 1.5);
		
		JsonObject channel1 = new JsonObject();
		channel1.addProperty("label", "Channel 1");
		channel1.add("data", channel1Data);
		channel1.addProperty("unit", "counts/min");
		channel1.addProperty("shadowSize", 0);
		channel1.addProperty("color", "red");
		channel1.addProperty("idx", 0);
		channel1.add("points", point1);

		JsonObject point2 = new JsonObject();
		point2.addProperty("errorbars", "n");
		point2.addProperty("symbol", "diamond");
		point2.addProperty("show", 1);
		point2.addProperty("radius", 1.5);
		
		JsonObject channel2 = new JsonObject();
		channel2.addProperty("label", "Channel 2");
		channel2.add("data", channel2Data);
		channel2.addProperty("unit", "counts/min");
		channel2.addProperty("shadowSize", 0);
		channel2.addProperty("color", "green");
		channel2.addProperty("idx", 1);		
		channel2.add("points", point2);

		JsonObject point3 = new JsonObject();
		point3.addProperty("errorbars", "n");
		point3.addProperty("symbol", "triangle");
		point3.addProperty("show", 1);
		point3.addProperty("radius", 1.5);
		
		JsonObject channel3 = new JsonObject();
		channel3.addProperty("label", "Channel 3");
		channel3.add("data", channel3Data);
		channel3.addProperty("unit", "counts/min");
		channel3.addProperty("shadowSize", 0);
		channel3.addProperty("color", "#2b65ec");
		channel3.addProperty("idx", 2);		
		channel3.add("points", point3);

		JsonObject point4 = new JsonObject();
		point4.addProperty("errorbars", "n");
		point4.addProperty("symbol", "circle");
		point4.addProperty("show", 1);
		point4.addProperty("radius", 1.5);
		
		JsonObject channel4 = new JsonObject();
		channel4.addProperty("label", "Channel 4");
		channel4.add("data", channel4Data);
		channel4.addProperty("unit", "counts/min");
		channel4.addProperty("shadowSize", 0);
		channel4.addProperty("color", "cyan");
		channel4.addProperty("idx", 3);
		channel4.add("points", point4);
 
 		JsonObject points = new JsonObject();
		points.addProperty("errorbars", "n");
		   
		JsonObject trigger = new JsonObject();
		trigger.addProperty("label", "Trigger");
		trigger.add("data", triggerData);
		trigger.addProperty("shadowSize", 0);
		trigger.addProperty("color", "magenta");
		trigger.add("points", points);
	
		JsonObject gpsSats = new JsonObject();
		gpsSats.addProperty("label", "GPS Satellites");
		gpsSats.add("data", satData);
		gpsSats.addProperty("shadowSize", 0);
		
		JsonObject volts = new JsonObject();
		volts.addProperty("label", "Volts");
		volts.add("data", voltData);
		volts.addProperty("shadowSize", 0);
		
		JsonObject temperature = new JsonObject();
		temperature.addProperty("label", "Temperature");
		temperature.add("data", tempData);
		temperature.addProperty("shadowSize", 0);
		
		JsonObject pressure = new JsonObject();
		pressure.addProperty("label", "Pressure");
		pressure.add("data", pressureData);
		pressure.addProperty("shadowSize", 0);
		
		JsonObject complete = new JsonObject(); 
		complete.add("isBenchmarked", new JsonPrimitive(isBenchmarked));
		complete.add("channel1", channel1);
		complete.add("channel2", channel2);
		complete.add("channel3", channel3);
		complete.add("channel4", channel4);
		complete.add("trigger", trigger);
		complete.add("satellites", gpsSats);
		complete.add("temperature", temperature);
		complete.add("pressure", pressure);
		complete.add("voltage", volts);
		
		return complete; 
	}

}
