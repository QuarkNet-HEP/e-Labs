<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
     <% String titleLabel="";
      String lfnName="";
      String label = request.getParameter("name");  //label you want to show
     if (label!=null) {  
         titleLabel=label.replaceAll("_"," "); 
         lfnName="Glossary_"+label;}
      %>
     
<head><title><%=titleLabel%></title>
<%@ include file="include/javascript.jsp" %></head>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">


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
	          ret += "<TABLE WIDTH=240>";
	         // if (label != null) ret += "<TR><TH align='left'><HR>"+label;
	          ret += "</TH></TR>";	
              if (list!=null && !list.isEmpty() ) {
	              for (Iterator i = list.iterator(); i.hasNext();) {
		            Tuple tuple = (Tuple)i.next(); 
		            if ((tuple.getKey()).equals("description")) {
		                 ret += "<TR><TD><FONT SIZE=-1>" + tuple.getValue() + "</FONT></TD></TR>";
                      } //if description
                    if ((tuple.getKey()).equals("height")) {
                        %> 
                    <script language="javascript">
                    var NS = (navigator.appName=="Netscape")?true:false;
                    function fitHeight() {
                        iHeight = (NS)?window.innerHeight:document.body.clientHeight;
                               
                        iHeight = <%=tuple.getValue()%> - iHeight;
                        window.resizeBy(0, iHeight);
                        self.focus();
                    };
                    </script>
                    <%
                      } //if height                   
                    } //for
                  } //if  list!null
	          } //try
	          catch (Exception e) {
                  ret = "<CENTER><FONT color=red>" + 
	              "Error viewing glossary..." +
	             "</FONT><BR><BR>";
	              ret += e + "<BR></CENTER>";
	          }
           } //dbschema - instanceof Annotation
          if (dbschema != null)
	        dbschema.close();
          if (annotation != null)
              ((DatabaseSchema)annotation).close();
     %>
<body onLoad="fitHeight()" background="graphics/Quadrille.gif">

    <%=ret%>
   <tr><td align="right"><HR><A HREF="javascript:window.close();"><FONT SIZE=-1>Close Window</FONT></A></td></tr></table></FONT>

    <%
      }  //if good args
      else
      { 
      %>
      <b>Glossary term not properly described.</b>
      <%
      }
%>
