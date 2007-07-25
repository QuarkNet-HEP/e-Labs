//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 20, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.analysis.AnalysisExecutor;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.InitializationException;
import gov.fnal.elab.datacatalog.CachingDataCatalogProvider;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.test.ElabTestProvider;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;

/**
 * Manages the instantiation of various elab functionality providers. User code
 * should use the <code>Elab.getXYZProvider</code> methods instead of calling
 * methods in this class directly.
 */
public class ElabFactory {
    private static ElabUserManagementProvider userManagementProvider;

    private static Object newInstance(Elab elab, String provider)
            throws ElabInstantiationException {
        String clsname = elab.getProperties().getProperty(
                "provider." + provider.toLowerCase());
        return newInstance(elab, provider, clsname);
    }

    private static Object newInstance(Elab elab, String provider, String clsname) {
        try {
            Class cls = ElabFactory.class.getClassLoader().loadClass(clsname);
            Object p = cls.newInstance();
            if (p instanceof ElabProvider) {
                ((ElabProvider) p).setElab(elab);
            }
            return p;
        }
        catch (Exception e) {
            throw new ElabInstantiationException(
                    "Failed to instantiate provider for " + provider
                            + " (class: " + clsname + ")", e);
        }
    }

    /**
     * Returns an instance of a user management provider for the specified elab.
     * A user management provider is used to implement I2U2 functionality
     * related to user management (such as log-ins, permissions, teachers, etc.)
     * 
     * @param elab
     *            An elab for which a user management provider is desired
     * @return A user management provider for the specified elab
     */
    public static synchronized ElabUserManagementProvider getUserManagementProvider(
            Elab elab) {
        if (userManagementProvider == null) {
            userManagementProvider = (ElabUserManagementProvider) newInstance(
                    elab, "usermanagement");
        }
        return userManagementProvider;
    }

    private static DataCatalogProvider dataCatalogProvider;

    /**
     * Returns an instance of a data catalog provider for the given elab. A data
     * catalog provider implements the functionality
     */
    public static synchronized DataCatalogProvider getDataCatalogProvider(
            Elab elab) {
        if (dataCatalogProvider == null) {
            setVDSHome(elab);
            dataCatalogProvider = new CachingDataCatalogProvider(
                    (DataCatalogProvider) newInstance(elab, "datacatalog"));
        }
        return dataCatalogProvider;
    }

    private static ElabTestProvider testProvider;

    /**
     * Returns an instance of an elab test provider for the specified elab. A
     * test provider implements functionality related to tests (surveys).
     */
    public static synchronized ElabTestProvider getTestProvider(Elab elab) {
        if (testProvider == null) {
            testProvider = (ElabTestProvider) newInstance(elab, "test");
        }
        return testProvider;
    }

    private static AnalysisExecutor analysisExecutor;

    /**
     * Returns an analysis provider/executor for the given elab. The analysis
     * provider is used to run analyses.
     */
    public static synchronized AnalysisExecutor getAnalysisProvider(Elab elab) {
        if (analysisExecutor == null) {
            setVDSHome(elab);
            analysisExecutor = (AnalysisExecutor) newInstance(elab,
                    "analysisexecutor");
        }
        return analysisExecutor;
    }

    /**
     * Returns a new analysis instance for the specified elab
     * 
     * @param elab
     *            An elab
     * @param impl
     *            The type of the analysis. The exact meaning of this parameter
     *            is left to the implementation of the analysis. In the VDS case
     *            it would be the transformation name
     * @param param
     *            An intialization parameter to pass to the analysis. The
     *            meaning of this parameter is also left to the implementation
     *            of the analysis. In the VDS case it is not used.
     * 
     * @return A new analysis object
     * @throws InitializationException
     *             if the initialization of the analysis with the given
     *             parameter fails
     * 
     */
    public static ElabAnalysis newElabAnalysis(Elab elab, String impl,
            String param) throws InitializationException {
        if (impl == null) {
            impl = elab.getProperties().getProperty("provider.analysis",
                    "vds-dynamic");
        }
        if ("vds-dynamic".equals(impl)) {
            impl = "gov.fnal.elab.analysis.VDSAnalysis";
        }
        else if ("vds-bean".equals(impl)) {
            impl = "gov.fnal.elab.analysis.BeanWrapper";
        }

        setVDSHome(elab);
        ElabAnalysis analysis = (ElabAnalysis) newInstance(elab, "analysis",
                impl);
        if (param != null) {
            analysis.initialize(param);
        }
        return analysis;
    }

    private static void setVDSHome(Elab elab) {
        System.setProperty("vds.home", elab.getProperties().getProperty(
                "vds.home"));
    }
}
