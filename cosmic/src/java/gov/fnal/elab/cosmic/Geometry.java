package gov.fnal.elab.cosmic;

import java.io.*;
import java.util.*;
import java.util.regex.*;

import org.griphyn.common.catalog.ReplicaCatalog;
import org.griphyn.common.catalog.replica.ReplicaFactory;
import org.griphyn.vdl.util.*;
import org.griphyn.vdl.classes.*;
import org.griphyn.vdl.dbschema.*;
import org.griphyn.vdl.directive.*;
import org.griphyn.vdl.annotation.*;
import org.griphyn.common.util.Separator;

import gov.fnal.elab.cosmic.beans.GeoEntryBean;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.vds.ElabVDS;

/**
 * Geometry holds the geometry data for one detector. Holds all of the specific
 * geometry entries (as represented by the {@link GeoEntry} and keeps them ordered. 
 * It supports the operations of adding, removing and searching.
 *
 * @author Eric Gilbert (egilbert -at- f n a l -dot- gov
 * @see GeoEntry
 */
public class Geometry {

    private TreeMap orderedGeoEntries = null;
    private String geoDir = null;
    private String geoFile = null;
    private String localGeoFile = null; 
    private boolean existenceEnsured = false;
    private String detectorID = null;

    /* Constructor where the geometry file is computed for you.
     *
     * @param dataDirectory The location of the cosmic data.
     * @param detectorID    The detector ID you want geometry for.
     */
    public Geometry(String dataDirectory, String detectorID) throws ElabException {
        orderedGeoEntries = new TreeMap();
        geoFile = dataDirectory + detectorID + "/" + detectorID + ".geo";
        localGeoFile = detectorID + ".geo";
        geoDir = dataDirectory + detectorID;
        this.detectorID = detectorID;

        try {
            ensureExistence();
        } catch (Exception e) {
            throw new ElabException("Problem ensuring existence of geometry file. " + e);
        }

        try {
            scanGeoFile();
        } catch (Exception ex) {
            throw new ElabException("Problem reading in geometry file. " + ex);
        }
    }

    public String getDetectorID() { return detectorID; }

    /**
     * Provides an Iterator for the geometry entries in ascending temporal
     * order.
     *
     * @return  An iterator that steps through the geometry entries.
     * @see GeoEntry
     */
    public Iterator getGeoEntries() { return orderedGeoEntries.values().iterator(); }

    /**
     * Provides an Iterator for the geometry entries in descending temporal
     * order.
     *
     * @return  An iterator that steps through the geometry entries.
     * @see GeoEntry
     */
    public Iterator getDescendingGeoEntries() {
        TreeMap tmp = new TreeMap(Collections.reverseOrder());
        tmp.putAll(orderedGeoEntries);
        return tmp.values().iterator();
    }

    /**
     * Adds a geometry entry to this geometry info.
     *
     * @param geb   The geometry to add.
     */
    public void addGeoEntry(GeoEntryBean geb) {
        orderedGeoEntries.put(geb.getJulianDay(), geb);
    }

    /**
     * Removes a geometry entry from this geometry info.
     *
     * @param geb   The geometry to add.
     */
    public void removeGeoEntry(GeoEntryBean geb) {
        orderedGeoEntries.remove(geb.getJulianDay());
    }

    /**
     * Gets a geometry entry specified by Julian Day.
     *
     * @param jd    The Julian Day in String form.
     */
    public GeoEntryBean getGeoEntry(String jd) {
        return (GeoEntryBean)orderedGeoEntries.get(jd);
    }
    
    /*
     * Makes sure that geometry file exists. If it does not then it is created.
     *
     * @throws ElabException    If some problem with writing the file occurs.
     *                          Sometimes this happens when the data directory changes in Tomcat.
     */
    private void ensureExistence() throws Exception {
        File dir = new File(geoDir);
        if(!dir.exists()){
            System.out.println(geoDir);
            System.out.flush();
            boolean b = dir.mkdir();
            if(!b){
                throw new ElabException("Error creating geometry directory. Maybe the disk is full.");
            }
        }

        //rc.data and metadata creation
        File f = new File(geoFile);
        if (!f.exists()) {
            f.createNewFile();


            try {
                ChimeraProperties props = ChimeraProperties.instance(); 
                String rcName =  props.getRCLocation();

                // get rc contents into memory
                ReplicaCatalog rc = ReplicaFactory.loadInstance();
                int c_rc = rc.insert(localGeoFile, geoFile, "local");

            } catch (Exception e) {
                throw new ElabException("Error creating rc.data entry for geometry.");
            } 
        }
        existenceEnsured = true;
    }

    /*
     * Reads the geometry file specified into memory for further processing.
     * 
     * @throws Exception    Something bad happens when reading the file, like it is moved.
     */
    private void scanGeoFile() throws Exception {    
        if (geoFile == null || !existenceEnsured) return;

        Pattern p1 = Pattern.compile("^[0-9]{7}(\\.[0-9]*)*$");                  //jd
        BufferedReader in = new BufferedReader(new FileReader(geoFile));
        String s = new String();
        String[] split = new String[4];
        while((s = in.readLine()) != null) {
            GeoEntryBean geb = new GeoEntryBean();
            geb.setDetectorID(detectorID);
            Matcher m1 = p1.matcher(s);
            if(m1.matches()){
                geb.setJulianDay(s);

                //then read in the next 8 lines for the geo data

                s = in.readLine();      //latitude
                split = s.split("\\.");
                geb.setLatitude(split[0] + ":" + split[1] + "." + split[2]);

                s = in.readLine();      //longitude
                split = s.split("\\.");
                geb.setLongitude(split[0] + ":" + split[1] + "." + split[2]);

                s = in.readLine();      //altitude
                geb.setAltitude(s);

                s = in.readLine();      //stacked
                geb.setStackedState(s);

                s = in.readLine();      //chan1
                split = s.split("\\s");
                geb.setChan1X(split[0]);
                geb.setChan1Y(split[1]);
                geb.setChan1Z(split[2]);
                geb.setChan1Area(Double.toString((Double.valueOf(split[3]).doubleValue())*100*100));
                //Sometimes the geo-file will not have an entry for cable length. If it doesn't
                //we have to use zero, and if it does we have to use that.
                if(split.length == 5) {
                    geb.setChan1CableLength(split[4]);
                } 

                s = in.readLine();      //chan2
                split = s.split("\\s");
                geb.setChan2X(split[0]);
                geb.setChan2Y(split[1]);
                geb.setChan2Z(split[2]);
                geb.setChan2Area(Double.toString((Double.valueOf(split[3]).doubleValue())*100*100));
                if(split.length == 5) {
                    geb.setChan2CableLength(split[4]);
                } 

                s = in.readLine();      //chan3
                split = s.split("\\s");
                geb.setChan3X(split[0]);
                geb.setChan3Y(split[1]);
                geb.setChan3Z(split[2]);
                geb.setChan3Area(Double.toString((Double.valueOf(split[3]).doubleValue())*100*100));
                if(split.length == 5) {
                    geb.setChan3CableLength(split[4]);
                }

                s = in.readLine();      //chan4
                split = s.split("\\s");
                geb.setChan4X(split[0]);
                geb.setChan4Y(split[1]);
                geb.setChan4Z(split[2]);
                geb.setChan4Area(Double.toString((Double.valueOf(split[3]).doubleValue())*100*100));
                if(split.length == 5) {
                    geb.setChan4CableLength(split[4]);
                }

                orderedGeoEntries.put(geb.getJulianDay(), geb);
            }
        }
        in.close();
    }

    /*
     * Commmit this geometry data to persistent storage. Currently this means write
     * it to the geometry file. In the future it could be our own database or perhaps
     * metadata.
     *
     * @throws ElabException    If a problem occurs in file writing.
     */
    public void commit() throws ElabException {
        if (geoFile == null || !existenceEnsured) return;

        try {
            Iterator it = orderedGeoEntries.values().iterator();
            PrintWriter pw = new PrintWriter(new FileWriter(new File(geoFile)));
            while (it.hasNext()) {
                GeoEntryBean geb = (GeoEntryBean)it.next();
                pw.println(geb.writeForFile());
            }
            pw.close();
        } catch (Exception e) {
            throw new ElabException("Problem commiting geometry information to a file: " + 
                e.getMessage());
        }
    }

    /**
     * Find all files that correspond to this geometry information in the VDS. Update their 
     * stacked state based on this information.
     *
     * @throws ElabException    Something goes wrong when accessing the VDS.
     */
    public void updateMetadata() throws ElabException {
        if (geoFile == null || !existenceEnsured) return;

        try {
            Iterator it = orderedGeoEntries.values().iterator();
            while (it.hasNext()) {
                GeoEntryBean geb = (GeoEntryBean)it.next();

                // Create the query string that selects all files that pertain to
                // this geometry entry  We will modify these files to hold a stacked
                // attribute in metadata.
                String stackedFilesQuery = null;
                int[] date = jdToGregorian(Double.valueOf(geb.getJulianDay()).doubleValue());
                // Believe it or not, I think Java Dates are even more of a pain.
                String leftBound = 
                    (date[2] < 10 ? "0" + String.valueOf(date[2]) :
                     String.valueOf(date[2])) + "-" + 
                    (date[1] < 10 ? "0" + String.valueOf(date[1]) :
                     String.valueOf(date[1])) + "-" +
                    (date[0] < 10 ? "0" + String.valueOf(date[0]) :
                     String.valueOf(date[0])) + " " +
                    (date[3] < 10 ? "0" + String.valueOf(date[3]) :
                     String.valueOf(date[3])) + ":" +
                    (date[4] < 10 ? "0" + String.valueOf(date[4]) :
                     String.valueOf(date[4])) + ":" +
                    (date[5] < 10 ? "0" + String.valueOf(date[5]) :
                     String.valueOf(date[5])) + "." +
                    String.valueOf(date[6]);
                // This gives the part of the tree strictly greater than the updates
                // made by the user, from which we will extract the first key.
                SortedMap sm = orderedGeoEntries.tailMap(geb.getJulianDay() + "\0");
                if (sm == null || sm.isEmpty()) {
                    stackedFilesQuery = "startdate >= \'" + leftBound + "\'";
                }
                else {
                    // This is the next temporal geo entry.
                    date = jdToGregorian(Double.valueOf((String)sm.firstKey()).doubleValue());
                    stackedFilesQuery = "startdate BETWEEN \'" + leftBound +
                        "\' AND \'" + 
                        (date[2] < 10 ? "0" + String.valueOf(date[2]) :
                         String.valueOf(date[2])) + "-" + 
                        (date[1] < 10 ? "0" + String.valueOf(date[1]) :
                         String.valueOf(date[1])) + "-" +
                        (date[0] < 10 ? "0" + String.valueOf(date[0]) :
                         String.valueOf(date[0])) + " " +
                        (date[3] < 10 ? "0" + String.valueOf(date[3]) :
                         String.valueOf(date[3])) + ":" +
                        (date[4] < 10 ? "0" + String.valueOf(date[4]) :
                         String.valueOf(date[4])) + ":" +
                        (date[5] < 10 ? "0" + String.valueOf(date[5]) :
                         String.valueOf(date[5])) + "." +
                        String.valueOf(date[6]) + "\'";
                }
                stackedFilesQuery += " AND detectorid = \'" + detectorID + "\'";
                ArrayList filesToUpdate = null;
                filesToUpdate = ElabVDS.getLFNsAndMeta(stackedFilesQuery);
                // Update the stacked attribute for the files we find.
                if (filesToUpdate != null) {
                    ArrayList meta = new ArrayList();
                    meta.add("stacked boolean " + (geb.getStackedState().equals("1") ? "true" : "false"));
                    boolean metaUpdated = true;
                    for (Iterator i = filesToUpdate.iterator(); i.hasNext(); ) {
                        ArrayList pair = (ArrayList)i.next();
                        String lfn = (String)pair.get(0);
                        ElabVDS.setMeta(lfn, meta);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ElabException("Problem updating metadata for all files pertaining to this geometry: " +
                e.getMessage());
        }
    }
                
    /**
     * Convert a julian day to Gregorian day (helper function)
     *
     * @param   jd      float jd to convert
     * @see jdToGregorian(int, double)
     */
    public static int[] jdToGregorian(double jd){
        String[] split = new String[2];
        Double f = new Double(jd);
        split = f.toString().split("\\.");
        split[1] = "." + split[1];
        int jd_int = Integer.parseInt((String)split[0]);
        double partial = Double.parseDouble((String)split[1]);

        return jdToGregorian(jd_int, partial);
    }

    /**
     * Convert a julian day to Gregorian day
     * Thanks to: http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
     *
     * @param  jd          integer julian day
     * @param  partial     partial julian day (between 0 and 1)
     * @return             a native array (day[1..31], month[1..12], year[..2004..]{, hour[0..23], min, sec, msec, micsec, nsec})
     */
    private static int[] jdToGregorian(int jd, double partial){
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

    /**
     * Direct helper function for Julian day conversion.
     *
     * @see jdToGregorian(int, double)
     */
    public static double gregorianToJD(int day, int month, int year, int hour, int min){
        //arguments: day[1..31], month[1..12], year[..2004..], hour[0..23], min[0..59]
        if (month < 3) {
            month = month + 12;
            year = year - 1;
        }

        return (2 -(int)(year/100)+(int)(year/400)+ day + (int)(365.25*(year+4716)) + (int)(30.6001*(month+1)) - 1524.5) + (hour + min/60.0)/24.0;
    }

    /**
     * Overrides the toString method in Object. Used mainly for debugging purposes.
     * You can do System.out.println(geoObject) and this method will get called.
     *
     * @return      The String representation of this object.
     */
    public String toString() {
        return getDetectorID();
    }

    /**
     * Tells you whether or not this Geometry objects has any entries in it or not.
     * Useful for knowing if a new detector has recently been entered.
     * 
     * @return      Whether it is empty.
     */
    public boolean isEmpty() {
        return orderedGeoEntries.isEmpty();
    }

    /**
     * Returns the number of entries in this Geometry.
     *
     * @return      The number of entries in this Geometry.    
     */
    public int size() {
        return orderedGeoEntries.size();
    }
}
