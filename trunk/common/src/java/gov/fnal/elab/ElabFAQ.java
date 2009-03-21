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

/**
 * Implements an FAQ for an elab. The FAQ queries the data catalog provider for
 * entries of type 'FAQ' and the current elab project name and retrieves the
 * 'description' metadata entry for each one of them.
 * 
 */
public class ElabFAQ {
    private Elab elab;

    public ElabFAQ(Elab elab) {
        this.elab = elab;
    }

    /**
     * Returns a list of strings with all the FAQs. Each item seems to be a
     * complete FAQ entry (of type <code>java.lang.String</code>), with both
     * the question and the answer.
     * 
     * @throws ElabException
     */
    public Collection entries() throws ElabException {
        ArrayList list = new ArrayList();

        And q = new And();
        q.add(new Equals("type", "FAQ"));
        q.add(new Equals("project", elab.getName()));
        
        DataCatalogProvider p;
        try {
            p = ElabFactory.getDataCatalogProvider(elab);
        }
        catch (ElabInstantiationException e) {
            throw new ElabException(e);
        }
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
