/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog;


public abstract class CatalogEntry {
    private String lfn;

    public abstract Object getTupleValue(String key);

    public void setLFN(String lfn) {
        this.lfn = lfn;
    }
    
    public String getLFN() {
        return this.lfn;
    }
}
