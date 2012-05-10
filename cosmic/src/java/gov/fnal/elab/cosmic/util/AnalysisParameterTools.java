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
    
    public static String getDetectorIds(Collection<String> rawData) {
        StringBuffer db = new StringBuffer();
        
        for (String s : rawData) {
        	db.append(getDetectorId(s) + ' ');
        }
        return db.toString(); 
    }

    public static String getDetectorId(String rawData) {
        return rawData.substring(0, rawData.indexOf("."));
    }
    
    public static List<String> getThresholdFiles(Elab elab, String[] rawData) {
    	List<String> rawDataList = Arrays.asList(rawData); 
        return getThresholdFiles(elab, rawDataList);
    }

    public static List<String> getThresholdFiles(Elab elab, Collection<String> rawData) {
        List<String> l = new ArrayList<String>(rawData.size());
        for (String n : rawData) {
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
    
    public static List<String> getGeometryFiles(Elab elab, Collection<String> rawData) {
        List<String> l = new ArrayList<String>(rawData.size());
        for (String i : rawData) {
        	String s = new File(i).getName();
        	String detectorID = s.substring(0, s.indexOf("."));
        	l.add(elab.getProperties().getDataDir() + File.separator
                    + detectorID + File.separator + detectorID + ".geo");
        }
        return l;
    }
    
    public static List<String> getWireDelayFiles(Elab elab, Collection<String> rawData) {
        List<String> l = new ArrayList<String>(rawData.size());
        for (String i : rawData) {
        	l.add(i + ".wd");
        }
        return l;
    }
    
    public static final Map<String, String> CHANNELS;
    static {
        CHANNELS = new HashMap();
        CHANNELS.put("chan1", "1");
        CHANNELS.put("chan2", "2");
        CHANNELS.put("chan3", "3");
        CHANNELS.put("chan4", "4");
    }
    
    public static int getEventCount(Elab elab, Collection<String> files) throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        int sum = 0;
        for (CatalogEntry e : rs) {
        	sum += getEvents("chan1", e);
            sum += getEvents("chan2", e);
            sum += getEvents("chan3", e);
            sum += getEvents("chan4", e);
        }
        return sum;
    }
    
    public static int getEventCount(Elab elab, Collection<String> files, int channel) throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        int sum = 0;
        for (CatalogEntry e : rs) {
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
    public static List<String> getValidChannels(Elab elab, Collection<String> files)
            throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        SortedSet<String> channels = new TreeSet();
        
        for (CatalogEntry e : rs) {
        	if (e == null) {
        		continue;
        	}
        	for (Map.Entry<String, String> f : CHANNELS.entrySet()) {
        		String cname = f.getKey();
        		Number l = (Number) e.getTupleValue(cname); 
        		if (l != null && l.longValue() > 0) {
        			channels.add(f.getValue());
        		}
        	}
        }
        return new ArrayList<String>(channels);
    }
    
    public static final Double DEFAULT_CPLD_FREQUENCY = new Double(41666667);
    
    public static String getCpldFrequencies(Elab elab, Collection<String> files)
            throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        List<Double> freqs = new ArrayList();
        
        for (CatalogEntry e : rs) {
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
    
    public static List<String> getFirmwareVersions(Elab elab, Collection<String> files) throws ElabException {
    	ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
    	List<String> l = new ArrayList<String>();
    	
    	for (CatalogEntry e : rs) {
    		if (e == null) {
    			continue;
    		}
    		String firmwareVersion = (String) e.getTupleValue("DAQFirmware");
    		if (firmwareVersion == null) {
    			firmwareVersion = "";
    		}
    		l.add(firmwareVersion); 
    	}
    	
    	return l; 
    }

}
