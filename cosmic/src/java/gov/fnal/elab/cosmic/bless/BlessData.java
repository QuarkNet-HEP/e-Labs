package gov.fnal.elab.cosmic.bless;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.TreeMap;
import gov.fnal.elab.Elab;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;

public class BlessData {

	private TreeMap<Integer, valueData> timeValueData; 
	private TreeMap<Long, valueData> timeValueDataLong; 
	
	public BlessData(File file) throws IOException {
		timeValueData = new TreeMap<Integer, valueData>(); 		
		String line;
		String[] split; 
		valueData thisLineData = null;
		int ts; 
		try {
			BufferedReader br = new BufferedReader(new FileReader(file));
			while ((line = br.readLine()) != null) {
				if (line.startsWith("#")) {
					continue; // comment line
				}
				else {
					split = line.split("\t"); 
					if (split.length != 15) {
						throw new IOException(file.getName() + " has malformed data. "); 
					}
					thisLineData = new valueData(	
							parseToDouble(split[1]),
							parseToDouble(split[2]),
							parseToDouble(split[3]),
							parseToDouble(split[4]),
							parseToDouble(split[5]),
							parseToDouble(split[6]),
							parseToDouble(split[7]),
							parseToDouble(split[8]),
							parseToDouble(split[9]),
							parseToDouble(split[10]),
							parseToInt(split[11]),
							parseToDouble(split[12]),
							parseToDouble(split[13]),
							parseToInt(split[14]),
							0.0,
							0.0,
							0.0,
							0.0,
							0.0,
							false
					);
						
					ts = parseToInt(split[0]);
					timeValueData.put(ts, thisLineData);				
				}
			}
			br.close();
		} catch (Exception ex) {
			System.out.print("Exception in BlessData: "+ex.getMessage()+"\n");
		}
	}

	//EPeronja: attempt to concatenate a few days together
	public BlessData(Elab elab, File[] file, String[] filenames) throws IOException {
		timeValueDataLong = new TreeMap<Long, valueData>(); 
		
		for (int i = 0; i < file.length; i++) {
			try {				
				//get startdate from database
				Timestamp startDate;
				Long secs = 0L;
				try {
					String[] nameParts = filenames[i].split("\\.");
					String filedate = nameParts[1]+nameParts[2];
					SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
					Date date = sdf.parse(filedate);
					sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
					String dateUTC = sdf.format(date);
					Date newDate = sdf.parse(dateUTC);
					secs = newDate.getTime();
					//VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);
					//if (e != null) {
					//	startDate = (Timestamp) e.getTupleValue("startdate");
					//	String df = new SimpleDateFormat("dd/MM/yyyy").format(startDate);
					//	Date date = new SimpleDateFormat("dd/MM/yyyy").parse(df);
					//	secs = date.getTime();
					//}
				} catch (Exception e) {	
					String message = e.toString();
				}
				BufferedReader br = new BufferedReader(new FileReader(file[i]));
				String line;
				String[] split; 
				valueData thisLineData = null;
				Long ts; 
				while ((line = br.readLine()) != null) {
					if (line.startsWith("#")) {
						continue; // comment line
					}
					else {
						split = line.split("\t"); 
						if (split.length != 15) {
							throw new IOException(file[i].getName() + " has malformed data. "); 
						}
						thisLineData = new valueData(	
								parseToDouble(split[1]),
								parseToDouble(split[2]),
								parseToDouble(split[3]),
								parseToDouble(split[4]),
								parseToDouble(split[5]),
								parseToDouble(split[6]),
								parseToDouble(split[7]),
								parseToDouble(split[8]),
								parseToDouble(split[9]),
								parseToDouble(split[10]),
								parseToInt(split[11]),
								parseToDouble(split[12]),
								parseToDouble(split[13]),
								parseToInt(split[14]),
								0.0,
								0.0,
								0.0,
								0.0,
								0.0,
								false
						);
						ts = secs + parseToLong(split[0]);
						timeValueDataLong.put(ts, thisLineData);				
					}
				}
				br.close();
			} catch (Exception ex) {
				System.out.print("Exception in BlessData: "+ex.getMessage()+"\n");
			}
		}
	}
	
	
	public BlessData(File file, String benchmark, Elab elab) throws IOException {
		timeValueData = new TreeMap<Integer, valueData>(); 
		boolean isBenchmarked = true;
		if (benchmark.equals("none") || benchmark.equals("")) {
			isBenchmarked = false;
		}
		String line;
		String[] split; 
		valueData thisLineData = null;
		int ts;
		Double bChannel1Rate = 0.0;
		Double bChannel2Rate = 0.0;
		Double bChannel3Rate = 0.0;
		Double bChannel4Rate = 0.0;
		Double bTriggerRate = 0.0;
		try {
			VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(benchmark);
			if (e != null) {
				bChannel1Rate = (Double) e.getTupleValue("chan1Rate");
				bChannel2Rate = (Double) e.getTupleValue("chan2Rate");
				bChannel3Rate = (Double) e.getTupleValue("chan3Rate");
				bChannel4Rate = (Double) e.getTupleValue("chan4Rate");
				bTriggerRate = (Double) e.getTupleValue("triggerRate");		
			}
		} catch (Exception e) {	
			String message = e.toString();
		}

		try {
			BufferedReader br = new BufferedReader(new FileReader(file));
			while ((line = br.readLine()) != null) {
				if (line.startsWith("#")) {
					continue; // comment line
				}
				else {
					split = line.split("\t"); 
					if (split.length != 15) {
						throw new IOException(file.getName() + " has malformed data. "); 
					}
					thisLineData = new valueData(
							parseToDouble(split[1]),
							parseToDouble(split[2]),
							parseToDouble(split[3]),
							parseToDouble(split[4]),
							parseToDouble(split[5]),
							parseToDouble(split[6]),
							parseToDouble(split[7]),
							parseToDouble(split[8]),
							parseToDouble(split[9]),
							parseToDouble(split[10]),
							parseToInt(split[11]),
							parseToDouble(split[12]),
							parseToDouble(split[13]),
							parseToInt(split[14]),
							(double) bChannel1Rate,
							(double) bChannel2Rate,
							(double) bChannel3Rate,
							(double) bChannel4Rate,
							(double) bTriggerRate,
							isBenchmarked
					);
						
					ts = parseToInt(split[0]);
					//ts = Integer.parseInt(split[0]);
					timeValueData.put(ts, thisLineData);
				}
			}
			br.close();
		} catch (Exception ex) {
			System.out.print("Exception in BlessData: "+ex.getMessage()+"\n");
		}			
	}
	
	
	
	//EPeronja-02/12/2013: Bug472- added to check for null values which will break the plotting code
	public int parseToInt(String split)
	{
		int result = 0;
		try{
			result = Integer.parseInt(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}

	//EPeronja-02/12/2013: Bug472- added to check for null values which will break the plotting code
	public Long parseToLong(String split)
	{
		Long result = 0L;
		try{
			result = Long.parseLong(split);
		} catch (NumberFormatException e) {
			result = 0L;
		}
		return result * 1000;
	}
	
    //EPeronja-02/12/2013: Bug472- added to check for null values which will break the plotting code	
	public double parseToDouble(String split)
	{
		double result = 0;
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}
	
	public TreeMap<Integer, valueData> getTimeValueData() {
		return timeValueData;
	}
	public TreeMap<Long, valueData> getTimeValueDataLong() {
		return timeValueDataLong;
	}
	
	public class valueData {
		private double channel1Rate, channel2Rate, channel3Rate, channel4Rate;
		private double channel1Error, channel2Error, channel3Error, channel4Error;
		private double triggerRate; 
		private double triggerError;
		private int pressure; 
		private double temperature; 
		private double voltage; 
		private int gpsSatellitesVisible; 
		private double benchmarkChannel1Rate, benchmarkChannel2Rate, benchmarkChannel3Rate, benchmarkChannel4Rate;
		private double benchmarkTriggerRate;
		private boolean benchmarked;
		
		private valueData(
				double channel1Rate, double channel1Error,
				double channel2Rate, double channel2Error,
				double channel3Rate, double channel3Error,
				double channel4Rate, double channel4Error,
				double triggerRate, double triggerError, 
				int pressure, double temperature, double voltage,  int gpsSatellitesVisible,
				double benchmarkChannel1Rate,
				double benchmarkChannel2Rate,
				double benchmarkChannel3Rate,
				double benchmarkChannel4Rate,
				double benchmarkTriggerRate,
				boolean benchmarked) {
			this.channel1Rate = channel1Rate; 
			this.channel2Rate = channel2Rate; 
			this.channel3Rate = channel3Rate; 
			this.channel4Rate = channel4Rate; 
			
			this.channel1Error = channel1Error;
			this.channel2Error = channel2Error;
			this.channel3Error = channel3Error;
			this.channel4Error = channel4Error;
			
			this.triggerRate = triggerRate;
			this.triggerError = triggerError; 
			
			this.pressure = pressure; 
			this.temperature = temperature; 
			this.voltage = voltage; 
			this.gpsSatellitesVisible = gpsSatellitesVisible; 

			this.benchmarkChannel1Rate = benchmarkChannel1Rate;
			this.benchmarkChannel2Rate = benchmarkChannel2Rate;
			this.benchmarkChannel3Rate = benchmarkChannel3Rate;
			this.benchmarkChannel4Rate = benchmarkChannel4Rate;
			this.benchmarkTriggerRate = benchmarkTriggerRate;		
			this.benchmarked = benchmarked;
		}

		public double getBenchmarkChannel1Rate() {
			return benchmarkChannel1Rate; 
		}

		public double getBenchmarkChannel2Rate() {
			return benchmarkChannel2Rate; 
		}

		public double getBenchmarkChannel3Rate() {
			return benchmarkChannel3Rate; 
		}

		public double getBenchmarkChannel4Rate() {
			return benchmarkChannel4Rate; 
		}

		public double getBenchmarkTriggerRate() {
			return benchmarkTriggerRate; 
		}

		public double getChannel1Rate() {
			return channel1Rate; 
		}
		
		public double getChannel2Rate() {
			return channel2Rate; 
		}
		
		public double getChannel3Rate() {
			return channel3Rate;
		}
		
		public double getChannel4Rate() {
			return channel4Rate;
		}
		
		public double getTriggerRate() {
			return triggerRate; 
		}
		
		public double getChannel1Error() {
			return channel1Error; 
		}
		
		public double getChannel2Error() {
			return channel2Error; 
		}
		
		public double getChannel3Error() {
			return channel3Error; 
		}
		
		public double getChannel4Error() {
			return channel4Error; 
		}
		
		public double getTriggerError() {
			return triggerError; 
		}
		
		public int getPressure() {
			return pressure;
		}
		
		public double getTemperature() {
			return temperature;
		}
		
		public double getVoltage() {
			return voltage; 
		}
		
		public int getGpsSatellitesVisible() {
			return gpsSatellitesVisible; 
		}
		
		public boolean isBenchmarked() {
			return benchmarked;
		}
		
	}
	
}
