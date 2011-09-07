/*
 * Created on Apr 21, 2007
 */
package gov.fnal.elab.cosmic.util;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.SortedSet;
import java.util.TreeSet;

public class AnalysisParameterTools {
    
    public static String getDetectorIds(String[] rawData) {
        return getDetectorIds(Arrays.asList(rawData));
    }
    
    public static String getDetectorIds(Collection rawData) {
        StringBuffer db = new StringBuffer();
        Iterator i = rawData.iterator();
        while (i.hasNext()) {
            String s = (String) i.next();
            db.append(getDetectorId(s));
            if (i.hasNext()) {
                db.append(' ');
            }
        }
        return db.toString();
    }

    public static String getDetectorId(String rawData) {
        return rawData.substring(0, rawData.indexOf("."));
    }
    
    public static List getThresholdFiles(Elab elab, String[] rawData) {
        return getThresholdFiles(elab, Arrays.asList(rawData));
    }

    public static List getThresholdFiles(Elab elab, Collection rawData) {
        List l = new ArrayList(rawData.size());
        Iterator i = rawData.iterator();
        while (i.hasNext()) {
            String n = (String) i.next();
            if (n == null) {
                throw new IllegalArgumentException("One of the raw data files is null");
            }
            String s = new File(n).getName();
            String detectorID = s.substring(0, s.indexOf("."));
            l.add(elab.getProperties().getDataDir() + File.separator
                    + detectorID + File.separator + s + ".thresh");
        }
        return l;
    }
    
    public static List getGeometryFiles(Elab elab, Collection rawData) {
        List l = new ArrayList(rawData.size());
        Iterator i = rawData.iterator();
        while (i.hasNext()) {
            String s = new File((String) i.next()).getName();
            String detectorID = s.substring(0, s.indexOf("."));
            l.add(elab.getProperties().getDataDir() + File.separator
                    + detectorID + File.separator + detectorID + ".geo");
        }
        return l;
    }
    
    public static List getWireDelayFiles(Elab elab, Collection rawData) {
        List l = new ArrayList(rawData.size());
        Iterator i = rawData.iterator();
        while (i.hasNext()) {
            l.add(i.next() + ".wd");
        }
        return l;
    }
    
    public static final Map CHANNELS;
    static {
        CHANNELS = new HashMap();
        CHANNELS.put("chan1", "1");
        CHANNELS.put("chan2", "2");
        CHANNELS.put("chan3", "3");
        CHANNELS.put("chan4", "4");
    }
    
    public static int getEventCount(Elab elab, Collection files) throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        Iterator i = rs.iterator();
        int sum = 0;
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            sum += getEvents("chan1", e);
            sum += getEvents("chan2", e);
            sum += getEvents("chan3", e);
            sum += getEvents("chan4", e);
        }
        return sum;
    }
    
    public static int getEventCount(Elab elab, Collection files, int channel) throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        Iterator i = rs.iterator();
        int sum = 0;
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            sum += getEvents("chan" + channel, e);
        }
        return sum;
    }
    
    private static int getEvents(String chan, CatalogEntry e) {
        Number ev = (Number) e.getTupleValue(chan);
        if (ev == null) {
            return 0;
        }
        else {
            return ev.intValue();
        }
    }
    
    private static final String[] STRING_ARRAY = new String[0];

    /**
     * Retrieves a set of valid channels used by the specified data. This method
     * is Cosmic specific and should be moved.
     * 
     * @param elab
     *            The current {@link Elab}
     * @param files
     *            A set of logical file names
     * 
     * @return A {@link List} containing used channels, each of each is
     *         guaranteed to appear at most once. The channels are sorted.
     */
    public static List getValidChannels(Elab elab, Collection files)
            throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        SortedSet channels = new TreeSet();
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            if (e == null) {
                continue;
            }
            Iterator j = CHANNELS.entrySet().iterator();
            while (j.hasNext()) {
                Map.Entry f = (Map.Entry) j.next();
                String cname = (String) f.getKey();
                Long l = (Long) e.getTupleValue(cname);
                if (l != null && l.longValue() > 0) {
                    channels.add(f.getValue());
                }
            }
        }
        return new ArrayList(channels);
    }
    
    public static final Double DEFAULT_CPLD_FREQUENCY = new Double(41666667);
    
    public static String getCpldFrequencies(Elab elab, Collection files)
            throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        List freqs = new ArrayList();
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            if (e == null) {
                continue;
            }
        	Number freq = (Number) e.getTupleValue("cpldfrequency"); 
            if (freq == null) {
                freq = DEFAULT_CPLD_FREQUENCY;
            }
            freqs.add(freq.doubleValue());
        }
        return ElabUtil.join(freqs, " ");
    }

}
