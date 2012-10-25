/*
 * Created on Apr 23, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.QueryElement;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;

/**
 * An implementation of a <code>DataCatalogProvider</code> which wraps another
 * provider and caches the last lookup.
 */
public class CachingCatalogProvider implements DataCatalogProvider, AnalysisCatalogProvider {
    private DataCatalogProvider dataDelegate;
    private AnalysisCatalogProvider analysisDelegate;

    private Collection<String> lastFiles;
    private ResultSet lastResultSet;
    private boolean updating;
    
    private long lastdate;
    public static final long INTERVAL = 1000*60;

    public CachingCatalogProvider(DataCatalogProvider delegate, AnalysisCatalogProvider analysisDelegate) {
        this.dataDelegate = delegate;
        this.analysisDelegate = analysisDelegate; 
    }

    private ResultSet getCachedEntries(Collection<String> files) throws ElabException {
    	long now;
        synchronized (this) {
        	now = System.currentTimeMillis();
            if (!updating && equals(files, lastFiles) && (now - lastdate < INTERVAL)) {
                return lastResultSet;
            }
        }
        ResultSet rs = dataDelegate.getEntries(files);
        synchronized (this) {
            lastFiles = files;
            lastResultSet = rs;
            lastdate = now;
        }
        return rs;
    }
    
    private boolean equals(Collection<?> c1, Collection<?> c2) {
        //here equals(null, null) == false
        if (c1 == null || c2 == null) {
            return false;
        }
        else {
            return new HashSet<Object>(c1).containsAll(c2) && c1.size() == c2.size();
        }
    }
    
    public ResultSet getEntries(Collection<String> lfns) throws ElabException {
        return getCachedEntries(lfns);
    }

    public ResultSet getEntries(String[] lfns) throws ElabException {
        return getCachedEntries(Arrays.asList(lfns));
    }

    public CatalogEntry getEntry(String lfn) throws ElabException {
        ResultSet rs = getEntries(Collections.singletonList(lfn));
        if (rs.isEmpty()) {
            return null;
        }
        else {
            CatalogEntry e = (CatalogEntry) rs.iterator().next();
            if (e.getTupleMap().isEmpty()) {
                return null;
            }
            else {
                return e;
            }
        }
    }
    
    public ResultSet runQueryNoMetadata(QueryElement q) throws ElabException {
        return dataDelegate.runQueryNoMetadata(q);
    }

    public int getUniqueCategoryCount(String key) throws ElabException {
        return dataDelegate.getUniqueCategoryCount(key);
    }

    public ResultSet runQuery(String query) throws ElabException {
        return dataDelegate.runQuery(query);
    }

    public ResultSet runQuery(QueryElement q) throws ElabException {
        return dataDelegate.runQuery(q);
    }
    
    private void startUpdate() {
        synchronized(this) {
            updating = true;
        }
    }
    
    private void endUpdate() {
        synchronized(this) {
            lastFiles = null;
            lastResultSet = null;
            updating = false;
        }
    }

    public void insert(CatalogEntry entry) throws ElabException {
        //there's a question of whether queries on a lfn should be allowed
        //while its metadata is being updated, but that's probably something
        //that the lower levels should enforce
        //we only disable caching during updates
        startUpdate();
        dataDelegate.insert(entry);
        endUpdate();
    }
    
    public void delete(CatalogEntry entry) throws ElabException {
        startUpdate();
        dataDelegate.delete(entry);
        endUpdate();
    }
    
    public void delete(String lfn) throws ElabException {
        startUpdate();
        dataDelegate.delete(lfn);
        endUpdate();
    }

    public void insertAnalysis(String name, ElabAnalysis analysis)
            throws ElabException {
    	analysisDelegate.insertAnalysis(name, analysis);
    }

    public ElabAnalysis getAnalysis(String lfn) throws ElabException {
        return analysisDelegate.getAnalysis(lfn);
    }
}
