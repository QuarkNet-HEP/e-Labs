/*
 * Created on Jun 28, 2007
 */
package gov.fnal.elab.usermanagement;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;
import java.util.TreeMap;

public interface CosmicElabUserManagementProvider extends
        ElabUserManagementProvider {

    Collection getDetectorIds(ElabGroup group) throws ElabException;
    
    void setDetectorIds(ElabGroup group, Collection<String> detectorIds) throws ElabException;
 
	//TreeMap<Integer, Boolean> getDetectorBenchmarkFileUse(ElabGroup group) throws ElabException;
    
    void setDetectorBenchmarkFileUse(ElabGroup group, String detectorId, boolean benchmark_file_use) throws ElabException;
}
