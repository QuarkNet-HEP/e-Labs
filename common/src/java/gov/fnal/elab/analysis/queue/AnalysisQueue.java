package gov.fnal.elab.analysis.queue;

import java.util.*;
import gov.fnal.elab.analysis.*;

//to be improved...
public class AnalysisQueue implements Runnable {

	private volatile static AnalysisQueue instance = null;
	private static List<AnalysisRun> queue = null;
	private static AnalysisRun current = null;
	private boolean isAlive = false;
	
	//written as a singleton
	private AnalysisQueue() {
	}//end of constructor
	
	public static AnalysisQueue getInstance() {
		return getInstanceHelper();
	}//end of getInstance

	public static AnalysisQueue getInstanceHelper() {
		AnalysisQueue result = instance;
		if (result == null) {
			synchronized (AnalysisQueue.class) {
				result = instance;
				if (result == null) {
					instance = result = new AnalysisQueue();
					System.out.println("Analysis Queue Instantiated");
				}
			}
		}
		return result;
	}
	
	public void enqueue(AnalysisRun analysis) {
		//has not been initialized yet
		synchronized(this) {
			if (queue == null) {
				queue = new ArrayList<AnalysisRun>();
			}
			analysis.setInitialStatus(AnalysisRun.STATUS_QUEUED);
			queue.add(analysis);
			System.out.println("Analysis: "+String.valueOf(analysis.getId()) + " queued.");
		}
	}//end of enqueue
	
	protected AnalysisRun dequeue(int ndx) {
		return queue.remove(ndx);
	}//end of dequeue
	
	public boolean isEmpty() {
		return (queue.size() == 0);
	}//end of isEmpty
	
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
	}//end of run
	
	public int getNext() {
		int ndx = 0;
		for (int i = 0; i < queue.size(); i++) {
		   AnalysisRun temp = queue.get(i);
		   //if there is a performance study in the queue, pop it before any other
		   if (temp.getAttribute("type").equals("PerformanceStudy")) {
			   return i;
		   }
		}
		return ndx;
	}//end of getNext
	
	public int getSize() {
		return queue.size();
	}//end of getSize
	
	public boolean isAlive() {
		return isAlive;
	}
	
	public List<AnalysisRun> getQueue() {
		return queue;
	}//end of getQueue
}