/*
 * Created on October 11 2013 (based on ThresholdTimes.java)
 * EPeronja-10/17/2013: THRESHOLD TEST
 * This code runs as an application in order to create all the .thresh files needed for analyses
 */
package gov.fnal.elab.cosmic.analysis;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.concurrent.Callable;
import java.util.*;

public class ThresholdTimesProcess {
    private String[] inputFiles, outputFiles, detectorIDs;
    private double[] cpldFrequencies;
    private double[] retime, fetime;
    private long[] rePPSTime, rePPSCount, reDiff;
    private int[] reTMC;
    private long lastRePPSTime, lastRePPSCount;
    private int lastGPSDay, jd;
    private String lastSecString;
    private double lastEdgeTime;
    private double cpldFrequency;
    private long starttime, endtime;
    private static int lineCount;
    BufferedWriter bwprocess;
    
    public static final NumberFormat NF2F = new DecimalFormat("0.00");
    public static final NumberFormat NF16F = new DecimalFormat("0.0000000000000000");
    
    public ThresholdTimesProcess(List inputFile, List outputFile, List detector, List cpldFrequency) {
    	this.inputFiles = new String[inputFile.size()];
    	this.outputFiles = new String[inputFile.size()];
    	this.detectorIDs = new String[inputFile.size()];
    	this.cpldFrequencies = new double[inputFile.size()];
        
    	for (int i = 0; i < inputFile.size(); i++) {
    		inputFiles[i] = inputFile.get(i).toString();
    		outputFiles[i] = outputFile.get(i).toString();
    		detectorIDs[i] = detector.get(i).toString();
    		cpldFrequencies[i] = Double.valueOf(cpldFrequency.get(i).toString()).doubleValue();
    	}
    	try {
            bwprocess = new BufferedWriter(new FileWriter("/tmp/ThresholdTimesProcess.log"));  
    	} catch (Exception e) {
    		System.out.println("Couldnt open file for output");
    	}    		
    }
    
    public void createTTFiles() {
        starttime = System.currentTimeMillis();
        lineCount = 0;
	    for (int i = 0; i < inputFiles.length; i++) {
	    	//clean up variables
	        lastSecString = "";
	        retime = new double[4];
	        fetime = new double[4];
	        rePPSTime = new long[4];
	        rePPSCount = new long[4];
	        reDiff = new long[4];
	        reTMC = new int[4];	    
	        lastGPSDay = 0;
	        lastEdgeTime = 0;
	        cpldFrequency = 0;	  
	        jd = 0; 
	        lastRePPSTime = 0;
	        lastRePPSCount = 0;

	    	try {
	    		//check if the .thresh exists, if so, do not overwrite it
	    		File tf = new File(outputFiles[i]);
	    		if (tf.exists()) {
	    			bwprocess.write("File exists: "+outputFiles[i]+" - not overwriting it");
	    			continue;
	    		}
	    		
		    	BufferedReader br = new BufferedReader(new FileReader(inputFiles[i]));
		        BufferedWriter bw = new BufferedWriter(new FileWriter(outputFiles[i]));
		        
		        bw.write("#$md5\n");
		        bw.write("#md5_hex("+inputFiles[i] +" "+outputFiles[i]+" " + detectorIDs[i] +" )\n");
		        bw.write("#ID.CHANNEL, Julian Day, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec)\n");
		
		        cpldFrequency = cpldFrequencies[i];
		        if (cpldFrequency == 0) {
		        	cpldFrequency = 41666667;
		        }
		        String line = br.readLine();
		        while (line != null) {
		            String[] parts = line.split("\\s"); // line validated in split.pl
		            for (int j = 0; j < 4; j++) {
		            	try {
		            		timeOverThreshold(parts, j, detectorIDs[i], bw);
		            	} catch (Exception e) {
		            		bwprocess.write("Exception for file: "+inputFiles[i]+" at line: "+String.valueOf(lineCount)+ " " +line+" - " + e.toString() + "\n");
		            		continue;
		            	}
		            }
		            line = br.readLine();
		        }
		        bw.close();
		        br.close();
		        lineCount++;
		        bwprocess.write("Processed file: " + inputFiles[i] + "\n");
		        bwprocess.write(""+ String.valueOf(i) + " files out of " + String.valueOf(inputFiles.length));
	    	} catch (IOException ioe) {
	    		System.out.println("File not found: " + inputFiles[i] + "\n");
	    	}
	    }//end of for loop
	    //record how long it took
        endtime = System.currentTimeMillis();
        System.out.println("The Threshold Time process took: " + String.valueOf(endtime - starttime) + " millisecs for " + String.valueOf(lineCount) + " files\n");
    }
    
    private void timeOverThreshold(String[] parts, int channel, String detector, BufferedWriter bw) throws IOException {
        int indexRE = channel * 2 + 1;
        int indexFE = indexRE + 1;

        int type = Integer.parseInt(parts[1], 16);
        if ((type & 0x80) != 0) {
            retime[channel] = 0;
            clearChannelState(channel);
        }

        int decFE = Integer.parseInt(parts[indexFE], 16);
        int decRE = Integer.parseInt(parts[indexRE], 16);

        if (retime[channel] != 0 && isEdge(decFE)) {
        	fetime[channel] = calctime(channel, decFE, parts);
            if (fetime[channel] != 0) {
            	printData(channel, parts, detector, bw);
                clearChannelState(channel);
            }

            if (isEdge(decRE)) {
                retime[channel] = calctime(channel, decRE, parts);
            }
        }
        else if (isEdge(decRE)) {
            retime[channel] = calctime(channel, decRE, parts);
            if (retime[channel] != 0 && isEdge(decFE)) {
                fetime[channel] = calctime(channel, decFE, parts);
            }
            if (retime[channel] != 0 && fetime[channel] != 0) {
                printData(channel, parts, detector, bw);
                clearChannelState(channel);
            }
        }
    }

    /**
     * Clear channel state for a given channel. 
     * 
     * @param channel Channel to reset. 
     */
    private void clearChannelState(int channel) {
        retime[channel] = 0;
        fetime[channel] = 0;
        rePPSTime[channel] = 0;
        rePPSCount[channel] = 0;
        reDiff[channel] = 0;
        reTMC[channel] = 0;
    }

    private boolean isEdge(int v) {
        return ((v & 0x20) != 0);
    }

    private void printData(int channel, String[] parts, String detector, BufferedWriter wr) throws IOException {
        boolean computeJD = true;

        int currGPSDay = Integer.parseInt(parts[11]);
        double currEdgeTime = 0;

        if (currGPSDay != lastGPSDay) {
            currEdgeTime = retime[channel];
            if ((currEdgeTime >= lastEdgeTime && lastEdgeTime != 0) || currEdgeTime < 0) {
                computeJD = false;
            }
        }

        if (computeJD) {
            int sign = parts[15].charAt(0) == '-' ? -1 : 1;
            int msecOffset = sign * Integer.parseInt(parts[15].substring(1));
            double offset = reDiff[channel] / cpldFrequency + reTMC[channel] / (cpldFrequency * 32) + msecOffset / 1000.0;
            jd = currLineJD(offset, parts);
            lastGPSDay = currGPSDay;
            lastEdgeTime = retime[channel];
        }

        double nanodiff = (fetime[channel] - retime[channel]) * 1e9 * 86400;
        String id = detector + "." + (channel + 1);

        if (nanodiff >= 0 && nanodiff < 10000) {
            wr.write(id);
            wr.write('\t');
            wr.write(String.valueOf(jd));
            wr.write('\t');
            wr.write(NF16F.format(retime[channel]));
            wr.write('\t');
            wr.write(NF16F.format(fetime[channel]));
            wr.write('\t');
            wr.write(NF2F.format(nanodiff));
            wr.write('\n');
        }
    }

    private double calctime(int channel, int edge, String[] parts) {
        int tmc = edge & 0x1f;
	    if (rePPSTime[channel] == 0 || rePPSCount[channel] == 0) {
            rePPSTime[channel] = lastRePPSTime;
            rePPSCount[channel] = lastRePPSCount;

            String currSecString = parts[10] + parts[15];
            if (!currSecString.equals(lastSecString)) {
                rePPSTime[channel] = currentPPSSeconds(parts[10], parts[15]);
                rePPSCount[channel] = Long.parseLong(parts[9], 16);
                lastRePPSTime = rePPSTime[channel];
                lastRePPSCount = rePPSCount[channel];
                lastSecString = currSecString;   
            }
            reTMC[channel] = tmc;
            reDiff[channel] = Long.parseLong(parts[0], 16) - rePPSCount[channel];
        }
	    
	    
	    long parsed = Long.parseLong(parts[0], 16);
        long diff = Long.parseLong(parts[0], 16) - rePPSCount[channel];

        if (diff < -0xaaaaaaaal) {
            diff += 0xffffffffl;
        }

        double first_part = rePPSTime[channel];
        double second_part = diff / cpldFrequency;
        double third_part = tmc / (cpldFrequency * 32);
        double edgetime = rePPSTime[channel] + diff / cpldFrequency + tmc / (cpldFrequency * 32);
        if (edgetime > 86400) {
            edgetime -= 86400;
        }
        return edgetime / 86400;
    }
    
    private static long currentPPSSeconds(String num, String offset) {
        int hour = (Integer.parseInt(num.substring(0, 2)) + 12) % 24;
        int min = Integer.parseInt(num.substring(2, 4));
        double sec = Double.parseDouble(num.substring(4));
        int sign = 1;
        if (offset.charAt(0) == '-') {
            sign = -1;
        }

        long secoffset = Math.round(sec + sign * Integer.parseInt(offset.substring(1)) / 1000.0);
        String edit = offset.substring(1);
        
        long daySeconds = hour * 3600 + min * 60 + secoffset; 
        
        return daySeconds;
    }
    
    private static int currLineJD(double offset, String[] parts) {
        int day = Integer.parseInt(parts[11].substring(0, 2));
        int month = Integer.parseInt(parts[11].substring(2, 4));
        int year = Integer.parseInt(parts[11].substring(4, 6)) + 2000;
        int hour = Integer.parseInt(parts[10].substring(0, 2));
        int min = Integer.parseInt(parts[10].substring(2, 4));
        int sec = Integer.parseInt(parts[10].substring(4, 6));
        int msec = Integer.parseInt(parts[10].substring(7, 10));
        long secOffset = Math.round(sec + msec / 1000.0 + offset);
        double jd = gregorianToJulian(year, month, day, hour, min, (int) secOffset);
        jd = Math.rint(jd * 86400);     
        return (int) Math.floor(jd / 86400);
    }
 
    /**
     * arguments: day[1..31], month[1..12], year[..2004..], hour[0..23],
     * min[0..59]
     */

    private static double gregorianToJulian(int year, int month, int day,
            int hour, int minute, int second) {
        if (month < 3) {
            month = month + 12;
            year = year - 1;
        }    
        return (2.0 -(Math.floor(year/100))+(Math.floor(year/400))+ day + Math.floor(365.25*(year+4716)) + Math.floor(30.6001*(month+1)) - 1524.5) + (hour + minute/60.0 + second/3600.0)/24;
    }
    
    //main receives a txt file created from a query to the database
    //the file should have 4 columns separated by commas
    //1-data path (eg. /disks/i2u2-dev/cosmic/data
    //2-input file name (eg. 6119.2013.0522.1)
    //3-output file name (eg. 6119.2013.0522.1.thresh)
    //4-cpld frequency for that file (eg. 25000000)
    //to create the input file, you can run something like:
    /*
	drop table ep_create_thresh_file

	select  '/disks/data4/i2u2-dev/cosmic/data' as path,
		al.name, 
		al.name || '.thresh' as threshfile,
		al1.id as recordid,
		af.value
	  into ep_create_thresh_file
	  from anno_lfn al
	 inner join anno_text at
	    on al.id = at.id
	 full outer join anno_lfn al1
	    on al.name = al1.name
	 full outer join anno_float af
	    on al1.id = af.id
	 where at.value = 'split'
	   --and al.name like '6148%'
	   and al1.mkey = 'cpldfrequency'
	   order by al.name
	
	select * 
	 from ep_create_thresh_file
	
	update ep_create_thresh_file
	   set value = anno_int.value
	  from anno_int 
	where anno_int.id = ep_create_thresh_file.recordid  
	
	drop table ep_create_thresh_file_complete
	
	select path, name, threshfile, value
	 into ep_create_thresh_file_complete 
	 from ep_create_thresh_file 
     */
    
    public static void main(String[] args) {
    	ThresholdTimesProcess ttp;
    	List inputFile = new ArrayList();
    	List outputFile = new ArrayList();
    	List detector = new ArrayList();
    	List cpldFrequency = new ArrayList();
    	
    	if (args.length == 1) {
    		String iFile = args[0];
    		try {
    			BufferedReader br = new BufferedReader(new FileReader(iFile));			
		        String line = br.readLine();
		        while (line != null) {
			        String[] splitLine = line.split(","); 
			        if (splitLine.length == 4) {
			        	String filename = splitLine[1];
			        	String threshfile = splitLine[2];
			        	String detectorId = filename.substring(0, filename.indexOf('.'));
			        	String path = splitLine[0] + File.separator + detectorId + File.separator;
			        	String cpldf = splitLine[3];
			        	inputFile.add(path+filename);
			        	outputFile.add(path+threshfile);
			        	detector.add(detectorId);
			        	cpldFrequency.add(cpldf);
			        }
		            line = br.readLine();
		        }
		        
		        br.close();
		        
    		} catch (Exception e) {
        		System.out.println("Could not open the file");    			
    		}

    		ttp = new ThresholdTimesProcess(inputFile, outputFile, detector, cpldFrequency);      
    		ttp.createTTFiles();
    	} else {
    		System.out.println("Usage: ThresholdTimesProcess input_file");
    	}
    }//end of main   
}
