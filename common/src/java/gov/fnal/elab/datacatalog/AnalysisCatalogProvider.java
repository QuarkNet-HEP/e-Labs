package gov.fnal.elab.datacatalog;

import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.util.ElabException;

public interface AnalysisCatalogProvider extends ElabProvider{

	/**
     * Inserts an analysis into the catalog
     */
    void insertAnalysis(String name, ElabAnalysis analysis)
            throws ElabException;

    /**
     * Retrieves an analysis from the catalog.
     */
    ElabAnalysis getAnalysis(String lfn) throws ElabException;
    
}
