package gov.fnal.elab.datacatalog.impl.vds;

import gov.fnal.elab.datacatalog.Tuple;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.MultiQueryElement;
import gov.fnal.elab.datacatalog.query.NestedQueryElement;
import gov.fnal.elab.datacatalog.query.QueryElement;
import gov.fnal.elab.datacatalog.query.QueryLeaf;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;

import java.sql.SQLException;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.WeakHashMap;

import org.apache.commons.lang.time.DateFormatUtils;
import org.griphyn.vdl.annotation.Predicate;
import org.griphyn.vdl.annotation.QueryTree;
import org.griphyn.vdl.annotation.TupleBoolean;
import org.griphyn.vdl.annotation.TupleDate;
import org.griphyn.vdl.annotation.TupleFloat;
import org.griphyn.vdl.annotation.TupleInteger;
import org.griphyn.vdl.annotation.TupleString;
import org.griphyn.vdl.dbschema.Annotation;
import org.griphyn.vdl.dbschema.AnnotationSchema;
import org.griphyn.vdl.dbschema.DatabaseSchema;
import org.griphyn.vdl.directive.Connect;
import org.griphyn.vdl.util.ChimeraProperties;

public abstract class VDSCatalogProvider {
	
	protected static String DATEFORMAT = "yyyy-MM-dd HH:mm:ssZ";
    protected WeakHashMap<String, VDSCatalogEntry> entryCache;
    
    public VDSCatalogProvider() {
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
    
    protected QueryTree printQT(QueryTree tree) {
        StringBuffer sb = new StringBuffer();
        print(tree, sb);
        System.out.println(sb.toString());
        return tree;
    }

    protected void print(QueryTree tree, StringBuffer sb) {
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
    
    protected synchronized VDSCatalogEntry getCachedEntry(
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

    protected synchronized void deleteCachedEntry(CatalogEntry e) {
        entryCache.remove(e.getLFN());
    }

    protected synchronized void deleteCachedEntry(String lfn) {
        entryCache.remove(lfn);
    }
    
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
}
