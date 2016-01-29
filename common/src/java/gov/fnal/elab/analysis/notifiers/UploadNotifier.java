/*
 * Created on Feb 27, 2010
 */
/// replaced references to help@i2u2.org -> e-labs@fnal.gov 29Jan2016 JG
package gov.fnal.elab.analysis.notifiers;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabFactory;
import gov.fnal.elab.analysis.AnalysisNotifier;
import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.analysis.AnalysisRunListener;
import gov.fnal.elab.notifications.ElabNotificationsProvider;
import gov.fnal.elab.notifications.Notification;
import gov.fnal.elab.util.ElabException;

import java.io.File;
import java.util.*;

public class UploadNotifier implements AnalysisRunListener, AnalysisNotifier {
    private AnalysisRun run;

    public void setRun(AnalysisRun run) {
        this.run = run;
    }

    public void runStatusChanged(int status) {
        if (status == AnalysisRun.STATUS_FAILED || status == AnalysisRun.STATUS_COMPLETED) {
            boolean failed = AnalysisRun.STATUS_FAILED == status;
            Elab elab = run.getAnalysis().getElab();
		    //EP-send an email when an analysis fails
            if (AnalysisRun.STATUS_FAILED == status) {
            	Throwable e = run.getException();
            	String to = elab.getProperty(elab.getName() + ".notifyAnalysisFailureTO");
            	if (to == null) {
            		to="e-labs@fnal.gov";
            	}
            	String cc = elab.getProperty(elab.getName() + ".notifyAnalysisFailureCC");

			    String emailmessage = "", subject = "Job Id: " + run.getId()+" - Cosmic Analysis failed to complete properly";
			    String emailBody =  "MESSAGE: "+e.getMessage()+"\n" +
	    				   			"ERROR: "+run.getSTDERR() +"\n" +
	    				   			"STACK TRACE: "+e.getStackTrace().toString() + "\n" +
	    				   			"DEBUGGING INFO: "+run.getDebuggingInfo() + "\n";
			    try {
			    	String result = elab.getUserManagementProvider().sendEmail(to, subject, emailBody);
	            	if (cc != null) {
	            		result = elab.getUserManagementProvider().sendEmail(cc, subject, emailBody);
	            	}
			    } catch (Exception ex) {
	                System.err.println("Failed to send email");
	                ex.printStackTrace();
			    }
            }
            ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(elab);
            Notification n = new Notification();
            n.setCreatorGroupId(run.getAnalysis().getUser().getId());
            String s = failed ? " failed" : " completed";
            String cont = (String) (failed ? run.getAttribute("onError") : run.getAttribute("continuation"));            
            String fn = String.valueOf(run.getAnalysis().getParameter("in"));
            n.setMessage("Upload of " + new File(fn).getName() + s);
        	GregorianCalendar gc = new GregorianCalendar();
        	//EPeronja-have to check how long we want this to stay until it expires
        	gc.add(Calendar.DAY_OF_MONTH, 2);
        	n.setExpirationDate(gc.getTimeInMillis());
            try {
                np.addNotification(run.getAnalysis().getUser(), n);
                run.setAttribute("notification-id", n.getId());
            }
            catch (ElabException e) {
                System.err.println("Failed to send notification");
                e.printStackTrace();
            }
        }
    }
}
