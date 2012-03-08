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
		
		JsonObject channel1 = new JsonObject();
		channel1.addProperty("label", "Channel 1");
		channel1.add("data", channel1Data);
		channel1.addProperty("unit", "counts/min");
		channel1.addProperty("shadowSize", 0);
		channel1.addProperty("color", "red");
		channel1.add("points", points);
		
		JsonObject channel2 = new JsonObject();
		channel2.addProperty("label", "Channel 2");
		channel2.add("data", channel2Data);
		channel2.addProperty("unit", "counts/min");
		channel2.addProperty("shadowSize", 0);
		channel2.addProperty("color", "green");
		channel2.add("points", points);
		
		JsonObject channel3 = new JsonObject();
		channel3.addProperty("label", "Channel 3");
		channel3.add("data", channel3Data);
		channel3.addProperty("unit", "counts/min");
		channel3.addProperty("shadowSize", 0);
		channel3.addProperty("color", "blue");
		channel3.add("points", points);
		
		JsonObject channel4 = new JsonObject();
		channel4.addProperty("label", "Channel 4");
		channel4.add("data", channel4Data);
		channel4.addProperty("unit", "counts/min");
		channel4.addProperty("shadowSize", 0);
		channel4.addProperty("color", "cyan");
		channel4.add("points", points);
		
		JsonObject trigger = new JsonObject();
		trigger.addProperty("label", "Trigger");
		trigger.add("data", triggerData);
		trigger.addProperty("unit", "counts/min");
		trigger.addProperty("shadowSize", 0);
		trigger.addProperty("color", "magenta");
		trigger.add("points", points);
		
		JsonObject gpsSats = new JsonObject();
		gpsSats.addProperty("label", "GPS Satellites");
		gpsSats.add("data", satData);
		gpsSats.addProperty("ylabel", "Satellites in view");
		gpsSats.addProperty("shadowSize", 0);
		
		JsonObject volts = new JsonObject();
		volts.addProperty("label", "Volts");
		volts.add("data", voltData);
		volts.addProperty("ylabel", "Vcc");
		volts.addProperty("unit", "volts");
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
