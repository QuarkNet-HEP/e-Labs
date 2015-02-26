package gov.fnal.elab.cosmic.bless;
import java.util.*;
import java.io.File;
import java.text.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.LineNumberReader;

/*
 * EPeronja-12/02/2014: tool to analyze files that have a benchmark and want to recheck their blessed status
 * 						this runs outside the elab, therefore it needs an input file with everything
 */

public class BlessProcessDryRun {
	double sigmas = 10;
	int linecount = 0;
	//constructor
	public BlessProcessDryRun() {
	}
	
	public void BlessDatafile(String splitfile, Long chan1, Long chan2, Long chan3, Long chan4, Long triggers,
								String blessfilepath, String blessedstatus, String benchmark, Long duration,
								Double chan1rate, Double chan2rate, Double chan3rate, Double chan4rate, Double triggerrate) throws IOException {
		String message = "";
		String errorCode = "";
		boolean goBless = true;
		String reportline = "";
		if (linecount == 0) {
			reportline = "Split,CurrentStatus,Benchmark,NewStatus,FailReason,StatusChanged\n";
			linecount ++;
		}
		reportline += splitfile+","+blessedstatus+","+benchmark;
		String newstatus = "";
		//get the catalog entry of the file to be blessed
		if (goBless) {
			try {
				LineNumberReader in = new LineNumberReader(new FileReader(blessfilepath));
		        BufferedWriter report = new BufferedWriter(new FileWriter("/users/edit/edit_scratch/BLESSING/epBlessDryRunReport.txt",true));

				int lineNumber = 0;
				try {						
					String line = "";
					String[] split; 
					boolean pass = true;
					errorCode = "0";
					String failReason = "If this message is not overwritten the blessfile is empty";
					if ((chan1 == 0L && chan1rate != 0) || (chan1 != 0L && chan1rate == 0)){
						errorCode = "5";
						pass = false;
						failReason = "There is a mismatch in channel 1: between split: "+
								splitfile + " with value: "+String.valueOf(chan1)+" and benchmark: "+
								benchmark + " with value: "+String.valueOf(chan1rate);
					}
					if ((chan2 == 0L && chan2rate != 0) || (chan2 != 0L && chan2rate == 0)){
						errorCode = "5";
						pass = false;
						failReason = "There is a mismatch in channel 2: between split: "+
								splitfile + " with value: "+String.valueOf(chan2)+" and benchmark: "+
								benchmark + " with value: "+String.valueOf(chan2rate);
					}
					if ((chan3 == 0L && chan3rate != 0) || (chan3 != 0L && chan3rate == 0)){
						errorCode = "5";
						pass = false;
						failReason = "There is a mismatch in channel 3: between split: "+
								splitfile + " with value: "+String.valueOf(chan3)+" and benchmark: "+
								benchmark + " with value: "+String.valueOf(chan3rate);
					}
					if ((chan4 == 0L && chan4rate != 0) || (chan4 != 0L && chan4rate == 0)){
						errorCode = "5";
						pass = false;
						failReason = "There is a mismatch in channel 4: between split: "+
								splitfile + " with value: "+String.valueOf(chan4)+" and benchmark: "+
								benchmark + " with value: "+String.valueOf(chan4rate);
					}
					
					while ((line = in.readLine()) != null && pass) {
						if (line.startsWith("#")) {
							continue; // comment line
						} else {
							split = line.split("\t"); 
							if (split.length != 15) {
								errorCode = "2";
								failReason = splitfile + ".bless has malformed data. ";
							}
							for (int i = 0; i < split.length; i++) {
								if (split[i].equals("")) {
									split[i] = "0";
								}
							}
							//compare channel 1 and see if file can be blessed
							if (chan1rate <= (parseToDouble(split[1]) + parseToDoubleSigmas(split[2])) && chan1rate >= (parseToDouble(split[1]) - parseToDoubleSigmas(split[2]))) {
								pass = true;
							} else {
								pass = false;
								errorCode = "3";
								failReason = formatFailReason(split[0], "channel 1", String.valueOf(chan1rate), split[1], split[2]);
							}
							//compare channel 2 and see if file can be blessed
							if (pass) {
								if (chan2rate <= (parseToDouble(split[3]) + parseToDoubleSigmas(split[4])) && chan2rate >= (parseToDouble(split[3]) - parseToDoubleSigmas(split[4]))) {
									pass = true;
								} else {
									pass = false;
									errorCode = "3";
									failReason = formatFailReason(split[0], "channel 2", String.valueOf(chan2rate), split[3], split[4]);
								}
							}
							//compare channel 3 and see if file can be blessed
							if (pass) {
								if (chan3rate <= (parseToDouble(split[5]) + parseToDoubleSigmas(split[6])) && chan3rate >= (parseToDouble(split[5]) - parseToDoubleSigmas(split[6]))) {
									pass = true;
								} else {
									pass = false;
									errorCode = "3";
									failReason = formatFailReason(split[0], "channel 3", String.valueOf(chan3rate), split[5], split[6]);
								}
							}
							//compare channel 4 and see if file can be blessed
							if (pass) {
								if (chan4rate <= (parseToDouble(split[7]) + parseToDoubleSigmas(split[8])) && chan4rate >= (parseToDouble(split[7]) - parseToDoubleSigmas(split[8]))) {
									pass = true;
								} else {
									pass = false;
									errorCode = "3";
									failReason = formatFailReason(split[0], "channel 4", String.valueOf(chan4rate), split[7], split[8]);
								}
							}
							//compare triggers and see if file can be blessed
							//if the trigger + triggerError < 2, we are not going to bother comparing
							//this was decided on the Nov 13 2013 telecon
							//low trigger rates alone shouldn't fail a file
							if (pass) {
								if ((parseToDouble(split[9]) + parseToDoubleSigmas(split[10])) >= 2) {
									if (triggerrate < (parseToDouble(split[9]) + parseToDoubleSigmas(split[10])) && triggerrate > (parseToDouble(split[9]) - parseToDoubleSigmas(split[10])) ) {
										pass = true;
									} else {
										pass = false;
										errorCode = "3";
										failReason = formatFailReason(split[0], "trigger", String.valueOf(triggerrate), split[9], split[10]);
									}
								}
							}
						}
						lineNumber++;
					}//end while loop
					boolean needsBlessedFlag = false;
					if (pass && lineNumber > 0) {
						failReason = "None: file has been blessed.";
						newstatus = "t";
						//blessed true
					} else {
						newstatus = "f";
						//blessed false	
					}
					if (lineNumber == 0) {
						errorCode = "4";
						failReason = "The .bless file is empty. There is no information to run the blessing routine.";
					}
					String statuschanged = "No";
					if (!blessedstatus.equals(newstatus)) {
						statuschanged = "Yes";
					}
					reportline += ","+newstatus+","+failReason+","+statuschanged+"\n";
		        	report.write(reportline+"\n");
					report.close();
				} catch (Exception e) {
	        		System.out.println(e.getMessage()+"\n");
				}
			} catch (Exception e) {
        		System.out.println(e.getMessage()+"\n");

			}
		}
	}//end of BlessDatafile
	
	public int parseToInt(String split)
	{
		int result = 0;
		if (split.equals("")) {
			split = "0";
		}
		try{
			result = Integer.parseInt(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of parseToInt
	
	public double parseToDouble(String split)
	{
		double result = 0;
		if (split.equals("")) {
			split = "0.0";
		}
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of parseToDouble

	public double parseToDoubleSigmas(String split)
	{
		double result = 0;
		if (split.equals("")) {
			split = "0.0";
		}
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result*sigmas;
	}//end of parseToDouble
	
	public double calculateQuality(double splitRate, double channelRate, double splitError) {
		double quality = 0;
		if (splitError != 0) {
			quality = (splitRate - channelRate) / splitError;
		}
		return (quality < 0) ? -quality : quality;
	}
	
	//EPeronja: convert the time in seconds to H:M:S
	public String convertToHMS(String time) {
		String hms = "";
		if (time != null) {
			int secs = Integer.parseInt(time);
			int hours = secs/3600;
			int remainder = secs - hours * 3600;
		    int minutes = remainder / 60;
		    remainder = remainder - minutes * 60;
		    int seconds = remainder;
		    hms = String.valueOf(hours)+ ":"+ String.valueOf(minutes)+ ":"+ String.valueOf(seconds);
		}
		return hms;
	}//end of convertToHMS
	
	public String formatFailReason(String seconds, String label, String benchmarkRate, String column1, String column2) {
		String failReason = "";
	    NumberFormat NF5F = new DecimalFormat("0.00000");
	    double difference = Math.abs(Double.valueOf(benchmarkRate) - Double.valueOf(column1));
		if (seconds != null && label != null && benchmarkRate != null && column1 != null && column2 != null) {
			failReason = "This file failed the blessing comparison at "+seconds+" seconds past midnight "+
					 "("+convertToHMS(seconds)+"); the failure was in "+label+". The data rate was "+
					 ""+NF5F.format(Double.valueOf(column1))+" +/- "+NF5F.format(Double.valueOf(column2))+". The benchmark indicates a target rate "+
					 "of: "+NF5F.format(Double.valueOf(benchmarkRate))+" Hz. The difference between the rate in the file and the "+
					 "benchmark is "+NF5F.format(difference)+" Hz. This is larger than our comparison "+
					 "test allows; we allow a drift of "+String.valueOf(sigmas)+ " * the error "+
					 "("+NF5F.format(Double.valueOf(column2))+" Hz).";		}
		return failReason;
	}//end of formatFailReason
	
	
    public static void main(String[] args) {
    	BlessProcessDryRun bpdr;
    	
    	if (args.length == 1) {
    		String iFile = args[0];
    		try {
    			bpdr = new BlessProcessDryRun();
    			BufferedReader br = new BufferedReader(new FileReader(iFile));			
		        String line = br.readLine();
		        while (line != null) {
			        String[] splitLine = line.split(","); 
			        if (splitLine.length == 16) {
			        	String split = splitLine[1];
			        	if (split.equals("6119.2014.0610.0")) {
			        		System.out.println(split+"\n");
			        	}
			        	Long chan1 = Long.parseLong(splitLine[2]);
			        	Long chan2 = Long.parseLong(splitLine[3]);
			        	Long chan3 = Long.parseLong(splitLine[4]);
			        	Long chan4 = Long.parseLong(splitLine[5]);
			        	Long triggers = Long.parseLong(splitLine[6]);
			        	String blessfilepath = splitLine[7];
			        	String currentstatus = splitLine[8];
			        	String benchmark = splitLine[9];
			        	Long duration = Long.parseLong(splitLine[10]);
			        	Double chan1rate = Double.parseDouble(splitLine[11]);
			        	Double chan2rate = Double.parseDouble(splitLine[12]);
			        	Double chan3rate = Double.parseDouble(splitLine[13]);
			        	Double chan4rate = Double.parseDouble(splitLine[14]);
			        	Double triggerrate = Double.parseDouble(splitLine[15]);
			        	bpdr.BlessDatafile(split, chan1, chan2, chan3, chan4, triggers, blessfilepath, currentstatus, benchmark, duration, chan1rate, chan2rate, chan3rate, chan4rate, triggerrate);
			        }
		            line = br.readLine();
		        }
		        
		        br.close();
		        
    		} catch (Exception e) {
        		System.out.println("Could not open the file");    			
    		}

    	} else {
    		System.out.println("Usage: ThresholdTimesProcess input_file");
    	}
    }//end of main   

}//end of BlessProcess