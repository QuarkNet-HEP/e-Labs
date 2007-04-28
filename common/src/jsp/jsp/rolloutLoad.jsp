<%@ page import="java.io.*, java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.Timestamp" %> 
<%@ page import="java.text.DateFormat" %>
<%@ page import="org.griphyn.vdl.util.ChimeraProperties" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.apache.batik.transcoder.image.PNGTranscoder" %>
<%@ page import="org.apache.batik.transcoder.TranscoderInput" %>
<%@ page import="org.apache.batik.transcoder.TranscoderOutput" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>

<%

// read properties file if we haven't already read it in 
// (we use the definition of vds.home to determine this)
if(System.getProperty("vds.home") == null){
   ServletContext context = getServletContext();
   String home = context.getRealPath("").replace('\\', '/');
   String tempdir = context.getAttribute("javax.servlet.context.tempdir").toString();
    String pfFile = home + "/WEB-INF/elab.properties";
    File pf = new File(pfFile);
    if (pf.canRead()) {
        Properties prop = new Properties();
        try{
            prop.load(new FileInputStream(pf));
                for ( Enumeration e = prop.propertyNames(); e.hasMoreElements(); ) {
                        String key = (String) e.nextElement();
                        String value = prop.getProperty(key);
                        System.setProperty(key, value);
                        //out.println("key: " + key + " value: " + value);
                    }
            
            //System.setProperties(prop);
        } catch (Exception e){
            throw new ElabException("While setting the elab System properties...: " + e.getMessage());
        }
    }
    else{
        throw new ElabException("Couldn't read the elab System properties file: " + pfFile);
    }
%>
<!-- eLab properties loaded by this page request. -->
<%
} else {
%>
<!-- eLab properties have been previously loaded - this page 
     request did not reload them. -->
<%

}
%>

