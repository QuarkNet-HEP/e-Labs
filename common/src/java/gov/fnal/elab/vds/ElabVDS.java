package gov.fnal.elab.vds;

import java.io.*;
import java.util.*;
import org.griphyn.common.catalog.ReplicaCatalog;
import org.griphyn.common.catalog.replica.ReplicaFactory;
import org.griphyn.vdl.util.ChimeraProperties;
import org.griphyn.vdl.util.*;
import org.griphyn.vdl.classes.*;
import org.griphyn.vdl.directive.*;
import org.griphyn.vdl.annotation.*;
import org.griphyn.vdl.dbschema.*;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import gov.fnal.elab.util.ElabException;

/**
 * Helper and wrapper functions for common VDS functions useful for elab
 * pages.
 */
public class ElabVDS {

    private static DatabaseSchema dbschema = null;
    private static String schemaName = null;
    private static Connect connect = null;
    private static AnnotationSchema annotationschema = null;
    private static Annotation annotation = null;

    /*
     * Open a connection to the VDS database.
     * @see ChimeraProperties
     * @see Connect#connectDatabase
     */
    private static void dbConnect() throws ElabException{
        try{
            schemaName = ChimeraProperties.instance().getVDCSchemaName();
            connect = new Connect();
            dbschema = connect.connectDatabase(schemaName);

            if (! (dbschema instanceof Annotation)) {
                dbDisconnect();
                throw new ElabException("The database does not support metadata!");
            }
        } catch(Exception e){
            dbDisconnect();
            throw new ElabException("While connecting to the VDS:" + e);
        }
    }

    /*
     * Close the open connection to the VDS database.
     * @see AnnotationSchema#close
     * @see DatabaseSchema#close
     */
    private static void dbDisconnect() throws ElabException{
        try {
            if (annotationschema != null)
                annotationschema.close();
            if (dbschema != null)
                dbschema.close();
        } catch (Exception e) {
            throw new ElabException("While closing the VDS connection:" + e);
        }
    } 

    /**
     * Return the fully qualified filename from a logical filename
     *
     * @param  lfn     logical filename
     * @return         the fully qualified physical filename on the system
     * @see Catalog#lookup
     */
    public static String getPFN(String lfn) throws ElabException{
        String pfn = null;
        try {
            ChimeraProperties props = ChimeraProperties.instance();
            String rcName =  props.getRCLocation();
            ReplicaCatalog rc = ReplicaFactory.loadInstance();
            pfn = rc.lookup(lfn,"local");
        }
        catch (Exception e) {
            throw new ElabException("While looking up: " + lfn + " " + e.getMessage());
        } 

        return pfn;
    }

    /**
     * Set metadata for a filename already in the VDC
     *
     * @param  filename    filename we're setting metadata for
     * @param  meta        key/type/value tripples each separated by a space
     * @see AnnotationSchema#saveAnnotation
     */
    public static void setMeta(String filename, Collection meta) throws ElabException{

        dbConnect();

        try{
            /*
             * Set the metadata in the VDC
             */
            annotationschema = (AnnotationSchema)dbschema;
            for(Iterator i=meta.iterator(); i.hasNext(); ){
                String[] line = ((String)i.next()).split("\\s", 3);

                if(line.length < 3){
                    //invalid format
                    continue;
                }

                String key=line[0];
                String type=line[1];
                String value=line[2];
                Tuple tuple = null;
                if (type.equalsIgnoreCase("int") || type.equalsIgnoreCase("i")){
                    tuple = new TupleInteger(key, 0); 
                }
                if (type.equalsIgnoreCase("float") || type.equalsIgnoreCase("f")){
                    tuple = new TupleFloat(key, 0); 
                }
                if (type.equalsIgnoreCase("bool") ||type.equalsIgnoreCase("boolean") ||type.equalsIgnoreCase("b") ){
                    tuple = new TupleBoolean(key, false); 
                }
                if (type.equalsIgnoreCase("string") || type.equalsIgnoreCase("s")){
                    tuple = new TupleString(key, null); 
                }
                if (type.equalsIgnoreCase("date") || type.equalsIgnoreCase("d")){
                    tuple = new TupleDate(key, 0);
                }
                if (tuple != null) {
                    if ( tuple instanceof TupleBoolean ){
                        tuple.setValue(Boolean.valueOf(value));
                    }
                    else{
                        tuple.setValue(value);
                    }
                    annotationschema.saveAnnotation(filename, null, Annotation.CLASS_FILENAME, tuple, true);
                }
            }
        }
        catch (Exception e) {
            throw new ElabException("Error writing metadata: " + e.getMessage());
        } finally {
            dbDisconnect();
        } 
    }


    /**
     * Add an entry for a filename into the RC Catalog
     *
     * @param  lfn         logical filename
     * @param  pfn         fully qualified physical filename
     * @return             <code>true</code> if the entry was added without error
     *                     <code>false</code> if the entry already exists in the Catalog.
     * @see Catalog#addEntry
     */
    public static boolean addRC(String lfn, String pfn) throws ElabException{
        String pool = "local";
        try {
            ChimeraProperties props = ChimeraProperties.instance();	
            String rcName =  props.getRCLocation();

            // read rc contents into memory
            ReplicaCatalog rc = ReplicaFactory.loadInstance();
            int c = rc.insert(lfn, pfn, pool);

            if (c==1)
                return true;
            else
                return false;
        }
        catch (Exception e) {
            throw new ElabException(e.getMessage());
        } 
    }

    /**
     * Delete any annotation information associated with a logical filename. Also
     * deletes any of the following if it's within the metadata: dvname, 
     * provinance, rawanalyze, thumbnail.
     *
     * @param  lfn         logical filename to delete
     * @return             <code>true</code> if the metadata was deleted without error
     *                     <code>false</code> otherwise.
     * @see Annotation#loadAnnotation(String, Object, int)
     * @see Annotation#deleteAnnotationFilename
     * @see Delete#deleteDefinition(String, String, String, int)
     */
    public static boolean deleteLFNMeta(String lfn) throws ElabException{
        String primary = lfn;
        String secondary = null;
        int kind = Annotation.CLASS_FILENAME;
        boolean allModified = false;               //true if the database was successfully modified


        /*
         * Connect to the database
         */
        dbConnect();

        try{
            /*
             * Delete annotations for the file in the VDC
             */
            annotationschema = (AnnotationSchema)dbschema;
            java.util.List metaTuples = annotationschema.loadAnnotation(lfn, null, kind);

            boolean currModified = true;
            boolean setAllModified = false;
            if(metaTuples.iterator().hasNext()){
                setAllModified = true;  //if there is at least 1 thing to modify, assume success unless we get a failure
            }
            for(Iterator i=metaTuples.iterator(); i.hasNext(); ){
                Tuple t = (Tuple)i.next();
                String key = t.getKey();

                /* delete DV (if available) */
                if(key.equals("dvname")){
                    String val = (String)t.getValue();
                    Delete del = new Delete(dbschema);
                    //NOTE: assumption of null version and .Users directory in the VDC
                    java.util.List deleted = del.deleteDefinition("Quarknet.Cosmic.Users", val, null, Definition.DERIVATION);
                    if(deleted == null){
                        throw new ElabException("Nothing returned when deleting dv: " + val);
                    }
                }

                /* delete provenance (if available) */
                if(key.equals("provenance")){
                    String val = (String)t.getValue();
                    String pfn = getPFN(val);
                    File f = new File(pfn);

                    //delete physical file
                    if(f.canWrite()){
                        boolean fileDeleted = f.delete();
                    }
                    else{
                        throw new ElabException("Could not delete file: " + pfn + 
                                "...Either it doesn't exists or the system doesn't have " + 
                                "permission to delete it.");
                    }
                }

                /* delete rawanalyze file (if available) */
                if(key.equals("rawanalyze")){
                    String val = (String)t.getValue();
                    String pfn = getPFN(val);
                    File f = new File(pfn);

                    //delete physical file
                    if(f.canWrite()){
                        boolean fileDeleted = f.delete();
                    }
                    else{
                        throw new ElabException("Could not delete file: " + pfn + 
                                "...Either it doesn't exists or the system doesn't have " + 
                                "permission to delete it.");
                    }
                }

                /* delete thumbnail (if available) */
                if(key.equals("thumbnail")){
                    String val = (String)t.getValue();
                    String pfn = getPFN(val);
                    File f = new File(pfn);

                    //delete physical file
                    if(f.canWrite()){
                        boolean fileDeleted = f.delete();
                    }
                    else{
                        throw new ElabException("Could not delete file: " + pfn + 
                                "...Either it doesn't exists or the system doesn't have " + 
                                "permission to delete it.");
                    }
                }

                try{
                    //currModified = annotationschema.deleteAnnotation(primary, secondary, kind, t.getKey());
                    currModified = annotationschema.deleteAnnotationFilename(primary, key);
                }
                catch(Exception e){
                    throw new ElabException("Error while deleting the annotation key: " + t.getKey() + " - " + e);
                }
                if(currModified == false){
                    setAllModified = false;
                }
            }
            allModified = setAllModified;

        } catch(Exception e){
            throw new ElabException("Error while deleting metadata:" + e);
        } finally {
            dbDisconnect();
        } 

        return allModified;
    }

    /**
     * Delete a file from the RC Catalog, any annotation information associated
     * with the file, the DV associated with the file and the physical file on the 
     * system.
     * Also delete files associated via metadata.
     *
     * @param  lfn logical filename to delete
     * @return             <code>true</code> if everything was deleted without error
     *                     <code>false</code> otherwise.
     * @see #deleteLFNMeta
     */
    public static boolean deleteLFN(String lfn) throws ElabException{
        int kind = Annotation.CLASS_FILENAME;
        java.util.List metaTuples = null;       //list of metaTuples for this lfn


        /* delete annotation metadata and DV */
        if(deleteLFNMeta(lfn) == false){
            return false;
        }

        /* delete entry from rc.data */
        //FIXME: entries aren't deleted from the Catalog because it doesn't support it

        /* delete original pfn file */

        String pfn = getPFN(lfn);
        File f = new File(pfn);
        if(f.canWrite()){
            return f.delete();
        }

        return false;
    }

    /**
     * Get the logical filenames associated with an annotaion query
     *
     * @param  query       query string
     * @return             list of logical filenames returned by the query
     *                     null if nothing found
     * @see                Annotation#searchAnnotation
     */
    public static java.util.List getLFNs(String query) throws ElabException{
        int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
        java.util.List lfns = null;     //list of filenames to return

        /*
         * Connect to the database
         */
        dbConnect();

        try{
            /*
             * Search for lfns
             */
            annotation = (AnnotationSchema)dbschema;
            StringReader sr = new StringReader(query);
            QueryParser parser = new QueryParser(sr);
            QueryTree tree = parser.parse(); 
            lfns = ((AnnotationSchema) annotation).searchAnnotationSafe(kind, null, tree);
        } catch (Exception e) {
            throw new ElabException("Error searching metadata..." + e.getMessage());
        } finally {
            dbDisconnect();
        } 

        return lfns;
    }

    /**
     * Get metadata Tuples associated with a filename
     *
     * @param  lfn         logical filename to get metadata for
     * @return             list of every {@link Tuple} associated with this filename
     *                     null if nothing found
     * @see Tuple
     * @see Annotation#loadAnnotation(String, Object, int)
     */
    public static java.util.List getMeta(String lfn) throws ElabException{
        int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
        java.util.List metaTuples = null;     //list of metadata Tuples for this lfn

        /*
         * Connect to the database
         */
        dbConnect();

        try{
            /*
             * Get Tuples
             */
            annotationschema = (AnnotationSchema)dbschema;
            metaTuples = annotationschema.loadAnnotation(lfn, null, kind);

        } catch (Exception e) {
            throw new ElabException("Error searching metadata..." + e.getMessage());
        } finally {
            dbDisconnect();
        } 

        return metaTuples;
    }

    /**
     * Get the metadata Tuple associated with this filename and key
     *
     * @param  lfn         logical filename to get metadata for
     * @param  key         get the Tuple associated with this metadata key
     * @return             the metadata Tuple
     * @see Tuple
     * @see Annotation#loadAnnotation(String, Object, int)
     */
    public static Tuple getMetaKey(String lfn, String key) throws ElabException{
        int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
        Tuple value = null;                     //Tuple of metadata with this key

        /*
         * Connect to the database
         */
        dbConnect();

        try{
            annotationschema = (AnnotationSchema)dbschema;
            value = annotationschema.loadAnnotation(lfn, null, kind, key);
        } catch (Exception e) {
            throw new ElabException("Error on searching metatata..." + e.getMessage());
        } finally {
            dbDisconnect();
        }
        return value;
    }

    /**
     * Return a list of "pairs" where each pair contains an lfn filename 
     * <code>String</code> and a <code>ArrayList</code> of metadata
     * {@link Tuple}s for that lfn.
     *
     * @param  query       query string
     * @return             list of unordered "pairs"
     *                     null if nothing found.
     * @see Tuple
     * @see Annotation#loadAnnotation(String, Object, int)
     */
    public static ArrayList getLFNsAndMeta(String query) throws ElabException{
        int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
        ArrayList pairs = null;     //list of lfn-metadata_Tuple pairs to return
        java.util.List lfns = null;     //list of filenames from this query

        /*
         * Connect to the database
         */
        dbConnect();

        try{
            annotation = (Annotation)dbschema;
            StringReader sr = new StringReader(query);
            QueryParser parser = new QueryParser(sr);
            QueryTree tree = parser.parse(); 
            lfns = ((AnnotationSchema) annotation).searchAnnotationSafe(kind, null, tree);
        } catch (Exception e) {
            throw new ElabException("Error searching annotations. Using query string: " + query + "..." + e);
        } finally {
            dbDisconnect();
        }

        try{
            if (lfns==null || lfns.isEmpty() ) {
                pairs = null;
            }
            else{
                annotationschema = (AnnotationSchema)dbschema;
                pairs = new ArrayList();
                java.util.List metaTuples = null;
                for(Iterator i = lfns.iterator(); i.hasNext(); ){
                    String lfn = (String)i.next();
                    try{
                        metaTuples = annotationschema.loadAnnotationFilename(lfn);
                    } catch(Exception ee){
                        throw new ElabException("While loading annotation for: " + lfn + "..." + ee);
                    }

                    ArrayList currPair = new ArrayList(2);
                    currPair.add(0, lfn);
                    currPair.add(1, metaTuples);
                    pairs.add(currPair);    //add the current lfn-metadata_Tuple to the list of pairs for this query
                }
            }
        } catch (Exception e) {
            throw new ElabException("Error while fetching metadata..." + e);
        } finally {
            dbDisconnect();
        }
        return pairs;
    }

    /**
     * Get a string of the number of files in the database.
     *
     * @return  a String with a custom status message from the database. 
     *     Or an empty string if nothing was found.
     * @see AnnotationSchema#backdoor
     */
    public static String getDBStatusMessage() throws ElabException{
        String status = "";

        /*
         * Connect to the database
         */
        dbConnect();

        /*
         * Query the database
         */
        try{
            annotationschema = (AnnotationSchema)dbschema;
            java.sql.ResultSet rs = annotationschema.backdoor("SELECT COUNT(*) FROM anno_text WHERE value = 'split'");
            if (rs.next())
                status = "Searching " + rs.getString(1) + " data files";
            rs = annotationschema.backdoor(
                    "select count(distinct value) from anno_text where id in (select id from anno_lfn where mkey = 'school')");
            if (rs.next())
                status += " from " + rs.getString(1) + " schools";
            rs = annotationschema.backdoor(
                    "select count(distinct value) from anno_text where id in (select id from anno_lfn where mkey = 'state')");
            if (rs.next())
                status += " in " + rs.getString(1) + " states";
        } catch (Exception e) {
            throw new ElabException("Error searching metadata..." + e.getMessage());
        } finally {
            dbDisconnect();
        }

        return status;
    }
    
    //EPeronja-06/21/2013: 222-Allow Admin user to delete data files but check dependencies
    public static int checkFileDependency(String filename) throws ElabException{
    	int count = 0;
        /*
         * Connect to the database
         */
        dbConnect();

        /*
         * Query the database
         */
        try{
            annotationschema = (AnnotationSchema)dbschema;
            java.sql.ResultSet rs = annotationschema.backdoor("SELECT COUNT(*) FROM anno_lfn_i WHERE name = '"+filename+"'");
            if (rs.next()) {
            	count = rs.getInt(1);
            }
        } catch (Exception e) {
            throw new ElabException("Error searching metadata..." + e.getMessage());
        } finally {
            dbDisconnect();
        }

        return count;
    }
    
    
}
