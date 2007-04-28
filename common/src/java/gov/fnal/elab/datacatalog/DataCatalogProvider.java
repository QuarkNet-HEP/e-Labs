/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.QueryElement;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;

//TODO Get rid of ElabException
public interface DataCatalogProvider {
    ResultSet runQuery(String query) throws ElabException;
    
    int getUniqueCategoryCount(String key) throws ElabException;

    ResultSet runQuery(QueryElement q) throws ElabException;
        
    ResultSet getEntries(String[] lfns) throws ElabException;
    
    CatalogEntry getEntry(String lfn) throws ElabException;
    
    void insert(CatalogEntry entry) throws ElabException;
    
    //these should probably not be here
    void insertAnalysis(String name, ElabAnalysis analysis)
            throws ElabException;
    
    ElabAnalysis getAnalysis(String lfn) throws ElabException;
}
