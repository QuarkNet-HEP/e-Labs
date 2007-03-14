/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.util.ElabException;

public interface DataCatalogProvider {
    ResultSet runQuery(SimpleQuery query) throws ElabException;
}
