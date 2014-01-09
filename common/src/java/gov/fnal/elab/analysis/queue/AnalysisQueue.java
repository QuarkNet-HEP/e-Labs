package gov.fnal.elab.analysis.queue;

import java.util.*;
import gov.fnal.elab.analysis.*;

public class AnalysisQueue implements Runnable {

	private volatile static AnalysisQueue instance = null;
	private static List<AnalysisRun> queue = null;
	private static AnalysisRun current = null;
	private boolean isAlive = false;
	
	//written as a singleton
	private AnalysisQueue() {
	}
	
	public static AnalysisQueue getInstance() {
		if (instance == null) {
			synchronized (AnalysisQueue.class) {
				if (instance == null) {
					instance = new AnalysisQueue();
					System.out.println("Analysis Queue Instantiated");
				}
			}
		}
		return instance;
	}
	
	public static void enqueue(AnalysisRun analysis) {
		//has not been initialized yet
		if (queue == null) {
			queue = new ArrayList<AnalysisRun>();
		}
		analysis.setInitialStatus(AnalysisRun.STATUS_QUEUED);
		queue.add(analysis);
		System.out.println("Analysis: "+String.valueOf(analysis.getId()) + " queued.");
	}
	
	protected AnalysisRun dequeue(int ndx) {
		return queue.remove(ndx);
	}
	
	public boolean isEmpty() {
		return (queue.size() == 0);
	}
	
	public void run() {
		while(!isEmpty()) {
			//first check if there is anything running
			boolean launchNew = true;
			if (current != null) {
				launchNew = current.isFinished();
			}
			if (launchNew) {
				current = dequeue(getNext());
				current.start();
				System.out.println("Analysis: "+String.valueOf(current.getId()) + " running.");
			}
			isAlive = true;
		}
		isAlive = false;
	}
	
	public int getNext() {
		int ndx = 0;
		for (int i = 0; i < queue.size(); i++) {
		   AnalysisRun temp = queue.get(i);
		   if (temp.getAttribute("type").equals("PerformanceStudy")) {
			   return i;
		   }
		}
		return ndx;
	}
	
	public int getSize() {
		return queue.size();
	}
	
	public boolean isAlive() {
		return isAlive;
	}
	
	public List<AnalysisRun> getQueue() {
		return queue;
	}
}