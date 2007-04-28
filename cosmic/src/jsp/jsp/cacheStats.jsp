<%@ page import="org.griphyn.vdl.util.ChimeraProperties" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>
<%
    application.setAttribute("status_message", getDBStatusMessage());
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
            throw new ElabException("The database does not support metadata! dbschema class is "+dbschema.getClass().toString());
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
                throw new ElabException("Error searching metadata", e);
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                    annotationschema = null;
                } catch (Exception exc) {
                    throw new ElabException("Could not close annotation db",exc);
                }
            }
        } 
    } catch(Exception e){
            throw new ElabException("DB threw exception",e);
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
            dbschema = null;
        } catch (Exception exc) {
            throw new ElabException("Could not close annotation db",exc);
        }
    }
    if (status != null)
        return (status + ".");
    else
        return null;
}
%>
