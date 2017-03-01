package gov.fnal.elab.analysis.queue;

import java.util.*;
import gov.fnal.elab.analysis.*;

import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

public class AnalysisBlockingQueue implements Runnable {

	private static final int QUEUE_INITIAL_CAPACITY  = 1000;
	//runMode:local
	private BlockingQueue<AnalysisRun> analysisQueueLocal;
	//runMode:i2u2
	private BlockingQueue<AnalysisRun> analysisQueueNodes;
	//runMode:mixed
	private BlockingQueue<AnalysisRun> analysisQueueMixed;
	
	private AnalysisRun currentLocal, currentNodes, currentMixed;
	private boolean keepLooping = true;
	private StringBuilder sb = new StringBuilder();
	
	private volatile static AnalysisBlockingQueue instance;
	static Thread tc;
	static { 
		instance = new AnalysisBlockingQueue();
		Thread t = new Thread(instance, "Analysis Queue - Local, i2u2 and/or Mixed");
		tc = t;
		t.start();
	}
	public static AnalysisBlockingQueue getInstance() {
		return instance;
	}//end of getInstance
	
	public AnalysisBlockingQueue() {
		analysisQueueLocal = new ArrayBlockingQueue<AnalysisRun>(QUEUE_INITIAL_CAPACITY);
		analysisQueueNodes = new ArrayBlockingQueue<AnalysisRun>(QUEUE_INITIAL_CAPACITY);
		analysisQueueMixed = new ArrayBlockingQueue<AnalysisRun>(QUEUE_INITIAL_CAPACITY);
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

	public AnalysisRun getCurrent(String runMode) {
		AnalysisRun a = null;
		if (runMode.equals("local")) {
			a = currentLocal;
		}
		if (runMode.equals("i2u2")) {
			a = currentNodes;
		}
		if (runMode.equals("mixed")) {
			a = currentMixed;
		}
		return a;
	}//end of get

	public Thread getThread() {
		return tc;
	}//end of getThreadStatus
	
	public BlockingQueue<AnalysisRun> getQueueLocal() {
		return analysisQueueLocal;
	}//end of getQueueLocal
	
	public BlockingQueue<AnalysisRun> getQueueNodes() {
		return analysisQueueNodes;
	}//end of getQueueNodes
	
	public BlockingQueue<AnalysisRun> getQueueMixed() {
		return analysisQueueMixed;
	}//end of getQueueMixed
	
	public boolean getSwitch() {
		return keepLooping;
	}//end of getSwitch
	
	public String getExceptions() {
		return sb.toString();
	}//end of getExceptions
	
	public void run() {
		try {
			while(keepLooping) {
				if ((currentLocal == null || 
						currentLocal.getStatus() == AnalysisRun.STATUS_CANCELED || 
						currentLocal.getStatus() == AnalysisRun.STATUS_FAILED ||
						currentLocal.getStatus() == AnalysisRun.STATUS_COMPLETED) 
						&& !analysisQueueLocal.isEmpty()) {
					try {
						currentLocal = get("local");
						if (currentLocal != null) {
							currentLocal.start();
						}
					} catch (Exception e) {
						currentLocal = null;
						sb.append("Exception in queue-run method (local): " + e.getMessage());
					}
				}//end of test for current local
				if ((currentNodes == null || 
						currentNodes.getStatus() == AnalysisRun.STATUS_CANCELED || 
						currentNodes.getStatus() == AnalysisRun.STATUS_FAILED ||
						currentNodes.getStatus() == AnalysisRun.STATUS_COMPLETED) 
						&& !analysisQueueNodes.isEmpty()) {
					try {
						currentNodes = get("i2u2");
						if (currentNodes != null) {
							currentNodes.start();
						}
					} catch (Exception e) {
						currentNodes = null;
						sb.append("Exception in queue-run method (i2u2): " + e.getMessage());
					}
				}//end of test for current nodes
				if ((currentMixed == null || 
						currentMixed.getStatus() == AnalysisRun.STATUS_CANCELED || 
						currentMixed.getStatus() == AnalysisRun.STATUS_FAILED ||
						currentMixed.getStatus() == AnalysisRun.STATUS_COMPLETED) 
						&& !analysisQueueMixed.isEmpty()) {
					try {
						currentMixed = get("mixed");
						if (currentMixed != null) {
							currentMixed.start();
						}
					} catch (Exception e) {
						currentMixed = null;
						sb.append("Exception in queue-run method (mixed): " + e.getMessage());
					}
				}//end of test for current mixed
			}
		} catch (Exception ex) {
			sb.append("WHILE LOOP EXCEPTION: " + ex.getMessage());
		}
	}//end of run	
}
