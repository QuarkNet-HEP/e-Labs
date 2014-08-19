package gov.fnal.elab.cosmic.plot;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TreeMap;
import java.lang.Math;
import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;


public class FluxPlotData {

	private TreeMap<Integer, eventTimeData> plotFluxData; 
	
	public FluxPlotData(File file) throws IOException {
			BufferedReader br = new BufferedReader(new FileReader(file));		
			eventTimeData thisLineData = null;
			plotFluxData = new TreeMap<Integer, eventTimeData>();
			plotFluxData = saveLineData(br);
	}

	public TreeMap<Integer, eventTimeData> saveLineData(BufferedReader br) {
		eventTimeData thisLineData = null;
		String[] split; 
		String line;
		TreeMap<Integer, eventTimeData> plotData = new TreeMap<Integer, eventTimeData>();
		int ts=0; 
		try {
			while ((line = br.readLine()) != null) {
				if (!line.startsWith("#")) {
					split = line.split("\\s");
					if (split.length < 4) {
						return null;
					}
					thisLineData = new eventTimeData( split[0]+" "+split[1],	
													  parseToDouble(split[2]),
													  parseToDouble(split[3])
					);				
					ts++;
					plotData.put(ts, thisLineData);				
				}
			}
		} catch (Exception e) {
			return null;
		}
		return plotData;
	}
	
	public TreeMap<Integer, eventTimeData> getTimeEvents() {
		return plotFluxData;
	}
	
	public class eventTimeData {
		private String datetime;
		private Timestamp timestamp;
		private long timeinmillis;
		private double events;
		private double yError;
        DateFormat df = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss");
		
		private eventTimeData(String date,
						      double events,
						      double yerror) {
				this.datetime = date;
				try {
					Date parsedDate = df.parse(date);
					timestamp = new Timestamp(parsedDate.getTime());
					timeinmillis = parsedDate.getTime();
				} catch (Exception e) {
					
				}
				this.events = events;
				this.yError = yerror;
		}

		public String getDateTime() {
			return datetime; 
		}
		public Timestamp getTimestamp() {
			return timestamp; 
		}	
		public long getTimeMillis() {
			return timeinmillis;
		}
		public double getEvents() {
			return events; 
		}	
		public double getYError() {
			return yError; 
		}	
	}

	public double parseToDouble(String split)
	{
		double result = 0;
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of parseToDouble	
}
