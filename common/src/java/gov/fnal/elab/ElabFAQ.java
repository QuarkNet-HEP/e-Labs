/*
 * Created on Mar 12, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.datacatalog.query.And;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.Equals;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

public class ElabFAQ {
    private Elab elab;

    public ElabFAQ(Elab elab) {
        this.elab = elab;
    }

    /**
     * Returns a list of strings with all the FAQs. Each item seems to be a complete
     * FAQ entry, with both the question and the answer.
     * @throws ElabException 
     */
    public Collection entries() throws ElabException {
        ArrayList list = new ArrayList();
        
        And q = new And();
        q.add(new Equals("type", "FAQ"));
        q.add(new Equals("project", elab.getName()));
        
        DataCatalogProvider p = ElabFactory.getDataCatalogProvider(elab);
        ResultSet rs = p.runQuery(q);
        
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            String desc = (String) e.getTupleValue("description");
            list.add(desc);
        }
        
        return list;
    }
}
