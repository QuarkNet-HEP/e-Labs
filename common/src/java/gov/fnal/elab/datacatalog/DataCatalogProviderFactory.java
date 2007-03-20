/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.ElabProperties;
import gov.fnal.elab.datacatalog.impl.vds.VDSDataCatalogProvider;

public class DataCatalogProviderFactory {
    public static DataCatalogProvider getDefault(ElabProperties properties) {
    	System.setProperty("vds.home", properties.getProperty("vds.home"));
        return new VDSDataCatalogProvider();
    }
}
