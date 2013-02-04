/*
 * This code builds the json object for the scatter plots
 * 
 * Edit Peronja: 01/23/2013 - Bug 472: code updates, see below
 */
package gov.fnal.elab.cosmic.bless;

import java.lang.reflect.Type;
import java.util.TreeMap;

import com.google.gson.*;

public class BlessDataJsonSerializer implements JsonSerializer<BlessData> {

	@Override
	public JsonElement serialize(BlessData src, Type typeOfSrc,
			JsonSerializationContext context) {
		
		TreeMap<Integer, BlessData.valueData> tm = src.getTimeValueData(); 
				
		JsonArray channel1Data  = new JsonArray();
		JsonArray channel2Data  = new JsonArray();
		JsonArray channel3Data  = new JsonArray();
		JsonArray channel4Data  = new JsonArray();
		JsonArray triggerData  = new JsonArray();
		JsonArray pressureData = new JsonArray();
		JsonArray tempData = new JsonArray(); 
		JsonArray voltData = new JsonArray();
		JsonArray satData  = new JsonArray();
		
		JsonArray tmp; 
		for (int i : tm.keySet()) {
			BlessData.valueData vd = tm.get(i);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel1Rate()));
			tmp.add(new JsonPrimitive((double) vd.getChannel1Error() / 2.0));
			channel1Data.add(tmp); 
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel2Rate()));
			tmp.add(new JsonPrimitive((double) vd.getChannel2Error() / 2.0));
			channel2Data.add(tmp);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel3Rate()));
			tmp.add(new JsonPrimitive((double) vd.getChannel3Error() / 2.0));
			channel3Data.add(tmp);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel4Rate()));
			tmp.add(new JsonPrimitive((double) vd.getChannel4Error() / 2.0));
			channel4Data.add(tmp);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getTriggerRate()));
			tmp.add(new JsonPrimitive((double) vd.getTriggerError() / 2.0));
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
		
		JsonObject yerr = new JsonObject();
		yerr.addProperty("show", true);
		yerr.addProperty("upperCap", "-");
		yerr.addProperty("lowerCap", "-");
		yerr.addProperty("radius", 3);

		JsonObject points = new JsonObject();
		points.addProperty("errorbars", "n");
		points.add("yerr", yerr);
		
		//EPeronja-01/18/2013: Bug472-Added a custom point to channel1 to be able to choose a symbol
		JsonObject point1 = new JsonObject();
		point1.addProperty("errorbars", "n");
		point1.add("yerr", yerr);
		point1.addProperty("symbol", "square");
		point1.addProperty("show", 1);
		point1.addProperty("radius", 1.5);
		
		JsonObject channel1 = new JsonObject();
		channel1.addProperty("label", "Channel 1");
		channel1.add("data", channel1Data);
		channel1.addProperty("unit", "counts/min");
		channel1.addProperty("shadowSize", 0);
		channel1.addProperty("color", "red");
		//EPeronja-01/22/2013: Bug472-Added this property in order to be able to format the labels in blessing.js
		channel1.addProperty("idx", 0);
		channel1.add("points", point1);

		//EPeronja-01/18/2013: Bug472-Added a custom point to channel2 to be able to choose a symbol
		JsonObject point2 = new JsonObject();
		point2.addProperty("errorbars", "n");
		point2.add("yerr", yerr);
		point2.addProperty("symbol", "diamond");
		point2.addProperty("show", 1);
		point2.addProperty("radius", 1.5);
		
		JsonObject channel2 = new JsonObject();
		channel2.addProperty("label", "Channel 2");
		channel2.add("data", channel2Data);
		channel2.addProperty("unit", "counts/min");
		channel2.addProperty("shadowSize", 0);
		channel2.addProperty("color", "green");
		//EPeronja-01/22/2013: Bug472-Added this property in order to be able to format the labels in blessing.js
		channel2.addProperty("idx", 1);		
		channel2.add("points", point2);

		//EPeronja-01/18/2013: Bug472-Added a custom point to channel3 to be able to choose a symbol		
		JsonObject point3 = new JsonObject();
		point3.addProperty("errorbars", "n");
		point3.add("yerr", yerr);
		point3.addProperty("symbol", "triangle");
		point3.addProperty("show", 1);
		point3.addProperty("radius", 1.5);
		
		JsonObject channel3 = new JsonObject();
		channel3.addProperty("label", "Channel 3");
		channel3.add("data", channel3Data);
		channel3.addProperty("unit", "counts/min");
		channel3.addProperty("shadowSize", 0);
		channel3.addProperty("color", "blue");
		//EPeronja-01/22/2013: Bug472-Added this property in order to be able to format the labels in blessing.js		
		channel3.addProperty("idx", 2);		
		channel3.add("points", point3);

		//EPeronja-01/18/2013: Bug472-Added a custom point to channel4 to be able to choose a symbol
		JsonObject point4 = new JsonObject();
		point4.addProperty("errorbars", "n");
		point4.add("yerr", yerr);
		point4.addProperty("symbol", "circle");
		point4.addProperty("show", 1);
		point4.addProperty("radius", 1.5);
		
		JsonObject channel4 = new JsonObject();
		channel4.addProperty("label", "Channel 4");
		channel4.add("data", channel4Data);
		channel4.addProperty("unit", "counts/min");
		channel4.addProperty("shadowSize", 0);
		channel4.addProperty("color", "cyan");
		//EPeronja-01/22/2013: Bug472-Added this property in order to be able to format the labels in blessing.js		
		channel4.addProperty("idx", 3);
		channel4.add("points", point4);
		
		JsonObject trigger = new JsonObject();
		trigger.addProperty("label", "Trigger");
		trigger.add("data", triggerData);
		//trigger.addProperty("unit", "counts/min");
		trigger.addProperty("ylabel", "Trigger Rate");
		trigger.addProperty("unit", "Hz");		
		trigger.addProperty("shadowSize", 0);
		trigger.addProperty("color", "magenta");
		trigger.add("points", points);
		
		JsonObject gpsSats = new JsonObject();
		gpsSats.addProperty("label", "GPS Satellites");
		gpsSats.add("data", satData);
		//EPeronja-01/23/2013: Bug472-Updated label below
		gpsSats.addProperty("ylabel", "# Satellites in view");
		gpsSats.addProperty("shadowSize", 0);
		
		JsonObject volts = new JsonObject();
		volts.addProperty("label", "Volts");
		volts.add("data", voltData);
		volts.addProperty("ylabel", "Vcc");
		//EPeronja-01/23/2013: Bug472-Updated label below		
		volts.addProperty("unit", "Volts");
		volts.addProperty("shadowSize", 0);
		
		JsonObject temperature = new JsonObject();
		temperature.addProperty("label", "Temperature");
		temperature.add("data", tempData);
		temperature.addProperty("ylabel", "Temperature");
		temperature.addProperty("unit", "&deg; C");
		temperature.addProperty("shadowSize", 0);
		
		JsonObject pressure = new JsonObject();
		pressure.addProperty("label", "Pressure");
		pressure.add("data", pressureData);
		pressure.addProperty("ylabel", "Pressure");
		pressure.addProperty("unit", "mb");
		pressure.addProperty("shadowSize", 0);
		
		JsonObject complete = new JsonObject(); 
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
