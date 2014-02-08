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
		JsonArray benchmarkChannel1Data  = new JsonArray();
		JsonArray benchmarkChannel2Data  = new JsonArray();
		JsonArray benchmarkChannel3Data  = new JsonArray();
		JsonArray benchmarkChannel4Data  = new JsonArray();
		JsonArray benchmarkTriggerData  = new JsonArray();
		JsonArray channel1UpperError  = new JsonArray();
		JsonArray channel2UpperError = new JsonArray();
		JsonArray channel3UpperError  = new JsonArray();
		JsonArray channel4UpperError  = new JsonArray();		
		JsonArray channel1LowerError  = new JsonArray();
		JsonArray channel2LowerError = new JsonArray();
		JsonArray channel3LowerError  = new JsonArray();
		JsonArray channel4LowerError  = new JsonArray();		
		JsonArray triggerUpperError  = new JsonArray();
		JsonArray triggerLowerError  = new JsonArray();
		
		JsonArray tmp; 
		for (int i : tm.keySet()) {
			BlessData.valueData vd = tm.get(i);
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel1Rate()));
			tmp.add(new JsonPrimitive((double) vd.getChannel1Error()));
			channel1Data.add(tmp); 

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getChannel1Rate() + (double) vd.getChannel1Error()));
			channel1UpperError.add(tmp); 			

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getChannel1Rate() - (double) vd.getChannel1Error()));
			channel1LowerError.add(tmp); 			
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel2Rate()));
			tmp.add(new JsonPrimitive((double) vd.getChannel2Error()));
			channel2Data.add(tmp);

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getChannel2Rate() + (double) vd.getChannel2Error()));
			channel2UpperError.add(tmp); 			

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getChannel2Rate() - (double) vd.getChannel2Error()));
			channel2LowerError.add(tmp); 			
					
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel3Rate()));
			tmp.add(new JsonPrimitive((double) vd.getChannel3Error()));
			channel3Data.add(tmp);

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getChannel3Rate() + (double) vd.getChannel3Error()));
			channel3UpperError.add(tmp); 			

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getChannel3Rate() - (double) vd.getChannel3Error()));
			channel3LowerError.add(tmp); 			
							
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getChannel4Rate()));
			tmp.add(new JsonPrimitive((double) vd.getChannel4Error()));
			channel4Data.add(tmp);

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getChannel4Rate() + (double) vd.getChannel4Error()));
			channel4UpperError.add(tmp); 			

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getChannel4Rate() - (double) vd.getChannel4Error()));
			channel4LowerError.add(tmp); 			
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(vd.getTriggerRate()));
			tmp.add(new JsonPrimitive((double) vd.getTriggerError()));
			triggerData.add(tmp);

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getTriggerRate() + (double) vd.getTriggerError()));
			triggerUpperError.add(tmp); 			

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getTriggerRate() - (double) vd.getTriggerError()));
			triggerLowerError.add(tmp); 			
			
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

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getBenchmarkChannel1Rate()));
			benchmarkChannel1Data.add(tmp); 			

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getBenchmarkChannel2Rate()));
			benchmarkChannel2Data.add(tmp); 
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getBenchmarkChannel3Rate()));
			benchmarkChannel3Data.add(tmp); 

			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getBenchmarkChannel4Rate()));
			benchmarkChannel4Data.add(tmp); 
			
			tmp = new JsonArray();
			tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive((double) vd.getBenchmarkTriggerRate()));
			benchmarkTriggerData.add(tmp); 			
		}
		
		JsonObject yerr = new JsonObject();
		yerr.addProperty("show", true);
		yerr.addProperty("upperCap", "-");
		yerr.addProperty("lowerCap", "-");
		yerr.addProperty("radius", 1);
		yerr.addProperty("color", "#a8a8a8");

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

		JsonObject benchmarkChannel1 = new JsonObject();
		benchmarkChannel1.add("data", benchmarkChannel1Data);
		benchmarkChannel1.addProperty("color", "black");
        benchmarkChannel1.addProperty("idx", 4);
        benchmarkChannel1.addProperty("radius", 0.25);
                
		JsonObject channel1DataLowerError = new JsonObject();
		channel1DataLowerError.add("data", channel1LowerError);
		channel1DataLowerError.addProperty("color", "#e77471");
		channel1DataLowerError.addProperty("idx", 4);
		channel1DataLowerError.addProperty("radius", 0.25);

		JsonObject channel1DataUpperError = new JsonObject();
		channel1DataUpperError.add("data", channel1UpperError);
		channel1DataUpperError.addProperty("color", "#e77471");
		channel1DataUpperError.addProperty("idx", 4);
		channel1DataUpperError.addProperty("radius", 0.25);		
		
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

		JsonObject benchmarkChannel2 = new JsonObject();
		benchmarkChannel2.add("data", benchmarkChannel2Data);
		benchmarkChannel2.addProperty("color", "black");
        benchmarkChannel2.addProperty("idx", 5);
        benchmarkChannel2.addProperty("radius", 0.25);
 
		JsonObject channel2DataLowerError = new JsonObject();
		channel2DataLowerError.add("data", channel2LowerError);
		channel2DataLowerError.addProperty("color", "#b5eaaa");
		channel2DataLowerError.addProperty("idx", 5);
		channel2DataLowerError.addProperty("radius", 0.25);

		JsonObject channel2DataUpperError = new JsonObject();
		channel2DataUpperError.add("data", channel2UpperError);
		channel2DataUpperError.addProperty("color", "#b5eaaa");
		channel2DataUpperError.addProperty("idx", 5);
		channel2DataUpperError.addProperty("radius", 0.25);		        
        
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
		channel3.addProperty("color", "#2b65ec");
		//EPeronja-01/22/2013: Bug472-Added this property in order to be able to format the labels in blessing.js		
		channel3.addProperty("idx", 2);		
		channel3.add("points", point3);
		
		JsonObject benchmarkChannel3 = new JsonObject();
		benchmarkChannel3.add("data", benchmarkChannel3Data);
		benchmarkChannel3.addProperty("color", "black");
        benchmarkChannel3.addProperty("idx", 6);
        benchmarkChannel3.addProperty("radius", 0.25);

		JsonObject channel3DataLowerError = new JsonObject();
		channel3DataLowerError.add("data", channel3LowerError);
		channel3DataLowerError.addProperty("color", "#82cafa");
		channel3DataLowerError.addProperty("idx", 6);
		channel3DataLowerError.addProperty("radius", 0.25);

		JsonObject channel3DataUpperError = new JsonObject();
		channel3DataUpperError.add("data", channel3UpperError);
		channel3DataUpperError.addProperty("color", "#82cafa");
		channel3DataUpperError.addProperty("idx", 6);
		channel3DataUpperError.addProperty("radius", 0.25);	        
        
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
		
		JsonObject benchmarkChannel4 = new JsonObject();
		benchmarkChannel4.add("data", benchmarkChannel4Data);
		benchmarkChannel4.addProperty("color", "black");
        benchmarkChannel4.addProperty("idx", 7);
        benchmarkChannel4.addProperty("radius", 0.25);

		JsonObject channel4DataLowerError = new JsonObject();
		channel4DataLowerError.add("data", channel4LowerError);
		channel4DataLowerError.addProperty("color", "#9afeff");
		channel4DataLowerError.addProperty("idx", 7);
		channel4DataLowerError.addProperty("radius", 0.25);

		JsonObject channel4DataUpperError = new JsonObject();
		channel4DataUpperError.add("data", channel4UpperError);
		channel4DataUpperError.addProperty("color", "#9afeff");
		channel4DataUpperError.addProperty("idx", 7);
		channel4DataUpperError.addProperty("radius", 0.25);	        
        
		JsonObject trigger = new JsonObject();
		trigger.addProperty("label", "Trigger");
		trigger.add("data", triggerData);
		//trigger.addProperty("unit", "counts/min");
		trigger.addProperty("ylabel", "Trigger Rate");
		trigger.addProperty("unit", "Hz");		
		trigger.addProperty("shadowSize", 0);
		trigger.addProperty("color", "magenta");
		trigger.add("points", points);

		JsonObject benchmarkTrigger = new JsonObject();
		benchmarkTrigger.add("data", benchmarkTriggerData);
		benchmarkTrigger.addProperty("color", "black");
		benchmarkTrigger.addProperty("idx", 1);
		benchmarkTrigger.addProperty("radius", 0.25);		

		JsonObject triggerDataLowerError = new JsonObject();
		triggerDataLowerError.add("data", triggerLowerError);
		triggerDataLowerError.addProperty("color", "#f9b7ff");
		triggerDataLowerError.addProperty("idx", 4);
		triggerDataLowerError.addProperty("radius", 0.25);

		JsonObject triggerDataUpperError = new JsonObject();
		triggerDataUpperError.add("data", triggerUpperError);
		triggerDataUpperError.addProperty("color", "#f9b7ff");
		triggerDataUpperError.addProperty("idx", 4);
		triggerDataUpperError.addProperty("radius", 0.25);	 		
		
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
		complete.add("channel1LowerError", channel1DataLowerError);
		complete.add("channel1UpperError", channel1DataUpperError);
		complete.add("channel2LowerError", channel2DataLowerError);
		complete.add("channel2UpperError", channel2DataUpperError);
		complete.add("channel3LowerError", channel3DataLowerError);
		complete.add("channel3UpperError", channel3DataUpperError);
		complete.add("channel4LowerError", channel4DataLowerError);
		complete.add("channel4UpperError", channel4DataUpperError);
		complete.add("triggerLowerError", triggerDataLowerError);
		complete.add("triggerUpperError", triggerDataUpperError);		
		complete.add("benchmarkChannel1", benchmarkChannel1);
		complete.add("benchmarkChannel2", benchmarkChannel2);
		complete.add("benchmarkChannel3", benchmarkChannel3);
		complete.add("benchmarkChannel4", benchmarkChannel4);
		complete.add("benchmarkTrigger", benchmarkTrigger);
		complete.add("trigger", trigger);
		complete.add("satellites", gpsSats);
		complete.add("temperature", temperature);
		complete.add("pressure", pressure);
		complete.add("voltage", volts);
		
		return complete; 
	}

}
