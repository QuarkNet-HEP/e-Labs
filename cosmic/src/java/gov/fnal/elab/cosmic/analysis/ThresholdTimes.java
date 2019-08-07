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
public class ThresholdTimes {
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
    private int currentDetector;
    Elab elabReference;
    
    public static final NumberFormat NF0F = new DecimalFormat("0");
    public static final NumberFormat NF2F = new DecimalFormat("0.00");
    public static final NumberFormat NF16F = new DecimalFormat("0.0000000000000000");
    public final int detectorSeriesChange = 6000;
    public final double upperFirstHalfDay = 0.9999999999999999;
    public final double lowerFirstHalfDay = 0.5; 
    public static boolean dayRolled = false;
    
    /**
     * Constructor arguments: Elab elab, String[] inputFiles, String detectorId
     */   
    public ThresholdTimes(Elab elab, String[] inputFiles, String detectorId) {
    	this.inputFiles = inputFiles;
    	this.outputFiles = new String[inputFiles.length];
    	this.detectorIDs = new String[inputFiles.length];
    	this.cpldFrequencies = new double[inputFiles.length];
    	this.firmwares = new double[inputFiles.length];
    	this.elabReference = elab;
    	for (int i = 0; i < inputFiles.length; i++) {
    		outputFiles[i] = inputFiles[i] + ".thresh";
    		detectorIDs[i] = detectorId;
    		try {
				VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(inputFiles[i]);
				if (entry != null) {
					Long cpldf = (Long) entry.getTupleValue("cpldfrequency");
					String firmware = (String) entry.getTupleValue("DAQFirmware");
					cpldFrequencies[i] = cpldf.doubleValue();
					firmwares[i] = Double.valueOf(firmware);
				} else {
					cpldFrequencies[i] = 0;
					firmwares[i] = 0;
				}
    		} catch (Exception e) {
    			cpldFrequencies[i] = 0;
				firmwares[i] = 0;
    		}
    	}
    }
    
    public void createThresholdFiles() {
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
		        
						String inputFile = elabReference.getProperties().getDataDir() + File.separator + detectorIDs[i] +File.separator + inputFiles[i];
						String outputFile = elabReference.getProperties().getDataDir() + File.separator + detectorIDs[i] +File.separator + outputFiles[i];
						//check if the .thresh exists, if so, do not overwrite it
						//File tf = new File(outputFile);
						//if (tf.exists()) {
						//	System.out.println("File exists: "+outputFiles[i]+" - not overwriting it");
						//	continue;
						//}
		        BufferedReader br = new BufferedReader(new FileReader(inputFile));
		        BufferedWriter bw = new BufferedWriter(new FileWriter(outputFile));
		
		        bw.write("#$md5\n");
		        bw.write("#md5_hex(0)\n");
		        bw.write("#ID.CHANNEL, Julian Day, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec), RISING EDGE(INT), FALLING EDGE(INT)\n");
		
		        cpldFrequency = cpldFrequencies[i];
		        currentDetector = Integer.parseInt(detectorIDs[i]);
		        firmware = firmwares[i];
		        if (cpldFrequency == 0) {
								if (currentDetector < detectorSeriesChange) {
		        		cpldFrequency = 41666667;
		        	} else {
		        		cpldFrequency = 25000000;
		        	}
		        }
		        //System.out.println(String.valueOf(cpldFrequency));
		        
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

			/* 'parts' is the array breakdown of the 16-word raw data line
				 'parts[1]' is RE0, which includes the trigger tag in the 8th bit */
			int type = Integer.parseInt(parts[1], 16);
			// '&' is bitwise AND: (type & 0x80) != 0 iff 'type' has a '1' in the 8th bit
			if ((type & 0x80) != 0) {
					// Zero the times if there's a trigger tag
					retime[channel] = 0;
					retimeINT[channel] = 0;
			}

			/* These are the hexadecimal-format falling and rising edge times of
				 the given channel.  Why 'dec' instead of 'hex'? */
			int decFE = Integer.parseInt(parts[indexFE], 16);
			int decRE = Integer.parseInt(parts[indexRE], 16);

			/* This block is executed if the line is non-trigger AND a valid edge
				 bit exists for the given channel */
			/* Can it happen that a line has no trigger bit, yet has a retime=0 for 
				 a channel? */
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

		/**
		 * Check a RE/FE data word for the "valid edge" bit.
		 *
		 * @param v 8-bit hexadecimal integer to check.
		 */
		private boolean isEdge(int v) {
				/* '&' is bitwise AND: (v & 0x20) != 0 iff 'v' has a '1' in the 6th bit,
					 defined to indicate a valid rising/falling edge */
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

				// The thresh file itself is written here:
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
				/* 'tmc' is the hex value of the 1st 5 bits of 'edge', representing 
					 the TMC clock reading */
				int tmc = edge & 0x1f;

				/* What sets '(lastR|r)ePPS(Time|Count)' the first time they are
					 encountered in this conditional block? */
				/* rePPSTime[] and rePPSCount[] are zeroed by clearChannelState().
					 lastRePPSTime and lastRePPSCount are zeroed by createThresholdFiles().
					 Otherwise, all four values are determined by only the following 
					 block. */
				if (rePPSTime[channel] == 0 || rePPSCount[channel] == 0) {
						/* 'lastRePPS*' do not exist outside the current block and are 
							 used to store values between executions of calctime() */
						rePPSTime[channel] = lastRePPSTime;
            rePPSCount[channel] = lastRePPSCount;

						/* parts[10] is the last GPS update in UTC time
							 parts[15] is the time delay between that and the 1PPS
							 This is String concatenation, not math! */
            String currSecString = parts[10] + parts[15];
						/// Ex: currSecString = "202133.242-0389"
						/* Most DAQs now are 6000-series.
							 To (negligibly) optimize we would invert this check */
						if (currentDetector >= detectorSeriesChange) {
								// For 6000-series DAQs we drop the time delay from currSecString
								currSecString = parts[10];
								/// Ex: currSecString = "202133.242"
						}

						/* 'lastSecString' is initialized to "" by createThresholdFiles().
							 Otherwise, its value is determined by only the following 
							 block. */
            if (!currSecString.equals(lastSecString)) {
								//for bug 459
								/* Set 'rePPSTime' to the integer number of seconds since the 
									 most recent UTC 12:00:00 associated with the matching 
									 1PPS signal: */
								if (currentDetector >= detectorSeriesChange) {
										// For 6000-series DAQs,
										rePPSTime[channel] = currentPPSSeconds(parts[10], "+0");
								} else {
										// For 5000-series and proto DAQs,
										rePPSTime[channel] = currentPPSSeconds(parts[10], parts[15]);
								}

								// parts[9] is the CPLD count of the last 1PPS as a 32-bit hex
                rePPSCount[channel] = Long.parseLong(parts[9], 16);
								/* Neither 'rePPSCount' nor 'rePPSTime' are directly related 
									 to a rising edge PMT signal.  I don't know what the 're'
									 prefix represents here. */

								lastRePPSTime = rePPSTime[channel];
                lastRePPSCount = rePPSCount[channel];

                lastSecString = currSecString;
            }

						/* 'reTMC[]' and 'reDiff[]' are used only to calculate 'offset' 
							 in printData() */
            reTMC[channel] = tmc;
						/* 'parts[0]' is the CPLD count of the trigger as a 32-bit hex.
							 'rePPSCount' is the CPLD count of the last 1PPS as a 32-bit hex.
							 'reDiff' represents the number of CPLD ticks between the 1PPS 
							 signal and the trigger. */
            reDiff[channel] = Long.parseLong(parts[0], 16) - rePPSCount[channel];
        }

				/* The block immediately above can affect 'rePPSCount'.  Under what
					 conditions does that make 'reDiff' different from 'diff'? */
        long diff = Long.parseLong(parts[0], 16) - rePPSCount[channel];

				/* 'aaaaaaaa' is 2863311530 CPLD ticks, or 
					     ~114.5s @ 40ns/25MHz      (6000 series)
							  ~63.7s @ 24ns/41.666MHz  (5000 series)
					 Why this number?
					 The condition is true if the trigger occurs more than 114.5s 
					 *before* the milestone 1PPS signal being used.  How is this even
					 possible?  How do the other 113 1PPS signals get missed? */
				/* This must have something to do with the CPLD rolling over, but 
					 I can't figure out what.  A comment or two would do wonders here. */
        if (diff < -0xaaaaaaaal) {
            diff += 0xffffffffl;
						/* 'ffffffff' is 4294967295 CPLD ticks, or
							     ~171.8s @ 40ns/25MHz      (6000 series)
									 ~103.1s @ 24ns/41.666MHz  (5000 series)
						*/
            //Bug 469: if the difference is negative, the number needs to be corrected
            //		   but it was not stored for later use, now fixed by this:
            reDiff[channel] = diff;
        }
 
        //As per Mark Adams' feedback, we should run the following check for firmware less than 1.12
        //and DAQ 6000 series and add a second if the diff/cpld is less than 0.07
        double diffOverCpld = diff / cpldFrequency;

				// Can use 'detectorSeriesChange' to avoid hard-coding 5999
        if (firmware != 0 && firmware < 1.12 && currentDetector > 5999) {
        	if (diffOverCpld < 0.07) {
        		diffOverCpld = (diff / cpldFrequency) + 1.0;
        	}
        }

        double edgetime = rePPSTime[channel] + diffOverCpld + tmc / (cpldFrequency * 32);
        if (edgetime > 86400) {
            edgetime -= 86400;
        }
                
        //return edgetime / 86400;
        return edgetime;
    }

		/**
		 * Finds the nearest whole UTC second given a GPS data time and its offset 
		 * and returns is as the integer number of seconds since the most recent 
		 * UTC 12:00:00.  This integer second is taken to be that of the 
		 * associated 1PPS signal.
		 *
		 * @param num String representing the UTC time of a GPS data signal.
		 * @param offset String representing the millisecond correction to 'num'
		 */
		private static long currentPPSSeconds(String num, String offset) {
				/* For UTC hour '20', this gives 'hour' = 8.
					 For UTC hour '08', this gives 'hour' = 20.
					 If we don't care about the date, this is shifting the timescale
					 by 12 hours; i.e. noon -> midnight.
					 If we do care about the date, this is flip-flopping AM to PM.
					 I can't imagine a reason ever to do that. */
        int hour = (Integer.parseInt(num.substring(0, 2)) + 12) % 24;
        int min = Integer.parseInt(num.substring(2, 4));
        double sec = Double.parseDouble(num.substring(4));
        int sign = 1;
        if (offset.charAt(0) == '-') {
            sign = -1;
        }

				// The UTC seconds value plus offset, rounded to the nearest integer
        long secoffset = Math.round(sec + sign * Integer.parseInt(offset.substring(1)) / 1000.0);

				/* Integer number of whole seconds that have elapsed since the
					 last UTC 12:00:00 */
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
    
}
