//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 14, 2007
 */
package gov.fnal.elab.datacatalog.impl.vds;

import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.impl.vds.VDSAnalysis;
import gov.fnal.elab.analysis.impl.vds.VDSAnalysisExecutor;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.datacatalog.DataTools;
import gov.fnal.elab.datacatalog.Tuple;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.MultiQueryElement;
import gov.fnal.elab.datacatalog.query.NestedQueryElement;
import gov.fnal.elab.datacatalog.query.QueryElement;
import gov.fnal.elab.datacatalog.query.QueryLeaf;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.vds.ElabTransformation;

import java.io.StringReader;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.WeakHashMap;

import org.apache.commons.lang.time.DateFormatUtils;

import org.griphyn.vdl.annotation.Predicate;
import org.griphyn.vdl.annotation.QueryParser;
import org.griphyn.vdl.annotation.QueryTree;
import org.griphyn.vdl.annotation.TupleBoolean;
import org.griphyn.vdl.annotation.TupleDate;
import org.griphyn.vdl.annotation.TupleFloat;
import org.griphyn.vdl.annotation.TupleInteger;
import org.griphyn.vdl.annotation.TupleString;
import org.griphyn.vdl.classes.Derivation;
import org.griphyn.vdl.classes.Leaf;
import org.griphyn.vdl.classes.Pass;
import org.griphyn.vdl.classes.Scalar;
import org.griphyn.vdl.classes.Text;
import org.griphyn.vdl.classes.Value;
import org.griphyn.vdl.dbschema.Annotation;
import org.griphyn.vdl.dbschema.AnnotationSchema;
import org.griphyn.vdl.dbschema.DatabaseSchema;
import org.griphyn.vdl.directive.Connect;
import org.griphyn.vdl.util.ChimeraProperties;


public class VDSDataCatalogProvider extends VDSCatalogProvider implements DataCatalogProvider {

    public VDSDataCatalogProvider() {
        super(); 
    }

    public ResultSet runQuery(QueryElement query) throws ElabException {
        return runQuery(printQT(buildQueryTree(query)));
    }
    
    public ResultSet runQueryNoMetadata(QueryElement query) throws ElabException {
        return runQueryNoMetadata(buildQueryTree(query));
    }

    public ResultSet runQuery(String query) throws ElabException {
        try {
            return runQuery(new QueryParser(new StringReader(query)).parse());
        }
        catch (Exception e) {
            throw new ElabException("Failed to parse query (" + query + ")", e);
        }
    }

    public ResultSet runQuery(QueryTree tree) throws ElabException {
        DatabaseSchema dbschema = openSchema();
        Annotation annotation = (Annotation) dbschema;

        // Connect to the database.
        long start = System.currentTimeMillis();
        try {
            AnnotationSchema annotationschema = null;
            List<String> lfns = ((AnnotationSchema) annotation).searchAnnotationSafe(Annotation.CLASS_FILENAME,
                    null, tree);
            if (lfns == null || lfns.isEmpty()) {
                return ResultSet.EMPTY_RESULT_SET;
            }
            else {
                ResultSet rs = new ResultSet();
                annotationschema = (AnnotationSchema) annotation;
                for (String lfn : lfns) {
                	VDSCatalogEntry e = getCachedEntry(annotationschema, lfn);
                	rs.add(e);
                }
                System.out.println("Entry cache size: " + entryCache.size());
                return rs;
            }

        }
        catch (Exception e) {
            throw new ElabException(
                    e.toString() + " getting LFNs and metadata", e);
        }
        finally {
            closeSchema(dbschema);
            System.out.println("Raw query time: "
                    + (System.currentTimeMillis() - start) + " ms");
        }
    }
    
    public ResultSet runQueryNoMetadata(QueryTree tree) throws ElabException {
        DatabaseSchema dbschema = openSchema();
        Annotation annotation = (Annotation) dbschema;

        // Connect to the database.
        long start = System.currentTimeMillis();
        try {
            AnnotationSchema annotationschema = null;
            List<String> lfns = ((AnnotationSchema) annotation).searchAnnotationSafe(Annotation.CLASS_FILENAME,
                    null, tree);
            if (lfns == null || lfns.isEmpty()) {
                return ResultSet.EMPTY_RESULT_SET;
            }
            else {
                ResultSet rs = new ResultSet();
                annotationschema = (AnnotationSchema) annotation;
                for (String lfn : lfns) {
                    VDSCatalogEntry e = new VDSCatalogEntry();
                    e.setLFN(lfn);
                    rs.addEntry(e);
                }
                System.out.println("Entry cache size: " + entryCache.size());
                return rs;
            }

        }
        catch (Exception e) {
            throw new ElabException(
                    e.toString() + " getting LFNs and metadata", e);
        }
        finally {
            closeSchema(dbschema);
            System.out.println("Raw query time: "
                    + (System.currentTimeMillis() - start) + " ms");
        }
    }

    public ResultSet getEntries(String[] lfns) throws ElabException {
        return getEntries(Arrays.asList(lfns));
    }


    public void delete(String lfn) throws ElabException {
        delete(getEntry(lfn));
    }

    public void delete(CatalogEntry entry) throws ElabException {
        int kind = Annotation.CLASS_FILENAME; // searching on lfn's

        DatabaseSchema dbschema = openSchema();
        Annotation annotation = (Annotation) dbschema;
        try {
            AnnotationSchema annotationschema = (AnnotationSchema) annotation;
            
            for (String s : entry.getTupleMap().keySet()) {
            	annotationschema.deleteAnnotation(entry.getLFN(), null, kind, s);
            }
            
            deleteCachedEntry(entry);
        }
        catch (Exception e) {
            throw new ElabException(
                    e.toString() + " getting LFNs and metadata", e);
        }
        finally {
            closeSchema(dbschema);
        }
    }

    protected QueryTree buildQueryTree(Iterator<QueryElement> i, QueryElement.TYPES type) {
        QueryElement qe = i.next();
        if (i.hasNext()) {
            QueryTree qt = new QueryTree(new Predicate(getPredicateType(type)));
            qt.setLchild(buildQueryTree(qe));
            qt.setRchild(buildQueryTree(i, type));
            return qt;
        }
        else {
            return buildQueryTree(qe);
        }
    }

    public int getUniqueCategoryCount(String key) throws ElabException {
        DatabaseSchema dbschema = openSchema();
        // Connect to the database.
        try {
            AnnotationSchema annotationschema = null;

            annotationschema = (AnnotationSchema) dbschema;
            java.sql.ResultSet rs;
            
            String query;
            if (key == null || key.equals("split")) {
                query = "SELECT COUNT(*) FROM anno_text WHERE value = 'split'";
            }
            else {
                query = "select count(distinct value) from anno_text where id in (select id from anno_lfn where mkey='"
                    + ElabUtil.fixQuotes(key) + "')";
            }
            System.out.println(query);
            rs = annotationschema.backdoor(query);

            if (rs.next()) {
                String r = rs.getString(1);
                try {
                    return Integer.parseInt(r);
                }
                catch (NumberFormatException e) {
                    throw new ElabException(
                            "Invalid category count returned by the VDC: " + r);
                }
            }
            else {
                return -1;
            }
        }
        catch (Exception e) {
            throw new ElabException("DB threw exception", e);
        }
        finally {
            closeSchema(dbschema);
        }
    }

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
