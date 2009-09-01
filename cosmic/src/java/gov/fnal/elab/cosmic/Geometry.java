package gov.fnal.elab.cosmic;

import gov.fnal.elab.cosmic.beans.GeoEntryBean;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.datacatalog.DataTools;
import gov.fnal.elab.datacatalog.query.And;
import gov.fnal.elab.datacatalog.query.Between;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.Equals;
import gov.fnal.elab.datacatalog.query.GreaterThan;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.util.NanoDate;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.LineNumberReader;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.griphyn.common.catalog.ReplicaCatalog;
import org.griphyn.common.catalog.replica.ReplicaFactory;
import org.griphyn.vdl.util.ChimeraProperties;

/**
 * Geometry holds the geometry data for one detector. Holds all of the specific
 * geometry entries (as represented by the {@link GeoEntry} and keeps them
 * ordered. It supports the operations of adding, removing and searching.
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
    private int detectorID;

    /*
     * Constructor where the geometry file is computed for you.
     * 
     * @param dataDirectory The location of the cosmic data. @param detectorID
     * The detector ID you want geometry for.
     */
    public Geometry(String dataDirectory, int detectorID)
            throws ElabException {
        orderedGeoEntries = new TreeMap();
        geoFile = dataDirectory + File.separator + detectorID + File.separator
                + detectorID + ".geo";
        localGeoFile = detectorID + ".geo";
        geoDir = dataDirectory + File.separator + detectorID;
        this.detectorID = detectorID;

        try {
            ensureExistence();
        }
        catch (Exception e) {
            throw new ElabException(
                    "Problem ensuring existence of geometry file. ", e);
        }

        try {
            scanGeoFile();
        }
        catch (Exception ex) {
            throw new ElabException("Problem reading in geometry file. ", ex);
        }
    }

    public int getDetectorID() {
        return detectorID;
    }

    /**
     * Provides an Iterator for the geometry entries in ascending temporal
     * order.
     * 
     * @return An iterator that steps through the geometry entries.
     * @see GeoEntry
     */
    public Iterator getGeoEntries() {
        return orderedGeoEntries.values().iterator();
    }

    public SortedMap getGeoEntriesBefore(String julianDay) {
        return orderedGeoEntries.headMap(julianDay);
    }

    /**
     * Provides an Iterator for the geometry entries in descending temporal
     * order.
     * 
     * @return An iterator that steps through the geometry entries.
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
     * @param geb
     *            The geometry to add.
     */
    public void addGeoEntry(GeoEntryBean geb) {
        orderedGeoEntries.put(geb.getJulianDay(), geb);
    }

    /**
     * Removes a geometry entry from this geometry info.
     * 
     * @param geb
     *            The geometry to add.
     */
    public void removeGeoEntry(GeoEntryBean geb) {
        orderedGeoEntries.remove(geb.getJulianDay());
    }

    /**
     * Gets a geometry entry specified by Julian Day.
     * 
     * @param jd
     *            The Julian Day in String form.
     */
    public GeoEntryBean getGeoEntry(String jd) {
        return (GeoEntryBean) orderedGeoEntries.get(jd);
    }

    /*
     * Makes sure that geometry file exists. If it does not then it is created.
     * 
     * @throws ElabException If some problem with writing the file occurs.
     * Sometimes this happens when the data directory changes in Tomcat.
     */
    private void ensureExistence() throws Exception {
        File dir = new File(geoDir);
        if (!dir.exists()) {
            System.out.println(geoDir);
            System.out.flush();
            boolean b = dir.mkdir();
            if (!b) {
                throw new ElabException(
                        "Error creating geometry directory. Maybe the disk is full.");
            }
        }

        // rc.data and metadata creation
        File f = new File(geoFile);
        if (!f.exists()) {
            f.createNewFile();

            try {
                ChimeraProperties props = ChimeraProperties.instance();
                String rcName = props.getRCLocation();

                // get rc contents into memory
                ReplicaCatalog rc = ReplicaFactory.loadInstance();
                int c_rc = rc.insert(localGeoFile, geoFile, "local");

            }
            catch (Exception e) {
                throw new ElabException(
                        "Error creating rc.data entry for geometry.", e);
            }
        }
        existenceEnsured = true;
    }

    /*
     * Reads the geometry file specified into memory for further processing.
     * 
     * @throws Exception Something bad happens when reading the file, like it is
     * moved.
     */
    private void scanGeoFile() throws Exception {
        if (geoFile == null || !existenceEnsured)
            return;
        Pattern p1 = Pattern.compile("^[0-9]{7}(\\.[0-9]*)*$");
        LineNumberReader in = new LineNumberReader(new FileReader(geoFile));
        String s = new String();
        String[] split = new String[4];
        try {
            while ((s = in.readLine()) != null) {
                GeoEntryBean geb = new GeoEntryBean();
                geb.setDetectorID(detectorID);
                Matcher m1 = p1.matcher(s);
                if (m1.matches()) {
                    geb.setJulianDay(s);

                    // then read in the next 9 lines for the geo data

                    s = in.readLine(); // latitude
                    split = s.split("\\.");
                    if (split[0].startsWith("-")) {
                        geb.setLatitude(split[0].substring(1) + ":" + split[1]
                                + "." + split[2] + " S");
                    }
                    else {
                        geb.setLatitude(split[0] + ":" + split[1] + "."
                                + split[2] + " N");
                    }

                    s = in.readLine(); // longitude
                    split = s.split("\\.");
                    if (split[0].startsWith("-")) {
                        geb.setLongitude(split[0].substring(1) + ":" + split[1]
                                + "." + split[2] + " W");
                    }
                    else {
                        geb.setLongitude(split[0] + ":" + split[1] + "."
                                + split[2] + " E");
                    }

                    s = in.readLine(); // altitude
                    geb.setAltitude(s);

                    s = in.readLine(); // stacked
                    geb.setStackedState(s);

                    s = in.readLine(); // chan1
                    split = s.split("\\s");
                    geb.setChan1X(split[0]);
                    geb.setChan1Y(split[1]);
                    geb.setChan1Z(split[2]);
                    // The area in the geo file is has units of m^2, but the
                    // user expects to see units of cm^2
                    // It is easier for the user to measure their counter in cm
                    // and enter those values
                    // The next line converts the units for proper display in
                    // the form
                    geb.setChan1Area(Double.toString((Double.valueOf(split[3])
                            .doubleValue()) * 100 * 100));
                    // Sometimes the geo-file will not have an entry
                    // for cable length. If it doesn't, then
                    // we have to use zero, and if it does we have to use that.
                    if (split.length == 5) {
                        // The cable length in the geo file has units of time.
                        // The user expects to see units of length.
                        // We do this because it is easier for the user to
                        // measure the lenght of the cable in meters and enter
                        // those values.
                        // So the next line converts the value read from the
                        // file for proper display in the form.
                        // The conversion from m to 10e-11 s is conveniently =
                        // 500. (Propagation speed = 2/3 c)
                        // before the change the line was:
                        // geb.setChan1CableLength(split[4]);
                        geb.setChan1CableLength(Double.toString((Double
                                .valueOf(split[4]).doubleValue()) / 500));
                    }

                    s = in.readLine(); // chan2
                    split = s.split("\\s");
                    geb.setChan2X(split[0]);
                    geb.setChan2Y(split[1]);
                    geb.setChan2Z(split[2]);
                    geb.setChan2Area(Double.toString((Double.valueOf(split[3])
                            .doubleValue()) * 100 * 100));
                    if (split.length == 5) {
                        // geb.setChan2CableLength(split[4]);
                        geb.setChan2CableLength(Double.toString((Double
                                .valueOf(split[4]).doubleValue()) / 500));
                    }

                    s = in.readLine(); // chan3
                    split = s.split("\\s");
                    geb.setChan3X(split[0]);
                    geb.setChan3Y(split[1]);
                    geb.setChan3Z(split[2]);
                    geb.setChan3Area(Double.toString((Double.valueOf(split[3])
                            .doubleValue()) * 100 * 100));
                    if (split.length == 5) {
                        // geb.setChan3CableLength(split[4]);
                        geb.setChan3CableLength(Double.toString((Double
                                .valueOf(split[4]).doubleValue()) / 500));
                    }

                    s = in.readLine(); // chan4
                    split = s.split("\\s");
                    geb.setChan4X(split[0]);
                    geb.setChan4Y(split[1]);
                    geb.setChan4Z(split[2]);
                    geb.setChan4Area(Double.toString((Double.valueOf(split[3])
                            .doubleValue()) * 100 * 100));
                    if (split.length == 5) {
                        // geb.setChan4CableLength(split[4]);
                        geb.setChan4CableLength(Double.toString((Double
                                .valueOf(split[4]).doubleValue()) / 500));
                    }

                    // gps cable length
                    s = in.readLine();
                    if (s != null && !s.matches("^[0-9]{7}(\\.[0-9]*)*$")) {
                        // if next line is a julian day, user hasn't set the
                        // cable length and we assume it's zero
                        geb.setGpsCableLength(Double.toString((Double
                                .valueOf(s).doubleValue()) / 500));
                    }

                    orderedGeoEntries.put(geb.getJulianDay(), geb);
                }
            }
        }
        catch (Exception e) {
            int lineNumber = in.getLineNumber();
            throw new ElabException("Reading geometry file " + geoFile + ":"
                    + in, e);
        }
        finally {
            in.close();
        }
    }

    /*
     * Commmit this geometry data to persistent storage. Currently this means
     * write it to the geometry file. In the future it could be our own database
     * or perhaps metadata.
     * 
     * @throws ElabException If a problem occurs in file writing.
     */
    public void commit() throws ElabException {
        if (geoFile == null || !existenceEnsured)
            return;

        try {
            Iterator it = orderedGeoEntries.values().iterator();
            PrintWriter pw = new PrintWriter(new FileWriter(new File(geoFile)));
            while (it.hasNext()) {
                GeoEntryBean geb = (GeoEntryBean) it.next();
                pw.println(geb.writeForFile());
            }
            pw.close();
        }
        catch (Exception e) {
            throw new ElabException(
                    "Problem commiting geometry information to a file: ", e);
        }
    }

    /**
     * Find all files that correspond to this geometry information in the VDS.
     * Update their stacked state based on this information.
     * 
     * @param dcp
     * @param geoEntry
     * 
     * @throws ElabException
     *             Something goes wrong when accessing the VDS.
     */
    public void updateMetadata(DataCatalogProvider dcp, GeoEntryBean geoEntry)
            throws ElabException {
        if (geoFile == null || !existenceEnsured)
            return;

        Date endDate = null;

        Iterator j = getGeoEntries();
        while (j.hasNext()) {
            GeoEntryBean gb = (GeoEntryBean) j.next();
            if (geoEntry.getDate().equals(gb.getDate()) && j.hasNext()) {
                endDate = ((GeoEntryBean) j.next()).getDate();
            }
        }

        // Update the stacked state of all files that use this geo entry
        DateFormat fmt = new SimpleDateFormat("MM/dd/yyyy HH:mm:SS");

        And and = new And();
        and.add(new Equals("type", "split"));
        and.add(new Equals("detectorid", geoEntry.getDetectorID()));
        if (endDate != null) {
            and.add(new Between("startdate", fmt.format(geoEntry.getDate()),
                    fmt.format(endDate)));
        }
        else {
            and
                    .add(new GreaterThan("startdate", fmt.format(geoEntry
                            .getDate())));
        }

        ResultSet rs = dcp.runQueryNoMetadata(and);

        boolean stacked = geoEntry.getStackedState().equals("1");

        boolean updated = true;

        ArrayList meta = new ArrayList();
        meta.add("stacked boolean " + stacked);

        Iterator k = rs.iterator();
        while (k.hasNext()) {
            CatalogEntry e = (CatalogEntry) k.next();
            dcp.insert(DataTools.buildCatalogEntry(e.getLFN(), meta));
        }
    }

    private String itemsToDate(int[] items) {
        StringBuffer sb = new StringBuffer();
        appendPadded(sb, items[2], "-");
        appendPadded(sb, items[1], "-");
        appendPadded(sb, items[0], " ");
        appendPadded(sb, items[3], ":");
        appendPadded(sb, items[4], ":");
        appendPadded(sb, items[5], ".");
        sb.append(items[6]);
        return sb.toString();
    }

    private void appendPadded(StringBuffer sb, int val, String after) {
        if (val < 10) {
            sb.append('0');
            sb.append(val);
        }
        else {
            sb.append(val);
        }
        sb.append(after);
    }

    /**
     * Convert a julian day to Gregorian day (helper function)
     * 
     * @param jd
     *            float jd to convert
     * @see jdToGregorian(int, double)
     */
    public static NanoDate jdToGregorian(double jd) {
        String[] split = new String[2];
        Double f = new Double(jd);
        split = f.toString().split("\\.");
        split[1] = "." + split[1];
        int jd_int = Integer.parseInt(split[0]);
        double partial = Double.parseDouble(split[1]);

        return ElabUtil.julianToGregorian(jd_int, partial);
    }

    /**
     * Overrides the toString method in Object. Used mainly for debugging
     * purposes. You can do System.out.println(geoObject) and this method will
     * get called.
     * 
     * @return The String representation of this object.
     */
    public String toString() {
        return Integer.toString(getDetectorID());
    }

    /**
     * Tells you whether or not this Geometry objects has any entries in it or
     * not. Useful for knowing if a new detector has recently been entered.
     * 
     * @return Whether it is empty.
     */
    public boolean isEmpty() {
        return orderedGeoEntries.isEmpty();
    }

    public boolean getEmpty() {
        return isEmpty();
    }

    /**
     * Returns the number of entries in this Geometry.
     * 
     * @return The number of entries in this Geometry.
     */
    public int size() {
        return orderedGeoEntries.size();
    }

    /**
     * JSP friendly size method
     */
    public int getSize() {
        return size();
    }
}
