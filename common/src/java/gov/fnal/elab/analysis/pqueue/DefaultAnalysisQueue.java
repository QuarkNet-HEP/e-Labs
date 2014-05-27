/*
 * Created on May 23, 2014
 */
package gov.fnal.elab.analysis.pqueue;

import gov.fnal.elab.analysis.AnalysisRun;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Set;

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
public class DefaultAnalysisQueue implements AnalysisQueue {
    private final int parallelism;
    
    private Queue<AnalysisRun> queued;
    private Set<AnalysisRun> running;
    
    public DefaultAnalysisQueue(int parallelism) {
        this.parallelism = parallelism;
        queued = new LinkedList<AnalysisRun>();
        running = new HashSet<AnalysisRun>();
    }
    
    @Override
    public synchronized void add(AnalysisRun run) {
        if (running.size() < parallelism) {
            // few are running than allowed, so start immediately
            start(run);
        }
        else {
            queue(run);
        }
    }
    
    private void start(AnalysisRun run) {
        running.add(run);
        // add a listener to be notified when the run state changes
        // and chain the previous listener so that it still receives
        // notifications
        run.setListener(new ChainingQueueListener(this, run.getListener(), run));
        run.start();
    }
    
    private void queue(AnalysisRun run) {
        run.setInitialStatus(AnalysisRun.STATUS_QUEUED);
        queued.add(run);
    }

    protected synchronized void runTerminated(AnalysisRun run) {
        running.remove(run);
        while (running.size() < parallelism && !queued.isEmpty()) {
            start(queued.remove());
        }
    }

    @Override
    public synchronized Collection<AnalysisRun> getQueued() {
    	// make a copy of the list since it might be iterated
    	// over while another thread may modify it
        return new ArrayList<AnalysisRun>(queued);
    }

    @Override
    public synchronized Collection<AnalysisRun> getRunning() {
        return new ArrayList<AnalysisRun>(running);
    }
}
