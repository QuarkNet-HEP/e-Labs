/*
 * Created on Mar 20, 2009
 */
package gov.fnal.elab.cosmic.beans;

import java.util.AbstractMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

public class GeometryErrors {
	public static final String ERROR_DATE_FIELD_NOT_SET = "date-field-not-set";
	public static final String ERROR_DATE_IN_THE_FUTURE = "date-in-the-future";
	public static final String ERROR_DATE_EXISTING = "date-existing";
	public static final String ERROR_CHANNEL_1_CABLE_LENGTH = "channel1-cable-length";
	public static final String ERROR_CHANNEL_1_AREA = "channel1-area";
	public static final String ERROR_CHANNEL_1_EW = "channel1-ew";
	public static final String ERROR_CHANNEL_1_NS = "channel1-ns";
	public static final String ERROR_CHANNEL_1_UD = "channel1-ud";
	public static final String ERROR_CHANNEL_2_CABLE_LENGTH = "channel2-cable-length";
	public static final String ERROR_CHANNEL_2_AREA = "channel2-area";
	public static final String ERROR_CHANNEL_2_EW = "channel2-ew";
	public static final String ERROR_CHANNEL_2_NS = "channel2-ns";
	public static final String ERROR_CHANNEL_2_UD = "channel2-ud";
	public static final String ERROR_CHANNEL_3_CABLE_LENGTH = "channel3-cable-length";
	public static final String ERROR_CHANNEL_3_AREA = "channel3-area";
	public static final String ERROR_CHANNEL_3_EW = "channel3-ew";
	public static final String ERROR_CHANNEL_3_NS = "channel3-ns";
	public static final String ERROR_CHANNEL_3_UD = "channel3-ud";
	public static final String ERROR_CHANNEL_4_CABLE_LENGTH = "channel4-cable-length";
	public static final String ERROR_CHANNEL_4_AREA = "channel4-area";
	public static final String ERROR_CHANNEL_4_EW = "channel4-ew";
	public static final String ERROR_CHANNEL_4_NS = "channel4-ns";
	public static final String ERROR_CHANNEL_4_UD = "channel4-ud";
	public static final String ERROR_STACKED_EW = "stacked-ew";
	public static final String ERROR_STACKED_NS = "stacked-ns";
	public static final String ERROR_STACKED_UD = "stacked-ud";
	public static final String ERROR_LATITUDE = "latitude";
	public static final String ERROR_LONGITUDE = "longitude";
	public static final String ERROR_ALTITUDE = "altitude";
	public static final String ERROR_GPS_CABLE_LENGTH = "gps-cable-length";
	
	private static Properties errors;
	
	static {
		errors = new Properties();
		errors.put(ERROR_DATE_FIELD_NOT_SET, "Please check that your Date/Time values are all selected.");
		errors.put(ERROR_DATE_IN_THE_FUTURE, "Date cannot exceed current date.");
		errors.put(ERROR_DATE_EXISTING, "Date exactly matches that of an existing geometry entry.");
		for (int i = 1; i <= 4; i++) {
			errors.put("channel" + i + "-cable-length", "Please check that your channel " + i + " Cable Length value is correct.");
			errors.put("channel" + i + "-area", "Please check that your channel " + i + " Area value is correct.");
			errors.put("channel" + i + "-ew", "Please check that your channel " + i + " E-W value is correct.");
			errors.put("channel" + i + "-ns", "Please check that your channel " + i + " N-S value is correct.");
			errors.put("channel" + i + "-ud", "Please check that your channel " + i + " Up-Dn value is correct.");
		}
		errors.put(ERROR_STACKED_EW, "With stacked orientation, the E-W values for all four channels should be equal.");
		errors.put(ERROR_STACKED_NS, "With stacked orientation, the N-S values for all four channels should be equal.");
		errors.put(ERROR_STACKED_UD, "With stacked orientation, the Up-Dn values for all four channels should be different");
		errors.put(ERROR_LATITUDE, "Please check that your Latitude value is correct.");
		errors.put(ERROR_LONGITUDE, "Please check that your Longitude value is correct.");
		errors.put(ERROR_ALTITUDE, "Please check that your Altitude value is correct.");
		errors.put(ERROR_GPS_CABLE_LENGTH, "Please check that your GPS Cable Length value is correct.");
	}
	
	public GeometryErrors() {
	}
	
	public Map getKeys() {
		return new AbstractMap() {
			public Object get(Object key) {
				if (errors.containsKey(key)) {
					return key;
				}
				else {
					throw new IllegalArgumentException("No such key: " + key);
				}
			}

			public Set entrySet() {
				return null;
			}
		};
	}
	
	public Map getErrors() {
		return errors;
	}
}
