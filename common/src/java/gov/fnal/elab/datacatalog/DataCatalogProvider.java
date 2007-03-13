/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog;

public interface DataCatalogProvider {
    ResultSet runQuery(Query query);
}
