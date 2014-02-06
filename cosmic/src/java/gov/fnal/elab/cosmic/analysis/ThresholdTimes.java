/*
 * Created on October 11 2013 (based on ThresholdTimes.java - trunk)
 * EPeronja-10/17/2013: THRESHOLD TEST
 */
package gov.fnal.elab.cosmic.analysis;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.concurrent.Callable;
import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;


/**
 * Calculates the absolute time of both the rising and falling edge of an event to a precision of 0.75ns. 
 */
public class ThresholdTimes implements Runnable{
    private String[] inputFiles, outputFiles, detectorIDs;
    private double[] cpldFrequencies;
    private double[] retime, fetime;
    private double[] retimeINT, fetimeINT;  
    private long[] rePPSTime, rePPSCount, reDiff;
    private int[] reTMC;
    private long lastRePPSTime, lastRePPSCount;
    private int lastGPSDay, jd;
    private String lastSecString;
    private double lastEdgeTime;
    private double cpldFrequency;
    private int currentDetector;
    Elab elabReference;
    
    public static final NumberFormat NF0F = new DecimalFormat("0");
    public static final NumberFormat NF2F = new DecimalFormat("0.00");
    public static final NumberFormat NF16F = new DecimalFormat("0.0000000000000000");

    /**
     * Constructor arguments: Elab elab, String[] inputFiles, String detectorId
     */   
    public ThresholdTimes(Elab elab, String[] inputFiles, String detectorId) {
    	this.inputFiles = inputFiles;
    	this.outputFiles = new String[inputFiles.length];
    	this.detectorIDs = new String[inputFiles.length];
    	this.cpldFrequencies = new double[inputFiles.length];
    	this.elabReference = elab;
    	for (int i = 0; i < inputFiles.length; i++) {
    		outputFiles[i] = inputFiles[i] + ".thresh";
    		detectorIDs[i] = detectorId;
    		try {
				VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(inputFiles[i]);
				if (entry != null) {
					Long cpldf = (Long) entry.getTupleValue("cpldfrequency");
					cpldFrequencies[i] = cpldf.doubleValue();
				} else {
					cpldFrequencies[i] = 0;
				}
    		} catch (Exception e) {
    			cpldFrequencies[i] = 0;
    		}
    	}
    }
    
    public void run() {
    	try {
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
		        
				String inputFile = elabReference.getProperties().getDataDir() + File.separator + detectorIDs[i] +File.separator + inputFiles[i];
				String outputFile = elabReference.getProperties().getDataDir() + File.separator + detectorIDs[i] +File.separator + outputFiles[i];
		        BufferedReader br = new BufferedReader(new FileReader(inputFile));
		        BufferedWriter bw = new BufferedWriter(new FileWriter(outputFile));
		
		        bw.write("#$md5\n");
		        bw.write("#md5_hex(0)\n");
		        bw.write("#ID.CHANNEL, Julian Day, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec), RISING EDGE(INT), FALLING EDGE(INT)\n");
		
		        cpldFrequency = cpldFrequencies[i];
		        currentDetector = Integer.parseInt(detectorIDs[i]);
		        if (cpldFrequency == 0) {
		        	if (currentDetector < 6000) {
		        		cpldFrequency = 41666667;
		        	} else {
		        		cpldFrequency = 25000000;
		        	}
		        }
		        String line = br.readLine();
		        while (line != null) {
		            String[] parts = line.split("\\s"); // line validated in split.pl 
		            for (int j = 0; j < 4; j++) {
		            	try {
		            		timeOverThreshold(parts, j, detectorIDs[i], bw);
		            	} catch (Exception e) {
		            		System.out.println("Exception for file: "+inputFiles[i]+": " + e.toString());
		            		continue;
		            	}
		            }
		            line = br.readLine();
		        }
		        bw.close();
		        br.close();
		    }
        }
        catch (IOException ioe) {
        	// abort?
        }
    }

    private void timeOverThreshold(String[] parts, int channel, String detector, BufferedWriter bw) throws IOException {
    	double edgetimeSeconds = 0;
    	long exp = Double.valueOf("1.0E+11").longValue();   	
        int indexRE = channel * 2 + 1;
        int indexFE = indexRE + 1;

        int type = Integer.parseInt(parts[1], 16);
        if ((type & 0x80) != 0) {
            retime[channel] = 0;
            retimeINT[channel] = 0;            
        }

        int decFE = Integer.parseInt(parts[indexFE], 16);
        int decRE = Integer.parseInt(parts[indexRE], 16);

        if (retime[channel] != 0 && retimeINT[channel] != 0 && isEdge(decFE)) {
        	edgetimeSeconds = calctime(channel, decFE, parts);
        	fetime[channel] = edgetimeSeconds/86400;
        	fetimeINT[channel] = edgetimeSeconds * exp;
        	
            if (fetime[channel] != 0 && fetimeINT[channel] != 0) {
            	printData(channel, parts, detector, bw);
                clearChannelState(channel);
            }

            if (isEdge(decRE)) {
            	edgetimeSeconds = calctime(channel, decRE, parts);
                retime[channel] = edgetimeSeconds/86400;
                retimeINT[channel] = edgetimeSeconds * exp;
            }
        }
        else if (isEdge(decRE)) {
        	edgetimeSeconds = calctime(channel, decRE, parts);
            retime[channel] = edgetimeSeconds/86400;
            retimeINT[channel] = edgetimeSeconds * exp;
            if (retime[channel] != 0 && retimeINT[channel] != 0 && isEdge(decFE)) {
            	edgetimeSeconds = calctime(channel, decFE, parts);
                fetime[channel] = edgetimeSeconds/86400;
                fetimeINT[channel] = edgetimeSeconds * exp;
            }
            if (retime[channel] != 0 && retimeINT[channel] != 0 && fetime[channel] != 0) {
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
            int msecOffset = 0;
            //459: newer cards dont use the offset
            if (currentDetector < 6000) {
                msecOffset = sign * Integer.parseInt(parts[15].substring(1));            	
            }
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
            wr.write('\t');
            wr.write(NF0F.format(retimeINT[channel]));
            wr.write('\t');
            wr.write(NF0F.format(fetimeINT[channel]));            
            wr.write('\n');
        }
    }

    private double calctime(int channel, int edge, String[] parts) {
        int tmc = edge & 0x1f;

        if (rePPSTime[channel] == 0 || rePPSCount[channel] == 0) {
            rePPSTime[channel] = lastRePPSTime;
            rePPSCount[channel] = lastRePPSCount;

            String currSecString = parts[10] + parts[15];
        	if (currentDetector > 5999) {
        		currSecString = parts[10];
        	}    
            if (!currSecString.equals(lastSecString)) {
            	//for bug 459
            	if (currentDetector > 5999) {
            		rePPSTime[channel] = currentPPSSeconds(parts[10], "+0");
            	} else {
            		rePPSTime[channel] = currentPPSSeconds(parts[10], parts[15]);            		
            	}
            	
                rePPSCount[channel] = Long.parseLong(parts[9], 16);
                lastRePPSTime = rePPSTime[channel];
                lastRePPSCount = rePPSCount[channel];

                lastSecString = currSecString;               
            }

            reTMC[channel] = tmc;
            reDiff[channel] = Long.parseLong(parts[0], 16) - rePPSCount[channel];
        }

        long diff = Long.parseLong(parts[0], 16) - rePPSCount[channel];

        if (diff < -0xaaaaaaaal) {
            diff += 0xffffffffl;
        }

        double edgetime = rePPSTime[channel] + diff / cpldFrequency + tmc / (cpldFrequency * 32);
        if (edgetime > 86400) {
            edgetime -= 86400;
        }
                
        //return edgetime / 86400;
        return edgetime;
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
    
}
