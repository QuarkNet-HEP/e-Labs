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


public class ThresholdTimesProcessDebug {
    private String[] inputFiles, outputFiles, detectorIDs;
    private double[] cpldFrequencies;
    private double[] retime, fetime;
    private double[] retimeINT, fetimeINT;  
    private long[] rePPSTime, rePPSCount, reDiff;
    private int[] reTMC;
    private long lastRePPSTime, lastRePPSCount;
    private int lastGPSDay, jd;
    private String lastSecString;
    private double lastEdgeTime, lastjdplustime;
    private double cpldFrequency;
    private long starttime, endtime;
    private static int lineCount;
    private static int printLineCount;
    private int currentDetector;

    public static final NumberFormat NF0F = new DecimalFormat("0");
    public static final NumberFormat NF2F = new DecimalFormat("0.00");
    public static final NumberFormat NF16F = new DecimalFormat("0.0000000000000000");
    public static final NumberFormat TIME_FORMAT;
    public final int detectorSeriesChange = 6000;
    
    static {
        TIME_FORMAT = NumberFormat.getNumberInstance();
        TIME_FORMAT.setMaximumFractionDigits(3);
        TIME_FORMAT.setMinimumFractionDigits(3);
    }
    
    public ThresholdTimesProcessDebug(List inputFile, List outputFile, List detector, List cpldFrequency) {
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
    	} catch (Exception e) {
    		System.out.println("Couldnt open file for output");
    	}
    }
    
    public void createTTFiles() {
        starttime = System.currentTimeMillis();
        lineCount = 0;
        printLineCount = 0;
        try {
        	//File report = new File("/users/edit/showertest/threshcreation.txt");
        	//if (!report.exists()) {
        	//	report.createNewFile();
        	//}
		    for (int i = 0; i < inputFiles.length; i++) {
		        lastSecString = "";
		        retime = new double[4];
		        fetime = new double[4];
		        retimeINT = new double[4];
		        fetimeINT = new double[4];
		        rePPSTime = new long[4];
		        rePPSCount = new long[4];
		        reDiff = new long[4];
		        reTMC = new int[4];	 
		        jd = 0;
		        lastGPSDay = 0;
		        lastEdgeTime = 0;
		        lastRePPSTime = 0;
		        lastRePPSCount = 0;
		        lastjdplustime = 0;
		    	try {
		    		//check if the .thresh exists, if so, do not overwrite it
		    		File tf = new File(outputFiles[i]);
		    		//if (tf.exists()) {
		    		//	System.out.println("File exists: "+outputFiles[i]+" - not overwriting it");
		    		//	continue;
		    		//}
		    		
			    	BufferedReader br = new BufferedReader(new FileReader(inputFiles[i]));
			        BufferedWriter bw = new BufferedWriter(new FileWriter(outputFiles[i]));
			        BufferedWriter report = new BufferedWriter(new FileWriter("/users/edit/ep_home/ep_thresh/threshcreation.txt"));
			        			        
			        bw.write("#$md5\n");
			        bw.write("#md5_hex(0)\n");
			        bw.write("#ID.CHANNEL, Julian Day, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec), RISING EDGE(INT), FALLING EDGE(INT)\n");
			
			        cpldFrequency = cpldFrequencies[i];
			        currentDetector = Integer.parseInt(detectorIDs[i]);
			        
			        if (cpldFrequency == 0) {
			        	if (Integer.parseInt(detectorIDs[i]) < detectorSeriesChange) {
			        		cpldFrequency = 41666667;
			        	} else {
			        		cpldFrequency = 25000000;
			        	}
			        }
	        		cpldFrequency = 25000000;
			        String line = br.readLine();
			        
			        boolean printoneexception = true;
			        while (line != null) {
			        	report.write("\n"+line+"\n");
			            String[] parts = line.split("\\s"); // line validated in split.pl
			            for (int j = 0; j < 4; j++) {
			            	try {
			            		timeOverThreshold(parts, j, detectorIDs[i], bw, report);
			            	} catch (Exception e) {
			            		if (printoneexception) {
			            			printoneexception = false;
				            		System.out.println("Exception for file: "+inputFiles[i]+": " + e.toString());
			            		}
			            		continue;
			            	}
			            }
			            line = br.readLine();
			        }
			        bw.close();
			        br.close();
			        report.close();
			        lineCount++;
		    		System.out.println("Processed file: " + inputFiles[i]+" "+ String.valueOf(i) + " files out of " + String.valueOf(inputFiles.length));
		    	} catch (IOException ioe) {
		    		System.out.println("File not found: " + inputFiles[i]);
		    	}
		    }//end of for loop
        } catch (Exception ex) {
        	
        }
		//record how long it took
        endtime = System.currentTimeMillis();
        System.out.println("The Threshold Time process took: " + formatTime(endtime - starttime) + " for " + String.valueOf(lineCount) + " files\n");
    }
    public String formatTime(long time) {
        return TIME_FORMAT.format((double) time / 1000);
    }
    
    private void timeOverThreshold(String[] parts, int channel, String detector, BufferedWriter bw, BufferedWriter report) throws IOException {
    	double edgetimeSeconds = 0;
    	long exp = Double.valueOf("1.0E+11").longValue();
    	int indexRE = channel * 2 + 1;
        int indexFE = indexRE + 1;
        
        int type = Integer.parseInt(parts[1], 16);
        if ((type & 0x80) != 0) {
            retime[channel] = 0;
            retimeINT[channel] = 0;
            clearChannelState(channel);
        }

        int decFE = Integer.parseInt(parts[indexFE], 16);
        int decRE = Integer.parseInt(parts[indexRE], 16);

        if (retime[channel] != 0 && retimeINT[channel] != 0 && isEdge(decFE)) {
        	//if (printLineCount > 967540){
        		//report.write("channel: "+String.valueOf(channel)+"\n");
        		//report.write("decFE: "+String.valueOf(decFE)+"\n");
        		//report.write("isEdge(decFE) --> (("+String.valueOf(decFE)+" & 0x20) != 0): "+String.valueOf(isEdge(decFE))+"\n");
        		//report.write("value of RE time for this channel: "+String.valueOf(retime[channel])+"\n");
        	//}
        	edgetimeSeconds = calctime(channel, decFE, parts, report);
        	fetime[channel] = edgetimeSeconds/86400;
        	fetimeINT[channel] = edgetimeSeconds * exp;
        	//if (printLineCount > 967540){
        		//report.write("value of FE time for this channel: "+String.valueOf(fetime[channel])+"\n");
        	//}
            if (fetime[channel] != 0 && fetimeINT[channel] != 0) {
            //	if (printLineCount > 967540){
            		//report.write("value of FE time for this channel: "+String.valueOf(fetime[channel])+"\n");
            		//report.write("printing to thresh file...\n");       
            //	}
            	printData(channel, parts, detector, bw, report);
                clearChannelState(channel);
            }

            if (isEdge(decRE)) {
            //	if (printLineCount > 967540){
            		//report.write("isEdge(decRE) --> (("+String.valueOf(decRE)+" & 0x20) != 0): "+String.valueOf(isEdge(decRE))+"\n");
            //	}
            	edgetimeSeconds = calctime(channel, decRE, parts, report);
                retime[channel] = edgetimeSeconds/86400;
                retimeINT[channel] = edgetimeSeconds * exp;
           // 	if (printLineCount > 967540){
            		//report.write("value of RE time for this channel: "+String.valueOf(retime[channel])+"\n");
            //	}
            }
        }
        else if (isEdge(decRE)) {
        	//if (printLineCount > 967540){
        		//report.write("channel: "+String.valueOf(channel)+"\n");
        		//report.write("isEdge(decRE) --> (("+String.valueOf(decRE)+" & 0x20) != 0): "+String.valueOf(isEdge(decRE))+"\n");
        	//}
        	edgetimeSeconds = calctime(channel, decRE, parts, report);
            retime[channel] = edgetimeSeconds/86400;
            retimeINT[channel] = edgetimeSeconds * exp;
        	//if (printLineCount > 967540){
        		//report.write("value of RE time for this channel: "+String.valueOf(retime[channel])+"\n");
        	//}
            if (retime[channel] != 0 && retimeINT[channel] != 0 && isEdge(decFE)) {
            	edgetimeSeconds = calctime(channel, decFE, parts, report);
                fetime[channel] = edgetimeSeconds/86400;
                fetimeINT[channel] = edgetimeSeconds * exp;
            //	if (printLineCount > 967540){
            		//report.write("value of FE time for this channel: "+String.valueOf(fetime[channel])+"\n");
            //	}
            }
            if (retime[channel] != 0 && retimeINT[channel] != 0 && fetime[channel] != 0) {
            //	if (printLineCount > 967540){
            		//report.write("printing to thresh file...\n");       
            //	}
                printData(channel, parts, detector, bw, report);
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
        retimeINT[channel] = 0;
        fetimeINT[channel] = 0;
        rePPSTime[channel] = 0;
        rePPSCount[channel] = 0;
        reDiff[channel] = 0;
        reTMC[channel] = 0;
    }

    private boolean isEdge(int v) {
        return ((v & 0x20) != 0);
    }

    private void printData(int channel, String[] parts, String detector, BufferedWriter wr, BufferedWriter report) throws IOException {
        boolean computeJD = true;

        int currGPSDay = Integer.parseInt(parts[11]);
        double currEdgeTime = 0;

        if (currGPSDay != lastGPSDay) {
            currEdgeTime = retime[channel];
            if ((currEdgeTime >= lastEdgeTime && lastEdgeTime != 0) || currEdgeTime < 0) {
                computeJD = false;
            }
        }
    	//report.write("currGPSDay: "+String.valueOf(currGPSDay)+"\n");

        if (computeJD) {
            int sign = parts[15].charAt(0) == '-' ? -1 : 1;
            int msecOffset = 0;
            //459: newer cards don't use the offset
            if (currentDetector < detectorSeriesChange) {
                msecOffset = sign * Integer.parseInt(parts[15].substring(1));            	
            }
        	//report.write("reDiff[channel]: "+String.valueOf(reDiff[channel])+"\n");
        	//report.write("cpldFrequency: "+String.valueOf(cpldFrequency)+"\n");
        	//report.write("reTMC[channel]: "+String.valueOf(reTMC[channel])+"\n");
        	//report.write("msecOffset: "+String.valueOf(msecOffset)+"\n");
            double offset = reDiff[channel] / cpldFrequency + reTMC[channel] / (cpldFrequency * 32) + msecOffset / 1000.0;
            if (lastjdplustime > 0) {
            	double tempjdplustime = currLineJD(offset, parts, report) + retime[channel];
            	if (tempjdplustime > lastjdplustime) {
                    jd = currLineJD(offset, parts, report);           		
            	}
            } else {
                jd = currLineJD(offset, parts, report);           		            	
            }
            lastGPSDay = currGPSDay;
            lastEdgeTime = retime[channel];
        }

        double nanodiff = (fetime[channel] - retime[channel]) * 1e9 * 86400;
    	//if (printLineCount > 967540){
    		//report.write("nanodiff (fetime[channel] - retime[channel]) * 1e9 * 86400: "+String.valueOf(nanodiff)+"\n");
    	//}								   
        String id = detector + "." + (channel + 1);
        if (nanodiff >= 0 && nanodiff < 10000) {
        	lastjdplustime = jd + retime[channel];
        	printLineCount = printLineCount + 1;
            wr.write(id);
            wr.write('\t');
            wr.write(String.valueOf(jd));
            wr.write('\t');
            wr.write(NF16F.format(retime[channel]));
            wr.write('\t');
            wr.write(NF16F.format(fetime[channel]));
            wr.write('\t');
            wr.write(NF2F.format(nanodiff));
            wr.write('\t');
            wr.write(NF0F.format(retimeINT[channel]));
            wr.write('\t');
            wr.write(NF0F.format(fetimeINT[channel]));
            wr.write('\n');
        	//if (printLineCount > 967540){
            	report.write("lastjdplustime: "+String.valueOf(lastjdplustime)+"\n");
        		report.write("\nTHRESH FILE LINE:"+id+"\t"+
    				String.valueOf(jd)+"\t"+
    				NF16F.format(retime[channel])+"\t"+
    				NF16F.format(fetime[channel])+"\t"+
    				NF2F.format(nanodiff)+"\t"+
    				NF0F.format(retimeINT[channel])+"\t"+
    				NF0F.format(fetimeINT[channel])+"\n");
        	//}
        }
    }

    private double calctime(int channel, int edge, String[] parts, BufferedWriter report) {
        int tmc = edge & 0x1f;
        try {
        	//if (printLineCount > 967540){ 		       	
        		//report.write("\nIn calctime...\n");
        		//report.write("tmc ("+String.valueOf(edge)+" & 0x1f): "+String.valueOf(tmc)+"\n");
        	//}
		    if (rePPSTime[channel] == 0 || rePPSCount[channel] == 0) {
	            rePPSTime[channel] = lastRePPSTime;
	            rePPSCount[channel] = lastRePPSCount;
	            String currSecString = parts[10] + parts[15];
	            boolean answer = currentDetector > 5999;
	            
	        	if (currentDetector >= detectorSeriesChange) {
	        		currSecString = parts[10];
	        	}           
	            if (!currSecString.equals(lastSecString)) {
	            	if (currentDetector >= detectorSeriesChange) {
	            		rePPSTime[channel] = currentPPSSeconds(parts[10], "+0");
	            	} else {
	            		rePPSTime[channel] = currentPPSSeconds(parts[10], parts[15]);            		
	            	}
	            	rePPSCount[channel] = Long.parseLong(parts[9], 16);
	                lastRePPSTime = rePPSTime[channel];
	                lastRePPSCount = rePPSCount[channel];
	                lastSecString = currSecString;   
	            }
	        	//if (printLineCount > 967540){	            
	        		//report.write("rePPSTime calculated from "+parts[10]+"\n");
	        		//report.write("reCount calculated from "+parts[9]+"\n");
	        		//report.write("value of re PPSTime for this channel: "+String.valueOf(rePPSTime[channel])+"\n");
	        		//report.write("value of re Count for this channel: "+String.valueOf(rePPSCount[channel])+"\n");
	        	//}
	        	reTMC[channel] = tmc;
	            reDiff[channel] = Long.parseLong(parts[0], 16) - rePPSCount[channel];
	        	//if (printLineCount > 967540){
	        		//report.write("first part:  "+String.valueOf(Long.parseLong(parts[0], 16))+" from hex to long\n");
	        		//report.write("second part:  "+String.valueOf(rePPSCount[channel])+" from hex to long\n");
	        		//report.write("re Diff calculated from "+parts[0]+" from hex to long\n");
	        		//report.write("value of re Diff for this channel: "+String.valueOf(reDiff[channel])+"\n");
	        	//}
		    }
		      
		    long parsed = Long.parseLong(parts[0], 16);
	        long diff = Long.parseLong(parts[0], 16) - rePPSCount[channel];
	
    		//report.write("-->diff for this channel (see code): "+String.valueOf(diff)+"\n");
	        if (diff < -0xaaaaaaaal) {
	            diff += 0xffffffffl;
	            reDiff[channel] = diff;
	        }
        	//if (printLineCount > 967540){
        		report.write("-->new value of diff for this channel (see code): "+String.valueOf(diff)+"\n");
        	//}
	        double first_part = rePPSTime[channel];
	        double second_part = diff / cpldFrequency;
	        double third_part = tmc / (cpldFrequency * 32);
	        double edgetime = rePPSTime[channel] + diff / cpldFrequency + tmc / (cpldFrequency * 32);
        	//if (printLineCount > 967540){
		        //report.write("value of rePPSTime[channel] for this channel: "+String.valueOf(first_part)+"\n");
		        //report.write("value of diff / cpldFrequency for this channel: "+String.valueOf(second_part)+"\n");
		        //report.write("value of tmc / (cpldFrequency * 32) for this channel: "+String.valueOf(third_part)+"\n");
		        //report.write("value of rePPSTime[channel] + diff / cpldFrequency + tmc / (cpldFrequency * 32) for this channel: "+String.valueOf(edgetime)+"\n");
        	//}
	        if (edgetime > 86400) {
	            edgetime -= 86400;
	        }
        	//if (printLineCount > 967540){		        
        		//report.write("edgetime (if corrected): "+String.valueOf(edgetime)+"\n");
        	//}
        	//return edgetime / 86400;
	        return edgetime;
        } catch(Exception e) {
        	
        }
        return 0;
    }
    
    public double truncateDouble(double number, int numDigits) {
        double result = number;
        String arg = "" + number;
        int idx = arg.indexOf('.');
        if (idx!=-1) {
            if (arg.length() > idx+numDigits) {
                arg = arg.substring(0,idx+numDigits+1);
                result  = Double.parseDouble(arg);
            }
        }
        return result ;
    }
    
    public static double roundToNumberOfSignificantDigits(double num, int n) {

        final double maxPowerOfTen = Math.floor(Math.log10(Double.MAX_VALUE));

        if(num == 0) {
            return 0;
        }

        final double d = Math.ceil(Math.log10(num < 0 ? -num: num));
        final int power = n - (int) d;

        double firstMagnitudeFactor = 1.0;
        double secondMagnitudeFactor = 1.0;
        if (power > maxPowerOfTen) {
            firstMagnitudeFactor = Math.pow(10.0, maxPowerOfTen);
            secondMagnitudeFactor = Math.pow(10.0, (double) power - maxPowerOfTen);
        } else {
            firstMagnitudeFactor = Math.pow(10.0, (double) power);
        }

        double toBeRounded = num * firstMagnitudeFactor;
        toBeRounded *= secondMagnitudeFactor;

        final long shifted = Math.round(toBeRounded);
     
        double rounded = ((double) shifted) / firstMagnitudeFactor;
        rounded /= secondMagnitudeFactor;
        return rounded;
    }   
    
    private static long currentPPSSeconds(String num, String offset) {
        int hour = (Integer.parseInt(num.substring(0, 2)) + 12) % 24;
        int min = Integer.parseInt(num.substring(2, 4));
        double sec = Double.parseDouble(num.substring(4));
        int sign = 1;
        if (offset.charAt(0) == '-') {
            sign = -1;
        }

        int x = Integer.parseInt(offset.substring(1));
        double y = Integer.parseInt(offset.substring(1)) / 1000.0;
        long secoffset = Math.round(sec + sign * Integer.parseInt(offset.substring(1)) / 1000.0);
        //String edit = offset.substring(1);
        
        long daySeconds = hour * 3600 + min * 60 + secoffset; 
        
        return daySeconds;
    }
       
    private static int currLineJD(double offset, String[] parts, BufferedWriter report) {
        int day = Integer.parseInt(parts[11].substring(0, 2));
        int month = Integer.parseInt(parts[11].substring(2, 4));
        int year = Integer.parseInt(parts[11].substring(4, 6)) + 2000;
        int hour = Integer.parseInt(parts[10].substring(0, 2));
        int min = Integer.parseInt(parts[10].substring(2, 4));
        int sec = Integer.parseInt(parts[10].substring(4, 6));
        int msec = Integer.parseInt(parts[10].substring(7, 10));
        long secOffset = Math.round(sec + msec / 1000.0 + offset);
        try{
        	report.write("In currLineJD");
        	report.write("day: "+String.valueOf(day)+"\n");
        	report.write("month: "+String.valueOf(month)+"\n");
        	report.write("year: "+String.valueOf(year)+"\n");
        	report.write("hour: "+String.valueOf(hour)+"\n");
        	report.write("min: "+String.valueOf(min)+"\n");
        	report.write("sec: "+String.valueOf(sec)+"\n");
        	report.write("msec: "+String.valueOf(msec)+"\n");
        	report.write("secOffset: "+String.valueOf(secOffset)+"\n");
        } catch (Exception e) {
        	
        }
        double jd = gregorianToJulian(year, month, day, hour, min, (int) secOffset, report);
        jd = Math.rint(jd * 86400);
        try{
        	report.write("jd: "+String.valueOf(jd / 86400)+"\n");
        	report.write("jd: "+String.valueOf(Math.rint(jd * 86400))+"\n");
        	report.write("jd: "+String.valueOf((int) Math.floor(jd / 86400))+"\n");
        } catch (Exception e) {
        	
        }
        return (int) Math.floor(jd / 86400);
    }
 
    /**
     * arguments: day[1..31], month[1..12], year[..2004..], hour[0..23],
     * min[0..59]
     */

    private static double gregorianToJulian(int year, int month, int day,
            int hour, int minute, int second, BufferedWriter report) {
        if (month < 3) {
            month = month + 12;
            year = year - 1;
        }      
        try{
        	report.write("in gregorian to julian function");
        	report.write("month: "+String.valueOf(month)+"\n");
        	report.write("year: "+String.valueOf(year)+"\n");
        	report.write("returns: "+String.valueOf((2.0 -(Math.floor(year/100))+(Math.floor(year/400))+ day + Math.floor(365.25*(year+4716)) + Math.floor(30.6001*(month+1)) - 1524.5) + (hour + minute/60.0 + second/3600.0)/24)+"\n");
        } catch (Exception e) {
        	
        }        
        return (2.0 -(Math.floor(year/100))+(Math.floor(year/400))+ day + Math.floor(365.25*(year+4716)) + Math.floor(30.6001*(month+1)) - 1524.5) + (hour + minute/60 + second/3600.0)/24;
    	//return (2 -(int($year/100))+(int($year/400))+ $day + int(365.25*($year+4716)) + int(30.6001*($month+1)) - 1524.5) + ($hour + $min/60 + $sec/3600)/24;
    }
    
    //main receives a txt file created from a query to the database
    //the file should have 4 columns separated by commas
    //1-data path (eg. /disks/i2u2-dev/cosmic/data
    //2-input file name (eg. 6119.2013.0522.1)
    //3-output file name (eg. 6119.2013.0522.1.thresh)
    //4-cpld frequency for that file (eg. 25000000)
    //to create the input file, you can run something like:
    /*
     * 		   select  '/disks/i2u2-dev/cosmic/data' as path,
						al.name, 
						al.name || '.thresh' as threshfile,
						ai.value
		  		 from 	anno_lfn al
		   inner join 	anno_text at
		    	   on 	al.id = at.id
	  full outer join 	anno_lfn al1
		    	   on 	al.name = al1.name
	  full outer join 	anno_int ai
		    	   on 	al1.id = ai.id
		 	    where 	at.value = 'split'
		   		  and 	al.name like '6119%'
		   		  and 	al1.mkey = 'cpldfrequency'
		   	 order by 	al.name
   	 *
     */
    public static void main(String[] args) {
    	ThresholdTimesProcessDebug ttp;
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

    		ttp = new ThresholdTimesProcessDebug(inputFile, outputFile, detector, cpldFrequency);      
    		ttp.createTTFiles();
    	} else {
    		System.out.println("Usage: ThresholdTimesProcess input_file");
    	}
    }//end of main   
}
