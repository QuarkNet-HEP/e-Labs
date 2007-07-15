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

    public static synchronized ElabUserManagementProvider getUserManagementProvider(
            Elab elab) {
        if (userManagementProvider == null) {
            userManagementProvider = (ElabUserManagementProvider) newInstance(
                    elab, "usermanagement");
        }
        return userManagementProvider;
    }

    private static DataCatalogProvider dataCatalogProvider;

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

    public static synchronized ElabTestProvider getTestProvider(Elab elab) {
        if (testProvider == null) {
            testProvider = (ElabTestProvider) newInstance(elab, "test");
        }
        return testProvider;
    }

    private static AnalysisExecutor analysisExecutor;

    public static synchronized AnalysisExecutor getAnalysisProvider(Elab elab) {
        if (analysisExecutor == null) {
            setVDSHome(elab);
            analysisExecutor = (AnalysisExecutor) newInstance(elab,
                    "analysisexecutor");
        }
        return analysisExecutor;
    }

    public static ElabAnalysis newElabAnalysis(Elab elab, String impl,
            String param) {
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
        return (ElabAnalysis) newInstance(elab, "analysis", impl);
    }

    private static void setVDSHome(Elab elab) {
        System.setProperty("vds.home", elab.getProperties().getProperty(
                "vds.home"));
    }
}
