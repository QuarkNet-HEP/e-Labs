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
    private double[] cpldFrequencies, firmwares;
    private double[] retime, fetime;
    private double[] retimeINT, fetimeINT;  
    private long[] rePPSTime, rePPSCount, reDiff;
    private int[] reTMC;
    private long lastRePPSTime, lastRePPSCount;
    private int lastGPSDay, jd, startJd, nextJd;
    private String lastSecString;
    private double lastEdgeTime, lastjdplustime, firstRE;
    private double cpldFrequency, firmware;
    private long starttime, endtime;
    private static int lineCount;
    private static int printLineCount;
    private int currentDetector;

    public static final NumberFormat NF0F = new DecimalFormat("0");
    public static final NumberFormat NF2F = new DecimalFormat("0.00");
    public static final NumberFormat NF16F = new DecimalFormat("0.0000000000000000");
    public static final NumberFormat TIME_FORMAT;
    public final int detectorSeriesChange = 6000;
    public final double upperFirstHalfDay = 0.9999999999999999;
    public final double lowerFirstHalfDay = 0.5;
    public static boolean dayRolled = false;
    
    static {
        TIME_FORMAT = NumberFormat.getNumberInstance();
        TIME_FORMAT.setMaximumFractionDigits(3);
        TIME_FORMAT.setMinimumFractionDigits(3);
    }
    
    public ThresholdTimesProcess(List inputFile, List outputFile, List detector, List cpldFrequency, List firmware) {
    	this.inputFiles = new String[inputFile.size()];
    	this.outputFiles = new String[inputFile.size()];
    	this.detectorIDs = new String[inputFile.size()];
    	this.cpldFrequencies = new double[inputFile.size()];
       	this.firmwares = new double[inputFile.size()];
               
    	for (int i = 0; i < inputFile.size(); i++) {
    		inputFiles[i] = inputFile.get(i).toString();
    		outputFiles[i] = outputFile.get(i).toString();
    		detectorIDs[i] = detector.get(i).toString();
    		cpldFrequencies[i] = Double.valueOf(cpldFrequency.get(i).toString()).doubleValue();
    		firmwares[i] = Double.valueOf(firmware.get(i).toString()).doubleValue();
       	    	}
    	try {
    	} catch (Exception e) {
    		System.out.println("Couldnt open file for output");
    	}
    }
    
    public void createTTFiles() {
        starttime = System.currentTimeMillis();
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
		        lastjdplustime = 0;
		        startJd = 0;
		        nextJd = 0;
		        firstRE = -1.0;
		        
		    	try {
			    	BufferedReader br = new BufferedReader(new FileReader(inputFiles[i]));
			        BufferedWriter bw = new BufferedWriter(new FileWriter(outputFiles[i]));
			        			        
			        bw.write("#$md5\n");
			        bw.write("#md5_hex(0)\n");
			        bw.write("#ID.CHANNEL, Julian Day, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec), RISING EDGE(INT), FALLING EDGE(INT)\n");
			
			        cpldFrequency = cpldFrequencies[i];
			        currentDetector = Integer.parseInt(detectorIDs[i]);
			        firmware = firmwares[i];
			        
			        //hardcoded for this time around
			        if (cpldFrequency == 0) {
			        	if (Integer.parseInt(detectorIDs[i]) < detectorSeriesChange) {
			        		cpldFrequency = 41666667;
			        	} else {
			        		cpldFrequency = 25000000;
			        	}
			        }

			        String line = br.readLine();			        
			        boolean printoneexception = true;
			        while (line != null) {
			            String[] parts = line.split("\\s"); // line validated in split.pl
			            for (int j = 0; j < 4; j++) {
			            	try {
			            		timeOverThreshold(parts, j, detectorIDs[i], bw);
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
			        checkFileTiming(outputFiles[i]);
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

    public void checkFileTiming(String threshfile) throws IOException {
    	try {
	    	BufferedReader br = new BufferedReader(new FileReader(threshfile));
	        String line = br.readLine();
	        Double priortime = 0.0;
	        Double beginjd = 0.0;
	        Double lastjd = 0.0;
	        int linecount = 0;
	        while (line != null) {
	            String[] parts = line.split("\\s");
	            Double newtime = Double.valueOf(parts[1]) + Double.valueOf(parts[2]);
	            if (linecount == 0) {
	            	beginjd = Double.valueOf(parts[1]);
	            }
	            linecount++;
	            lastjd = Double.valueOf(parts[1]);
	            if (newtime < priortime) {
	            	System.out.println(threshfile + " has a time problem: "+String.valueOf(priortime)+" before "+String.valueOf(newtime)+"\n");
	            }
	            priortime = newtime;
	            line = br.readLine();
	        }
	        if (lastjd - beginjd > 1) {
            	System.out.println(threshfile + " has a julian day problem: "+String.valueOf(beginjd)+" to "+String.valueOf(lastjd)+"\n");
	        }
	        br.close();
    		
    	} catch (Exception e) {
    		
    	}
    }//end of checkFileTiming
    
    private void timeOverThreshold(String[] parts, int channel, String detector, BufferedWriter bw) throws IOException {
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
            //459: newer cards don't use the offset
            if (currentDetector < detectorSeriesChange) {
                msecOffset = sign * Integer.parseInt(parts[15].substring(1));            	
            }
            double offset = reDiff[channel] / cpldFrequency + reTMC[channel] / (cpldFrequency * 32) + msecOffset / 1000.0;
            //Bug 469: the rollover of the julian day and the RE needs be in sync
            //		   to check that, the new julian day + rising edge needs to be larger than the prior one
            if (lastjdplustime > 0) {
            	double tempjdplustime = currLineJD(offset, parts) + retime[channel];
            	double tempdiff = tempjdplustime - lastjdplustime;
            	if (tempjdplustime > lastjdplustime && tempdiff < -0.9) {
                    jd = currLineJD(offset, parts);           		            	            		
            	} else {
                    tempjdplustime = currLineJD(offset, parts)+ retime[channel];    
                    //need to add extra testing here because in rare occasion the rint and floor mess up
                    double newtempdiff = tempjdplustime - lastjdplustime;
                    if (newtempdiff == tempdiff && tempdiff < -0.9 && retime[channel] < 0.1) {
                		jd = currLineJD(offset, parts) + 1;
                    } else {                    	
                        jd = currLineJD(offset, parts);           		            	
                    }
            	} 
            } else {
                jd = currLineJD(offset, parts);           		            	
            }

            lastGPSDay = currGPSDay;
            lastEdgeTime = retime[channel];
        }
        
        double nanodiff = (fetime[channel] - retime[channel]) * 1e9 * 86400;
        String id = detector + "." + (channel + 1);
        if (nanodiff >= 0 && nanodiff < 10000 && retime[channel] > 0) {
        	lastjdplustime = jd + retime[channel];
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
        try {
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
	        	reTMC[channel] = tmc;
	            reDiff[channel] = Long.parseLong(parts[0], 16) - rePPSCount[channel];
		    }
		      
		    long parsed = Long.parseLong(parts[0], 16);
		    //diff between word 0 and 9
	        long diff = Long.parseLong(parts[0], 16) - rePPSCount[channel];
	
	        if (diff < -0xaaaaaaaal) {
	            diff += 0xffffffffl;
	            //Bug 469: if the difference is negative, the number needs to be corrected
	            //		   but it was not stored for later use, now fixed by this:
	            reDiff[channel] = diff;
	        }
	        //As per Mark Adams' feedback, we should run the following check for firmware less than 1.12
	        //and DAQ 6000 series and add a second if the diff/cpld is less than 0.07
	        double diffOverCpld = diff / cpldFrequency;
	        
	        if (firmware != 0 && firmware < 1.12 && currentDetector > 5999) {
	        	if (diffOverCpld < 0.07) {
	        		diffOverCpld = (diff / cpldFrequency) + 1.0;
	        	}
	        }

	        double edgetime = rePPSTime[channel] + diffOverCpld + tmc / (cpldFrequency * 32);
	        if (edgetime > 86400) {
	            edgetime -= 86400;
	        }
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
        return (2.0 -(Math.floor(year/100))+(Math.floor(year/400))+ day + Math.floor(365.25*(year+4716)) + Math.floor(30.6001*(month+1)) - 1524.5) + (hour + minute/60 + second/3600.0)/24;
    }
    
    //main receives a txt file created from a query to the database
    //the file should have 4 columns separated by commas
    //1-data path (eg. /disks/i2u2-dev/cosmic/data
    //2-input file name (eg. 6119.2013.0522.1)
    //3-output file name (eg. 6119.2013.0522.1.thresh)
    //4-cpld frequency for that file (eg. 25000000)
    //5-firmware (eg. 1.12)
    //to create the input file, you can run something like:
    /*
     * 		   select  '/disks/i2u2-dev/cosmic/data' as path,
						al.name, 
						al.name || '.thresh' as threshfile,
						ai.value
						'0' as firmware (then update this value with another query)
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
    	ThresholdTimesProcess ttp;
    	List inputFile = new ArrayList();
    	List outputFile = new ArrayList();
    	List detector = new ArrayList();
    	List cpldFrequency = new ArrayList();
    	List firmware = new ArrayList();
    	
    	if (args.length == 1) {
    		String iFile = args[0];
    		try {
    			BufferedReader br = new BufferedReader(new FileReader(iFile));
		        BufferedWriter bw = new BufferedWriter(new FileWriter("/disks/ThreshOutput/filesToMove"));
		            			
		        String line = br.readLine();
		        while (line != null) {
			        String[] splitLine = line.split(","); 
			        if (splitLine.length == 5) {
			        	String filename = splitLine[1];
			        	String threshfile = splitLine[2];
			        	String detectorId = filename.substring(0, filename.indexOf('.'));
			        	String path = splitLine[0] + File.separator + detectorId + File.separator;
			        	String outputpath = "/disks/ThreshOutput/";
			        	String cpldf = splitLine[3];
			        	String fware = splitLine[4];
			        	inputFile.add(path+filename);
			        	outputFile.add(outputpath+threshfile);
			        	detector.add(detectorId);
			        	cpldFrequency.add(cpldf);
			        	firmware.add(fware);
			        	//origin, destination: this will be the input to a python program that will copy those files
				        bw.write(outputpath+threshfile+" "+path+"\n");
			        }
		            line = br.readLine();
		        }
		        
		        br.close();
		        bw.close();
		        
    		} catch (Exception e) {
        		System.out.println("Could not open the file");    			
    		}

    		ttp = new ThresholdTimesProcess(inputFile, outputFile, detector, cpldFrequency, firmware);      
    		ttp.createTTFiles();
    	} else {
    		System.out.println("Usage: ThresholdTimesProcess input_file");
    	}
    }//end of main   
}
