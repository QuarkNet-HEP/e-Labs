/*
 * Created on Feb 24, 2010
 */
package gov.fnal.elab.cosmic.analysis;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;

import java.util.Arrays;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * Sample multithreaded implementation of ThresholdTimes. Not much faster than the single-threaded version?
 **/

public class ThresholdTimesMT implements Runnable {
	protected String inputFile; 
	protected String outputFile; 
	protected String detectorId; 
	protected double cpldFrequency;
	
	protected BufferedWriter bw; 
		
	protected static final int NUM_EXECUTION_THREADS = 4;
	
	protected static final ExecutorService threadPool = Executors.newFixedThreadPool(NUM_EXECUTION_THREADS);
	
    private static final ThreadLocal<NumberFormat> NF2F = new ThreadLocal<NumberFormat>() {
    	@Override protected NumberFormat initialValue() {
    		return new DecimalFormat("0.00");
    	}
    }; 
    
    private static final ThreadLocal<NumberFormat> NF16F = new ThreadLocal<NumberFormat>() {
    	@Override protected NumberFormat initialValue() {
    		return new DecimalFormat("0.0000000000000000");
    	}
    }; 

	public ThresholdTimesMT(String inputFile, String outputFile, String detectorId, double cpldFrequency) {
		this.inputFile = inputFile;
		this.outputFile = outputFile;
		this.detectorId = detectorId; 
		this.cpldFrequency = cpldFrequency; 
	}

	public static void main(String[] args) {
		ThresholdTimesMT tt; 
        
        switch(args.length) {
    	case 3: 
    		tt = new ThresholdTimesMT(args[0], args[1], args[2], 41666667 );
    		break;
    	case 4:
    		tt = new ThresholdTimesMT(args[0], args[1], args[2], Double.parseDouble(args[3]));
    		break; 
		default: 
			System.out.println("Usage: ThresholdTimes input_file output_file serial_number [cpld_frequency]");
			return; 
    	}
        try {
            tt.run();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

	@Override
	public void run() {
		try {
			run2();
		}
		catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		catch (ExecutionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
	}
	
	private void run2() throws IOException, InterruptedException, ExecutionException {
		BufferedReader br = new BufferedReader(new FileReader(inputFile));
        bw = new BufferedWriter(new FileWriter(outputFile));
        
        bw.write("#$md5\n");
        bw.write("#md5_hex(0)\n");
        bw.write("#ID.CHANNEL, Julian Day, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec)\n");
        
        // queues to feed 
        BlockingQueue<DataLine<String[]>> ch1dataQueue = new LinkedBlockingQueue<DataLine<String[]>>(); 
        BlockingQueue<DataLine<String[]>> ch2dataQueue = new LinkedBlockingQueue<DataLine<String[]>>(); 
        BlockingQueue<DataLine<String[]>> ch3dataQueue = new LinkedBlockingQueue<DataLine<String[]>>(); 
        BlockingQueue<DataLine<String[]>> ch4dataQueue = new LinkedBlockingQueue<DataLine<String[]>>(); 
        
        // time over threshold thread setup 
        Runnable ch1tot = new TimeOverThreshold(0, ch1dataQueue); 
        Runnable ch2tot = new TimeOverThreshold(1, ch2dataQueue);
        Runnable ch3tot = new TimeOverThreshold(2, ch3dataQueue);
        Runnable ch4tot = new TimeOverThreshold(3, ch4dataQueue);
        
        // run the processing threads 
        threadPool.execute(ch1tot); 
        threadPool.execute(ch2tot); 
        threadPool.execute(ch3tot); 
        threadPool.execute(ch4tot);
        
        // run the writer thread
        // Future<Boolean> writerDone = threadPool.submit(writerThread);
        
        String[] parts; 
        String line = br.readLine();
        
        // read in data and sent to the four queues that feed the four threads 
        while (line != null) {
        	parts = line.split("\\s"); // line validated in split.pl
        	ch1dataQueue.put(new DataLine<String[]>(parts));
        	ch2dataQueue.put(new DataLine<String[]>(parts));
        	ch3dataQueue.put(new DataLine<String[]>(parts));
        	ch4dataQueue.put(new DataLine<String[]>(parts));
        	line = br.readLine();
        }
        br.close();
        
        // Add poison pills to terminate execution
        ch1dataQueue.put(new DataLine<String[]>(true));
    	ch2dataQueue.put(new DataLine<String[]>(true));
    	ch3dataQueue.put(new DataLine<String[]>(true));
    	ch4dataQueue.put(new DataLine<String[]>(true));
    	    	
    	// writerDone.get(); 
    	
    	threadPool.shutdown(); 
       
        return;
	}
	
	private class DataLine<T> {
		private T data; 
		private boolean poisonPill;
		
		public DataLine(T data) {
			this.data = data; 
			this.poisonPill = false; 
		}
		
		public DataLine(boolean pill) {
			this.data = null;
			this.poisonPill = true; 
		}
		
		public boolean isPoison() {
			return poisonPill; 
		}
		
		public T getData() {
			return data; 
		}
	}
	
	
	private class TimeOverThreshold implements Runnable {
		protected double retime = 0, fetime = 0;
	    protected long rePPSTime = 0, rePPSCount = 0, reDiff = 0;
	    protected int reTMC = 0;
	    protected long lastRePPSTime = 0, lastRePPSCount = 0;
	    protected int lastGPSDay = 0, jd = 0;
	    protected String lastSecString = "";
	    protected double lastEdgeTime = 0;
	    
	    protected int channel; 
	    
	    protected String[] parts; 
	    
	    private BlockingQueue<DataLine<String[]>> dataQueue; 
	    
	    public TimeOverThreshold(int channel, BlockingQueue<DataLine<String[]>> dataQueue) {
	    	this.channel = channel; 
	    	this.dataQueue = dataQueue; 
	    }
	    
	    private void clearChannelState() {
	        retime = 0;
	        fetime = 0;
	        rePPSTime = 0;
	        rePPSCount = 0;
	        reDiff = 0;
	        reTMC = 0;
	    }
	    
	    private boolean isEdge(int v) {
	        return ((v & 0x20) != 0);
	    }
	    
	    private double calctime(int channel, int edge, String[] parts) {
	        int tmc = edge & 0x1f;

	        if (rePPSTime == 0 || rePPSCount == 0) {
	            rePPSTime = lastRePPSTime;
	            rePPSCount = lastRePPSCount;

	            String currSecString = parts[10] + parts[15];
	            if (!currSecString.equals(lastSecString)) {
	                rePPSTime = currentPPSSeconds(parts[10], parts[15]);
	                rePPSCount = Long.parseLong(parts[9], 16);
	                lastRePPSTime = rePPSTime;
	                lastRePPSCount = rePPSCount;

	                lastSecString = currSecString;
	            }

	            reTMC = tmc;
	            reDiff = Long.parseLong(parts[0], 16) - rePPSCount;
	        }

	        long diff = Long.parseLong(parts[0], 16) - rePPSCount;

	        if (diff < -0xaaaaaaaal) {
	            diff += 0xffffffffl;
	        }

	        double edgetime = rePPSTime + diff / cpldFrequency + tmc / (cpldFrequency * 32);
	        if (edgetime > 86400) {
	            edgetime -= 86400;
	        }
	                
	        return edgetime / 86400;
	    }
	    
	    private long currentPPSSeconds(String num, String offset) {
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

	    private int currLineJD(double offset, String[] parts) {
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
	    
	    private double gregorianToJulian(int year, int month, int day, int hour, int minute, int second) {
	        if (month < 3) {
	            month = month + 12;
	            year = year - 1;
	        }
	        
	        return (2.0 -(Math.floor(year/100))+(Math.floor(year/400))+ day + Math.floor(365.25*(year+4716)) + Math.floor(30.6001*(month+1)) - 1524.5) + (hour + minute/60.0 + second/3600.0)/24;
	    }
	    
	    private String printData(int channel, String[] parts, String detector)  {
	    	StringBuffer sb = new StringBuffer();
	    	
	        boolean computeJD = true;

	        int currGPSDay = Integer.parseInt(parts[11]);
	        double currEdgeTime = 0;

	        if (currGPSDay != lastGPSDay) {
	            currEdgeTime = retime;
	            if ((currEdgeTime >= lastEdgeTime && lastEdgeTime != 0) || currEdgeTime < 0) {
	                computeJD = false;
	            }
	        }

	        if (computeJD) {
	            int sign = parts[15].charAt(0) == '-' ? -1 : 1;
	            int msecOffset = sign * Integer.parseInt(parts[15].substring(1));
	            double offset = reDiff / cpldFrequency + reTMC / (cpldFrequency * 32) + msecOffset / 1000.0;
	            jd = currLineJD(offset, parts);
	            lastGPSDay = currGPSDay;
	            lastEdgeTime = retime;
	        }

	        double nanodiff = (fetime - retime) * 1e9 * 86400;
	        String id = detector + "." + (channel + 1);

	        if (nanodiff >= 0 && nanodiff < 10000) {
	            sb.append(id);
	            sb.append('\t');
	            sb.append(String.valueOf(jd));
	            sb.append('\t');
	            sb.append(NF16F.get().format(retime));
	            sb.append('\t');
	            sb.append(NF16F.get().format(fetime));
	            sb.append('\t');
	            sb.append(NF2F.get().format(nanodiff));
	            sb.append('\n');
	        }
	        
	        return sb.toString(); 
	    }
	    
	    private String calculateEdgeTime() {
	    	String retval = null;
	    	int indexRE = channel * 2 + 1;
	        int indexFE = indexRE + 1;
	        
	        int decFE = Integer.parseInt(parts[indexFE], 16);
	        int decRE = Integer.parseInt(parts[indexRE], 16);

	        int type = Integer.parseInt(parts[1], 16);
	        if ((type & 0x80) != 0) {
	            retime = 0;
	        }
			
	        if (retime != 0 && isEdge(decFE)) {
	            fetime = calctime(channel, decFE, parts);
	            if (fetime != 0) {
	                retval = printData(channel, parts, detectorId);
	                clearChannelState();
	            }

	            if (isEdge(decRE)) {
	                retime = calctime(channel, decRE, parts);
	            }
	        }
	        else if (isEdge(decRE)) {
	            retime = calctime(channel, decRE, parts);
	            if (retime != 0 && isEdge(decFE)) {
	                fetime = calctime(channel, decFE, parts);
	            }
	            if (retime != 0 && fetime != 0) {
	                retval = printData(channel, parts, detectorId);
	                clearChannelState();
	            }
	        }
			return retval;
	    }
	    
	    private synchronized void write(String s) throws IOException {
	    	bw.write(s);
	    }
	    
		@Override
		public void run() {
			try {
				String pd = ""; 
				DataLine<String[]> de = dataQueue.take();
				while (!de.isPoison()) {
					parts = de.getData();
					if (parts != null) {
						pd = calculateEdgeTime();
						if (pd != null) { 
							write(pd);
						}
					}
					de = dataQueue.take();
				}
			}
			catch (InterruptedException ie) {
				// do nothing right now - probably should halt all threads
			}
			catch (IOException iow) {
				// do nothing right now - probably should halt all threads
			}
			
			return;
		}
	}
}
