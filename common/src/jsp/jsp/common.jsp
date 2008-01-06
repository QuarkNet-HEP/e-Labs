<%@ page import="java.io.*, java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.Timestamp" %> 
<%@ page import="java.text.DateFormat" %>
<%@ page import="org.griphyn.vdl.util.ChimeraProperties" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.common.catalog.replica.ReplicaFactory" %>
<%@ page import="org.griphyn.common.catalog.ReplicaCatalog" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.apache.batik.transcoder.image.PNGTranscoder" %>
<%@ page import="org.apache.batik.transcoder.TranscoderInput" %>
<%@ page import="org.apache.batik.transcoder.TranscoderOutput" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>
<%@ page import="gov.fnal.elab.*" %>

<!-- include file with name of the current eLab -->
<%@ include file="include/elab_name.jsp" %>

<%@ include file="include/login_url_base.jsp" %>

<%
System.setProperty("vds.home", elab.getProperty("vds.home"));
ElabGroup cmnuser = (ElabGroup) request.getAttribute("user");
if (request.getAttribute("user") == null) {
	cmnuser = ElabGroup.getUser(session);
	request.setAttribute("user", cmnuser);
}
// rough timing information for this page execution.  Is there an API for this?
long pageStartTime = System.currentTimeMillis();

ServletContext context = getServletContext();
String home = context.getRealPath("").replace('\\', '/');
String tempdir = context.getAttribute("javax.servlet.context.tempdir").toString();

//Useful directory variables
String dataDir = elab.getProperty("data.dir");
if (dataDir != null) {
	System.setProperty("portal.datadir", dataDir);
}
String templateDir = elab.getProperty("templates.dir");
String userArea = null;
String userDir = elab.getProperties().getUsersDir();
String runDir = null;
String runDirURL = null;
String plotDir = null;
String plotDirURL = null;
String posterDir = null;
String posterDirURL = null;


//Other useful variables
String groupName = null;    //same as session.getAttribute("login")
String groupTeacher = null;
String groupSchool = null;
String groupCity = null;
String groupState = null;
String groupYear = null;
String eLab = elab.getName();

if (cmnuser != null) {
	userArea = cmnuser.getUserArea();
	runDir = cmnuser.getDir("scratch");
	runDirURL = cmnuser.getDirURL("scratch");
	plotDir = cmnuser.getDir("plots");
	plotDirURL = cmnuser.getDirURL("plots");
	posterDir = cmnuser.getDir("posters");
	posterDirURL = cmnuser.getDirURL("posters");
	if(userArea != null){
    	String[] sp = userArea.split("/");
    	groupYear = sp[0];
	    groupState = sp[1].replaceAll("_", " ");    //useful for metadata searches if the state, city, school, and teacher have spaces instead of underscores
    	groupCity = sp[2].replaceAll("_", " ");
	    groupSchool = sp[3].replaceAll("_", " ");
    	groupTeacher = sp[4].replaceAll("_", " ");
	    groupName = sp[5];
	}
	session.setAttribute("role", cmnuser.getRole());
	session.setAttribute("UserName", cmnuser.getName());
	session.setAttribute("groupID", cmnuser.getId());
}


%>

<%!

public static void warn(JspWriter out, String error) throws ElabException {
    try{
        out.write("<font color=red><b>" + error + "</b></font>");
    }
    catch(Exception e){
        throw new ElabException("writing warn message ("+error+")",e);
    }
}

%>


<%!
/**
  * Gets the full path name from rc.data for the specified file string
  *
  * @deprecated     use the version without the "out" variable
  * @param  out     current JspWriter out handle
  * @param  lfn     logical filename
  * @return         the fully qualified physical filename on the system
  */
public static String getPFN(JspWriter out, String lfn) throws ElabException{
    String pfn = null;
    try {
        ReplicaCatalog rc = ReplicaFactory.loadInstance();
        pfn = rc.lookup(lfn, "local");
        rc.close();
    }
    catch (Exception e) {
        throw new ElabException("Lookup up LFN "+lfn,e);
    } 
    return pfn;
}
%>


<%!
/**
  * Gets the full path name from rc.data for the specified file string
  *
  * @param  lfn     logical filename
  * @return         the fully qualified physical filename on the system
  */
public static String getPFN(String lfn) throws ElabException{
    String pfn = null;
    try {
        ReplicaCatalog rc = ReplicaFactory.loadInstance();
        pfn = rc.lookup(lfn, "local");
        rc.close();
    }
    catch (Exception e) {
        throw new ElabException("While looking up: " + lfn, e);
    } 
    return pfn;
}
%>


<%!
/**
  * Sets metadata for a filename in the VDC
  *
  * @param  out         current JspWriter out handle
  * @param  filename    filename we're setting metadata for
  * @param  meta        tuples of key/type/value pairs each separated by a space
  * @return             <code>true</code> if the metadata was set without error
  *                     <code>false</code> otherwise.
  */
public static boolean setMeta(String filename, java.util.List meta) throws ElabException{
    // Connect the database.
    DatabaseSchema dbschema = null;
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            dbschema.close();
            throw new ElabException("The database does not support metadata!");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
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
                }   //for
            }   //annotation
            catch (Exception e) {
                throw new ElabException("Error writing metadata", e);
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }
            } 
        }   //dbschema
    } catch(Exception e) {
        throw new ElabException("setting metadata", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }
    return true;
}
%>


<%!
/**
  * Sets metadata for a filename in the VDC
  *
  * @deprecated         use the version without the "out" parameter
  * @param  out         current JspWriter out handle
  * @param  filename    filename we're setting metadata for
  * @param  meta        tuples of key/type/value pairs each separated by a space
  * @return             <code>true</code> if the metadata was set without error
  *                     <code>false</code> otherwise.
  */
public static boolean setMeta(JspWriter out, String filename, java.util.List meta)  throws ElabException  {
    // Connect the database.
    DatabaseSchema dbschema = null;
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            out.write("<CENTER><FONT color= red>The database does not support metadata!</FONT><BR><BR></CENTER>");
            dbschema.close();
            return false;
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
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
                }   //for
            }   //annotation
            catch (Exception e) {
                out.write("<CENTER><FONT color= red>Error writing metadata...</FONT><BR><BR>" + e + "<BR></CENTER>");
                return false;
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotationschema", ex);
                }
            } 
        }   //dbschema
    } catch(Exception e) {
        throw new ElabException("setting metadata", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }
    return true;
}
%>


<%!
/**
  * Adds an entry into the RC Catalog for a file
  *
  * @param  lfn         logical filename
  * @param  pfn         fully qualified physical filename
  * @return             <code>true</code> if the entry was added without error
  *                     <code>false</code> if the entry already exists in the Catalog.
  */
public static boolean addRC(String lfn, String pfn) throws ElabException{
    return true;
}
%>


<%!
/**
  * Adds an entry into the RC Catalog for a file
  *
  * @deprecated         use the version without the "out" parameter
  * @param  out         current JspWriter out handle
  * @param  lfn         logical filename
  * @param  pfn         fully qualified physical filename
  * @return             <code>true</code> if the entry was added without error
  *                     <code>false</code> otherwise.
  */
public static boolean addRC(JspWriter out, String lfn, String pfn)
    throws ElabException {
    return true;
}
%>
<%!
/**
  * Delete any annotation information associated
  * with the file.
  *
  * @bug                As of 10/7/2004 does not delete from the RC Catalog
  * @param  out         current JspWriter out handle
  * @param  lfn         logical filename to delete
  * @return             <code>true</code> if all 3 steps completed without error
  *                     <code>false</code> otherwise.
  */
public static boolean deleteLFNMeta(String lfn) throws ElabException {
    String primary = lfn;
    String secondary = null;
    int kind = Annotation.CLASS_FILENAME;
    java.util.List metaTuples = null;       //list of metaTuples for this lfn
    boolean allModified = false;               //true if the database was successfully modified

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            throw new ElabException("The database does not support metadata!");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
                annotationschema = (AnnotationSchema)dbschema;
                metaTuples = annotationschema.loadAnnotation(lfn, null, kind);

                boolean setAllModified = false;
                boolean currModified = true;
                if(metaTuples.iterator().hasNext()){
                    setAllModified = true;  //if there is at least 1 thing to modify, assume success unless we get a failure
                }
                for(Iterator i=metaTuples.iterator(); i.hasNext(); ){
                    Tuple t = (Tuple)i.next();
                    String key = t.getKey();
                    try{
                        //currModified = annotationschema.deleteAnnotation(primary, secondary, kind, t.getKey());
                        currModified = annotationschema.deleteAnnotationFilename(primary, key);
                    }
                    catch(Exception e){
                        throw new ElabException("Error while deleting the annotation key: " + t.getKey(), e);
                    }
                        //throw new ElabException("GIVING: " + primary + secondary + kind + " " + key + " " + currModified + "<br>");
                        if(currModified == false){
                            setAllModified = false;
                        }
                }
                allModified = setAllModified;
            } catch (Exception e) {
                throw new ElabException("<CENTER><FONT color= red>Error deleting metadata...</FONT><BR></CENTER>", e);
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) 
                {
                    throw new ElabException("closing annotationschema", ex);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("deleting LFN metadata", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }

      //return allModified;
    return true;
}
%>


<%!
/**
  * Delete a file from the RC Catalog, any annotation information associated
  * with the file, the DV associated with the file and the physical file on the 
  * system.
  * Also delete files associated via metadata.
  *
  * @param  lfn         logical filename to delete
  */
public static void deleteLFN(String lfn) throws ElabException{
    int kind = Annotation.CLASS_FILENAME;
    java.util.List metaTuples = null;       //list of metaTuples for this lfn

    //NOTE: entries aren't deleted from the Catalog because it doesn't support it

    /* delete annotation metadata and DV */

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            throw new ElabException("The database does not support metadata!");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
                annotationschema = (AnnotationSchema)dbschema;
                metaTuples = annotationschema.loadAnnotation(lfn, null, kind);
            } catch(Exception e){
                if (annotationschema != null)
                    annotationschema.close();
                throw new ElabException("in deleteLFN", e);
            }
            if(metaTuples == null){
                if (annotationschema != null)
                    annotationschema.close();
                throw new ElabException("No metadata for lfn: " + lfn);
            }

            /* delete all metadata and files linked via metadata */
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

                /* delete current key from the database */
                try{
                    boolean annodelete = annotationschema.deleteAnnotationFilename(lfn, key);
                }
                catch(Exception e){
                    if (annotationschema != null)
                        annotationschema.close();
                    throw new ElabException("Error while deleting the annotation key: " + t.getKey(), e);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("in deleteLFN", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }

    /* finally, delete original pfn file */

    String pfn = getPFN(lfn);
    File f = new File(pfn);
    if(f.canWrite()){
        boolean fileDeleted = f.delete();
    }
    else{
        throw new ElabException("Could not delete file: " + pfn + 
                "...Either it doesn't exists or the system doesn't have " + 
                "permission to delete it.");
    }
}
%>



 

<%!
/**
  * Delete a file from the RC Catalog, any annotation information associated
  * with the file, and the physical file on the system.
  *
  * @deprecated         use the version without the "out" parameter
  * @bug                As of 10/7/2004 does not delete from the RC Catalog
  * @param  out         current JspWriter out handle
  * @param  lfn         logical filename to delete
  * @return             <code>true</code> if all 3 steps completed without error
  *                     <code>false</code> otherwise.
  */
public static boolean deleteLFN(JspWriter out, String lfn)
    throws ElabException {
    String primary = lfn;
    String secondary = null;
    int kind = Annotation.CLASS_FILENAME;
    java.util.List metaTuples = null;       //list of metaTuples for this lfn
    boolean allModified = false;               //true if the database was successfully modified

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            out.write("<CENTER><FONT color= red>The database does not support metadata!</FONT><BR><BR></CENTER>");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
                annotationschema = (AnnotationSchema)dbschema;
                metaTuples = annotationschema.loadAnnotation(lfn, null, kind);

                boolean setAllModified = false;
                boolean currModified = true;
                if(metaTuples.iterator().hasNext()){
                    setAllModified = true;  //if there is at least 1 thing to modify, assume success unless we get a failure
                }
                for(Iterator i=metaTuples.iterator(); i.hasNext(); ){
                    Tuple t = (Tuple)i.next();
                    String key = t.getKey();
                    try{
                        //currModified = annotationschema.deleteAnnotation(primary, secondary, kind, t.getKey());
                        currModified = annotationschema.deleteAnnotationFilename(primary, key);
                    }
                    catch(Exception e){
                        out.println("Error while deleting the annotation key: " + t.getKey() + " - " + e);
                    }
                        //out.println("GIVING: " + primary + secondary + kind + " " + key + " " + currModified + "<br>");
                        if(currModified == false){
                            setAllModified = false;
                        }
                }
                allModified = setAllModified;
            } catch (Exception e) {
                out.println("<CENTER><FONT color= red>Error deleting metadata...</FONT><BR><BR>" + e + "<BR></CENTER>");
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotationschema", ex);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("deleting LFN", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }

    boolean fileDeleted = false;    //true if the lfn is deleted from the filesystem
    if(true){
        String pfn = getPFN(out, lfn);
        File f = new File(pfn);
        if(f.canWrite()){
            fileDeleted = f.delete();
            try{
            }catch(Exception e){
                throw new ElabException("deleting file "+pfn, e);
            }
        }
        else{
            //out.println("<CENTER><FONT color= red>Could not delete file: " + pfn + "...</FONT><BR><BR>Either it doesn't exists or the system doesn't have permission to delete it.<BR></CENTER>");
            ;
            try{
            out.write("cantwrite!!");
            }catch(Exception e){
                throw new ElabException("when trying to output cantwrite error message", e);
            }
        }
    }

    boolean rcDeleted = false;      //true if the rc.data entry is successfully deleted

    //return allModified;
    return true;
}
%>



<%!
/**
  * Get the logical filenames associated with an annotaion query
  *
  * @param  query       query string
  * @return             list of logical filenames returned by the query
  *                     null if nothing found
  * @see                Annotation
  */
public static java.util.List getLFNs(String query) throws ElabException{
    int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
    java.util.List lfns = null;     //list of filenames to return

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            throw new ElabException("The database does not support metadata!");
        }
        else {
            Annotation annotation = null;
            try {
                annotation = (Annotation)dbschema;
                StringReader sr = new StringReader(query);
                QueryParser parser = new QueryParser(sr);
                QueryTree tree = parser.parse(); 
                lfns = annotation.searchAnnotation(kind, null, tree);
            } catch (Exception e) {
                throw new ElabException("Error searching metadata...", e);
            } finally {
                try {
                    if (annotation != null)
                        ((DatabaseSchema)annotation).close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }
            }
        } 
    } catch(Exception e) {
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception e) {
            throw new ElabException("closing db schema", e);
        }
    }
    return lfns;
}
%>
 
<%!
/**
  * Get the logical filenames associated with an annotaion query
  *
  * @deprecated         use the version without the "out" parameter
  * @param  out         current JspWriter out handle
  * @param  query       query string
  * @return             list of logical filenames returned by the query
  * @see                Annotation
  */
public static java.util.List getLFNs(JspWriter out, String query)
    throws ElabException {
    int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
    java.util.List lfns = null;     //list of filenames to return

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            out.write("<CENTER><FONT color= red>The database does not support metadata!</FONT><BR><BR></CENTER>");
        }
        else {
            Annotation annotation = null;
            try {
                annotation = (Annotation)dbschema;
                StringReader sr = new StringReader(query);
                QueryParser parser = new QueryParser(sr);
                QueryTree tree = parser.parse(); 
                lfns = annotation.searchAnnotation(kind, null, tree);

                //if (lfns==null || lfns.isEmpty() ) {
                //    out.write("<CENTER><FONT color= red>Your query returned no results</FONT><BR><BR></CENTER>");
                //}
            } catch (Exception e) {
                out.write("<CENTER><FONT color= red>Error searching metadata...</FONT><BR><BR>" + e + "<BR></CENTER>");
            } finally {
                try {
                    if (annotation != null)
                        ((DatabaseSchema)annotation).close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }
            }
        } 
    } catch(Exception e) {
        throw new ElabException("retrieving LFNs", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception e) {
            throw new ElabException("closing dbschema", e);
        }
    }
    return lfns;
}
%>


<%!
/**
  * Get metadata Tuples associated with a filename
  *
  * @param  lfn         logical filename to get metadata for
  * @return             list of every {@link Tuple} associated with this filename
  *                     null if nothing found
  * @see                Tuple
  * @see                AnnotationSchema
  */
public static java.util.List getMeta(String lfn) throws ElabException{
    int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
    java.util.List metaTuples = null;     //list of metadata Tuples for this lfn

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            throw new ElabException("The database does not support metadata!");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
                annotationschema = (AnnotationSchema)dbschema;
                metaTuples = annotationschema.loadAnnotation(lfn, null, kind);
            } catch (Exception e) {
                throw new ElabException("Error searching metadata...", e);
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("getting metadata for LFN "+lfn, e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception e) {
            throw new ElabException("closing dbschema", e);
        }
    }
    return metaTuples;
}
%>


<%!
/**
  * Get metadata Tuples associated with a filename
  *
  * @param  out         current JspWriter out handle
  * @param  lfn         logical filename to get metadata for
  * @return             list of every {@link Tuple} associated with this filename
  * @see                Tuple
  * @see                AnnotationSchema
  */
public static java.util.List getMeta(JspWriter out, String lfn)
    throws ElabException {
    int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
    java.util.List metaTuples = null;     //list of metadata Tuples for this lfn

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            out.write("<CENTER><FONT color= red>The database does not support metadata!</FONT><BR><BR></CENTER>");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
                annotationschema = (AnnotationSchema)dbschema;
                metaTuples = annotationschema.loadAnnotation(lfn, null, kind);

                //if (metaTuples==null || metaTuples.isEmpty() ) {
                //    out.write("<CENTER><FONT color= red>Your query returned no results</FONT><BR><BR></CENTER>");
                //}
            } catch (Exception e) {
                out.write("<CENTER><FONT color= red>Error searching metadata...</FONT><BR><BR>" + e + "<BR></CENTER>");
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("getting metadata", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception e) {
            throw new ElabException("closing dbschema", e);
        }
    }
    return metaTuples;
}
%>


<%!
/**
  * Get the metadata Tuple associated with this filename and key
  *
  * @param  lfn         logical filename to get metadata for
  * @param  key         get the Tuple associated with this metadata key
  * @return             Tuple containing the key/type/value
  */
public static Tuple getMetaKey(String lfn, String key)
    throws ElabException {
    int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
    Tuple value = null;                     //Tuple of metadata with this key

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            throw new ElabException("The database does not support metadata!");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
                annotationschema = (AnnotationSchema)dbschema;
                value = annotationschema.loadAnnotation(lfn, null, kind, key);
            } catch (Exception e) {
                throw new ElabException("Error on searching metatata...", e);
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("in getMetaKey", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }
    return value;
}
%>


<%!
/**
  * Get the metadata Tuple associated with this filename and key
  *
  * @deprecated         use the version without the "out" parameter
  * @param  out         current JspWriter out handle
  * @param  lfn         logical filename to get metadata for
  * @param  key         get the Tuple associated with this metadata key
  * @return             Tuple containing the key/type/value
  */
public static Tuple getMetaKey(JspWriter out, String lfn, String key)
    throws ElabException {
    int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
    Tuple value = null;                     //Tuple of metadata with this key

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            out.write("<CENTER><FONT color= red>The database does not support metadata!</FONT><BR><BR></CENTER>");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
                annotationschema = (AnnotationSchema)dbschema;
                value = annotationschema.loadAnnotation(lfn, null, kind, key);
            } catch (Exception e) {
                out.write("<CENTER><FONT color= red>Error searching metadata...</FONT><BR><BR>" + e + "<BR></CENTER>");
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("in getMetaKey", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }
    return value;
}
%>



<%!
/**
  * Get a structure containing both the logical filenames and the metadata
  * associated with those filenames for a specific annotation query
  *
  * @param  query       query string
  * @return             list of unordered "pairs" which consist of a logical
  *                     filename string and a list of metadata Tuples 
  *                     associated with each file.
  *                     null if nothing found.
  */
public static ArrayList getLFNsAndMeta(String query)
    throws ElabException {
    int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
    ArrayList pairs = null;     //list of lfn-metadata_Tuple pairs to return
    java.util.List lfns = null;     //list of filenames from this query
    DatabaseSchema dbschema = null;

    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            throw new ElabException("The database does not support metadata!");
        }
        else {
            Annotation annotation = null;
            AnnotationSchema annotationschema = null;
            try {
                annotation = (Annotation)dbschema;
                StringReader sr = new StringReader(query);
                QueryParser parser = new QueryParser(sr);
                QueryTree tree = parser.parse(); 
                lfns = annotation.searchAnnotation(kind, null, tree);
                if (lfns==null || lfns.isEmpty() ) {
                    pairs = null;
                }
                else{
                    annotationschema = (AnnotationSchema)dbschema;
                    pairs = new ArrayList();
                    java.util.List metaTuples = null;
                    for(Iterator i = lfns.iterator(); i.hasNext(); ){
                        String lfn = (String)i.next();
                        metaTuples = annotationschema.loadAnnotation(lfn, null, kind);

                        //if (metaTuples==null || metaTuples.isEmpty() ) {
                        //    out.write("<CENTER><FONT color= red>The lfn: " + lfn + " has no metadata associated with it</FONT><BR><BR></CENTER>");
                        //}
                        ArrayList currPair = new ArrayList(2);
                        currPair.add(0, lfn);
                        currPair.add(1, metaTuples);
                        pairs.add(currPair);    //add the current lfn-metadta_Tuple to the list of pairs for this query
                    }
                }
            } catch (Exception e) {
                throw new ElabException("Error searching metadata", e);
            } finally {
                try {
                    if (annotation != null)
                        ((DatabaseSchema)annotation).close();
                    annotation = null;
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }

                try {
                    if (annotationschema != null)
                        annotationschema.close();
                    annotationschema = null;
                } catch (Exception exc) {
                    throw new ElabException("closing annotation schema", exc);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("getting LFNs and metadata", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
            dbschema = null;
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }
    return pairs;
}
%>

<%!
/**
  * Get a structure containing both the logical filenames and the metadata
  * associated with those filenames for a specific annotation query
  *
  * @deprecated         use the version without the "out" parameter
  * @param  out         current JspWriter out handle
  * @param  query       query string
  * @return             list of unordered "pairs" which consist of a logical
  *                     filename string and a list of metadata Tuples 
  *                     associated with each file.
  */
public static ArrayList getLFNsAndMeta(JspWriter out, String query)
    throws ElabException {
    int kind = Annotation.CLASS_FILENAME;   //searching on lfn's
    ArrayList pairs = null;     //list of lfn-metadata_Tuple pairs to return
    java.util.List lfns = null;     //list of filenames from this query
    DatabaseSchema dbschema = null;

    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            out.write("<CENTER><FONT color= red>The database does not support metadata!</FONT><BR><BR></CENTER>");
        }
        else {
            Annotation annotation = null;
            AnnotationSchema annotationschema = null;
            try {
                annotation = (Annotation)dbschema;
                StringReader sr = new StringReader(query);
                QueryParser parser = new QueryParser(sr);
                QueryTree tree = parser.parse(); 
                lfns = annotation.searchAnnotation(kind, null, tree);
                if (lfns==null || lfns.isEmpty() ) {
                    pairs = null;
                }
                else{
                    annotationschema = (AnnotationSchema)dbschema;
                    pairs = new ArrayList();
                    java.util.List metaTuples = null;
                    for(Iterator i = lfns.iterator(); i.hasNext(); ){
                        String lfn = (String)i.next();
                        metaTuples = annotationschema.loadAnnotation(lfn, null, kind);

                        //if (metaTuples==null || metaTuples.isEmpty() ) {
                        //    out.write("<CENTER><FONT color= red>The lfn: " + lfn + " has no metadata associated with it</FONT><BR><BR></CENTER>");
                        //}
                        ArrayList currPair = new ArrayList(2);
                        currPair.add(0, lfn);
                        currPair.add(1, metaTuples);
                        pairs.add(currPair);    //add the current lfn-metadta_Tuple to the list of pairs for this query
                    }
                }
            } catch (Exception e) {
                out.write("<CENTER><FONT color= red>Error searching metadata...</FONT><BR><BR>" + e + "<BR></CENTER>");
            } finally {
                try {
                    if (annotation != null)
                        ((DatabaseSchema)annotation).close();
                    annotation = null;
                } catch (Exception ex) {
                    throw new ElabException("closing annotation schema", ex);
                }

                try {
                    if (annotationschema != null)
                        annotationschema.close();
                    annotationschema = null;
                } catch (Exception exc) {
                    throw new ElabException("closing annotation schema", exc);
                }
            }
        } 
    } catch(Exception e){
        throw new ElabException("getting LFNs and meta", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
            dbschema = null;
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }
    return pairs;
}
%>


<%!
/**
  * Get the number of files in the database.
  *
  * @return             a String with a custom status message from the database. 
  *                     null if nothing found
  *
  */
public static String getDBStatusMessage() throws ElabException{
    DatabaseSchema dbschema = null;
    String status = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            throw new ElabException("The database does not support metadata!");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
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
                throw new ElabException("Error searching metadata...", e);
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                    annotationschema = null;
                } catch (Exception exc) {
                    throw new ElabException("closing annotation schema", exc);
                }
            }
        } 
    } catch(Exception e){
            throw new ElabException("DB threw exception", e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
            dbschema = null;
        } catch (Exception ex) {
            throw new ElabException("closing db schema", ex);
        }
    }
    if (status != null)
        return (status + ".");
    else
        return null;
}
%>


<%!
/**
  * Get the number of files in the database.
  *
  * @deprecated         use the version without the "out" parameter
  * @param  out         current JspWriter out handle
  * @return             a String with a custom status message from the database. 
  *
  */
public static String getDBStatusMessage(JspWriter out) 
    throws ElabException {
    DatabaseSchema dbschema = null;
    String status = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            out.write("<CENTER><FONT color= red>The database does not support metadata!</FONT><BR><BR></CENTER>");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
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
                out.write("<CENTER><FONT color= red>Error searching metadata...</FONT><BR><BR>" + e + "<BR></CENTER>");
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                    annotationschema = null;
                } catch (Exception exc) {
                    throw new ElabException("closing annotation schema", exc);
                }
            }
        } 
    } catch(Exception e){
        try {
            Throwable t = e;
            while (t != null) {
                out.write("DB threw exception: " + t.getMessage() + "<br>");
                t = t.getCause();
            }
        } catch (Exception excep) {
            throw new ElabException("dumping exception chain", excep);
        }
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
            dbschema = null;
        } catch (Exception ex) {
            throw new ElabException("closing dbschema", ex);
        }
    }
    if (status != null)
        return (status + ".");
    else
        return null;
}
%>


<%!
/**
  * Checks if a geometry file exists
  *
  * @param  id          detector/DAC board number  
  * @param  dataDir     base geometry pathname. In "path/id/id.geo" this is "path"
  * @return             <code>true</code> if the geometry file exists
  *                     <code>false</code> otherwise.
  */
public static boolean geoFileExists(int id, String dataDir){
    File f = new File(dataDir + "/" + id);
    if(f.isDirectory()){
        File f2 = new File(dataDir + "/" + id + "/" + id + ".geo");
        if(f2.isFile()){
            return f2.canRead();
        }
        return false;
    }
    return false;
}
%>

<%!
/**
 * Convert a .svg image to a .png and create a thumbnail of the image as well.
 *
 * @param   svgfilename     full path to the svg image
 * @param   pngfilename     full path to the png image to output
 * @param   thumbpngfilename  full path to the thumbnail png image to output
 * @param   pngheight       pixel height of the png image
 * @param   thumbpngheight    pixel height of the thumbnail png image
 */
public static void svg2png(String svgfilename, String pngfilename, String thumbpngfilename, String pngheight, String thumbpngheight) throws IOException, ElabException{
    try {
        String svgFile = (new File(svgfilename)).toURL().toString();

        // Convert the SVG image to PNG using the Batik toolkit.
        // Thanks to the Batik website's tutorial for this code (http://xml.apache.org/batik/rasterizerTutorial.html).
        PNGTranscoder trans = new PNGTranscoder();
        // Regular size image.
        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(pngheight));
        TranscoderInput input = new TranscoderInput(svgFile);
        OutputStream ostream = new FileOutputStream(pngfilename);
        TranscoderOutput output = new TranscoderOutput(ostream);
        trans.transcode(input, output);
        ostream.flush();
        ostream.close();

        trans = new PNGTranscoder();
        // Thumbnail.
        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(thumbpngheight));
        ostream = new FileOutputStream(thumbpngfilename);
        output = new TranscoderOutput(ostream);
        trans.transcode(input, output);
        ostream.flush();
        ostream.close();
    } catch (Exception e) {
        throw new ElabException("Failed to create plot from SVG file", e);
    }
}
%>



<%!
/**
 * Convert a .svg image to a .png and create a thumbnail of the image as well.
 *
 * @deprecated         use the version without the "out" parameter
 * @param   svgfilename     full path to the svg image
 * @param   pngfilename     full path to the png image to output
 * @param   thumbpngfilename  full path to the thumbnail png image to output
 * @param   pngheight       pixel height of the png image
 * @param   thumbpngheight    pixel height of the thumbnail png image
 */
public static void svg2png(JspWriter out, String svgfilename, String pngfilename, String thumbpngfilename, String pngheight, String thumbpngheight) throws IOException{
    try {
        String svgFile = (new File(svgfilename)).toURL().toString();

        // Convert the SVG image to PNG using the Batik toolkit.
        // Thanks to the Batik website's tutorial for this code (http://xml.apache.org/batik/rasterizerTutorial.html).
        PNGTranscoder trans = new PNGTranscoder();
        // Regular size image.
        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(pngheight));
        TranscoderInput input = new TranscoderInput(svgFile);
        OutputStream ostream = new FileOutputStream(pngfilename);
        TranscoderOutput output = new TranscoderOutput(ostream);
        trans.transcode(input, output);
        ostream.flush();
        ostream.close();

        trans = new PNGTranscoder();
        // Thumbnail.
        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(thumbpngheight));
        ostream = new FileOutputStream(thumbpngfilename);
        output = new TranscoderOutput(ostream);
        trans.transcode(input, output);
        ostream.flush();
        ostream.close();
    } catch (Exception e) {
        out.write("Error: Failed to create plot from SVG file:<br>" + e.getMessage() + "<br>");
    }
}
%>

<%!
//jd_to_gregorian helper function
/**
 * Convert a julian day to Gregorian day (helper function)
 * see jd_to_gregorian with 2 parameters
 *
 * @param   jd      float jd to convert
 */
public int[] jd_to_gregorian(double jd){
    String[] split = new String[2];
    Double f = new Double(jd);
    split = f.toString().split("\\.");
    split[1] = "." + split[1];
    int jd_int = Integer.parseInt((String)split[0]);
    double partial = Double.parseDouble((String)split[1]);

    return jd_to_gregorian(jd_int, partial);
}

/**
  * Convert a julian day to Gregorian day
  * Thanks to: http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
  *
  * @param  jd          integer julian day
  * @param  partial     partial julian day (0 <= float < 1)
  * @return             a native array (day[1..31], month[1..12], year[..2004..]{, hour[0..23], min, sec, msec, micsec, nsec})
  */
public int[] jd_to_gregorian(int jd, double partial){
    int Z = (int)(jd + 0.5 + partial);
    int W = (int)((Z - 1867216.25)/36524.25);
    int X = (int)(W/4);
    int A = Z+1+W-X;
    int B = A+1524;
    int C = (int)((B-122.1)/365.25);
    int D = (int)(365.25*C);
    int E = (int)((B-D)/30.6001);
    int F = (int)(30.6001*E);
    int day = B-D-F;
    int month = E-1 <= 12 ? E-1 : E-13; //Month = E-1 or E-13 (must get number less than or equal to 12)
    int year = month <= 2 ? C-4715 : C-4716;    //Year = C-4715 (if Month is January or February) or C-4716 (otherwise)

    int[] array = new int[10];
    array[0] = day;
    array[1] = month;
    array[2] = year;

    if(partial != 0){
        int hour = (int)(partial*24);
        int min = (int)((partial*24-hour)*60);
        int sec = (int)(((partial*24-hour)*60-min)*60);
        int msec = (int)((((partial*24-hour)*60-min)*60-sec)*1000);
        int micsec = (int)(((((partial*24-hour)*60-min)*60-sec)*1000-msec)*1000);
        int nsec = (int)((((((partial*24-hour)*60-min)*60-sec)*1000-msec)*1000)*1000);

        array[3] = (hour+12)%24;
        array[4] = min;
        array[5] = sec;
        array[6] = msec;
        array[7] = micsec;
        array[8] = nsec;
    }

    return array;
}

/**
 * Convert a Gregorian day to a julian day
 * Thanks to: http://www.friesian.com/numbers.htm
 *
 * @param   year        integer year of gregorian date
 * @param   month       integer month of gregorian date (1-12)
 * @param   day         integer day of gregorian date (1-x)
 * @param   hour        integer hour of gregorian date (0-23)
 * @param   minute      integer minute of gregorian date (0-59)
 * @param   second      integer second of gregorian date (0-59)
 * @return              a string holding julian day
 */
public String gregorian_to_jd(int year, int month, int day, int hour, int minute, int second){
    double step1 = (year + 4712)/4.0;
    int step1Int = (int)step1;
    double remainder = (step1 - step1Int)*4;
    int monthNum = 0;
    if (month == 3) { monthNum = 0; }
    if (month == 4) { monthNum = 31; }
    if (month == 5) { monthNum = 61; }
    if (month == 6) { monthNum = 92; }
    if (month == 7) { monthNum = 122; }
    if (month == 8) { monthNum = 153; }
    if (month == 9) { monthNum = 184; }
    if (month == 10) { monthNum = 214; }
    if (month == 11) { monthNum = 245; }
    if (month == 12) { monthNum = 275; }
    if (month == 1) { monthNum = 306; }
    if (month == 2) { monthNum = 337; }
    double PJD = (hour*3600 + minute*60 + second)/86400.0;
    double jd = step1Int*1461 + remainder*365 + monthNum + day + 59 - 13 - .5 + PJD;
    return String.valueOf(jd);
}
%>


<%!
/**
 * Sort any array of arrays by column.
 *
 * No parameters since this method is called from Collections.sort()
 */
class SortByColumn implements Comparator{
    public final int compare (Object a, Object b){
        ArrayList rowA = (ArrayList)a;
        ArrayList rowB = (ArrayList)b;

        //if either object is null, sort to bottom of list
        if(rowA == null){
            return 1;
        }
        if(rowB == null){
            return -1;
        }

        Object objA = rowA.get(this.sortColumn);
        Object objB = rowB.get(this.sortColumn);

        //Return a negative integer, zero, or a positive integer if objA is less than, equal to, or greater than objB. (higher goes to top)
        int ret = 0;
        if (objA instanceof Integer){
            Integer obj1 = (Integer)objA;
            Integer obj2 = (Integer)objB;
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Long){
            Long obj1 = (Long)objA;
            Long obj2 = (Long)objB;
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Float){
            Float obj1 = (Float)objA;
            Float obj2 = (Float)objB;
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Boolean){
            Boolean obj1 = (Boolean)objA;
            Boolean obj2 = (Boolean)objB;
            boolean eq = obj1.equals(obj2);
            if(eq){ ret = -1; } else{ ret = 1; }
        }
        if (objA instanceof String){
            String obj1 = (String)objA;
            String obj2 = (String)objB;
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof java.util.Date){
            java.util.Date obj1 = (java.util.Date)objA;
            java.util.Date obj2 = (java.util.Date)objB;
            ret = obj1.compareTo(obj2);  //newest dates first
        }
        if (objA instanceof Timestamp){
            Timestamp obj1 = (Timestamp)objA;
            Timestamp obj2 = (Timestamp)objB;
            ret = obj1.compareTo(obj2);  //newest dates first
        }

        return asc == true ? ret : -1*ret;
    }

    public SortByColumn(int i){
        setSortColumn(i);
    }

    /*
     * Should be called before calling Collections sort() method
     * (Column numbering starts at 0)
     */
    public void setSortColumn(int i){
        this.sortColumn = i;
    }

    public void sortAscending(){
        asc = true;
    }

    public void sortDescending(){
        asc = false;
    }

    private int sortColumn = 0;
    private boolean asc = true;    //sort ascending
}
%>


<%!
/**
  * Format html output for metadata tags
  *
  * @author             Paul Nepywoda
  */
public class MetaFormat{
    //Input: String key of metadata, value of metadata (from (Tuple)t.getValue())
    /**
     * Pick which formatting method to call based on the metadata key
     *
     * @param  key          metadata key
     * @param  value        metadata value
     * @return              html formatted value, or simply the value if no
     *                      special formatting is required
     */
    public String pickMeta(String key, Object value){
        if(value != null){
            if(key.equals("blessed")){
                return this.blessed(value);
            }
            else if(key.equals("stacked")){
                return this.stacked(value);
            }
            else if(key.equals("chan1")){
                return this.chan1(value);
            }
            else if(key.equals("chan2")){
                return this.chan2(value);
            }
            else if(key.equals("chan3")){
                return this.chan3(value);
            }
            else if(key.equals("chan4")){
                return this.chan4(value);
            }
            else if(key.equals("startdate")){
                return this.startdate(value);
            }
            else if(key.equals("creationdate")){
                return this.creationdate(value);
            }
            else if(key.equals("date")){
                return this.date(value);
            }
            else{
                //if no special handling is needed, return an unformatted value
                return value.toString();
            }
        }
        else{
            return "";
        }
    }

    public String blessed(Object value){
        boolean blessed = ((Boolean)value).booleanValue();
        String ret = "";
        if(blessed){
            ret += "<img border=\"0\" alt=\"Blessed data\" src=\"graphics/star.gif\">";
        }
        return ret;
    }
    
    public String stacked(Object value){
        boolean stacked = ((Boolean)value).booleanValue();
        String ret = "";
        if(stacked){
            ret += "<img border=\"0\" alt=\"Stacked data\" src=\"graphics/stacked.gif\">";
        }
        else{
            ret += "<img border=\"0\" alt=\"Unstacked data\"  src=\"graphics/unstacked.gif\">";
        }
        return ret;
    }

    public String chan1(Object value){
        int chan1=0;
        chan1 = ((Long)value).intValue();
        String ret = "";
        if(chan1 > 0){
            ret += "<img src=\"graphics/chan1-on.png\"";
        }
        else{
            ret += "<img src=\"graphics/chan1-off.png\"";
        }
        return ret;
    }

    public String chan2(Object value){
        int chan2=0;
        chan2 = ((Long)value).intValue();
        String ret = "";
        if(chan2 > 0){
            ret += "<img src=\"graphics/chan2-on.png\"";
        }
        else{
            ret += "<img src=\"graphics/chan2-off.png\"";
        }
        return ret;
    }

    public String chan3(Object value){
        int chan3=0;
        chan3 = ((Long)value).intValue();
        String ret = "";
        if(chan3 > 0){
            ret += "<img src=\"graphics/chan3-on.png\"";
        }
        else{
            ret += "<img src=\"graphics/chan3-off.png\"";
        }
        return ret;
    }

    public String chan4(Object value){
        int chan4=0;
        chan4 = ((Long)value).intValue();
        String ret = "";
        if(chan4 > 0){
            ret += "<img src=\"graphics/chan4-on.png\"";
        }
        else{
            ret += "<img src=\"graphics/chan4-off.png\"";
        }
        return ret;
    }

    public String startdate(Object value){
        return this.dateFormatterDataFiles((java.util.Date)value);
    }

    public String creationdate(Object value){
        return this.datetimeFormatter((java.util.Date)value);
    }

    public String date(Object value){
        return this.dateFormatter((java.util.Date)value);
    }


    //helper functions
    private String dateFormatter(java.util.Date d){
        String formatted=new String();
		GregorianCalendar calendar = new GregorianCalendar();

		calendar.setTime(d);
		String month = month_name(1+calendar.get(Calendar.MONTH));
		String day = calendar.get(Calendar.DATE)+"";

		formatted = month;
		formatted += " " + day;

        return formatted;
    }
    
    private String dateFormatterDataFiles(java.util.Date d){
        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("EEE d");
        return formatter.format(d);
    }

    private String datetimeFormatter(java.util.Date d){
        String formatted=new String();
		GregorianCalendar calendar = new GregorianCalendar();

		calendar.setTime(d);
        return java.text.DateFormat.getDateInstance().format(calendar.getTime());
		/*String month = (1+calendar.get(Calendar.MONTH))+"/";
		String day = calendar.get(Calendar.DATE)+"/";

		formatted = month;
		formatted += day;
		formatted += calendar.get(Calendar.YEAR) + " ";
		formatted += calendar.get(Calendar.HOUR_OF_DAY) + ":";
		formatted += calendar.get(Calendar.MINUTE) + ":";
		formatted += calendar.get(Calendar.SECOND);

        return formatted;*/
    }
}
%>


<%!
/**
  * Sorts the ArrayList returned by {@link getLFNsAndMeta} based on a metadata
  * key.
  * Many thanks to http://www.onjava.com/pub/a/onjava/2003/03/12/java_comp.html?page=2 
  * which had some great examples
  *
  * @author             Paul Nepywoda
  */
class MetaCompare implements Comparator{
    /**
     * Implemented as {@link Comparator} specifies.
     * Should not be called directly.
     */
    public final int compare (Object a, Object b){
        java.util.List la = (java.util.List)a;
        java.util.List lb = (java.util.List)b;
        java.util.List tuplesA = (java.util.List)la.get(1);
        java.util.List tuplesB = (java.util.List)lb.get(1);

        String sortKey = this.getSortKey();
        //search through the list until you find the Tuple to sort on
        Tuple sortTupleA = null;
        for(Iterator i=tuplesA.iterator(); i.hasNext(); ){
            Tuple t = (Tuple)i.next();
            String key = (String)t.getKey();
            if(key.equals(sortKey)){
                sortTupleA = t;
            }
        }
        Tuple sortTupleB = null;
        for(Iterator i=tuplesB.iterator(); i.hasNext(); ){
            Tuple t = (Tuple)i.next();
            String key = (String)t.getKey();
            if(key.equals(sortKey)){
                sortTupleB = t;
            }
        }

        //if either Tuple is null, sort to bottom of list
        if(sortTupleA == null){
            return 1;
        }
        if(sortTupleB == null){
            return -1;
        }


        Object objA = sortTupleA.getValue();
        Object objB = sortTupleB.getValue();
        
        //if either object is null, sort to bottom of list
        if(objA == null){
            return 1;
        }
        if(objB == null){
            return -1;
        }

        //Compares its two arguments for order. Returns a negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater than the second.
        int ret = 0;
        if (objA instanceof Long){
            Long obj1 = (Long)sortTupleA.getValue();
            Long obj2 = (Long)sortTupleB.getValue();
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Float){
            Float obj1 = (Float)sortTupleA.getValue();
            Float obj2 = (Float)sortTupleB.getValue();
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Boolean){
            Boolean obj1 = (Boolean)sortTupleA.getValue();
            Boolean obj2 = (Boolean)sortTupleB.getValue();
            boolean eq = obj1.equals(obj2);
            if(eq){ ret = -1; } else{ ret = 1; }
        }
        if (objA instanceof String){
            String obj1 = (String)sortTupleA.getValue();
            String obj2 = (String)sortTupleB.getValue();
            ret = obj1.compareTo(obj2);
        }
        if (objA instanceof Timestamp){
            Timestamp obj1 = (Timestamp)sortTupleA.getValue();
            Timestamp obj2 = (Timestamp)sortTupleB.getValue();
            ret = obj1.compareTo(obj2);  //newest dates first
        }
        if (!isAscending)
            ret = -ret;
        
        return ret;
    }
    
    /**
     * Returns the current search key
     *
     * @return              current search key
     */
    public String getSortKey(){
        return this.sortKey;
    }
    /**
     * Set the key to sort by
     *
     * @param   s           metadata key to sort by
     */
    public void setSortKey(String s){
        this.sortKey = s;
    }

    /**
     *  Directs the sort in ascending order.
     *
     */
    public void setSortAscending() {
        this.isAscending = true;
    }

    /**
     * Directs the sort in descending order.
     *
     */
    public void setSortDescending() {
        this.isAscending = false;
    }

    private String sortKey = "project";
    private boolean isAscending = true;
}
%>


<%!
/**
 * Return the filename lfn that matches the detector id and has start and end
 * dates which encompass the date given
 *
 * @param   int         detector id
 * @param   Date        timestamp
 * @return              lfn of filename
 */
public static String lfn_from_date(int id, java.util.Date date) throws ElabException{
    java.util.List result = null;
    String lfn = null;

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    sdf.setTimeZone(TimeZone.getTimeZone("UTC"));

    String q = "type='split' AND project='cosmic' AND detectorid='" + id
        + "' AND startdate < '" + sdf.format(date) + "' AND enddate > '"
        + sdf.format(date) + "'";
    result = getLFNs(q);
    if(result != null){
        Iterator i=result.iterator(); 
        if(i.hasNext()){    //only grab the first lfn if there's more than one
            lfn = (String)i.next();
        }
    }

    return lfn;
}
%>


<%!
/**
  * Convert an integer to a month name (starting from 1)
  *
  * @param  int         month integer
  * @return             month name
  */
public static String month_name(int month){
    switch(month){
        case 0: return new String("Month");
        case 1: return new String("January");
        case 2: return new String("February");
        case 3: return new String("March");
        case 4: return new String("April");
        case 5: return new String("May");
        case 6: return new String("June");
        case 7: return new String("July");
        case 8: return new String("August");
        case 9: return new String("September");
        case 10: return new String("October");
        case 11: return new String("November");
        case 12: return new String("December");
        default:
                 return new String("Not a month!");
    }
}

/**
  * Convert a month name to an integer (starting from 1)
  *
  * @param  m           month name
  * @return             month integer
  */
public static int month_number(String m){
    if(m.equals("Month")){
        return 0;
    }
    else if(m.equals("January")){
        return 1;
    }
    else if(m.equals("February")){
        return 2;
    }
    else if(m.equals("March")){
        return 3;
    }
    else if(m.equals("April")){
        return 4;
    }
    else if(m.equals("May")){
        return 5;
    }
    else if(m.equals("June")){
        return 6;
    }
    else if(m.equals("July")){
        return 7;
    }
    else if(m.equals("August")){
        return 8;
    }
    else if(m.equals("September")){
        return 9;
    }
    else if(m.equals("October")){
        return 10;
    }
    else if(m.equals("November")){
        return 11;
    }
    else if(m.equals("December")){
        return 12;
    }
    return 0;
}
%>
