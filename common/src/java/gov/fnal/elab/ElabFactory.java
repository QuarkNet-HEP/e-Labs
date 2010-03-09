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
import gov.fnal.elab.analysis.BeanWrapper;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.GenericAnalysis;
import gov.fnal.elab.analysis.InitializationException;
import gov.fnal.elab.analysis.impl.vds.VDSAnalysis;
import gov.fnal.elab.datacatalog.CachingDataCatalogProvider;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.notifications.ElabNotificationsProvider;
import gov.fnal.elab.survey.ElabSurveyProvider;
import gov.fnal.elab.test.ElabTestProvider;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;

import java.util.HashMap;
import java.util.Map;

/**
 * Manages the instantiation of various elab functionality providers. User code
 * should use the <code>Elab.getXYZProvider</code> methods instead of calling
 * methods in this class directly.
 */
public class ElabFactory {
    
    private static Map providers = new HashMap();
    
    private static Object get(Elab elab, String provider) {
        synchronized(providers) {
            return providers.get(elab.getName() + ":" + provider);
        }
    }
    
    private static void set(Elab elab, String provider, Object value) {
        synchronized(providers) {
            providers.put(elab.getName() + ":" + provider, value);
        }
    }

    private static Object newInstance(Elab elab, String provider)
            throws ElabInstantiationException {
        String clsname = elab.getProperties().getProperty(
                "provider." + provider.toLowerCase());
        return newInstance(elab, provider, clsname);
    }

    private static Object newInstance(Elab elab, String provider, String clsname) {
        try {
        	clsname = clsname.trim();
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

    private static final String USERMANAGEMENT = "usermanagement";
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
        Object p = get(elab, USERMANAGEMENT);
        if (p == null) {
            p = newInstance(elab, USERMANAGEMENT);
            set(elab, USERMANAGEMENT, p);
        }
        return (ElabUserManagementProvider) p;
    }
    
    private static final String DATACATALOG = "datacatalog";

    /**
     * Returns an instance of a data catalog provider for the given elab. A data
     * catalog provider implements the functionality
     */
    public static synchronized DataCatalogProvider getDataCatalogProvider(
            Elab elab) {
        Object p = get(elab, DATACATALOG);
        if (p == null) {
            setVDSHome(elab);
            p = new CachingDataCatalogProvider((DataCatalogProvider) newInstance(elab, DATACATALOG));
            set(elab, DATACATALOG, p);
        }
        return (DataCatalogProvider) p;
    }

    private static final String TEST = "test";

    /**
     * Returns an instance of an elab test provider for the specified elab. A
     * test provider implements functionality related to tests (surveys).
     * This is for older survey implementations and is deprecated. 
     */
    public static synchronized ElabTestProvider getTestProvider(Elab elab) {
        Object p = get(elab, TEST);
        if (p == null) {
            p = newInstance(elab, TEST);
            set(elab, TEST, p);
        }
        return (ElabTestProvider) p;
    }
    
    private static final String SURVEY = "survey";
    
    /**
     * Return an instance of an elab survey provider for the specified elab. A
     * survey provider implements functionality related to surveys. 
     */
    public static synchronized ElabSurveyProvider getSurveyProvider(Elab elab) {
    	Object p = get(elab, SURVEY);
    	if (p == null) { 
    		p = newInstance(elab, SURVEY);
    		set(elab, SURVEY, p);
    	}
    	return (ElabSurveyProvider) p; 
    }

    private static final String ANALYSISEXECUTOR = "analysisexecutor";

    /**
     * Returns an analysis provider/executor for the given elab. The analysis
     * provider is used to run analyses.
     */
    public static synchronized AnalysisExecutor getAnalysisProvider(Elab elab) {
        Object p = get(elab, ANALYSISEXECUTOR);
        if (p == null) {
            setVDSHome(elab);
            p = newInstance(elab, ANALYSISEXECUTOR);
            set(elab, ANALYSISEXECUTOR, p);
        }
        return (AnalysisExecutor) p;
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
            impl = VDSAnalysis.class.getName();
        }
        else if ("vds-bean".equals(impl)) {
            impl = BeanWrapper.class.getName();
        }
        else if ("generic".equals(impl)) {
        	impl = GenericAnalysis.class.getName();
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
    
    private static final String NOTIFICATIONS = "notifications";
    
    public static synchronized ElabNotificationsProvider getNotificationsProvider(
            Elab elab) {
        Object p = get(elab, NOTIFICATIONS);
        if (p == null) {
            p = newInstance(elab, NOTIFICATIONS);
            set(elab, NOTIFICATIONS, p);
        }
        return (ElabNotificationsProvider) p;
    }
}
