<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<% 
String label = request.getParameter("label");  //label you want to show
String primary = request.getParameter("tr");
String secondary = request.getParameter("arg");
int kind = Annotation.CLASS_DECLARE;
String message = "";
if ((primary!=null)&& !(primary.equals("")) && (secondary != null) && !(secondary.equals(""))) {
   // Connect the database.
   String schemaName = ChimeraProperties.instance().getVDCSchemaName();
   Connect connect = new Connect();
   DatabaseSchema dbschema = connect.connectDatabase(schemaName);
   Annotation annotation = null;
  if (! (dbschema instanceof Annotation)) {
      message = "The database does not support metadata!";
   } else {
      try {
        annotation = (Annotation)dbschema;
        java.util.List list = annotation.loadAnnotation(primary, secondary, kind);
        if (list!=null && !list.isEmpty() ) {
            for (Iterator i = list.iterator(); i.hasNext();) {
	            Tuple tuple = (Tuple)i.next(); 
	            if ((tuple.getKey()).equals("description")) {
	            	message += tuple.getValue();
                } //if description
              } //for
            } //if  list!null
        } //try
        catch (Exception e) {
            message = e.getMessage();
        }
    } //dbschema - instanceof Annotation
    if (dbschema != null)
         dbschema.close();
    if (annotation != null)
         ((DatabaseSchema)annotation).close();
}
request.setAttribute("message", message);
request.setAttribute("label", label);
%>     
<head><title>${label}</title>
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
<body onLoad="resizeWinTo(450,'txt');" background="graphics/Quadrille.gif">
<font face="ariel">
<table>
	<tr><td>${message}</td></tr>
    <tr><td align="right"><a href="javascript:window.close();">Close Window</a></td></tr>
</table>
</font>
</body>
</html>
