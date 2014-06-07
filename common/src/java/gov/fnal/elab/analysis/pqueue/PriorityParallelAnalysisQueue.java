package gov.fnal.elab.analysis.pqueue;

import gov.fnal.elab.analysis.AnalysisRun;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

public class PriorityParallelAnalysisQueue extends SimpleParallelAnalysisQueue {
	
	private List<Queue<AnalysisQueue.Entry>> queues;
	private int queuedCount;
	
	public PriorityParallelAnalysisQueue(int parallelism) {
		super(parallelism);
		queues = new ArrayList<Queue<AnalysisQueue.Entry>>();
		/*
		 * Queues are created in the order of priorities. The first
		 * item in the list of queues will be the queue for the 
		 * highest priority
		 */
		for (@SuppressWarnings("unused") AnalysisQueue.Priority p : AnalysisQueue.Priority.values()) {
			queues.add(new LinkedList<AnalysisQueue.Entry>());
		}
	}

	@Override
	protected void queue(Entry e) {
		assert(Thread.holdsLock(this));
		e.getRun().setInitialStatus(AnalysisRun.STATUS_QUEUED);
        queues.get(e.getPriority().ordinal()).add(e);
        queuedCount++;
	}

	@Override
	public synchronized void cancel(AnalysisRun run) {
		for (Queue<AnalysisQueue.Entry> q : queues) {
			
			Iterator<AnalysisQueue.Entry> i = q.iterator();
			while (i.hasNext()) {
				AnalysisQueue.Entry e = i.next();
				if (e.getRun() == run) {
					i.remove();
					queuedCount--;
					return;
				}
			}
		}
	}

	@Override
	protected boolean isQueueEmpty() {
		return queuedCount == 0;
	}

	@Override
	protected Entry dequeue() {
		assert(Thread.holdsLock(this));
		for (Queue<AnalysisQueue.Entry> q : queues) {
			if (!q.isEmpty()) {
				return q.remove();
			}
		}
		throw new IllegalStateException("dequeue() called on an empty queue");
	}
	
	
}
