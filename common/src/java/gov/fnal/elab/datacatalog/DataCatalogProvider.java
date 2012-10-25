/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.QueryElement;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;

// TODO Get rid of ElabException
/**
 * Describes the interaction with a data catalog
 */
public interface DataCatalogProvider extends ElabProvider {
    /**
     * Runs a query in string format. This should not be used as it is
     * implementation specific, and there is no formal specification of what a
     * valid query string is or how it should be constructed.
     */
    ResultSet runQuery(String query) throws ElabException;

    /**
     * Obscure at best. Counts the number of unique data entries that have a
     * given key as metadata value. It should probably be changed to count the
     * number of things that have a certain tuple.
     */
    int getUniqueCategoryCount(String key) throws ElabException;

    /**
     * Runs a query. Queries are build in a nice structured fashion with classes
     * in the {@link gov.fnal.elab.datacatalog.query} package.
     */
    ResultSet runQuery(QueryElement q) throws ElabException;
    
    ResultSet runQueryNoMetadata(QueryElement q) throws ElabException;

    /**
     * Returns the entries in the catalog matching the given logical file names.
     * The number of returned entries may be smaller then the size of the
     * specified array (if some entries are not found).
     */
    ResultSet getEntries(String[] lfns) throws ElabException;
    
    /**
     * Returns the entries in the catalog matching the given logical file names.
     * The number of returned entries may be smaller then the size of the
     * specified collection (if some entries are not found).
     */
    ResultSet getEntries(Collection<String> lfns) throws ElabException;

    /**
     * Returns a single entry from the catalog matching the specified logical
     * file name, or <code>null</code> if no such LFN exists in the catalog.
     */
    CatalogEntry getEntry(String lfn) throws ElabException;
    
    void delete(String lfn) throws ElabException;
    
    void delete(CatalogEntry entry) throws ElabException;

    /**
     * Inserts an entry in the catalog. If the entry already
     * exists, selectively update the metadata.
     */
    void insert(CatalogEntry entry) throws ElabException;    
}
