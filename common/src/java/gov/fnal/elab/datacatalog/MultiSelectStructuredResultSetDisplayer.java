/*
 * Created on Sep 1, 2007
 */
package gov.fnal.elab.datacatalog;

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
        out.write("<input type=\"checkbox\" name=\"rawData\" id=\"cb" + count
                + "\" value=\"" + file.getLFN() + "\"/>");
        count++;
        super.displayFileContents(out, file);
    }
}
