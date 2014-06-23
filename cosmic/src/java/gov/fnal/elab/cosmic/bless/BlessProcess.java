package gov.fnal.elab.cosmic.bless;

import java.util.*;
import java.io.File;
import java.text.*;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.LineNumberReader;

import gov.fnal.elab.Elab;
import gov.fnal.elab.cosmic.bless.BlessData.valueData;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;

/*
 * EPeronja-05/17/2013: Tools to bless files based on a benchmark file
 */

public class BlessProcess {
	//constructor
	public BlessProcess() {
	}
	
	public ArrayList<String> BlessDatafiles(Elab elab, String detectorid, String[] filenames, String benchmark) throws IOException {
        ArrayList<String> blessResults = new ArrayList<String>();
		if (elab != null && filenames != null && detectorid != null && benchmark != null) {
			for (int i = 0; i < filenames.length; i++) {
				blessResults.add(BlessDatafile(elab, detectorid, filenames[i], benchmark));
			}
		}
		return blessResults;
	}//end of BlessDataFiles
	
	public String BlessDatafile(Elab elab, String detectorid, String filename, String benchmark) throws IOException {
		String message = "";
		boolean goBless = true;
		//check if this split has been already blessed/unblessed by this benchmark, then do not do it again.
		//try {
		//	VDSCatalogEntry eCheck = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
		//	if (eCheck != null) {
		//		String benchmarkRef = (String) eCheck.getTupleValue("benchmarkreference");
		//		if (benchmarkRef != null) {
		//			if (benchmarkRef.equals(benchmark)) {
		//				goBless = false;
		//			}
		//		}
		//	}
		//} catch (Exception e) {
		//	System.out.println("BlessDatafile exception: " + e.getMessage());
		//}
		//get the catalog entry of the file to be blessed
		if (goBless) {
			try {
				VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(benchmark);
				if (entry != null) {
					//get all the tuples needed for the blessing
					Long chan1 = (Long) entry.getTupleValue("chan1");
					Long chan2 = (Long) entry.getTupleValue("chan2");
					Long chan3 = (Long) entry.getTupleValue("chan3");
					Long chan4 = (Long) entry.getTupleValue("chan4");
					Long triggers = (Long) entry.getTupleValue("triggers");
					Date startdate = (Date) entry.getTupleValue("startdate");
					Date enddate = (Date) entry.getTupleValue("enddate");
					Long duration = 0L;
					try {
						duration = (Long) entry.getTupleValue("duration");
						Double chan1Rate = (Double) entry.getTupleValue("chan1Rate");
						Double chan2Rate = (Double) entry.getTupleValue("chan2Rate");
						Double chan3Rate = (Double) entry.getTupleValue("chan3Rate");
						Double chan4Rate = (Double) entry.getTupleValue("chan4Rate");
						Double triggerRate = (Double) entry.getTupleValue("triggerRate");
						
						//get datafile *.bless file
						String blessFile = elab.getProperties().getDataDir() + File.separator + detectorid +
											File.separator + filename + ".bless";
						LineNumberReader in = new LineNumberReader(new FileReader(blessFile));
						int lineNumber = 0;
						try {						
							String line = "";
							String[] split; 
							boolean pass = true;
							String failReason = "If this message is not overwritten the blessfile is empty";
							try {
								VDSCatalogEntry splitFile = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
								VDSCatalogEntry benchmarkFile = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(benchmark);
								failReason = checkChannelMismatch(splitFile, benchmarkFile);
								if (!failReason.equals("")) {
									pass = false;
								}
							} catch (Exception e) {
								pass = false;
								failReason = "Exception comparing the channels in both files";
							}
							while ((line = in.readLine()) != null && pass) {
								if (line.startsWith("#")) {
									continue; // comment line
								}
								else {
									split = line.split("\t"); 
									if (split.length != 15) {
										failReason = blessFile + " has malformed data. ";
										throw new IOException(blessFile + " has malformed data. "); 
									}
									//compare channel 1 and see if file can be blessed
									if (chan1Rate <= (parseToDouble(split[1]) + parseToDouble2Sigmas(split[2])) && chan1Rate >= (parseToDouble(split[1]) - parseToDouble2Sigmas(split[2]))) {
										pass = true;
									} else {
										pass = false;
										failReason = formatFailReason(split[0], "channel 1", String.valueOf(chan1Rate), split[1], split[2]);
									}
									//compare channel 2 and see if file can be blessed
									if (pass) {
										if (chan2Rate <= (parseToDouble(split[3]) + parseToDouble2Sigmas(split[4])) && chan2Rate >= (parseToDouble(split[3]) - parseToDouble2Sigmas(split[4]))) {
											pass = true;
										} else {
											pass = false;
											failReason = formatFailReason(split[0], "channel 2", String.valueOf(chan2Rate), split[3], split[4]);
										}
									}
									//compare channel 3 and see if file can be blessed
									if (pass) {
										if (chan3Rate <= (parseToDouble(split[5]) + parseToDouble2Sigmas(split[6])) && chan3Rate >= (parseToDouble(split[5]) - parseToDouble2Sigmas(split[6]))) {
											pass = true;
										} else {
											pass = false;
											failReason = formatFailReason(split[0], "channel 3", String.valueOf(chan3Rate), split[5], split[6]);
										}
									}
									//compare channel 4 and see if file can be blessed
									if (pass) {
										if (chan4Rate <= (parseToDouble(split[7]) + parseToDouble2Sigmas(split[8])) && chan4Rate >= (parseToDouble(split[7]) - parseToDouble2Sigmas(split[8]))) {
											pass = true;
										} else {
											pass = false;
											failReason = formatFailReason(split[0], "channel 4", String.valueOf(chan4Rate), split[7], split[8]);
										}
									}
									//compare triggers and see if file can be blessed
									//if the trigger + triggerError < 2, we are not going to bother comparing
									//this was decided on the Nov 13 2013 telecon
									//low trigger rates alone shouldn't fail a file
									if (pass) {
										if ((parseToDouble(split[9]) + parseToDouble2Sigmas(split[10])) >= 2) {
											if (triggerRate < (parseToDouble(split[9]) + parseToDouble2Sigmas(split[10])) && triggerRate > (parseToDouble(split[9]) - parseToDouble2Sigmas(split[10])) ) {
												pass = true;
											} else {
												pass = false;
												failReason = formatFailReason(split[0], "trigger", String.valueOf(triggerRate), split[9], split[10]);
											}
										}
									}
								}
								lineNumber++;
							}//end while loop
							//do we bless?
							VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
							DataCatalogProvider dcp = elab.getDataCatalogProvider();
							boolean needsBlessedFlag = false;
							if (e != null) {
								if (e.getTupleValue("blessed") != null) {				
									if (pass && lineNumber > 0) {
										failReason = "";
										e.setTupleValue("blessed", true);
										e.setTupleValue("blessedstatus", "blessed");
									} else {
										e.setTupleValue("blessed", false);
										e.setTupleValue("blessedstatus", "not blessed");
									}
								} else {
									needsBlessedFlag = true;
								}
	
								dcp.insert(e);	
								ArrayList meta = new ArrayList();
								if (needsBlessedFlag) {
									meta.add("blessed boolean " + pass);
								}
								meta.add("benchmarkreference string "+ benchmark);
								meta.add("benchmarkfail string "+ failReason);
								dcp.insert(DataTools.buildCatalogEntry(filename, meta));
								if (pass && lineNumber > 0) {
									message = "<strong>"+filename + "</strong> has been blessed.";
								} else {
									if (lineNumber == 0) {
										failReason = "The .bless file is empty. There is no information to run the blessing routine.";
									}
									message = "<strong>"+filename + "</strong> has NOT been blessed. Fail reason: " + failReason;								
								}
							}
						} catch (Exception e) {
							message = "Blessfile: " + blessFile + "\n";
							message += "Dir: " + elab.getProperties().getDataDir() + "\n";
							message += "Filename: "+ filename +"\n";
							message += "Detector: "+ detectorid +"\n";
							message += e.toString() + "\n";
					}
						
					} catch (Exception e) {
						message += "Dir: " + elab.getProperties().getDataDir() + "\n";
						message += "Filename: "+ filename +"\n";
						message += "Detector: "+ detectorid +"\n";
						message += e.toString() + "\n";
					}
				}
			} catch (ElabException e) {
				message += "Dir: " + elab.getProperties().getDataDir() + "\n";
				message += "Filename: "+ filename +"\n";
				message += "Detector: "+ detectorid +"\n";
				message += e.toString() + "\n";
			}
		}
		return message;
	}//end of BlessDatafile
	
	public int parseToInt(String split)
	{
		int result = 0;
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
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of parseToDouble

	public double parseToDouble2Sigmas(String split)
	{
		double result = 0;
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result*2;
	}//end of parseToDouble
	
	public String checkChannelMismatch(VDSCatalogEntry split, VDSCatalogEntry benchmark) {
		String failReason = "";
		for (int i = 1; i <= 4; i++) {
			Long splitChannel = (Long) split.getTupleValue("chan"+String.valueOf(i));
			Long benchmarkChannel = (Long) benchmark.getTupleValue("chan"+String.valueOf(i));
			if (splitChannel == 0L && benchmarkChannel == 0L) {
				continue;
			}
			if ((splitChannel == 0L && benchmarkChannel != 0L) || (benchmarkChannel == 0L && splitChannel != 0L)) {
				return "There is a mismatch in channel: "+String.valueOf(i)+" between split: "+
						split.getLFN() + " with value: "+String.valueOf(splitChannel)+" and benchmark: "+
						benchmark.getLFN() + " with value: "+String.valueOf(benchmarkChannel);
			}
		}
		return failReason;
	}//checkChannelMismatch
	
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
		if (seconds != null && label != null && benchmarkRate != null && column1 != null && column2 != null) {
			failReason = "This file failed at: " + seconds + "(" + convertToHMS(seconds) + ")"+
					 " because the benchmark "+label+" rate: "+ benchmarkRate +
					 " (metadata value) was not between the ranges of comparison set by " + column1 +
					 " and " + String.valueOf(column2) + " 2 sigmas being: " + String.valueOf(parseToDouble2Sigmas(column2)) +
					 "(" + String.valueOf(parseToDouble(column1) - parseToDouble2Sigmas(column2)) +
					 " and " + String.valueOf(parseToDouble(column1) + parseToDouble2Sigmas(column2))+")" +
					 " - for these last values, look at the .bless file of the just split file.";									
		}
		return failReason;
	}//end of formatFailReason

}//end of BlessProcess