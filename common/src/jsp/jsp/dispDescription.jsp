<%-- This page provides pop-up descriptions of analysis parameters to the user via ?-boxes in the e-Lab interfaces. --%>
<%-- NB that Tuple, Annotation, etc. are used here from the VDS packages org.griphyn.vdl, which we don't have source code for - JG 19Jul2018 --%>
<%-- XSS PROBLEMS:
The GET parameters "tr" and "arg" are used to form "primary" and "secondary", which are passed to Annotation.loadAnnotation() to form "list".  The elements of "list" are used to form "ret", which is printed to file as a String of HTML.
If "tr" and "arg" contain JavaScript, it will be included in the file served to the user.  The exact mechanism by which this happens is obscured by the passage through Annotation, which we don't have source code for.  Thus, our only option for escaping malicious JavaScript input is to XML-escape the elements of "list" as we construct "ret".  This also escapes valid links that we want to print to the page, however.

If XML is not properly escaped, the URL
https://i2u2-dev.crc.nd.edu/elab/cosmic/jsp/dispDescription.jsp?tr=I2U2.Cosmic::PerformanceStudy'"()&%<acx><ScRiPt >9wq6(9625)</ScRiPt>
https://i2u2-dev.crc.nd.edu/elab/cosmic/jsp/dispDescription.jsp?tr=“/><script>alert(1)</script>
illustrates the XSS vulnerability

This page badly needs a rewrite.  Eliminate scriptlets and use JSP and the taglibs to construct the page's HTML layout instead of returning it as a String.
1) Figure out what Annotation.loadAnnotation() is doing
2) Find a new way to map from its inputs to its outputs that lets us control XML-escaping more granularly.
3) Eliminate the use of Annotation if possible

1) A typical value of "tr" is `I2U2.Cosmic::FluxStudy`
	 A typical value of "arg" is `flux_binWidth`
	 For these values, the returned pop-up text reads
	 ""
The time interval for data to fall into in a bin of a histogram, shown as vertical bars. The histogram represents the frequency ( the number of times ) data values fall into each bin. Try Interactive Histogram.
""
	This text is drawn from the `anno_text` table of the Postgres DB vds_cosmic2_testing (dev) or vds2006_1022 (production)	

- JG 2Aug2018
--%>.

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.io.*" %>
<%-- java.util.Iterator --%>
<%@ page import="java.util.*" %>

<%-- The following five packages do not exist in the repo or on the
		 server as of 20Jul2018, though there is documentation for them.
		 They may be unused in this page: --%>
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
											 // Hack: since Java doesn't have built-in XSS escaping, exit the
											 //   scriptlet and use JSTL to do it, then pass back into the scriptlet
											 String content = (String)tuple.getValue();
											 request.setAttribute("content", content);
											 %>
											 <c:set var="content" scope="request" value="${fn:escapeXml(content)}" />
											 <%
											 content = (String)request.getAttribute("content");

											 ret += "<TR><TD><FONT SIZE=-1>" + content + "</FONT></TD></TR>";
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
				<%=ret%>
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
<%-- For a successful construction of the description pop-up, the following close-font appears
to be superfluous: --%>
</font>
</body>
</html>
