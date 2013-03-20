/*
 * Created on Sep 1, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.datacatalog.StructuredResultSet.Detector;
import gov.fnal.elab.datacatalog.StructuredResultSet.File;
import gov.fnal.elab.datacatalog.StructuredResultSet.Month;

import java.io.IOException;

import javax.servlet.jsp.JspWriter;

public class MultiSelectStructuredResultSetDisplayer extends
        StructuredResultSetDisplayer {

    private int count = 0;

    public int display(JspWriter out) throws IOException {
        out.write("<div class=\"clearall\">");
        out.write("<a href=\"#\" onClick=\"selectAll(0, "
                + this.getResults().getDataFileCount()
                + ", false);return false;\">Clear selected data</a>");
        out.write("</div>");
        return super.display(out);
    }

    public void displayMonthContents(JspWriter out, Month month)
            throws IOException {
        if (month.getFileCount() > 1) {
            out.write("Select: ");
            out.write("<a href=\"#\" onClick=\"selectAll(" + count + ", "
                    + (count + month.getFileCount()) + ", true);return false;\">All</a>");
            out.write("&nbsp;");
            out.write("<a href=\"#\" onClick=\"selectAll(" + count + ", "
                    + (count + month.getFileCount()) + ", false);return false;\">None</a>");
        }
        super.displayMonthContents(out, month);
    }

    public void displayFileContents(JspWriter out, File file)
            throws IOException {
    	//EPeronja- 03/20/2013: Bug 537: Do not allow for selecting data if it doesn't have 
    	//						a geometry
    	//This actionName property will only be fed by the delete.jsp page because we need to be
    	//able to delete data file regardless of whether they have geometry or not.
    	//The action name property is set in StructuredResultSetDisplayer.java
    	
    	String actionName = getActionName();
    	if (actionName != null) {
    		if (actionName.equals("delete")) {
    			//show the checkboxes
    	   		out.write("<input type=\"checkbox\" name=\"" + getControlName() + "\" id=\"cb" + count
        				+ "\" value=\"" + file.getLFN() + "\"/>");
        		}
    	} else {
    		//we are working with all the other multiple selection searches
    		if (file.getStacked() != null) {
	    		out.write("<input type=\"checkbox\" name=\"" + getControlName() + "\" id=\"cb" + count
	    				+ "\" value=\"" + file.getLFN() + "\"/>");
	    	} else {
	    		//do not display a checkbox if it doesn't have a geo file (for analysis purposes 
	    		//this file is no good)
	    		out.write("");
	    	}
    	}
	    count++;
        super.displayFileContents(out, file);
    }
    
    public void displayDetectorContents(JspWriter out, Detector detector) throws IOException {
    	if (detector.getFileCount() > 1) {
    		out.write("Select: ");
            out.write("<a href=\"#\" onClick=\"selectAll(" + count + ", "
                    + (count + detector.getFileCount()) + ", true);return false;\">All</a>");
            out.write("&nbsp;");
            out.write("<a href=\"#\" onClick=\"selectAll(" + count + ", "
                    + (count + detector.getFileCount()) + ", false);return false;\">None</a>");
    	}
    
    	super.displayDetectorContents(out, detector);
    }
}
