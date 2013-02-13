package gov.fnal.elab.cosmic.bless;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.TreeMap;

public class BlessData {

	private TreeMap<Integer, valueData> timeValueData; 
	
	public BlessData(File file) throws IOException {
		BufferedReader br = new BufferedReader(new FileReader(file));
		
		timeValueData = new TreeMap<Integer, valueData>(); 
		
		String line;
		String[] split; 
		valueData thisLineData = null;
		int ts; 
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
						//Integer.parseInt(split[1]),
						//Integer.parseInt(split[2]),
						//Integer.parseInt(split[3]),
						//Integer.parseInt(split[4]),
						//Integer.parseInt(split[5]),
						//Integer.parseInt(split[6]),
						//Integer.parseInt(split[7]),
						//Integer.parseInt(split[8]),
						//Double.parseDouble(split[9]),
						//Integer.parseInt(split[10]),
						//Integer.parseInt(split[11]),
						//Double.parseDouble(split[12]),
						//Double.parseDouble(split[13]),
						//Integer.parseInt(split[14])						
						parseToInt(split[1]),
						parseToInt(split[2]),
						parseToInt(split[3]),
						parseToInt(split[4]),
						parseToInt(split[5]),
						parseToInt(split[6]),
						parseToInt(split[7]),
						parseToInt(split[8]),
						parseToDouble(split[9]),
						parseToInt(split[10]),
						parseToInt(split[11]),
						parseToDouble(split[12]),
						parseToDouble(split[13]),
						parseToInt(split[14])				
				);
					
				ts = parseToInt(split[0]);
				//ts = Integer.parseInt(split[0]);
				
				timeValueData.put(ts, thisLineData);
				
			}
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
	
	public class valueData {
		private int channel1Rate, channel2Rate, channel3Rate, channel4Rate;
		private int channel1Error, channel2Error, channel3Error, channel4Error;
		private double triggerRate; 
		private int triggerError;
		private int pressure; 
		private double temperature; 
		private double voltage; 
		private int gpsSatellitesVisible; 
		
		private valueData(
				int channel1Rate, int channel1Error,
				int channel2Rate, int channel2Error,
				int channel3Rate, int channel3Error,
				int channel4Rate, int channel4Error,
				double triggerRate, int triggerError, 
				int pressure, double temperature, double voltage,  int gpsSatellitesVisible) {
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
		}
		
		public int getChannel1Rate() {
			return channel1Rate; 
		}
		
		public int getChannel2Rate() {
			return channel2Rate; 
		}
		
		public int getChannel3Rate() {
			return channel3Rate;
		}
		
		public int getChannel4Rate() {
			return channel4Rate;
		}
		
		public double getTriggerRate() {
			return triggerRate; 
		}
		
		public int getChannel1Error() {
			return channel1Error; 
		}
		
		public int getChannel2Error() {
			return channel2Error; 
		}
		
		public int getChannel3Error() {
			return channel3Error; 
		}
		
		public int getChannel4Error() {
			return channel4Error; 
		}
		
		public int getTriggerError() {
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
		
	}
	
}
