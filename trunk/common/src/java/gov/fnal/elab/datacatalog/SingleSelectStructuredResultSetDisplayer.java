/*
 * Created on Sep 1, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.datacatalog.StructuredResultSet.File;

import java.io.IOException;

import javax.servlet.jsp.JspWriter;

public class SingleSelectStructuredResultSetDisplayer extends
        StructuredResultSetDisplayer {

    public void displayFileContents(JspWriter out, File file)
            throws IOException {
        out.write("<input type=\"radio\" name=\"" + getControlName() + "\" value=\""
                + file.getLFN() + "\"/>");
        super.displayFileContents(out, file);
    }

}
