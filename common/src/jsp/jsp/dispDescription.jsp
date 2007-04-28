<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
     <% String label = request.getParameter("label");  //label you want to show
      %>
     
<head><title><%=label%></title>
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


      if ( (primary!=null)&& !(primary.equals("")) && (secondary != null) && !(secondary.equals(""))) {

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
</font>
</body>
</html>
