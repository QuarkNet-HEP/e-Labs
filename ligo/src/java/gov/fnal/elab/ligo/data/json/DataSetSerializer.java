package gov.fnal.elab.ligo.data.json;

import gov.fnal.elab.expression.data.engine.DataSet;
import java.lang.reflect.Type;

import com.google.gson.*;

public class DataSetSerializer implements JsonSerializer<DataSet> {

	@Override
	public JsonElement serialize(DataSet src, Type typeOfSrc,
			JsonSerializationContext context) {
		JsonObject jo = new JsonObject(); 
		
		jo.addProperty("channel", src.getLabel());
		jo.addProperty("label", src.getLabel());
		jo.addProperty("unit", src.getYUnit().toString());
		
		JsonArray ja = new JsonArray();
		for (int i=0; i < src.size(); ++i) {
			JsonArray ija = new JsonArray();
			ija.add(new JsonPrimitive(src.getX(i)));
			ija.add(new JsonPrimitive(src.getY(i)));
			ja.add(ija);
		}
		jo.add("data", ja);

		return jo;
	}
	
}
