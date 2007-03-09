<%@ page import="java.io.*, java.util.*" %>
<%@ page import="org.griphyn.vdl.util.ChimeraProperties" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<%@ include file="common.jsp" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<%
	String f = request.getParameter("posterFile");
%>

<title><%=f%></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body LINK="white" VLINK="white">

<P>
<%
	//if to make file name is passed.
	
	if (f != null ) {
	// test for good file name
           if (f.indexOf("/") == -1 && f.indexOf("\\") == -1) {

              String posterFile = posterDirURL + f;  


 
 //   Get metadata to go with poster
 //-----
      int kind = -1; 	
      String primary = null;
      String secondary = null;

      String ret = "";

      String lfn = request.getParameter("posterFile");
      if (lfn != null && !lfn.equals("")) {
          kind = Annotation.CLASS_FILENAME;
	  primary = lfn;
       }

// if metadata        
 
      if (kind != -1) {
         // get metadata

         // Connect the database.
         String schemaName = ChimeraProperties.instance().getVDCSchemaName();

         Connect connect = new Connect();
         DatabaseSchema dbschema = connect.connectDatabase(schemaName);

	    if (! (dbschema instanceof Annotation)) {
              ret = "<CENTER><FONT color= red>" + 
	          "The database does not support metadata!" +
	          "</FONT><BR><BR></CENTER>";
	       } else 
	       {
            AnnotationSchema yschema = null;
            try {
	          yschema = (AnnotationSchema)dbschema;
	          java.util.List alist = yschema.loadAnnotation(primary, secondary, kind);
             if (alist!=null && !alist.isEmpty() ) { 
              String anno = ""; 
              for (Iterator i = alist.iterator(); i.hasNext();) { 
                    Tuple tuple = (Tuple)i.next(); 
                    anno += "<tr><td align='right' valign='top'><font size=-1>"+tuple.getKey()+":</font></td><td align='left' valign='top'><font size=-1>"+tuple.getValue()+"</font></td></tr>";
                    } 
                    ret += anno; 
                 } //end of checking for good list
                } catch (Exception e) {
               ret = "Error viewing metadata...";
	       //StringWriter sw = new StringWriter();
	       //e.printStackTrace(new PrintWriter(sw));	   
	       ret += e;
	    } // end of try
	    if (yschema != null)
            yschema.close();
        } // end of test for database supporting metadata
        if (dbschema != null)
	        dbschema.close();
     
     } // end of kind!=-1
     
//---------

%>
	<center><table><tr><td colspan="2" align="center" valign="top"><b>Metadata for file <%=f%></b></td></tr><%=ret%>
</center>
<%
        } // end of good file name
	
     } // end of if - non-null filename
%>	      
</body>
</html>


