/*
 * Created on May 23, 2014
 */
package gov.fnal.elab.analysis.pqueue;

import gov.fnal.elab.analysis.AnalysisRun;

import java.util.Collection;

public interface AnalysisQueue {
	public enum Priority {
		// lower is better
		HIGH, NORMAL, LOW;
	}
	
	public class Entry {
		private final AnalysisRun run;
		private final Priority priority;
		
		public Entry(AnalysisRun run, Priority priority) {
			this.run = run;
			this.priority = priority;
		}

		public AnalysisRun getRun() {
			return run;
		}

		public Priority getPriority() {
			return priority;
		}
	}
	
    void add(AnalysisRun run);
    void add(AnalysisRun run, Priority priority);
    void cancel(AnalysisRun run);
    
    Collection<AnalysisQueue.Entry> getQueued();
    Collection<AnalysisQueue.Entry> getRunning();
}
