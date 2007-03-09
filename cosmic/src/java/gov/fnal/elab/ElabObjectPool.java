package gov.fnal.elab;

import java.util.Stack;
import gov.fnal.elab.util.ElabException;

/**
 * A default implemenation of an object pool.  This is an abstract class, 
 * only subclasses may use it.  The intention is that multiple database 
 * connections can start from this class for object management.  Connection
 * management will fall to the implementing classes.
 *
 * This implementation is basically the Singleton pattern, without 
 * that instance() sillyness.
 * 
 * @author Eric Gilbert <egilbert -at- f n a l -dot- gov>
 * @see gov.fnal.elab.vds.VDCPool
 */

public abstract class ElabObjectPool {

    protected Stack availableObjects = null;
    protected Class objectType = null;
    protected boolean isInitialized = false;
    protected int objectsInUse = 0;
    
    /**
     * Empty constructor for use by subclasses.
     */
    protected ElabObjectPool() {}

    /**
     * Gets an object from this object pool.  The object
     * returned will depend on the subclass implementation.
     *
     * @return The object from the pool (or a newly created one).
     * @throws ElabException If the object pool has not been initialized yet.
     */
    protected Object checkOut() throws ElabException { 
        if (!isInitialized)
            throw new ElabException(
                "Object Pool not initialized.  You must explicitly initialize the object " + 
                "pool before you use it.");
        
        if (!availableObjects.isEmpty()) {
            Object ret = null;
            synchronized (availableObjects) {
                ret = availableObjects.pop();
                availableObjects.notifyAll();
            }
            return ret;
        }
        else {
            objectsInUse++;
            return create();
        }
    }
    
    /**
     * Puts an object back into the pool.  The object must be the same type as
     * the object types declared for this pool during initialization.
     *
     * @param obj               The object to return to the pool.
     * @throws ElabException    If the object pool has not been initialized yet,
     *                          or if the pool is null when it should not be, or
     *                          if the object checked in is of the wrong type.
     */
    protected void checkIn(Object obj) throws ElabException {
        if (!isInitialized)
            throw new ElabException(
                "Object Pool not initialized.  You must explicitly initialize the object " + 
                "pool before you use it.");

        if (availableObjects != null) {
            recycle(obj);
            synchronized (availableObjects) {
                availableObjects.push(obj);
                availableObjects.notifyAll();
            }
        } else { 
            throw new ElabException(
                "The Object Pool has been initialized, but the pool is null.  This should " +
                "never happen.");
        }
    }

    /**
     * Set up the object pool.
     *
     * @param initialObjects    The number of initial objects to create in the pool.
     * @param objectType        The class of the objects in this pool.
     */
    protected void initialize(int initialObjects, Class objectType) throws ElabException {
        availableObjects = new Stack();
        availableObjects.ensureCapacity(initialObjects);

        // Create the object pool using the abstract method create().
        for (int i = 1; i < initialObjects; i++) 
            availableObjects.push(create());
        
        this.objectType = objectType;
        isInitialized = true;
    }
                
    /**
     * Abstract method to create an object of the type specified at initialization time.
     * Will return null if any error occurs in initantiating the class.
     *
     * @return  A newly created object.
     */
    protected abstract Object create();
                
    /**
     * Perform any cleaning needed to put the object back in the pool.
     *
     * @param obj               The object to clean.
     * @throws ElabException    If the object if not the correct type.
     */
    protected abstract void recycle(Object obj) throws ElabException;

    /**
     * Perform any cleaning needed to put the object back in the pool.
     *
     * @param obj               The object to clean.
     * @throws ElabException    If the object if not the correct type.
     */
    protected abstract void destroy(Object obj) throws ElabException;
} 

