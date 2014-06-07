/*
 * Created on May 23, 2014
 */
package gov.fnal.elab.analysis.pqueue;

import gov.fnal.elab.analysis.AnalysisRun;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Queue;

/**
 * An analysis queue implementation supporting up to a certain number
 * of analyses running in parallel.
 * 
 * This is a thread-less implementation. A run can only be started in two cases:
 * 1. when a run is queued and fewer than the maximum number of 
 *    parallel runs are already running, in which case the run
 *    is started as soon as it is queued
 * 2. when a previously running analysis completes leaving a spot open
 *    for a new run to start; a listener is added to the run to monitor
 *    when it completes and start a new run if there is any waiting in the
 *    queue
 */
public class SimpleParallelAnalysisQueue implements AnalysisQueue {
    private final int parallelism;
    
    private Queue<AnalysisQueue.Entry> queued;
    private Map<AnalysisRun, AnalysisQueue.Entry> running;
    
    public SimpleParallelAnalysisQueue(int parallelism) {
        this.parallelism = parallelism;
        queued = new LinkedList<AnalysisQueue.Entry>();
        running = new HashMap<AnalysisRun, AnalysisQueue.Entry>();
    }
    
    @Override
    public void add(AnalysisRun run) {
    	add(run, AnalysisQueue.Priority.NORMAL);
    }
    
    @Override
    public synchronized void add(AnalysisRun run, AnalysisQueue.Priority priority) {
    	AnalysisQueue.Entry e = new AnalysisQueue.Entry(run, priority);
        if (running.size() < parallelism) {
            // few are running than allowed, so start immediately
            start(e);
        }
        else {
            queue(e);
        }
    }
    
    /**
     * Will only cancel a queued job, not a running one
     */
    @Override
	public synchronized void cancel(AnalysisRun run) {
		queued.remove(run);
	}

	protected void start(AnalysisQueue.Entry e) {
        running.put(e.getRun(), e);
        AnalysisRun run = e.getRun();
        // add a listener to be notified when the run state changes
        // and chain the previous listener so that it still receives
        // notifications
        run.setListener(new ChainingQueueListener(this, run.getListener(), run));
        run.start();
    }
    
    protected void queue(AnalysisQueue.Entry e) {
        e.getRun().setInitialStatus(AnalysisRun.STATUS_QUEUED);
        queued.add(e);
    }

    protected synchronized void runTerminated(AnalysisRun run) {
        running.remove(run);
        while (running.size() < parallelism && !isQueueEmpty()) {
            start(dequeue());
        }
    }

    protected boolean isQueueEmpty() {
		return queued.isEmpty();
	}

	protected AnalysisQueue.Entry dequeue() {
		return queued.remove();
	}

	@Override
    public synchronized Collection<AnalysisQueue.Entry> getQueued() {
    	// make a copy of the list since it might be iterated
    	// over while another thread may modify it
        return new ArrayList<AnalysisQueue.Entry>(queued);
    }

    @Override
    public synchronized Collection<AnalysisQueue.Entry> getRunning() {
        return new ArrayList<AnalysisQueue.Entry>(running.values());
    }
}
