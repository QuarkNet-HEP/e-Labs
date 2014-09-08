/*
 * This code builds the json object for the scatter plots
 * 
 */
package gov.fnal.elab.cosmic.plot;

import java.lang.reflect.Type;
import java.util.TreeMap;

import com.google.gson.*;

public class PlotDataJsonSerializer implements JsonSerializer<PlotData> {

	@Override
	public JsonElement serialize(PlotData src, Type typeOfSrc,
			JsonSerializationContext context) {

		String[] colors = {"red", "#00ff00", "blue", "cyan", "purple", "black", "orange", "pink", "yellow", "brown"};		
		TreeMap<Integer, PlotData.Detail> tm = src.getTimeData();  				
		JsonArray uploadedData  = new JsonArray();
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
			PlotData.Detail td = tm.get(i);
			tmp = new JsonArray();
			//tmp.add(new JsonPrimitive(i));
			tmp.add(new JsonPrimitive(td.getX()));
			tmp.add(new JsonPrimitive(td.getY()));
			tmp.add(new JsonPrimitive(td.getYError()));
			ndx = Integer.valueOf(td.getNdx());
			legend = td.getLegend();
			xunits = td.getXUnits();
			yunits = td.getYUnits();
			xaxisposition = td.getXAxisPosition();
			yaxisposition = td.getYAxisPosition();
			drawxaxis = td.getDrawXAxis();
			drawyaxis = td.getDrawYAxis();
			xaxisnum = td.getXAxisNum();
			yaxisnum = td.getYAxisNum();
			uploadedData.add(tmp); 
		}
		JsonObject yerr1 = new JsonObject();
		yerr1.addProperty("show", true);
		yerr1.addProperty("upperCap", "-");
		yerr1.addProperty("lowerCap", "-");
		yerr1.addProperty("radius", 3);
		if (ndx > 9) {
			yerr1.addProperty("color", "black");
		} else {
			if (ndx < 4 && (ndx+3) <= 9) {
				yerr1.addProperty("color", colors[ndx + 3]);
			} else {
				yerr1.addProperty("color", colors[ndx]);				
			}
		}
		
		JsonObject point1 = new JsonObject();
		point1.addProperty("errorbars", "y");
		point1.add("yerr", yerr1);
		point1.addProperty("symbol", "cross");
		point1.addProperty("show", 1);
		point1.addProperty("radius", 3);
		
		JsonObject data1 = new JsonObject();
		data1.addProperty("label", legend);
		data1.add("data", uploadedData);
		data1.addProperty("xunits", xunits);
	    data1.addProperty("yunits", yunits);
		data1.addProperty("shadowSize", 0);
		if (ndx > 9) {
			data1.addProperty("color", "black");
		} else {
			if (ndx < 4 && (ndx+3) <= 9) {
				data1.addProperty("color", colors[ndx + 3]);
			} else {
				data1.addProperty("color", colors[ndx]);				
			}
		}
		data1.addProperty("idx", ndx);
		data1.add("points", point1);
		if (drawxaxis) {
			int currxaxis = Integer.parseInt(xaxisnum);
			JsonObject xaxis1 = new JsonObject();
			xaxis1.add("n", new JsonPrimitive(currxaxis+1));
			if (!xaxisposition.equals("")) {
				xaxis1.addProperty("position", xaxisposition);
			}
			data1.add("xaxis", xaxis1);
		}
		if (drawyaxis) {
			int curryaxis = Integer.parseInt(yaxisnum);
			JsonObject yaxis1 = new JsonObject();
			yaxis1.add("n", new JsonPrimitive(curryaxis+1));
			if (!yaxisposition.equals("")) {
				yaxis1.addProperty("position", yaxisposition);
			}
			data1.add("yaxis", yaxis1);
		}
		JsonObject complete = new JsonObject(); 
		complete.add("uploadedData", data1);
		
		return complete; 
	}

}
