<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<%@ include file="include/javascript.jsp" %>
     <% String titleLabel="";
      String lfnName="";
     String label = request.getParameter("name");  //label you want to show
     String type = request.getParameter("type");  //label you want to show
     if (label!=null) {  
         titleLabel=label.replaceAll("_"," "); 
        if (type.equals("glossary"))
            lfnName="Glossary_"+label;
         if (type.equals("reference"))
            lfnName="Reference_"+label;
     }
      %>
     
<head><title><%=titleLabel%></title>
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
        x.focus();
}
</script>
</head>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">

<center>

<%
      String primary = lfnName;
      String secondary = "";
      int kind = Annotation.CLASS_FILENAME;

      String ret = "";


      if ( (primary!=null) && !(primary.equals("")) ) {

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
	          ret += "<div ID=\"txt\" style=\"left:0px;top:0px;text-align:center;\"><TABLE align=\"center\" WIDTH=\"240\">";
	         // if (label != null) ret += "<TR><TH align='left'><HR>"+label; 
	         // ret += "</TH></TR>";	
              if (list!=null && !list.isEmpty() ) {
	              for (Iterator i = list.iterator(); i.hasNext();) {
		            Tuple tuple = (Tuple)i.next(); 
		            if ((tuple.getKey()).equals("description")) {
		                 ret += "<TR><TD>" + tuple.getValue() + "</TD></TR>";
                      } //if description
                    
                    } //for
                  } //if  list!null
	          } //try
	          catch (Exception e) {
                  ret = "<CENTER><FONT color=red>" + 
	              "Error viewing " +  
                  type + "..." +
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

    <%=ret%>
   <tr><td align="right"><HR><A HREF="javascript:window.close();">Close Window</A></td></tr></table><br></div>

    <%
      }  //if good args
      else
      { 
      %>
      <b><%=type%> not properly described.</b>
      <%
      }
%>

</body>
</html>
