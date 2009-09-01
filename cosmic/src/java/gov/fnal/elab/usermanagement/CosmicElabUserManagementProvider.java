/*
 * Created on Jun 28, 2007
 */
package gov.fnal.elab.usermanagement;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;

public interface CosmicElabUserManagementProvider extends
        ElabUserManagementProvider {

    Collection getDetectorIds(ElabGroup group) throws ElabException;
    
    void setDetectorIds(ElabGroup group, Collection<String> detectorIds) throws ElabException;
}
