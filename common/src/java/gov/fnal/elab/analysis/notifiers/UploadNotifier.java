/*
 * Created on Feb 27, 2010
 */
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
import java.util.Calendar;
import java.util.GregorianCalendar;
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
            ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(elab);
            Notification n = new Notification();
            n.setCreatorGroupId(run.getAnalysis().getUser().getId());
            String s = failed ? " failed" : " completed";
            String cont = (String) (failed ? run.getAttribute("onError") : run.getAttribute("continuation"));            
            String fn = String.valueOf(run.getAnalysis().getParameter("in"));
            n.setMessage("<a href=\"" + cont + "\">Upload</a> of " + new File(fn).getName() + s);
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
