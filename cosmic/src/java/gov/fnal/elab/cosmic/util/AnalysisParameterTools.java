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
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
        Set l = new HashSet(rawData.size());
        Iterator i = rawData.iterator();
        while (i.hasNext()) {
            String s = new File((String) i.next()).getName();
            String detectorID = s.substring(0, s.indexOf("."));
            l.add(elab.getProperties().getDataDir() + File.separator
                    + detectorID + File.separator + detectorID + ".geo");
        }
        return new ArrayList(l);
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
     * @return A {@link Collection} containing used channels, each of each is
     *         guaranteed to appear at most once.
     */
    public static Collection getValidChannels(Elab elab, Collection files)
            throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        Set channels = new HashSet();
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
        return channels;
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
            Double freq = (Double) e.getTupleValue("cpldfrequency");
            if (freq == null) {
                freq = DEFAULT_CPLD_FREQUENCY;
            }
            freqs.add(freq);
        }
        return ElabUtil.join(freqs, " ");
    }

}
