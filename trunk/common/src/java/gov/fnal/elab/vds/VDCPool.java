package gov.fnal.elab.vds;

import gov.fnal.elab.ElabObjectPool;
import gov.fnal.elab.util.ElabException;

/**
 * Pools connections to the Virtual Data Catalog, allowing thread-safe, reusable 
 * connections for web clients.  Subclasses the general elab object pool.
 *
 * @author Eric Gilbert <egilbert -at- f n a l -dot- gov>
 * @see gov.fnal.elab.ElabObjectPool
 */

public class VDCPool extends ElabObjectPool {

    //private final Class VDCclass = Class.forName("org.griphyn.vdl.dbschema.VDC");
    
    /**
     * Create the VDC connection object.
     *
     * @return The reference to the VDC connection.
     */
    protected Object create() {return null; }

    /**
     * Clean up the VDC connection before giving it back to the pool.
     *
     * @param obj   The connection to recycle.
     */
    protected void recycle(Object obj) throws ElabException {return;}

    protected void initialize(int initialObjects, Class objectType) throws ElabException {return;}
    
    protected void destroy(Object obj) throws ElabException {return;}

}
    
