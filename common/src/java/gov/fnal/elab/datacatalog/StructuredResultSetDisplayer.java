/*
 * Created on Mar 23, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.datacatalog.StructuredResultSet.File;
import gov.fnal.elab.datacatalog.StructuredResultSet.Detector;
import gov.fnal.elab.datacatalog.StructuredResultSet.Month;
import gov.fnal.elab.datacatalog.StructuredResultSet.School;
import gov.fnal.elab.util.ElabUtil;

import org.apache.commons.lang.time.DateFormatUtils;
import gov.fnal.elab.util.URLEncoder;

import java.io.IOException;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.Locale;
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
    private String actionName;

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

    public String getActionName() {
    	return actionName;
    }
    public void setActionName(String actionName) {
    	this.actionName = actionName;
    }
    
    public int display(JspWriter out) throws IOException {
        Iterator<School> i = results.getSchoolsSorted().iterator();
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
            displaySchool(out, i.next());
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
    public static final String DAY_FORMAT = "EEE dd";

    static {
        EVENTS_FORMAT = DecimalFormat.getIntegerInstance();
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
        for (Month m : school.getMonthsSorted()) {
        	displayMonth(out, m);
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
    	for (int i : month.getDetectors().keySet()) {
    		displayDetector(out, month.getDetectors().get(i));
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
    	for (File f : detector.getFiles()) {
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
    
    //EPeronja-06/25/2013: 289- Lost functionality on data search
    //		  -07/22/2013: 556- Cosmic data search: requests from fellows 07/10/2013 (added duration)
    public String buildMetadata(File file){
        String DATEFORMAT = "MMM dd yyyy";
        SimpleDateFormat dateFormat = new SimpleDateFormat(DATEFORMAT);
        StringBuilder sb = new StringBuilder();
        sb.append("Group: " + file.getGroup() +"\n");
        sb.append("StartTime: " + dateFormat.format(file.getStartDate())+"\n");
        sb.append("UploadDate: " + dateFormat.format(file.getCreationDate())+"\n");
        if (file.getFileDuration() > 0L) {
        	sb.append("Duration: " + file.getFileDurationComponents()[0] + ":" + file.getFileDurationComponents()[1] + ":" + file.getFileDurationComponents()[2] + "\n");
        } 
        sb.append("Channel1: " + file.getChannel1()+" events\n");
        sb.append("Channel2: " + file.getChannel2()+" events\n");
        sb.append("Channel3: " + file.getChannel3()+" events\n");
        sb.append("Channel4: " + file.getChannel4()+" events");
    	return sb.toString();
    }
    
    public void displayFileContents(JspWriter out, File file)
            throws IOException {
        out.write("<a class=\"file-link\" href=\"../data/view.jsp?filename=");
        out.write(file.getLFN());
        out.write("\"");
        out.write(" title=\""+ buildMetadata(file));
        out.write("\">");
        out.write(DateFormatUtils.format(file.getDate(), DAY_FORMAT));
        out.write("</a>");
        //EPeronja-07/22/2013: 556- Cosmic data search: requests from fellows 07/10/2013 (changed icons for comments)
        out.write("<a href=\"../jsp/comments-add.jsp?fileName=");
        out.write(file.getLFN());
        if (file.getComments() != null && !file.getComments().equals("")) {
        	out.write("\"><img src=\"../graphics/balloon_talk_blue.gif\"/></a>");
        } else {
        	out.write("\"><img src=\"../graphics/balloon_talk_empty.gif\"/></a>");        	
        }
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
        } else {
        	//EPeronja-03/05/2013: Bug 364: add legend when there is no geometry
        	out.write("<i>No Geo</i>");
        }
        //EPeronja-01/30/2013: Bug472- to add icons next to the data for data blessing access 
        if (file.getBlessFile() != null) {
        	if (file.isBlessed()) {
        		out.write("<a href=\"../analysis-blessing/compare1.jsp?file=");
        		out.write(file.getLFN());
        		out.write("\">");   
        		out.write("<img alt=\"Blessed data\" "
                    + "src=\"../graphics/star.gif\"/></a>");
        	}
        	else {
        		out.write("<a href=\"../analysis-blessing/compare1.jsp?file=");
        		out.write(file.getLFN());
        		out.write("\">");   
        		out.write("<img alt=\"Blessed data\" "
                    + "src=\"../graphics/unblessed.gif\"/></a>");        	
        	}
        }
        if (file.getTriggers() > 0) {
        	out.write("<br />" + formatNumber(file.getTriggers()) + " events");
        } else {
        	out.write("<br />No trigger data");        	
        }
    }

    public void displayFileFooter(JspWriter out, File file) throws IOException {
        out.write("</td>\n");
    }
    
    public TreeMap<Integer, Collection<File>> collateFilesByDetector(Collection<File> files) {
    	TreeMap<Integer, Collection<File>> h = new TreeMap<Integer, Collection<File>>();
    	
    	for (File f : files) { 
    		int currentId = f.getDetector();
    		if (h.containsKey(currentId)) {
    			h.get(currentId).add(f);
    		}
    		else {
    			Collection<File> c = new ArrayList<File>();
    			c.add(f);
    			h.put(currentId, c);
    		}
    	}
    	
    	return h;
    }
    
    protected static String formatNumber(long x) {
    	DecimalFormat df = new DecimalFormat();
    	DecimalFormatSymbols dfs = new DecimalFormatSymbols(Locale.US);
    	return df.format(x);
    }
    
}
