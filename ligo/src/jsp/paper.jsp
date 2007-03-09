<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<%@ page import="org.apache.regexp.*" %>
<%@ include file="common.jsp" %>

<% String title = "Edit Poster"; %>
<%
   String ret = "";
   String dfile = request.getParameter("posterName");
   if (dfile==null)
   {
   %>
   <H2><FONT color="red">No poster name has notb been chosen.</font></h2>
   <%
   }
   { // ok to display it. because poster name is passed.
   HashMap tags = new HashMap();

 
      // For all requests, render the page from the current template_paper.htmt .data file
      // for the poster name passed.
      // template.html determines fields to show on form, and the field types
      // poster.data supplies field values. If file not present, fields are empty
      // GRAPH and DATA files in poster directory determine drop-down menu values for figures
      
      // Read poster template

      String tfile = "template_paper.htmt"; //paper version of the template
      String template = "";
      try {

        FileReader fr = new FileReader(templateDir+tfile);
        int count = 0;
        char buf[] = new char[100000];
        count=fr.read(buf, 0, 100000);
        fr.close();
        template = String.valueOf(buf,0,count);
      }
      catch (Exception e) {
        out.println(" EXCEPTION! reading template" + " " + e.getMessage() );
      }

      // Read and store tags from poster data file if it exists

      File pf = new File(posterDir+dfile+".data");
      String pdata = "";
      if(pf.exists()) {

        // Read the poster data file

        try {
          FileReader fr = new FileReader(posterDir+dfile+".data");
          int count = 0;
          char buf[] = new char[100000];
          count=fr.read(buf, 0, 100000);
          fr.close();
          pdata = String.valueOf(buf,0,count);
        }
        catch (Exception e) {
          out.println(" EXCEPTION! reading template" + " " + e.getMessage() );
        }

        // Store poster data into hash table, keyed by "tagtype:tagname"

        RE re = new RE("%(FIG|PARA|WORDS):([A-Z0-9]+)%\\n(.*?\\n)%END%");
        re.setMatchFlags(RE.MATCH_SINGLELINE);
        int p=0;
        while (re.match(pdata,p)) {
          String tagtype = re.getParen(1);
          String tagname = re.getParen(2);
          String tagval = re.getParen(3).trim();
          p = re.getParenEnd(0);
//          if (tagtype.equals("FIG")) tagval = tagval.trim();
          tags.put(tagtype+":"+tagname, tagval);
        }
  

      // Merge tag values into html template, by iterating over hash
      // of tag values and inserting them into the template string;
      // then write template into (user's) poster_mgb.html file

        Iterator it = tags.keySet().iterator();
        while (it.hasNext()) {
          String key = (String) it.next();
          template = template.replaceAll("%"+key+"%", (String)tags.get(key));
        }
  // replace src=" with src="+ path to plots (in user area).
       template=template.replaceAll("src=\"","src=\""+plotDirURL);

      out.println(template);
      }
      else //file does not exist!
      {
      %>
         <H2><FONT color="red">Poster by this name does not exist.</font></h2>
      <%
      }
 } // test on null posterName passed.
%>

</BODY>
</HTML>
