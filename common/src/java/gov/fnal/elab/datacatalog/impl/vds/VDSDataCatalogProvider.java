//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 14, 2007
 */
package gov.fnal.elab.datacatalog.impl.vds;

import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.datacatalog.ResultSet;
import gov.fnal.elab.datacatalog.SimpleQuery;
import gov.fnal.elab.datacatalog.Tuple;
import gov.fnal.elab.util.ElabException;

import java.util.Iterator;
import java.util.List;

import org.griphyn.vdl.annotation.Predicate;
import org.griphyn.vdl.annotation.QueryTree;
import org.griphyn.vdl.dbschema.Annotation;
import org.griphyn.vdl.dbschema.AnnotationSchema;
import org.griphyn.vdl.dbschema.DatabaseSchema;
import org.griphyn.vdl.directive.Connect;
import org.griphyn.vdl.util.ChimeraProperties;

public class VDSDataCatalogProvider implements DataCatalogProvider {

    public ResultSet runQuery(SimpleQuery query) throws ElabException {
        int kind = Annotation.CLASS_FILENAME; // searching on lfn's
        DatabaseSchema dbschema = null;

        // Connect to the database.
        try {
            String schemaName = ChimeraProperties.instance().getVDCSchemaName();

            Connect connect = new Connect();
            dbschema = connect.connectDatabase(schemaName);

            if (!(dbschema instanceof Annotation)) {
                throw new ElabException(
                        "The database does not support metadata!");
            }
            else {
                Annotation annotation = null;
                AnnotationSchema annotationschema = null;
                try {
                    annotation = (Annotation) dbschema;
                    QueryTree tree = buildQueryTree(query);
                    List lfns = annotation.searchAnnotation(kind, null, tree);
                    if (lfns == null || lfns.isEmpty()) {
                        return ResultSet.EMPTY_RESULT_SET;
                    }
                    else {
                        ResultSet rs = new ResultSet();
                        annotationschema = (AnnotationSchema) dbschema;
                        for (Iterator i = lfns.iterator(); i.hasNext();) {
                            String lfn = (String) i.next();
                            List metaTuples = annotationschema.loadAnnotation(lfn,
                                    null, kind);

                            VDSCatalogEntry e = new VDSCatalogEntry();
                            e.setLFN(lfn);
                            e.setTuples(metaTuples);
                            rs.addEntry(e);
                        }
                        return rs;
                    }
                }
                catch (Exception e) {
                    throw new ElabException("Error searching metadata", e);
                }
                finally {
                    try {
                        if (annotation != null) {
                            ((DatabaseSchema) annotation).close();
                        }
                    }
                    catch (Exception ex) {
                        throw new ElabException("closing annotation schema", ex);
                    }

                    try {
                        if (annotationschema != null) {
                            annotationschema.close();
                        }
                    }
                    catch (Exception exc) {
                        throw new ElabException("closing annotation schema",
                                exc);
                    }
                }
            }
        }
        catch (Exception e) {
            throw new ElabException(e.getMessage() + " getting LFNs and metadata", e);
        }
        finally {
            try {
                if (dbschema != null) {
                    dbschema.close();
                }
            }
            catch (Exception ex) {
                throw new ElabException("closing dbschema", ex);
            }
        }
    }
    
    protected QueryTree buildQueryTree(SimpleQuery query) {
        if (query == null) {
            return null;
        }
        /* 
         * So the QueryTree in VDS makes sense. Not sure whether that should be
         * reinvented.
         */
        QueryTree last = null;
        Iterator i = query.getConstraints().iterator();
        while (i.hasNext()) {
            Tuple t = (Tuple) i.next();
            QueryTree node = new QueryTree(new Predicate(Predicate.EQ, t.getKey(), t.getValue()));
            if (last == null) {
                last = node;
            }
            else {
                QueryTree crt = new QueryTree(new Predicate(Predicate.AND));
                crt.setLchild(last);
                crt.setRchild(node);
                last = crt;
            }
        }
        return last;
    }
}
