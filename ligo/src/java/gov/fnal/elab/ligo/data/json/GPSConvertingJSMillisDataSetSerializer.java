package gov.fnal.elab.ligo.data.json;

import gov.fnal.elab.expression.data.engine.DataSet;

import java.lang.reflect.Type;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

public class GPSConvertingJSMillisDataSetSerializer extends DataSetSerializer {
	private int shadowSize = 0; 

	@Override
	public JsonElement serialize(DataSet src, Type typeOfSrc,
			JsonSerializationContext context) {
		JsonObject jo = new JsonObject(); 
		
		jo.addProperty("channel", src.getLabel());
		jo.addProperty("label", src.getLabel());
		jo.addProperty("unit", src.getYUnit().toString());
		jo.addProperty("shadowSize", shadowSize);
		
		JsonArray ja = new JsonArray();
		for (int i=0; i < src.size(); ++i) {
			JsonArray ija = new JsonArray();
			ija.add(new JsonPrimitive(convertTimeGPSToUNIX(src.getX(i).doubleValue()) * 1000.0 ));
			ija.add(new JsonPrimitive(src.getY(i)));
			ja.add(ija);
		}
		jo.add("data", ja);

		return jo;
	}
	
	// Basic GPS Epoch Converter - probably off by a few seconds and shouldn't be here
	protected double convertTimeGPSToUNIX(double timeGPS) {
		return timeGPS + 315964787.0;
	}
}
