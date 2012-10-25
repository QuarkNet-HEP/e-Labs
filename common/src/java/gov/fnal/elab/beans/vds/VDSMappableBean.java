package gov.fnal.elab.beans.vds;

import org.griphyn.vdl.classes.Transformation;
import org.griphyn.vdl.classes.Derivation;

import gov.fnal.elab.beans.MappableBean;
import gov.fnal.elab.util.ElabException;

/**
 * This interface defines a method to map an object to and from a 
 * {@link Derivation}. The <code>Derivation</code> created should have all
 * the necessary values set. The <code>MappableBean</code> created should
 * also have all its values set.
 */
public interface VDSMappableBean extends MappableBean{
    /**
     * Map values in object to a new {@link Derivation}
     *
     * @param tr {@link Transformation} object
     * @param ns the namespace of the Derivation.
     * @param name the name of the Derivation.
     * @param version the version of the Derivation.
     * @param us the namespace to search for a Transformation.
     * @param uses the name of the Transformation.
     * @param min the minimum inclusive permissable version.
     * @param max the maximum inclusive permissable version.
     */
    public Derivation mapToDV(Transformation tr,
                            String ns,
                            String name,
                            String version,
                            String us,
                            String uses,
                            String min,
                            String max)
                            throws ElabException;

    /**
     * Map values from a {@link Derivation} into a JavaBean
     *
     * @param dv the darivation object to map
     */
    public void mapToBean(Derivation dv) throws ElabException;
}
