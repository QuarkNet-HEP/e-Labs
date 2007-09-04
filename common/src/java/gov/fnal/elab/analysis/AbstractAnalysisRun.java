/*
 * Created on Apr 19, 2007
 */
package gov.fnal.elab.analysis;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.vds.ElabTransformation;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public abstract class AbstractAnalysisRun implements AnalysisRun {
        private ElabAnalysis analysis;
        private Elab elab;
        private ElabGroup user;
        private ElabTransformation et;
        private Throwable exception;
        private int status;
        private String id;
        private static int sid = 0;
        private Map attributes;

        public AbstractAnalysisRun(ElabAnalysis analysis, Elab elab, ElabGroup user) {
            this.analysis = analysis;
            this.elab = elab;
            this.user = user;
            this.status = STATUS_NONE;
            synchronized(AnalysisRun.class) {
                this.id = String.valueOf(sid++);
            }
        }

        public Throwable getException() {
            return exception;
        }
        
        public void setException(Throwable t) {
            this.exception = t;
        }

        public String getId() {
            return id;
        }

        public double getProgress() {
            return 0;
        }

        public String getSTDERR() {
            return "";
        }

        public int getStatus() {
            updateStatus();
            return status;
        }
        
        public void setStatus(int status) {
            this.status = status;
        }

        public boolean isFailed() {
            return status == STATUS_FAILED;
        }

        public boolean isFinished() {
            return status == STATUS_FAILED || status == STATUS_COMPLETED;
        }

        public void updateStatus() {
        }

        public synchronized Object getAttribute(String name) {
            if (attributes == null) {
                return null;
            }
            else {
                return attributes.get(name);
            }
        }

        public synchronized void setAttribute(String name, Object value) {
            if (attributes == null) {
                attributes = new HashMap();
            }
            attributes.put(name, value);
        }
        
        public Map getAttributes() {
            return Collections.unmodifiableMap(attributes);
        }

        public ElabAnalysis getAnalysis() {
            return analysis;
        }

        public Elab getElab() {
            return elab;
        }

        public ElabGroup getUser() {
            return user;
        }
}
