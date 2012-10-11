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

public class VDSDataCatalogProvider implements DataCatalogProvider {
    private WeakHashMap<String, VDSCatalogEntry> entryCache;

    public VDSDataCatalogProvider() {
        entryCache = new WeakHashMap<String, VDSCatalogEntry>();
    }

    protected DatabaseSchema openSchema() throws ElabException {
        // Connect to the database.
        DatabaseSchema dbschema;
        try {
            String schemaName = ChimeraProperties.instance().getVDCSchemaName();

            Connect connect = new Connect();
            dbschema = connect.connectDatabase(schemaName);

            if (!(dbschema instanceof Annotation)) {
                throw new ElabException(
                        "The database does not support metadata!");
            }
        }
        catch (Exception e) {
            throw new ElabException(e.getMessage()
                    + " getting LFNs and metadata", e);
        }
        return dbschema;
    }

    protected void closeSchema(DatabaseSchema dbschema) throws ElabException {
        try {
            dbschema.close();
        }
        catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }

    public ResultSet runQuery(QueryElement query) throws ElabException {
        return runQuery(printQT(buildQueryTree(query)));
    }
    
    public ResultSet runQueryNoMetadata(QueryElement query) throws ElabException {
        return runQueryNoMetadata(buildQueryTree(query));
    }

    private QueryTree printQT(QueryTree tree) {
        StringBuffer sb = new StringBuffer();
        print(tree, sb);
        System.out.println(sb.toString());
        return tree;
    }

    private void print(QueryTree tree, StringBuffer sb) {
        Predicate p = (Predicate) tree.getData();
        sb.append(Predicate.PREDICATE_STRING[p.getPredicate()]);
        if (p.getKey() != null) {
            sb.append('*');
        }
        sb.append('(');
        if (p.getKey() != null) {
            sb.append(p.getKey());
            sb.append(", ");
            sb.append(p.getValue());
        }
        else {
            print(tree.getLchild(), sb);
            sb.append(", ");
            print(tree.getRchild(), sb);
        }
        sb.append(')');
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

    private synchronized VDSCatalogEntry getCachedEntry(
            AnnotationSchema annotationschema, String lfn)
            throws IllegalArgumentException, SQLException {
        VDSCatalogEntry e = entryCache.get(lfn);
        if (e == null) {
            List<org.griphyn.vdl.annotation.Tuple> metaTuples = annotationschema.loadAnnotation(lfn, null,
                    Annotation.CLASS_FILENAME);
            e = new VDSCatalogEntry();
            e.setLFN(lfn);
            e.setTuples(metaTuples);
            entryCache.put(lfn, e);
        }
        return e;
    }

    private synchronized void deleteCachedEntry(CatalogEntry e) {
        entryCache.remove(e.getLFN());
    }

    private synchronized void deleteCachedEntry(String lfn) {
        entryCache.remove(lfn);
    }

    public CatalogEntry getEntry(String lfn) throws ElabException {
        deleteCachedEntry(lfn);
        ResultSet rs = getEntries(Collections.singletonList(lfn));
        if (rs.isEmpty()) {
            return null;
        }
        else {
            CatalogEntry e = (CatalogEntry) rs.iterator().next();
            if (e.getTupleMap().isEmpty()) {
                return null;
            }
            else {
                return e;
            }
        }
    }

    public ResultSet getEntries(String[] lfns) throws ElabException {
        return getEntries(Arrays.asList(lfns));
    }

    public ResultSet getEntries(Collection<String> lfns) throws ElabException {
        if (lfns == null) {
            return new ResultSet();
        }

        int kind = Annotation.CLASS_FILENAME; // searching on lfn's

        DatabaseSchema dbschema = openSchema();
        Annotation annotation = (Annotation) dbschema;
        try {
            AnnotationSchema annotationschema = null;

            ResultSet rs = new ResultSet();
            annotationschema = (AnnotationSchema) annotation;
            Iterator<String> i = lfns.iterator();
            while (i.hasNext()) {
                String lfn = i.next();
                VDSCatalogEntry e = getCachedEntry(annotationschema, lfn);
                rs.addEntry(e);
            }
            return rs;
        }
        catch (Exception e) {
            throw new ElabException(
                    e.toString() + " getting LFNs and metadata", e);
        }
        finally {
            closeSchema(dbschema);
        }
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

    protected QueryTree buildQueryTree(QueryElement query) {
        if (query == null) {
            return null;
        }
        /*
         * So the QueryTree in VDS makes sense. Not sure whether that should be
         * reinvented. On the other hand, constraining all queries to a tree,
         * even when AND can be seen as a multivalued operator makes it kinda
         * weird.
         */
        QueryTree qt;
    	if (query instanceof MultiQueryElement) {
            MultiQueryElement meq = (MultiQueryElement) query;
            Collection<QueryElement> c = meq.getAll();
            if (c.size() < 1) {
                throw new IllegalArgumentException(
                        "Non-leaf operator with zero elements");
            }
            Iterator<QueryElement> i = c.iterator();
            QueryElement qe = i.next();
            if (i.hasNext()) {
                qt = new QueryTree(new Predicate(getPredicateType(query
                        .getType())));
                qt.setLchild(buildQueryTree(qe));
                qt.setRchild(buildQueryTree(i, meq.getType()));
            }
            else {
                qt = buildQueryTree(qe);
            }
    	}
    	else if (query instanceof NestedQueryElement) {        		
    		NestedQueryElement nqe = (NestedQueryElement) query;
    		QueryLeaf root = nqe.getRoot(); // Root of a NQE has values like leaves 
    		QueryElement child = nqe.getChild(); 
    		qt = new QueryTree(new Predicate(getPredicateType(nqe.getType()), 
    				root.getKey(), getType(root.getType()), format(root.getValue1()), format(root.getValue2())));
    		qt.setRchild(buildQueryTree(child));
    	}
        else {
            QueryLeaf t = (QueryLeaf) query;
            qt = new QueryTree(new Predicate(getPredicateType(query.getType()),
                    t.getKey(), getType(t.getValue()), format(t.getValue1()), format(t.getValue2())));
        }
        return qt;
    }
    
    private static String DATEFORMAT = "yyyy-MM-dd HH:mm:ssZ";
    
    /**
     * Private helper function to convert proper objects into string representations
     * since @org.griphyn.vdl.annotation.Predicate only stores strings (not objects) 
     * 
     * @deprecated QueryLeaf nodes may have 1-2 values; this is a legacy function that
     * assumes only one value. 
     * 
     * @param t
     * @return
     */
    @Deprecated private String format(QueryLeaf t) {
        return format(t.getValue());
    }
    
    /**
     * Private helper function to convert proper objects into string representations since {@link #Predicate} only stores strings (not objects) 
     * 
     * @param o
     * @return
     */
    private String format(Object o) {
    	if (o == null) {
    		return null; 
    	}
    	if (o instanceof Date) {
    		return DateFormatUtils.format((Date) o, DATEFORMAT);
    	}
    	else {
    		return String.valueOf(o);
    	}
    }

    /**
     * Helper functions to escape quotes in SQL input. 
     * 
     * @deprecated Escaping quotes does not protect SQL input, use {@link java.sql.PreparedStatement} instead 
     * @param param String with unescaped quotes
     * @return String with escaped quotes 
     */
    @Deprecated public static String quote(String param) {
        return ElabUtil.fixQuotes(param);
    }

    protected int getType(Object value) {
        if (value instanceof String) {
            return Predicate.TYPE_STRING;
        }
        else if (value instanceof Date) {
            return Predicate.TYPE_DATE;
        }
        else if (value instanceof Double || value instanceof Float) {
            return Predicate.TYPE_FLOAT;
        }
        else if (value instanceof Integer || value instanceof Long) {
            return Predicate.TYPE_INT;
        }
        else if (value instanceof Boolean) {
            return Predicate.TYPE_BOOL;
        }
        else {
            return Predicate.TYPE_STRING;
        }
    }

    protected int getPredicateType(QueryElement.TYPES type) {
        switch (type) {
            case AND:
                return Predicate.AND;
            case OR:
                return Predicate.OR;
            case EQ:
                return Predicate.EQ;
            case LT:
                return Predicate.LT;
            case GT:
                return Predicate.GT;
            case LE:
                return Predicate.LE;
            case GE:
                return Predicate.GE;
            case BETWEEN:
                return Predicate.BETWEEN;
            case LIKE:
                return Predicate.LIKE;
            case ILIKE:
            	return Predicate.ILIKE;
            case IN:
            	return Predicate.IN;
            case NOT:
            	return Predicate.NOT;
            default:
                throw new IllegalArgumentException(
                        "Unknown QueryElement type: " + type);
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

    public void insert(CatalogEntry entry) throws ElabException {
        int kind = Annotation.CLASS_FILENAME; // searching on lfn's

        deleteCachedEntry(entry);
        DatabaseSchema dbschema = openSchema();
        AnnotationSchema annotationschema = (AnnotationSchema) dbschema;

        // Connect to the database.
        try {
            Iterator<Tuple> i = entry.tupleIterator();
            while (i.hasNext()) {
                Tuple t = i.next();
                String key = t.getKey();
                Object val = t.getValue();
                org.griphyn.vdl.annotation.Tuple vt;
                if (val instanceof String) {
                    vt = new TupleString(key, (String) val);
                }
                else if (val instanceof Integer || val instanceof Long) {
                    vt = new TupleInteger(key, ((Number) val).longValue());
                }
                else if (val instanceof Float || val instanceof Double) {
                    vt = new TupleFloat(key, ((Number) val).doubleValue());
                }
                else if (val instanceof Boolean) {
                    vt = new TupleBoolean(key, Boolean.TRUE.equals(val));
                }
                else if (val instanceof Date) {
                    vt = new TupleDate(key, (Date) val);
                }
                else if (val != null) {
                    throw new ElabException(
                            "Unknown annotation value type for key '" + key
                                    + "': " + val.getClass());
                }
                else {
                    throw new IllegalArgumentException("Value for key '" + key
                            + "' is null");
                }
                annotationschema.saveAnnotation(entry.getLFN(), null,
                        Annotation.CLASS_FILENAME, vt, true);
                // annotationschema.saveAnnotationFilename(entry.getLFN(), vt,
                // true);
            }
        }
        catch (ElabException e) {
            throw e;
        }
        catch (Exception e) {
            throw new ElabException(e.toString() + " setting metadata", e);
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
