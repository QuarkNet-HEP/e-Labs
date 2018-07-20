<%-- This page provides pop-up descriptions of analysis parameters to the user via ?-boxes in the e-Lab interfaces. --%>
<%-- This page constructs an HTML pop-up page as a String within a scriptlet, then prints that HTML.  This is... not great from an XSS-protection perspective, and JSP/JSTL provide better ways to accomplish what we want, anyway.
Prime candidate for a rewrite.
NB that Tuple, Annotation, etc. are used here from the VDS packages org.griphyn.vdl, which we don't have source code for - JG 19Jul2018 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<% String label = request.getParameter("label");  //label you want to show
%>

<head><title><c:out value="${param.label}" /></title>
		<%@ include file="include/javascript.jsp" %>
		<script language='javascript'>
		 function getRefToDivMod( divID, oDoc ) {
         if( !oDoc ) { oDoc = document; }
         if( document.layers ) {
             if( oDoc.layers[divID] ) { return oDoc.layers[divID]; } else {
                 for( var x = 0, y; !y && x < oDoc.layers.length; x++ ) {
                     y = getRefToDivNest(divID,oDoc.layers[x].document); }
                 return y; } }
         if( document.getElementById ) { return oDoc.getElementById(divID); }
         if( document.all ) { return oDoc.all[divID]; }
         return document[divID];
		 }
		 function resizeWinTo(oW, idOfDiv ) {
         var oH = getRefToDivMod(idOfDiv); if( !oH ) { return false; }
         var oH = oH.clip ? oH.clip.height : oH.offsetHeight; if( !oH ) { return false; }
         var x = window; x.resizeTo( oW + 200, oH + 200 );
         var myW = 0, myH = 0, d = x.document.documentElement, b = x.document.body;
         if( x.innerWidth ) { myW = x.innerWidth; myH = x.innerHeight; }
         else if( d && d.clientWidth ) { myW = d.clientWidth; myH = d.clientHeight; }
         else if( b && b.clientWidth ) { myW = b.clientWidth; myH = b.clientHeight; }
         if( window.opera && !document.childNodes ) { myW += 16; }
         x.resizeTo( oW + ( ( oW + 200 ) - myW ), oH + ( (oH + 200 ) - myH ) );
         if( x.focus ) { x.focus(); }
		 }
		</script>

</head>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">


<%
String primary = request.getParameter("tr");
String secondary = request.getParameter("arg");
//Hack: since Java doesn't have built-in XSS escaping, exit the scriptlet and
//  use JSTL to do it, then pass back into the scriptlet
request.setAttribute("primary", primary);
request.setAttribute("secondary", secondary);
%>
<c:set var="primary" scope="request" value="${fn:escapeXml(primary)}" />
<c:set var="secondary" scope="request" value="${fn:escapeXml(secondary)}" />
<%
primary = request.getParameter("primary");
secondary = request.getParameter("secondary");
int kind = Annotation.CLASS_DECLARE;

String ret = "";

if ( (primary!=null) && !(primary.equals("")) && (secondary != null) && !(secondary.equals(""))) {

    // Connect the database.
    String schemaName = ChimeraProperties.instance().getVDCSchemaName();

    Connect connect = new Connect();
    DatabaseSchema dbschema = connect.connectDatabase(schemaName);
    Annotation annotation = null;

	  if (! (dbschema instanceof Annotation)) {
        ret = "<CENTER><FONT color= red>" + 
	      "The database does not support metadata!" +
	      "</FONT><BR><BR></CENTER>";
	  } else {
        try {
	          annotation = (Annotation)dbschema;
	          java.util.List list = annotation.loadAnnotation(primary, secondary, kind);
	          ret += "<div ID=\"txt\" style=\"left:0px;top:0px;text-align:center;\"><TABLE align='center' WIDTH=240>";
						// if (label != null) ret += "<TR><TH align='left'><HR>"+label;
	          ret += "</TH></TR>";	
            if (list!=null && !list.isEmpty() ) {
	              for (Iterator i = list.iterator(); i.hasNext();) {
										Tuple tuple = (Tuple)i.next(); 
										if ((tuple.getKey()).equals("description")) {
												ret += "<TR><TD><FONT SIZE=-1>" + tuple.getValue() + "</FONT></TD></TR>";
                    } //if description
                } //for
            } //if  list!null
	      } //try
	      catch (Exception e) {
            ret = "<CENTER><FONT color=red>" + 
	          "Error viewing metadata..." +
	          "</FONT><BR><BR>";
	          ret += e + "<BR></CENTER>";
	      }
    } //dbschema - instanceof Annotation

		// Added to help fix XSS fixes - JG 19Jul2018
		//request.setAttribute("ret", ret);
				
		if (dbschema != null)
    dbschema.close();
    if (annotation != null)
    ((DatabaseSchema)annotation).close();
%>
<body onLoad="resizeWinTo(300,'txt');" background="graphics/Quadrille.gif">
		<font face="ariel">
				<c:out value="${ret}" />
   <tr><td align="right"><HR><A HREF="javascript:window.close();"><FONT SIZE=-1>Close Window</FONT></A></td></tr></table><br>&nbsp;</div></FONT>

    <%
      }  //if good args
      else
      { 
      %>
      <b>Argument not properly described.</b>
      <%
      }
%>
</font>
</body>
</html>
