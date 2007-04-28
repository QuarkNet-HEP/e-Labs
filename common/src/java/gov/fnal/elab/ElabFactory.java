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
import gov.fnal.elab.analysis.VDSAnalysis;
import gov.fnal.elab.analysis.VDSAnalysisExecutor;
import gov.fnal.elab.datacatalog.CachingDataCatalogProvider;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.datacatalog.impl.vds.VDSDataCatalogProvider;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.usermanagement.impl.DatabaseUserManagementProvider;

public class ElabFactory {
    private static ElabUserManagementProvider userManagementProvider;

    public static synchronized ElabUserManagementProvider getUserManagementProvider(
            Elab elab) {
        if (userManagementProvider == null) {
            userManagementProvider = new DatabaseUserManagementProvider(elab);
        }
        return userManagementProvider;
    }

    private static DataCatalogProvider dataCatalogProvider;

    public static synchronized DataCatalogProvider getDataCatalogProvider(
            Elab elab) {
        if (dataCatalogProvider == null) {
            setVDSHome(elab);
            dataCatalogProvider = new CachingDataCatalogProvider(
                    new VDSDataCatalogProvider());
        }
        return dataCatalogProvider;
    }
    
    private static AnalysisExecutor analysisExecutor;

    public static synchronized AnalysisExecutor getAnalysisProvider(Elab elab) {
        if (analysisExecutor == null) {
            setVDSHome(elab);
            analysisExecutor = new VDSAnalysisExecutor();
        }
        return analysisExecutor;
    }

    public static ElabAnalysis newElabAnalysis(Elab elab, String impl,
            String param) throws ElabInstantiationException {
        if (impl == null) {
            impl = elab.getProperties().getProperty("elab.analysis.type",
                    "vds-dynamic");
        }
        try {
            setVDSHome(elab);
            if ("vds-dynamic".equals(impl)) {
                return new VDSAnalysis();
            }
            else if ("vds-bean".equals(impl)) {
                BeanWrapper bw = new BeanWrapper();
                bw.setBeanClass(param);
                return bw;
            }
            else {
                throw new ElabInstantiationException("Invalid analysis type: "
                        + impl);
            }
        }
        catch (Exception e) {
            throw new ElabInstantiationException("Cannot instantiate analysis "
                    + impl + " with param " + param, e);
        }
    }

    private static void setVDSHome(Elab elab) {
        System.setProperty("vds.home", elab.getProperties().getProperty(
                "vds.home"));
    }
}
