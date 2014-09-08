/*
 * This code builds the json object for the scatter plots
 * 
 */
package gov.fnal.elab.cosmic.plot;

import java.lang.reflect.Type;
import java.util.TreeMap;

import com.google.gson.*;

public class LifetimeDataJsonSerializer implements JsonSerializer<LifetimePlotData> {

	@Override
	public JsonElement serialize(LifetimePlotData src, Type typeOfSrc,
			JsonSerializationContext context) {

		TreeMap<Integer, LifetimePlotData.decayLengthData> tm = src.getDecayLength();
		JsonArray lifetimeData  = new JsonArray();
		JsonArray tmp;
		int ndx = 0;
		
		for (int i : tm.keySet()) {
			LifetimePlotData.decayLengthData td = tm.get(i);
			tmp = new JsonArray();
			//tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(td.getLength()));
			tmp.add(new JsonPrimitive(td.getDecay()));
			tmp.add(new JsonPrimitive(td.getYError()));
			lifetimeData.add(tmp); 
		}
		JsonObject yerr1 = new JsonObject();
		yerr1.addProperty("show", true);
		yerr1.addProperty("upperCap", "-");
		yerr1.addProperty("lowerCap", "-");
		yerr1.addProperty("radius", 3);
		yerr1.addProperty("color", "#00ff00");
		
		JsonObject point1 = new JsonObject();
		point1.addProperty("errorbars", "y");
		point1.add("yerr", yerr1);
		point1.addProperty("symbol", "cross");
		point1.addProperty("show", 1);
		point1.addProperty("radius", 3);
		
		JsonObject data1 = new JsonObject();
		data1.addProperty("label", "Events");
		data1.add("data", lifetimeData);
		data1.addProperty("xunits", "decay length");
	    data1.addProperty("yunits", "no. of decays");
		data1.addProperty("shadowSize", 0);
		data1.addProperty("color", "#00ff00");
		data1.addProperty("idx", ndx);
		data1.add("points", point1);
		JsonObject xaxis1 = new JsonObject();
		xaxis1.add("n", new JsonPrimitive(1));
		data1.add("xaxis", xaxis1);
		JsonObject yaxis1 = new JsonObject();
		yaxis1.add("n", new JsonPrimitive(1));
		data1.add("yaxis", yaxis1);
		JsonObject complete = new JsonObject(); 
		complete.add("lifetimedata", data1);
		
		return complete; 
	}

}
