package gov.fnal.elab.analysis.queue;

import java.util.*;
import gov.fnal.elab.analysis.*;

import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

public class AnalysisPriorityBlockingQueue implements Runnable{
	private volatile static AnalysisPriorityBlockingQueue instance = null;
	public static PriorityBlockingQueue<QueueItem> analysisQueue;
	private final AtomicLong counter;
	private static AnalysisRun current = null;
	private static final int initialCapacity  = 10000;

	public static AnalysisPriorityBlockingQueue getInstance() {
		return getInstanceHelper();
	}//end of getInstance

	public static AnalysisPriorityBlockingQueue getInstanceHelper() {
		AnalysisPriorityBlockingQueue result = instance;
		if (result == null) {
			synchronized (AnalysisPriorityBlockingQueue.class) {
				result = instance;
				if (result == null) {
					instance = result = new AnalysisPriorityBlockingQueue();
					System.out.println("Analysis Priority Queue Instantiated");
				}
			}
		}
		return result;
	}//end of getIntstanceHelper
	
	public AnalysisPriorityBlockingQueue() {
		counter = new AtomicLong(0);
		Comparator<QueueItem> comp = new Comparator<QueueItem>() {
			public int compare(QueueItem qi1, QueueItem qi2) {
				return qi1.priority > qi2.priority ? 1 : ( qi1.priority < qi2.priority ? -1 : 0);
			}
		};
		analysisQueue = new PriorityBlockingQueue<QueueItem>(initialCapacity, comp);
	}//end of constructor
	
	public void put(AnalysisRun ar) throws InterruptedException {
		if (ar != null) {
			ar.setInitialStatus(AnalysisRun.STATUS_QUEUED);
			if (ar.getAttribute("type").equals("PerformanceStudy")) {
				//this can be improved, I just have to think about how to set the priorities
				analysisQueue.put(new QueueItem(ar, (int) counter.incrementAndGet()));
			} else {
				analysisQueue.put(new QueueItem(ar, (int) counter.get()+1000));
			}
		}
	}//end of put
	
	public AnalysisRun get() throws InterruptedException {
		return analysisQueue.take().analysisRun;
	}//end of get
	
	public boolean isEmpty() {
		return (analysisQueue.size() == 0);
	}//end of isEmpty
	
	public void run() {
		while(!isEmpty()) {
			boolean launchNew = true;
			if (current != null) {
				launchNew = current.isFinished();
			}
			if (launchNew) {
				try {
					current = get();
					current.start();
					System.out.println("Analysis: "+String.valueOf(current.getId()) + " running.");
				} catch (Exception e) {
					System.out.println("Exception: " + e.getMessage());
				}
			}
		}
	}//end of run	
	
	public class QueueItem {
		private int priority;
		private AnalysisRun analysisRun;
		
		public QueueItem(AnalysisRun analysisRun, int priority) {
			this.analysisRun = analysisRun;
			this.priority = priority;
		}
	}//end of class QueueItem
}
