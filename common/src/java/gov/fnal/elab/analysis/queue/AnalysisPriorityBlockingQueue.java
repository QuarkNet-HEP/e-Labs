package gov.fnal.elab.analysis.queue;

import java.util.*;
import gov.fnal.elab.analysis.*;

import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

public class AnalysisPriorityBlockingQueue implements Runnable{

	private static final int QUEUE_INITIAL_CAPACITY  = 1000;
	//runMode:local
	private PriorityBlockingQueue<AnalysisRun> analysisQueueLocal;
	//runMode:i2u2
	private PriorityBlockingQueue<AnalysisRun> analysisQueueNodes;
	//runMode:mixed
	private PriorityBlockingQueue<AnalysisRun> analysisQueueMixed;
	private AnalysisRun currentLocal, currentNodes, currentMixed;
	
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
		analysisQueueLocal = new PriorityBlockingQueue<AnalysisRun>(QUEUE_INITIAL_CAPACITY, comp);
		analysisQueueNodes = new PriorityBlockingQueue<AnalysisRun>(QUEUE_INITIAL_CAPACITY, comp);
		analysisQueueMixed = new PriorityBlockingQueue<AnalysisRun>(QUEUE_INITIAL_CAPACITY, comp);
	}//end of constructor
	
	public void put(AnalysisRun ar) throws InterruptedException {
		if (ar != null) {
			ar.setInitialStatus(AnalysisRun.STATUS_QUEUED);
			String runMode = (String) ar.getAttribute("runMode");
			if (runMode.equals("local")) {
				analysisQueueLocal.put(ar);
			} else {
				if (runMode.equals("i2u2")) {
					analysisQueueNodes.put(ar);
				} else {
					if (runMode.equals("mixed")) {
						analysisQueueMixed.put(ar);
					}
				}
			}
		}
	}//end of put
	
	public AnalysisRun get(String runMode) throws InterruptedException {
		AnalysisRun a = null;
		if (runMode.equals("local")) {
			a = analysisQueueLocal.take();
		}
		if (runMode.equals("i2u2")) {
			a = analysisQueueNodes.take();
		}
		if (runMode.equals("mixed")) {
			a = analysisQueueMixed.take();
		}
		return a;
	}//end of get
	
	public void start() {
		if (t == null) {
			t = new Thread(instance, "Analysis Queue - Local, i2u2 and/or Mixed");
			t.start();
		}
	}//end of start
	
	public PriorityBlockingQueue<AnalysisRun> getQueueLocal() {
		return analysisQueueLocal;
	}//end of getQueueLocal
	
	public PriorityBlockingQueue<AnalysisRun> getQueueNodes() {
		return analysisQueueNodes;
	}//end of getQueue
	
	public PriorityBlockingQueue<AnalysisRun> getQueueMixed() {
		return analysisQueueMixed;
	}//end of getQueue
	
	public void run() {
		while(true) {
			if (currentLocal == null || currentLocal.getStatus() == AnalysisRun.STATUS_CANCELED || currentLocal.isFinished() ) {
				try {
					currentLocal = get("local");
					currentLocal.start();
				} catch (Exception e) {
					System.out.println("Exception in queue-run method (local): " + e.getMessage());
				}
			}//end of test for current local
			if (currentNodes == null || currentNodes.getStatus() == AnalysisRun.STATUS_CANCELED || currentNodes.isFinished() ) {
				try {
					currentNodes = get("i2u2");
					currentNodes.start();
				} catch (Exception e) {
					System.out.println("Exception in queue-run method (i2u2): " + e.getMessage());
				}
			}//end of test for current nodes
			if (currentMixed == null || currentMixed.getStatus() == AnalysisRun.STATUS_CANCELED || currentMixed.isFinished() ) {
				try {
					currentMixed = get("mixed");
					currentMixed.start();
				} catch (Exception e) {
					System.out.println("Exception in queue-run method (mixed): " + e.getMessage());
				}
			}//end of test for current mixed
		}
	}//end of run	
}
