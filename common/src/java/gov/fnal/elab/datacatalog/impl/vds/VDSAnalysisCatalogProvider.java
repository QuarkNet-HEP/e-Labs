package gov.fnal.elab.datacatalog.impl.vds;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.Map.Entry;

import org.griphyn.vdl.classes.Derivation;
import org.griphyn.vdl.classes.Leaf;
import org.griphyn.vdl.classes.Pass;
import org.griphyn.vdl.classes.Scalar;
import org.griphyn.vdl.classes.Text;
import org.griphyn.vdl.classes.Value;

import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.impl.vds.VDSAnalysis;
import gov.fnal.elab.analysis.impl.vds.VDSAnalysisExecutor;
import gov.fnal.elab.datacatalog.AnalysisCatalogProvider;
import gov.fnal.elab.datacatalog.DataTools;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.vds.ElabTransformation;

public class VDSAnalysisCatalogProvider extends VDSCatalogProvider implements AnalysisCatalogProvider {

	public void insertAnalysis(String name, ElabAnalysis analysis)
            throws ElabException {
        ElabTransformation et = VDSAnalysisExecutor.createTransformation(name,
                analysis);
        et.storeDV();
        et.close();
        List<String> metadata = new ArrayList<String>();
        Iterator<Entry<String, Object>> i = analysis.getAttributes().entrySet().iterator();
        while (i.hasNext()) {
        	Entry<String, Object> e = i.next();
        	if (e.getValue() instanceof String) {
        		metadata.add(e.getKey() + " string " + e.getValue());
        	}
        	else if (e.getValue() instanceof Integer) {
                metadata.add(e.getKey() + " int " + e.getValue());
            }
        	else if (e.getValue() instanceof Double) {
                metadata.add(e.getKey() + " float " + e.getValue());
            }
        	else if (e.getValue() instanceof Date) {
                metadata.add(e.getKey() + " date " + ((Date) e.getValue()).getTime());
            }
        }
        insert(DataTools.buildCatalogEntry(name, metadata));
    }

    public ElabAnalysis getAnalysis(String lfn) throws ElabException {
        try {
            ElabTransformation et = new ElabTransformation();
            et.loadDV(lfn);
            Derivation dv = et.getDV();

            List<Pass> l = dv.getPassList();
            Iterator<Pass> i = l.iterator();
            while (i.hasNext()) {
                Pass p = i.next();
                Value v = p.getValue();
                if (v.getContainerType() == Value.SCALAR) {
                    Scalar d = new Scalar();
                    Scalar s = (Scalar) v;
                    
                    for (ListIterator<Leaf> li = s.listIterateLeaf(); li.hasNext(); ) {
                    	Leaf leaf = li.next();
                    	if (leaf instanceof Text) {
                    		String content = ((Text) leaf).getContent();
                            if (content != null) {
                                d.addLeaf(new Text(content.replaceAll("\\\\n",
                                        "\n")));
                            }
                            else {
                                d.addLeaf(new Text());
                            }
                        }
                    	else {
                            d.addLeaf(leaf);
                        }
                    }
                    dv.setPass(new Pass(p.getBind(), d));
                }
            }
            
            VDSAnalysis analysis = new VDSAnalysis();
            analysis.setType(dv.getUsesspace() + "::" + dv.getUses(), et
                    .getDV());
            
            CatalogEntry e = getEntry(lfn);
            if (e != null) {
            	for (Entry<String, Object> me : e.getTupleMap().entrySet()) {
            		analysis.setAttribute(me.getKey(), me.getValue());
            	}
            }
            return analysis;
        }
        catch (Exception e) {
            throw new ElabException("Failed to retrieve stored analysis", e);
        }
    }

}
