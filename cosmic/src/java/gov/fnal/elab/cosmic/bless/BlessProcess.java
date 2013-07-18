/*
 * EPeronja-05/17/2013: Tools to bless files based on a benchmark file
 */
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

public class BlessProcess {

	public BlessProcess() {
	}
	
	public ArrayList<String> BlessDatafiles(Elab elab, String detectorid, String[] filenames, String benchmark) throws IOException {
        ArrayList<String> blessResults = new ArrayList<String>();
		if (filenames != null) {
			for (int i = 0; i < filenames.length; i++) {
				blessResults.add(BlessDatafile(elab, detectorid, filenames[i], benchmark));
			}
		}
		return blessResults;
	}//end of BlessDataFiles
	
	public String BlessDatafile(Elab elab, String detectorid, String filename, String benchmark) throws IOException {
		String message = "";
		
		//get the catalog entry of the file to be blessed
		try {
			//Write to a log file for the time being so all this can be checked
			String logfile = filename + "_blessing.txt";
			File file = new File(elab.getProperties().getDataDir() + File.separator + detectorid +
					File.separator + logfile);
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			
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
				//SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				Long duration = 0L;
				try {
					//duration = (int) (enddate.getTime() - startdate.getTime()) / 1000;
					//double chan1Rate = chan1.doubleValue()/ duration;
					//double chan2Rate = chan2.doubleValue() / duration;
					//double chan3Rate = chan3.doubleValue() / duration;
					//double chan4Rate = chan4.doubleValue() / duration;
					//double triggerRate = triggers.doubleValue() / duration;
					duration = (Long) entry.getTupleValue("duration");
					Double chan1Rate = (Double) entry.getTupleValue("chan1Rate");
					Double chan2Rate = (Double) entry.getTupleValue("chan2Rate");
					Double chan3Rate = (Double) entry.getTupleValue("chan3Rate");
					Double chan4Rate = (Double) entry.getTupleValue("chan4Rate");
					Double triggerRate = (Double) entry.getTupleValue("triggerRate");
					
					bw.write(filename + " blessing using benchmark: "+ benchmark+"\n");
					bw.write("enddate : "+enddate.toString()+"\n");
					bw.write("startdate : "+startdate.toString()+"\n");
					bw.write("duration : "+String.valueOf(duration)+"\n");
					bw.write("channel1 : "+chan1+"\n");
					bw.write("channel2 : "+chan2+"\n");
					bw.write("channel3 : "+chan3+"\n");
					bw.write("channel4 : "+chan4+"\n");
					bw.write("triggers : "+triggers+"\n");
					
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
								if (chan1Rate < (parseToDouble(split[1]) + parseToDouble(split[2])) && chan1Rate > (parseToDouble(split[1]) - parseToDouble(split[2]))) {
									bw.write(String.valueOf(split[0]) + ": chan1Rate : "+String.valueOf(chan1Rate)+"\n");
									bw.write(String.valueOf(split[0]) + ": col1-blessfile : "+split[1]+"\n");
									bw.write(String.valueOf(split[0]) + ": col2-blessfile : "+split[2]+"\n");
									bw.write(String.valueOf(split[0]) + ": " + String.valueOf(chan1Rate) + " < " + String.valueOf(parseToDouble(split[1]) + 
											parseToDouble(split[2])) + " && " + String.valueOf(chan1Rate) + " > " + 
											String.valueOf(parseToDouble(split[1]) - parseToDouble(split[2]))  + "\n");
									pass = true;
								} else {
									pass = false;
									failReason = "Time: " + String.valueOf(split[0]) + " - channel 1: "+ String.valueOf(chan1Rate) +
												 " - events: " + split[1] + " - error: " + split[2];
								}
								//compare channel 2 and see if file can be blessed
								if (chan2Rate < (parseToDouble(split[3]) + parseToDouble(split[4])) && chan2Rate > (parseToDouble(split[3]) - parseToDouble(split[4]))) {
									bw.write(String.valueOf(split[0]) + ": chan2Rate : "+String.valueOf(chan2Rate)+"\n");
									bw.write(String.valueOf(split[0]) + ": col3-blessfile : "+split[3]+"\n");
									bw.write(String.valueOf(split[0]) + ": col4-blessfile : "+split[4]+"\n");
									bw.write(String.valueOf(split[0]) + ": " + String.valueOf(chan2Rate) + " < " + String.valueOf(parseToDouble(split[3]) + 
											parseToDouble(split[4])) + " && " + String.valueOf(chan2Rate) + " > " + 
											String.valueOf(parseToDouble(split[3]) - parseToDouble(split[4]))  + "\n");
									pass = true;
								} else {
									pass = false;
									failReason = "Time: " + String.valueOf(split[0]) + " - channel 2: "+ String.valueOf(chan2Rate) +
											 " - events: " + split[3] + " - error: " + split[4];
								}
								//compare channel 3 and see if file can be blessed
								if (chan3Rate < (parseToDouble(split[5]) + parseToDouble(split[6])) && chan3Rate > (parseToDouble(split[5]) - parseToDouble(split[6]))) {
									bw.write(String.valueOf(split[0]) + ": chan3Rate : "+String.valueOf(chan3Rate)+"\n");
									bw.write(String.valueOf(split[0]) + ": col5-blessfile : "+split[5]+"\n");
									bw.write(String.valueOf(split[0]) + ": col6-blessfile : "+split[6]+"\n");
									bw.write(String.valueOf(split[0]) + ": " + String.valueOf(chan3Rate) + " < " + String.valueOf(parseToDouble(split[5]) + 
											parseToDouble(split[6])) + " && " + String.valueOf(chan3Rate) + " > " + 
											String.valueOf(parseToDouble(split[5]) - parseToDouble(split[6]))  + "\n");
									pass = true;
								} else {
									pass = false;
									failReason = "Time: " + String.valueOf(split[0]) + " - channel 3: "+ String.valueOf(chan3Rate) +
											 " - events: " + split[5] + " - error: " + split[6];
									
								}
								//compare channel 4 and see if file can be blessed
								if (chan4Rate < (parseToDouble(split[7]) + parseToDouble(split[8])) && chan4Rate > (parseToDouble(split[7]) - parseToDouble(split[8]))) {
									bw.write(String.valueOf(split[0]) + ": chan4Rate : "+String.valueOf(chan4Rate)+"\n");
									bw.write(String.valueOf(split[0]) + ": col7-blessfile : "+split[7]+"\n");
									bw.write(String.valueOf(split[0]) + ": col8-blessfile : "+split[8]+"\n");
									bw.write(String.valueOf(split[0]) + ": " + String.valueOf(chan4Rate) + " < " + String.valueOf(parseToDouble(split[7]) + 
											parseToDouble(split[8])) + " && " + String.valueOf(chan4Rate) + " > " + 
											String.valueOf(parseToDouble(split[7]) - parseToDouble(split[8]))  + "\n");
									pass = true;
								} else {
									pass = false;
									failReason = "Time: " + String.valueOf(split[0]) + " - channel 4: "+ String.valueOf(chan4Rate) +
											 " - events: " + split[7] + " - error: " + split[8];
								}
								//compare triggers and see if file can be blessed
								if (triggerRate < (parseToDouble(split[9]) + parseToDouble(split[10])) && triggerRate > (parseToDouble(split[9]) - parseToDouble(split[10]))) {
									bw.write(String.valueOf(split[0]) + ": triggerRate : "+String.valueOf(triggerRate)+"\n");
									bw.write(String.valueOf(split[0]) + ": col9-blessfile : "+split[9]+"\n");
									bw.write(String.valueOf(split[0]) + ": col10-blessfile : "+split[10]+"\n");
									bw.write(String.valueOf(split[0]) + ": " + String.valueOf(triggerRate) + " < " + String.valueOf(parseToDouble(split[9]) + 
											parseToDouble(split[10])) + " && " + String.valueOf(triggerRate) + " > " + 
											String.valueOf(parseToDouble(split[9]) - parseToDouble(split[10])) + "\n" );
									pass = true;
								} else {
									pass = false;
									failReason = "Time: " + String.valueOf(split[0]) + " - triggers: "+ String.valueOf(triggerRate) +
											 " - events: " + split[9] + " - error: " + split[10];
									
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
							bw.write("FailReason: "+ failReason + "\n");
							dcp.insert(DataTools.buildCatalogEntry(filename, meta));
							if (pass && lineNumber > 0) {
								message = "<a href='../analysis-blessing/benchmark-view.jsp?filename="+logfile+"'>"+filename + "</a> has been blessed.";
								bw.write(filename + " has been blessed." + "\n");
							} else {
								message = "<a href='../analysis-blessing/benchmark-view.jsp?filename="+logfile+"'>"+filename + "</a> has NOT been blessed. Fail reason: " + failReason;								
								bw.write(filename + " has NOT been blessed." + "\n");
							}
							bw.close();
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
	}

}//end of BlessProcess