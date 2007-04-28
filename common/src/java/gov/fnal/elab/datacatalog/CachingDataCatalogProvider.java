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

public class CachingDataCatalogProvider implements DataCatalogProvider {
    private DataCatalogProvider delegate;

    private String[] lastFiles;
    private ResultSet lastResultSet;

    public CachingDataCatalogProvider(DataCatalogProvider delegate) {
        this.delegate = delegate;
    }

    private ResultSet getCachedEntries(String[] files) throws ElabException {
        synchronized (this) {
            if (Arrays.equals(files, lastFiles)) {
                return lastResultSet;
            }
        }
        ResultSet rs = delegate.getEntries(files);
        synchronized (this) {
            lastFiles = files;
            lastResultSet = rs;
        }
        return rs;
    }

    public ResultSet getEntries(String[] lfns) throws ElabException {
        return getCachedEntries(lfns);
    }

    public CatalogEntry getEntry(String lfn) throws ElabException {
        ResultSet rs = getEntries(new String[] { lfn });
        if (rs.isEmpty()) {
            return null;
        }
        else {
            return (CatalogEntry) rs.iterator().next();
        }
    }

    public int getUniqueCategoryCount(String key) throws ElabException {
        return delegate.getUniqueCategoryCount(key);
    }

    public ResultSet runQuery(String query) throws ElabException {
        return delegate.runQuery(query);
    }

    public ResultSet runQuery(QueryElement q) throws ElabException {
        return delegate.runQuery(q);
    }

    public void insert(CatalogEntry entry) throws ElabException {
        delegate.insert(entry);
    }

    public void insertAnalysis(String name, ElabAnalysis analysis)
            throws ElabException {
        delegate.insertAnalysis(name, analysis);
    }

    public ElabAnalysis getAnalysis(String lfn) throws ElabException {
        return delegate.getAnalysis(lfn);
    }
}
