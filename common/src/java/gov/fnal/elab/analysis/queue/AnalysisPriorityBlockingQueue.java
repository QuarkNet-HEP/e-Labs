package gov.fnal.elab.analysis.queue;

import java.util.*;
import gov.fnal.elab.analysis.*;

import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

public class AnalysisPriorityBlockingQueue implements Runnable{

	private static final int QUEUE_INITIAL_CAPACITY  = 1000;
	private PriorityBlockingQueue<AnalysisRun> analysisQueue;
	private AnalysisRun current;
	
	private volatile static AnalysisPriorityBlockingQueue instance = new AnalysisPriorityBlockingQueue();
	static Thread t;
	
	public static AnalysisPriorityBlockingQueue getInstance() {
		return instance;
	}//end of getInstance
	
	public AnalysisPriorityBlockingQueue() {
		Comparator<AnalysisRun> comp = new Comparator<AnalysisRun>() {
			public int compare(AnalysisRun ar1, AnalysisRun ar2) {
				int rank = getRank(ar1) - getRank(ar2);
				return rank;
			}
			private int getRank(AnalysisRun run) {
				if ("PerformanceStudy".equals(run.getAttribute("type"))) {
					return 0;
				} else {
					return 1;
				}
			}
		};
		analysisQueue = new PriorityBlockingQueue<AnalysisRun>(QUEUE_INITIAL_CAPACITY, comp);
	}//end of constructor
	
	public void put(AnalysisRun ar) throws InterruptedException {
		if (ar != null) {
			ar.setInitialStatus(AnalysisRun.STATUS_QUEUED);
			analysisQueue.put(ar);
		}
	}//end of put
	
	public AnalysisRun get() throws InterruptedException {
		return analysisQueue.take();
	}//end of get
	
	public boolean isEmpty() {
		return (analysisQueue.size() == 0);
	}//end of isEmpty

	public boolean isAlive() {
		return t.isAlive();
	}//end of isAlive
	
	public void start() {
		if (t == null) {
			t = new Thread(instance, "Analysis Queue");
			t.start();
		}
	}//end of start
	
	public PriorityBlockingQueue getQueue() {
		return analysisQueue;
	}//end of getQueue
	
	public void run() {
		while(true) {
			if (current == null || current.getStatus() == AnalysisRun.STATUS_CANCELED || current.isFinished() ) {
				try {
					current = get();
					current.start();
				} catch (Exception e) {
					System.out.println("Exception in queue-run method: " + e.getMessage());
				}
			}
		}
	}//end of run	
}
