/*
 * Created on Mar 23, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.datacatalog.StructuredResultSet.File;
import gov.fnal.elab.datacatalog.StructuredResultSet.Detector;
import gov.fnal.elab.datacatalog.StructuredResultSet.Month;
import gov.fnal.elab.datacatalog.StructuredResultSet.School;
import gov.fnal.elab.util.ElabUtil;

import java.io.IOException;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.TreeMap;

import javax.servlet.jsp.JspWriter;

public class StructuredResultSetDisplayer {
    public static final int PAGE_SIZE = 10;
    public static final int PREV_LINK = 1;
    public static final int NEXT_LINK = 2;
    public static final int DEFAULT_COLUMNS = 4;

    private StructuredResultSet results;
    private int id, start, columns = DEFAULT_COLUMNS, crtCol, crtRow;
    private String controlName;

    public StructuredResultSetDisplayer() {
        this(null);
    }

    public StructuredResultSetDisplayer(StructuredResultSet srs) {
        this.results = srs;
        this.controlName = "rawData";
    }

    public int getColumns() {
        return columns;
    }

    public void setColumns(int columns) {
        this.columns = columns;
    }

    public void setResults(StructuredResultSet results) {
        this.results = results;
    }

    public StructuredResultSet getResults() {
        return results;
    }

    public int getStart() {
        return start;
    }

    public void setStart(int start) {
        this.start = start;
    }
    
    public String getControlName() {
        return controlName;
    }

    public void setControlName(String controlName) {
        this.controlName = controlName;
    }

    public int display(JspWriter out) throws IOException {
        Iterator i = results.getSchoolsSorted().iterator();
        /*
         * This is a lousy way of implementing paging.
         */
        int links = 0;
        if (start > 0) {
            links |= PREV_LINK;
        }
        for (int j = 0; j < start && i.hasNext(); j++) {
            i.next();
        }
        for (int j = 0; j < PAGE_SIZE && i.hasNext(); j++) {
            displaySchool(out, (School) i.next());
        }
        if (i.hasNext()) {
            links |= NEXT_LINK;
        }
        return links;
    }

    public void displaySchool(JspWriter out, School school) throws IOException {
    	if (school.getDataFileCount() > 0) {
    		displaySchoolHeader(out, school);
    		displaySchoolContents(out, school);
    		displaySchoolFooter(out, school);
    	}
    }

    public static final NumberFormat EVENTS_FORMAT;
    public static final DateFormat DAY_FORMAT;

    static {
        EVENTS_FORMAT = DecimalFormat.getIntegerInstance();
        DAY_FORMAT = new SimpleDateFormat("EEE dd");
    }

    public void displaySchoolHeader(JspWriter out, School school)
            throws IOException {
        int cid = id++;
        out.write("<div class=\"school-header\">");
        ElabUtil.vsWriteVisibleStart(out, "srsdisplayer" + cid, "school-v",
                null);
        displaySchoolInfo(out, school);
        ElabUtil.vsWriteVisibleEnd(out);
        out.write("</div>");
        out.write("<div class=\"school-header\">");
        ElabUtil
                .vsWriteHiddenStart(out, "srsdisplayer" + cid, "school-h", null);
        displaySchoolInfo(out, school);
    }

    protected void displaySchoolInfo(JspWriter out, School school)
            throws IOException {
        out.write("<span class=\"school-name\">");
        out.write(school.getName());
        out.write("</span>\n<div class=\"school-info\"><p>");
        out.write(school.getCity());
        out.write(", ");
        out.write(school.getState());
        out.write("</p>\n<p>");
        out.write(String.valueOf(school.getDataFileCount()));
        out.write(" data files: ");
        out.write(String.valueOf(school.getBlessedCount()));
        out.write(" blessed, ");
        out.write(String.valueOf(school.getStackedCount()));
        out.write(" stacked, ");
        out.write(EVENTS_FORMAT.format(school.getEventCount()));
        out.write(" total events.</p>");
        out.write("</div>");
    }

    public void displaySchoolContents(JspWriter out, School school)
            throws IOException {
        Iterator i = school.getMonthsSorted().iterator();
        while (i.hasNext()) {
            displayMonth(out, (Month) i.next());
        }
    }

    public void displaySchoolFooter(JspWriter out, School school)
            throws IOException {
        ElabUtil.vsWriteHiddenEnd(out);
        out.write("</div>");
    }

    public void displayMonth(JspWriter out, Month month) throws IOException {
    	if (month.getFileCount() > 0) {
	        displayMonthHeader(out, month);
	        displayMonthContents(out, month);
	        displayMonthFooter(out, month);
    	}
    }

    public void displayMonthHeader(JspWriter out, Month month)
            throws IOException {
        int cid = id++;
        out.write("<div class=\"date-header\">");
        ElabUtil.vsWriteVisibleStart(out, "srsdisplayer" + cid, null, null);
        displayMonthInfo(out, month);
        ElabUtil.vsWriteVisibleEnd(out);
        out.write("</div>");
        out.write("<div class=\"date-header\">");
        ElabUtil.vsWriteHiddenStart(out, "srsdisplayer" + cid, null, null);
        displayMonthInfo(out, month);
    }

    public void displayMonthInfo(JspWriter out, Month month) throws IOException {
        out.write("<span class=\"date-info\">");
        out.write(month.getMonth());
        out.write(", ");
        out.write(String.valueOf(month.getFileCount()));
        if (month.getFileCount() == 1) {
            out.write(" file");
        }
        else {
            out.write(" files");
        }
        out.write("</span>\n");
    }

    public void displayMonthContents(JspWriter out, Month month)
            throws IOException {
    	for (Iterator i = month.getDetectors().keySet().iterator(); i.hasNext(); ) {
    		Detector d = (Detector) month.getDetectors().get((Integer) i.next());
    		displayDetector(out, d);
    	}
    }

    public void displayMonthFooter(JspWriter out, Month month)
            throws IOException {
        ElabUtil.vsWriteHiddenEnd(out);
        out.write("</div>");
    }
    
    public void displayDetector(JspWriter out, Detector detector) throws IOException {
    	if (detector.getFileCount() > 0) {
	    	displayDetectorHeader(out, detector);
			displayDetectorContents(out, detector);
			displayDetectorFooter(out);
    	}
    }
    
    public void displayDetectorHeader(JspWriter out, Detector detector) throws IOException {
    	crtCol = 0;
    	crtRow = 0; 
    	out.write("<div class=\"data-files\">");
    	displayDetectorInfo(out, detector); 
    	out.write("<table>");
    	out.write("<tr>");
    }
    
    public void displayDetectorInfo(JspWriter out, Detector detector) throws IOException {
    	out.write("<span class=\"date-info\">");
    	out.write("Detector " + detector.getDetectorID().toString());
    	out.write(", ");
    	out.write(Integer.toString(detector.getFileCount()));
    	out.write(" file");
    	out.write(detector.getFileCount() > 1? "s" : "");
    	out.write("</span>\n");
    }
    
    public void displayDetectorContents(JspWriter out, Detector detector) throws IOException {
    	for (Iterator i = detector.getFiles().iterator(); i.hasNext(); ) {
    		File f = (File) i.next();
    		displayFile(out, f);
    	}
    }
    
    public void displayDetectorFooter(JspWriter out) throws IOException {
    	out.write("</tr>");
        out.write("</table>");
        out.write("</div>");
    }

    public void displayFile(JspWriter out, File file) throws IOException {
        displayFileHeader(out, file);
        displayFileContents(out, file);
        displayFileFooter(out, file);
    }

    public void displayFileHeader(JspWriter out, File file) throws IOException {
        if (crtCol == columns) {
            out.write("</tr>");
            if (crtRow % 2 == 1) {
                out.write("<tr class=\"odd\">");
            }
            else {
                out.write("<tr class=\"even\">");
            }
            crtCol = 0;
            crtRow++;
        }
        crtCol++;
        out.write("<td class=\"data-file\">");
    }

    public void displayFileContents(JspWriter out, File file)
            throws IOException {
        out.write("<a class=\"file-link\" href=\"../data/view.jsp?filename=");
        out.write(file.getLFN());
        out.write("\">");
        out.write(DAY_FORMAT.format(file.getDate()));
        out.write("</a>");
        out.write("<a href=\"../jsp/add-comments.jsp?fileName=");
        out.write(file.getLFN());
        out.write("\"><img src=\"../graphics/balloon_talk_gray.gif\"/></a>");
        if (file.getStacked() != null) {
            out.write("<a href=\"javascript:glossary('geometry', 200)\">");
            if (file.getStacked().booleanValue()) {
                out.write("<img alt=\"Stacked data\" "
                        + "src=\"../graphics/stacked.gif\"/>");
            }
            else {
                out.write("<img alt=\"Unstacked data\" "
                        + "src=\"../graphics/unstacked.gif\"/>");
            }
            out.write("</a>");
        }
        if (file.isBlessed()) {
            out.write("<img alt=\"Blessed data\" "
                    + "src=\"../graphics/star.gif\"/>");
        }
    }

    public void displayFileFooter(JspWriter out, File file) throws IOException {
        out.write("</td>\n");
    }
    
    public TreeMap collateFilesByDetector(Collection files) {
    	Iterator i = files.iterator();
    	TreeMap h = new TreeMap();
    	
    	while (i.hasNext()) {
    		File f = (File) i.next();
    		Integer currentID = new Integer(f.getDetector());
    		if (h.containsKey(currentID)) {
    			((Collection) h.get(currentID)).add(f);
    		}
    		else {
    			Collection c = new ArrayList();
    			c.add(f);
    			h.put(currentID, c);
    		}
    	}
    	
    	return h;
    }
    
}
