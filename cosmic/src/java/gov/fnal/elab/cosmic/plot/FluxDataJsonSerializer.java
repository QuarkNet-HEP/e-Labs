/*
 * This code builds the json object for the scatter plots
 * 
 */
package gov.fnal.elab.cosmic.plot;

import java.lang.reflect.Type;
import java.util.TreeMap;

import com.google.gson.*;

public class FluxDataJsonSerializer implements JsonSerializer<FluxPlotData> {

	@Override
	public JsonElement serialize(FluxPlotData src, Type typeOfSrc,
			JsonSerializationContext context) {

		TreeMap<Integer, FluxPlotData.eventTimeData> tm = src.getTimeEvents();
		JsonArray fluxData  = new JsonArray();
		JsonArray tmp;
		String legend = "";
		String xunits = "";
		String yunits = "";
		String xaxisposition = "";
		String yaxisposition = "";
		int ndx = 0;
		boolean drawxaxis = false;
		boolean drawyaxis = false;
		String xaxisnum = "1";
		String yaxisnum = "1";
		
		for (int i : tm.keySet()) {
			FluxPlotData.eventTimeData td = tm.get(i);
			tmp = new JsonArray();
			//tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(td.getTimeMillis()));
			tmp.add(new JsonPrimitive(td.getEvents()));
			tmp.add(new JsonPrimitive(td.getYError()));
			fluxData.add(tmp); 
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
		data1.add("data", fluxData);
		data1.addProperty("xunits", "time");
	    data1.addProperty("yunits", "events");
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
		complete.add("fluxdata", data1);
		
		return complete; 
	}

}
