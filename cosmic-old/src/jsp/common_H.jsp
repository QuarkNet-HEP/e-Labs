<%@ page import="java.io.*, java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.Timestamp" %> 
<%@ page import="java.text.DateFormat" %>
<%@ page import="org.griphyn.vdl.util.ChimeraProperties" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.planner.Catalog" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.apache.batik.transcoder.image.PNGTranscoder" %>
<%@ page import="org.apache.batik.transcoder.TranscoderInput" %>
<%@ page import="org.apache.batik.transcoder.TranscoderOutput" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>

<%@ page import="gov.fnal.elab.db.*"%>
<%
// rough timing information for this page execution.  Is there an API for this?
long pageStartTime = System.currentTimeMillis();

ServletContext context = getServletContext();
String home = context.getRealPath("").replace('\\', '/');

/*
 * If the System Properties have not been set yet, read from the
 * elab.properties file and set them.
 */
if(System.getProperty("vds.home") == null){
    String pfFile = home + "/WEB-INF/elab.properties";
    File pf = new File(pfFile);
    if (pf.canRead()) {
        Properties prop = new Properties();
        try{
            prop.load(new FileInputStream(pf));
            for ( Enumeration e = prop.propertyNames(); e.hasMoreElements(); ) {
                String key = (String) e.nextElement();
                String value = prop.getProperty(key);
                System.setProperty(key, value);
            }
        } catch (Exception e){
            throw new ElabException("While setting the elab System properties...: " + e.getMessage());
        }
    }
    else{
        throw new ElabException("Couldn't read the elab System properties file: " + pfFile);
    }
}


/*
 * Login Checking
 * If the user hasn't logged in, redirect to the login page
 */
if((Login)session.getAttribute("login") == null){
    String prevPage = request.getServletPath();
    String queryString = request.getQueryString();
    if(queryString != null){
        prevPage += "?" + queryString;
        prevPage = URLEncoder.encode(prevPage, "UTF-8");
    }

    //redirect to the SSL enabled login page
    response.sendRedirect(
            "https://" + System.getProperty("host") +  
            System.getProperty("sslport") + "/elab/cosmic/login_H.jsp?prevPage="+prevPage);
    return;
}

//Useful directory variables
/*
 * FIXME make sure these are changed in all files which use them
 */
/*
String dataDir = (String) System.getProperty("cosmic.datadir");
String templateDir = (String) System.getProperty("portal.templates");
*/

//Other useful variables
/*
 * FIXME make sure these are changed in all files which use them
 */
/*
String groupName = null;    //same as session.getAttribute("login")
String groupTeacher = null;
String groupSchool = null;
String groupCity = null;
String groupState = null;
String groupYear = null;
*/
%>

<%!
public static void warn(JspWriter out, String error){
    try{
        out.write("<font color=red><b>" + error + "</b></font>");
    }
    catch(Exception e){
        ;
    }
}
%>

<%!
/**
  * Checks if a geometry file exists
  *
  * @param  id          detector/DAC board number  
  * @param  dataDir     base geometry pathname. In "path/id/id.geo" this is "path"
  * @return             <code>true</code> if the geometry file exists
  *                     <code>false</code> otherwise.
  */
public static boolean geoFileExists(int id, String dataDir){
    File f = new File(dataDir + "/" + id);
    if(f.isDirectory()){
        File f2 = new File(dataDir + "/" + id + "/" + id + ".geo");
        if(f2.isFile()){
            return f2.canRead();
        }
        return false;
    }
    return false;
}
%>

<%!
/**
 * Convert a .svg image to a .png and create a thumbnail of the image as well.
 *
 * @param   svgfilename     full path to the svg image
 * @param   pngfilename     full path to the png image to output
 * @param   thumbpngfilename  full path to the thumbnail png image to output
 * @param   pngheight       pixel height of the png image
 * @param   thumbpngheight    pixel height of the thumbnail png image
 */
public static void svg2png(String svgfilename, String pngfilename, String thumbpngfilename, String pngheight, String thumbpngheight) throws IOException, ElabException{
    try {
        String svgFile = (new File(svgfilename)).toURL().toString();

        // Convert the SVG image to PNG using the Batik toolkit.
        // Thanks to the Batik website's tutorial for this code (http://xml.apache.org/batik/rasterizerTutorial.html).
        PNGTranscoder trans = new PNGTranscoder();
        // Regular size image.
        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(pngheight));
        TranscoderInput input = new TranscoderInput(svgFile);
        OutputStream ostream = new FileOutputStream(pngfilename);
        TranscoderOutput output = new TranscoderOutput(ostream);
        trans.transcode(input, output);
        ostream.flush();
        ostream.close();

        trans = new PNGTranscoder();
        // Thumbnail.
        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(thumbpngheight));
        ostream = new FileOutputStream(thumbpngfilename);
        output = new TranscoderOutput(ostream);
        trans.transcode(input, output);
        ostream.flush();
        ostream.close();
    } catch (Exception e) {
        throw new ElabException("Error: Failed to create plot from SVG file: " + e.getMessage());
    }
}
%>



<%!
/**
 * Convert a .svg image to a .png and create a thumbnail of the image as well.
 *
 * @deprecated         use the version without the "out" parameter
 * @param   svgfilename     full path to the svg image
 * @param   pngfilename     full path to the png image to output
 * @param   thumbpngfilename  full path to the thumbnail png image to output
 * @param   pngheight       pixel height of the png image
 * @param   thumbpngheight    pixel height of the thumbnail png image
 */
public static void svg2png(JspWriter out, String svgfilename, String pngfilename, String thumbpngfilename, String pngheight, String thumbpngheight) throws IOException{
    try {
        String svgFile = (new File(svgfilename)).toURL().toString();

        // Convert the SVG image to PNG using the Batik toolkit.
        // Thanks to the Batik website's tutorial for this code (http://xml.apache.org/batik/rasterizerTutorial.html).
        PNGTranscoder trans = new PNGTranscoder();
        // Regular size image.
        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(pngheight));
        TranscoderInput input = new TranscoderInput(svgFile);
        OutputStream ostream = new FileOutputStream(pngfilename);
        TranscoderOutput output = new TranscoderOutput(ostream);
        trans.transcode(input, output);
        ostream.flush();
        ostream.close();

        trans = new PNGTranscoder();
        // Thumbnail.
        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(thumbpngheight));
        ostream = new FileOutputStream(thumbpngfilename);
        output = new TranscoderOutput(ostream);
        trans.transcode(input, output);
        ostream.flush();
        ostream.close();
    } catch (Exception e) {
        out.write("Error: Failed to create plot from SVG file:<br>" + e.getMessage() + "<br>");
    }
}
%>



<%!
//convert Gregorian to Julian Day
public double jd(int day, int month, int year, int hour, int min){
    //arguments: day[1..31], month[1..12], year[..2004..], hour[0..23], min[0..59]
    if(month < 3) {
        month = month + 12;
        year = year - 1;
    }

    return (2 -(int)(year/100)+(int)(year/400)+ day + (int)(365.25*(year+4716)) + (int)(30.6001*(month+1)) - 1524.5) + (hour + min/60.0)/24.0;
}
%>

<%!
//jd_to_gregorian helper function
/**
 * Convert a julian day to Gregorian day (helper function)
 * see jd_to_gregorian with 2 parameters
 *
 * @param   jd      float jd to convert
 */
public int[] jd_to_gregorian(double jd){
    String[] split = new String[2];
    Double f = new Double(jd);
    split = f.toString().split("\\.");
    split[1] = "." + split[1];
    int jd_int = Integer.parseInt((String)split[0]);
    double partial = Double.parseDouble((String)split[1]);

    return jd_to_gregorian(jd_int, partial);
}

/**
  * Convert a julian day to Gregorian day
  * Thanks to: http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
  *
  * @param  jd          integer julian day
  * @param  partial     partial julian day (0 <= float < 1)
  * @return             a native array (day[1..31], month[1..12], year[..2004..]{, hour[0..23], min, sec, msec, micsec, nsec})
  */
public int[] jd_to_gregorian(int jd, double partial){
    int Z = (int)(jd + 0.5 + partial);
    int W = (int)((Z - 1867216.25)/36524.25);
    int X = (int)(W/4);
    int A = Z+1+W-X;
    int B = A+1524;
    int C = (int)((B-122.1)/365.25);
    int D = (int)(365.25*C);
    int E = (int)((B-D)/30.6001);
    int F = (int)(30.6001*E);
    int day = B-D-F;
    int month = E-1 <= 12 ? E-1 : E-13; //Month = E-1 or E-13 (must get number less than or equal to 12)
    int year = month <= 2 ? C-4715 : C-4716;    //Year = C-4715 (if Month is January or February) or C-4716 (otherwise)

    int[] array = new int[10];
    array[0] = day;
    array[1] = month;
    array[2] = year;

    if(partial != 0){
        int hour = (int)(partial*24);
        int min = (int)((partial*24-hour)*60);
        int sec = (int)(((partial*24-hour)*60-min)*60);
        int msec = (int)((((partial*24-hour)*60-min)*60-sec)*1000);
        int micsec = (int)(((((partial*24-hour)*60-min)*60-sec)*1000-msec)*1000);
        int nsec = (int)((((((partial*24-hour)*60-min)*60-sec)*1000-msec)*1000)*1000);

        array[3] = (hour+12)%24;
        array[4] = min;
        array[5] = sec;
        array[6] = msec;
        array[7] = micsec;
        array[8] = nsec;
    }

    return array;
}
%>


<%!
/**
 * Sort any array of arrays by column.
 *
 * No parameters since this method is called from Collections.sort()
 */
class SortByColumn implements Comparator{
    public final int compare (Object a, Object b){
        ArrayList rowA = (ArrayList)a;
        ArrayList rowB = (ArrayList)b;

        //if either object is null, sort to bottom of list
        if(rowA == null){
            return 1;
        }
        if(rowB == null){
            return -1;
        }

        Object objA = rowA.get(this.sortColumn);
        Object objB = rowB.get(this.sortColumn);

        //Return a negative integer, zero, or a positive integer if objA is less than, equal to, or greater than objB. (higher goes to top)
        int ret = 0;
        if (objA instanceof Integer){
            Integer obj1 = (Integer)objA;
            Integer obj2 = (Integer)objB;
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Long){
            Long obj1 = (Long)objA;
            Long obj2 = (Long)objB;
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Float){
            Float obj1 = (Float)objA;
            Float obj2 = (Float)objB;
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Boolean){
            Boolean obj1 = (Boolean)objA;
            Boolean obj2 = (Boolean)objB;
            boolean eq = obj1.equals(obj2);
            if(eq){ ret = -1; } else{ ret = 1; }
        }
        if (objA instanceof String){
            String obj1 = (String)objA;
            String obj2 = (String)objB;
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof java.util.Date){
            java.util.Date obj1 = (java.util.Date)objA;
            java.util.Date obj2 = (java.util.Date)objB;
            ret = obj1.compareTo(obj2);  //newest dates first
        }
        if (objA instanceof Timestamp){
            Timestamp obj1 = (Timestamp)objA;
            Timestamp obj2 = (Timestamp)objB;
            ret = obj1.compareTo(obj2);  //newest dates first
        }

        return asc == true ? ret : -1*ret;
    }

    public SortByColumn(int i){
        setSortColumn(i);
    }

    /*
     * Should be called before calling Collections sort() method
     * (Column numbering starts at 0)
     */
    public void setSortColumn(int i){
        this.sortColumn = i;
    }

    public void sortAscending(){
        asc = true;
    }

    public void sortDescending(){
        asc = false;
    }

    private int sortColumn = 0;
    private boolean asc = true;    //sort ascending
}
%>


<%!
/**
  * Format html output for metadata tags
  *
  * @author             Paul Nepywoda
  */
public class MetaFormat{
    //Input: String key of metadata, value of metadata (from (Tuple)t.getValue())
    /**
     * Pick which formatting method to call based on the metadata key
     *
     * @param  key          metadata key
     * @param  value        metadata value
     * @return              html formatted value, or simply the value if no
     *                      special formatting is required
     */
    public String pickMeta(String key, Object value){
        if(value != null){
            if(key.equals("blessed")){
                return this.blessed(value);
            }
            else if(key.equals("stacked")){
                return this.stacked(value);
            }
            else if(key.equals("chan1")){
                return this.chan1(value);
            }
            else if(key.equals("chan2")){
                return this.chan2(value);
            }
            else if(key.equals("chan3")){
                return this.chan3(value);
            }
            else if(key.equals("chan4")){
                return this.chan4(value);
            }
            else if(key.equals("startdate")){
                return this.startdate(value);
            }
            else if(key.equals("creationdate")){
                return this.creationdate(value);
            }
            else if(key.equals("date")){
                return this.date(value);
            }
            else{
                //if no special handling is needed, return an unformatted value
                return value.toString();
            }
        }
        else{
            return "";
        }
    }

    public String blessed(Object value){
        boolean blessed = ((Boolean)value).booleanValue();
        String ret = "";
        if(blessed){
            ret += "<img border=\"0\" alt=\"Blessed data\" src=\"graphics/star.gif\">";
        }
        return ret;
    }
    
    public String stacked(Object value){
        boolean stacked = ((Boolean)value).booleanValue();
        String ret = "";
        if(stacked){
            ret += "<img border=\"0\" alt=\"Stacked data\" src=\"graphics/stacked.gif\">";
        }
        else{
            ret += "<img border=\"0\" alt=\"Unstacked data\"  src=\"graphics/unstacked.gif\">";
        }
        return ret;
    }

    public String chan1(Object value){
        int chan1=0;
        chan1 = ((Long)value).intValue();
        String ret = "";
        if(chan1 > 0){
            ret += "<img src=\"graphics/chan1-on.png\"";
        }
        else{
            ret += "<img src=\"graphics/chan1-off.png\"";
        }
        return ret;
    }

    public String chan2(Object value){
        int chan2=0;
        chan2 = ((Long)value).intValue();
        String ret = "";
        if(chan2 > 0){
            ret += "<img src=\"graphics/chan2-on.png\"";
        }
        else{
            ret += "<img src=\"graphics/chan2-off.png\"";
        }
        return ret;
    }

    public String chan3(Object value){
        int chan3=0;
        chan3 = ((Long)value).intValue();
        String ret = "";
        if(chan3 > 0){
            ret += "<img src=\"graphics/chan3-on.png\"";
        }
        else{
            ret += "<img src=\"graphics/chan3-off.png\"";
        }
        return ret;
    }

    public String chan4(Object value){
        int chan4=0;
        chan4 = ((Long)value).intValue();
        String ret = "";
        if(chan4 > 0){
            ret += "<img src=\"graphics/chan4-on.png\"";
        }
        else{
            ret += "<img src=\"graphics/chan4-off.png\"";
        }
        return ret;
    }

    public String startdate(Object value){
        return this.dateFormatterDataFiles((java.util.Date)value);
    }

    public String creationdate(Object value){
        return this.datetimeFormatter((java.util.Date)value);
    }

    public String date(Object value){
        return this.dateFormatter((java.util.Date)value);
    }


    //helper functions
    private String dateFormatter(java.util.Date d){
        String formatted=new String();
		GregorianCalendar calendar = new GregorianCalendar();

		calendar.setTime(d);
		String month = month_name(1+calendar.get(Calendar.MONTH));
		String day = calendar.get(Calendar.DATE)+"";

		formatted = month;
		formatted += " " + day;

        return formatted;
    }
    
    private String dateFormatterDataFiles(java.util.Date d){
        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("EEE d");
        return formatter.format(d);
    }

    private String datetimeFormatter(java.util.Date d){
        String formatted=new String();
		GregorianCalendar calendar = new GregorianCalendar();

		calendar.setTime(d);
        return java.text.DateFormat.getDateInstance().format(calendar.getTime());
		/*String month = (1+calendar.get(Calendar.MONTH))+"/";
		String day = calendar.get(Calendar.DATE)+"/";

		formatted = month;
		formatted += day;
		formatted += calendar.get(Calendar.YEAR) + " ";
		formatted += calendar.get(Calendar.HOUR_OF_DAY) + ":";
		formatted += calendar.get(Calendar.MINUTE) + ":";
		formatted += calendar.get(Calendar.SECOND);

        return formatted;*/
    }
}
%>


<%!
/**
  * Sorts the ArrayList returned by {@link ElabVDC#getLFNsAndMeta} based on a metadata
  * key.
  * Many thanks to http://www.onjava.com/pub/a/onjava/2003/03/12/java_comp.html?page=2 
  * which had some great examples
  *
  * @author             Paul Nepywoda
  */
class MetaCompare implements Comparator{
    /**
     * Implemented as per {@link Comparator} speficies.
     * Should not be called directly.
     */
    public final int compare (Object a, Object b){
        java.util.List la = (java.util.List)a;
        java.util.List lb = (java.util.List)b;
        java.util.List tuplesA = (java.util.List)la.get(1);
        java.util.List tuplesB = (java.util.List)lb.get(1);

        String sortKey = this.getSortKey();
        //search through the list until you find the Tuple to sort on
        Tuple sortTupleA = null;
        for(Iterator i=tuplesA.iterator(); i.hasNext(); ){
            Tuple t = (Tuple)i.next();
            String key = (String)t.getKey();
            if(key.equals(sortKey)){
                sortTupleA = t;
            }
        }
        Tuple sortTupleB = null;
        for(Iterator i=tuplesB.iterator(); i.hasNext(); ){
            Tuple t = (Tuple)i.next();
            String key = (String)t.getKey();
            if(key.equals(sortKey)){
                sortTupleB = t;
            }
        }

        //if either Tuple is null, sort to bottom of list
        if(sortTupleA == null){
            return 1;
        }
        if(sortTupleB == null){
            return -1;
        }


        Object objA = sortTupleA.getValue();
        Object objB = sortTupleB.getValue();
        
        //if either object is null, sort to bottom of list
        if(objA == null){
            return 1;
        }
        if(objB == null){
            return -1;
        }

        //Compares its two arguments for order. Returns a negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater than the second.
        int ret = 0;
        if (objA instanceof Long){
            Long obj1 = (Long)sortTupleA.getValue();
            Long obj2 = (Long)sortTupleB.getValue();
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Float){
            Float obj1 = (Float)sortTupleA.getValue();
            Float obj2 = (Float)sortTupleB.getValue();
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Boolean){
            Boolean obj1 = (Boolean)sortTupleA.getValue();
            Boolean obj2 = (Boolean)sortTupleB.getValue();
            boolean eq = obj1.equals(obj2);
            if(eq){ ret = -1; } else{ ret = 1; }
        }
        if (objA instanceof String){
            String obj1 = (String)sortTupleA.getValue();
            String obj2 = (String)sortTupleB.getValue();
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Timestamp){
            Timestamp obj1 = (Timestamp)sortTupleA.getValue();
            Timestamp obj2 = (Timestamp)sortTupleB.getValue();
            ret = obj1.compareTo(obj2);  //newest dates first
        }
        if (!isAscending)
            ret = -ret;
        
        return ret;
    }
    
    /**
     * Returns the current search key
     *
     * @return              current search key
     */
    public String getSortKey(){
        return this.sortKey;
    }
    /**
     * Set the key to sort by
     *
     * @param   s           metadata key to sort by
     */
    public void setSortKey(String s){
        this.sortKey = s;
    }

    /**
     *  Directs the sort in ascending order.
     *
     */
    public void setSortAscending() {
        this.isAscending = true;
    }

    /**
     * Directs the sort in descending order.
     *
     */
    public void setSortDescending() {
        this.isAscending = false;
    }

    private String sortKey = "project";
    private boolean isAscending = true;
}
%>


<%!
/**
 * Return the filename lfn that matches the detector id and has start and end
 * dates which encompass the date given
 *
 * @param   int         detector id
 * @param   Date        timestamp
 * @return              lfn of filename
 */
public static String lfn_from_date(int id, java.util.Date date) throws ElabException{
    java.util.List result = null;
    String lfn = null;
    ElabVDS vdsInteraction = new ElabVDS();

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    sdf.setTimeZone(TimeZone.getTimeZone("GMT"));

    String q = "type='split' AND project='cosmic' AND detectorid='" + id
        + "' AND startdate < '" + sdf.format(date) + "' AND enddate > '"
        + sdf.format(date) + "'";
    result = vdsInteraction.getLFNs(q);
    if(result != null){
        Iterator i=result.iterator(); 
        if(i.hasNext()){    //only grab the first lfn if there's more than one
            lfn = (String)i.next();
        }
    }

    return lfn;
}
%>


<%!
/**
  * Convert an integer to a month name (starting from 1)
  *
  * @param  int         month integer
  * @return             month name
  */
public static String month_name(int month){
    switch(month){
        case 0: return new String("Month");
        case 1: return new String("January");
        case 2: return new String("February");
        case 3: return new String("March");
        case 4: return new String("April");
        case 5: return new String("May");
        case 6: return new String("June");
        case 7: return new String("July");
        case 8: return new String("August");
        case 9: return new String("September");
        case 10: return new String("October");
        case 11: return new String("November");
        case 12: return new String("December");
        default:
                 return new String("Not a month!");
    }
}

/**
  * Convert a month name to an integer (starting from 1)
  *
  * @param  m           month name
  * @return             month integer
  */
public static int month_number(String m){
    if(m.equals("Month")){
        return 0;
    }
    else if(m.equals("January")){
        return 1;
    }
    else if(m.equals("February")){
        return 2;
    }
    else if(m.equals("March")){
        return 3;
    }
    else if(m.equals("April")){
        return 4;
    }
    else if(m.equals("May")){
        return 5;
    }
    else if(m.equals("June")){
        return 6;
    }
    else if(m.equals("July")){
        return 7;
    }
    else if(m.equals("August")){
        return 8;
    }
    else if(m.equals("September")){
        return 9;
    }
    else if(m.equals("October")){
        return 10;
    }
    else if(m.equals("November")){
        return 11;
    }
    else if(m.equals("December")){
        return 12;
    }
    return 0;
}
%>
