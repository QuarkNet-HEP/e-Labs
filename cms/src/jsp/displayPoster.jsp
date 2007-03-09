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
   String templateType = request.getParameter("type"); // paper or poster
   String plotURL= request.getParameter("plotURL"); // URL for plots
   if (plotURL==null) plotURL="";
   if (dfile==null)
   {
   %>
   <H2><FONT color="red">No poster name has notb been chosen.</font></h2>
   <%
   }
   { // ok to display it. because poster name is passed.

                         	            // Lookup entry to rc.data for this file
  	 boolean c_rc = false;
	 ChimeraProperties props = ChimeraProperties.instance();	
	 String rcName =  props.getRCLocation();
     //String lfn=dfile +".data";
     String lfn = dfile;
     //Tibi and Liz
	//Catalog rc = new Catalog(rcName, "local");
	 //String pfn = rc.lookup("local", lfn);
	//String pfn="/var/tmp/quarknet-m/tomcat/webapps/elab/cms/output/AY2006/IN/notre_dame/ND_QN_Center/Beth_Marchant/cmsguest/cms/posters/"+dfile;	
	String pfn=System.getProperty("portal.users")+(plotURL.substring(0,plotURL.length()-6)).substring(6)+"posters/"+dfile;
	
	//out.write("plotURL "+plotURL);
	//out.write("pfn is "+ pfn);



   HashMap tags = new HashMap();

 
      // For all requests, render the page from the current template_paper.htmt .data file
      // for the poster name passed.
      // template.html determines fields to show on form, and the field types
      // poster.data supplies field values. If file not present, fields are empty
      // GRAPH and DATA files in poster directory determine drop-down menu values for figures
      
      // Read poster template

      String tfile = "template_"+templateType+"-cms.htmt"; //paper version of the template
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

      File pf2 = new File(pfn);
      String pdata = "";
      if(pf2.exists()) {

        // Read the poster data file

        try {
         // FileReader fr = new FileReader(posterDir+dfile+".data");
          FileReader fr = new FileReader(pfn);
          int count = 0;
          char buf[] = new char[100000];
          count=fr.read(buf, 0, 100000);
          fr.close();
          pdata = String.valueOf(buf,0,count);
        }
        catch (Exception e) {
          out.println(" EXCEPTION! reading poster file" + " " + e.getMessage() );
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
        String prevKey = null;
        while (it.hasNext()) {
            String key = (String) it.next();
            StringBuffer sb = new StringBuffer((String)tags.get(key));
            // Have to write a down and dirty replace for the dollar-sign character. It will throw 
            // an out of bounds exception if left to its own devices.
            int i = sb.indexOf("$", 0);
            while (i >= 0 && i < sb.length()) {
                sb = sb.insert(i, '\\');
                i += 2;
                i = sb.indexOf("$", i);
            }
            template = template.replaceAll("%"+key+"%", sb.toString());
        }
// replace all the empty information with "not provided"
       template=template.replaceAll("%PARA:ABSTRACT%","Not entered"); 
       template=template.replaceAll("%PARA:PROCEDURE%","Not entered"); 
       template=template.replaceAll("%PARA:RESULTS%","Not entered"); 
       template=template.replaceAll("%PARA:CONCLUSION%","Not entered");
       template=template.replaceAll("%PARA:AUTHORS%","Not entered");
       template=template.replaceAll("%WORDS:TITLE%","Not entered"); 
       template=template.replaceAll("%WORDS:SUBTITLE%","Not entered"); 
        if (templateType.equals("paper"))
        {
// replace src=" with src="+ path to plots (in user area).
          template=template.replaceAll("src=\"","src=\""+plotURL); //really only matters for paper
           template=template.replaceAll("%WORDS:CAPTION1%",""); 
           template=template.replaceAll("%WORDS:CAPTION2%",""); 
           template=template.replaceAll("%WORDS:CAPTION3%",""); 
           template=template.replaceAll("%WORDS:CAPTION4%",""); 
           template=template.replaceAll("%WORDS:CAPTION5%",""); 
           template=template.replaceAll(plotURL+"%FIG:FIGURE1%",""); 
           template=template.replaceAll(plotURL+"%FIG:FIGURE2%",""); 
           template=template.replaceAll(plotURL+"%FIG:FIGURE3%",""); 
           template=template.replaceAll(plotURL+"%FIG:FIGURE4%",""); 
           template=template.replaceAll(plotURL+"%FIG:FIGURE5%",""); 
       }

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
