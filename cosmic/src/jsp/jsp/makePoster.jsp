<%@ page import="org.apache.regexp.*" %>
<%@ include file="common.jsp" %>
<%@ page import="java.util.*" %>

<html>
<head>
    <title>Make-Edit Posters</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%@ include file="include/javascript.jsp" %>
<style type="text/css">
<!--
.displayArial {font-size:10pt;font-family: sans-serif}
-->
</style>

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Posters";
%>
<%@ include file="include/navbar_common.jsp" %>

<P>
<TABLE WIDTH=800 CELLPADDING=4>
<TR><TD   BGCOLOR="#408C66">
<FONT SIZE=+1 FACE=ARIAL color=black><B>Make or edit your poster.</B>
</TD></TR>
</TABLE>


<% 
String title = "Make/Edit Poster"; 
String dateString=new String();
GregorianCalendar cal = new GregorianCalendar();
Date currentDate=new Date();
cal.setTime(currentDate);
String year = cal.get(Calendar.YEAR) + "";
String month = 1 + cal.get(Calendar.MONTH) + "";
if(month.length() == 1){
    month = "0" + month;
}
String day = cal.get(Calendar.DAY_OF_MONTH) + "";
if(day.length() == 1){
    day = "0" + day;
}
dateString = month + "/";
dateString += day + "/";
dateString += year;
String singleQuote="&#39;";
String doubleQuote="&#34;";


boolean posterTitleEntered=false; //true if the title field is filled in by the user.
boolean posterNameEntered=false; //true if the field is filled in by the user.
String  posterName="";
String ret = "";
String dfile=""; //data file (e.g., poster.data)
   
String selectDefault = "Select graphic for figure.";
HashMap tags = new HashMap();
String pdata = ""; // data written to the poster.data file.

posterName=request.getParameter("posterName");
if (posterName != null)
{
    posterName=posterName.trim();
    if ((posterName.length() > 0))
    {
        posterNameEntered=true;
        posterName=posterName.replace(' ','_');
        posterName=posterName.replace('/','_');
        posterName=posterName.toLowerCase();

        dfile = posterName+".data";

    }
}

String posterTitle=request.getParameter("WORDS:TITLE");
if ( (posterTitle!=null) && (posterTitle.length() == 0 ))
{
        warn(out,"Please go back and enter the title for the poster.");
}
else posterTitleEntered=true;
String reqType = request.getParameter("button");

// If "Save" request, copy data from form fields to poster.data file

if (reqType != null && (reqType.equals("Make Poster")||reqType.equals("View Poster"))) {
    Enumeration fields = request.getParameterNames();
    while (fields.hasMoreElements()) {
        String name = (String) fields.nextElement();
        String val = request.getParameter(name);
        val=val.replaceAll("\"", doubleQuote); //Avoid double quotes
        RE re = new RE("(PARA|WORDS|FIG):([A-Z0-9]+)");
        if (val.length() > 0 && re.match(name) && !val.equals(selectDefault))
            pdata += "%" + name + "%\n" + val + "\n" + "%END%\n";
    }
    try {
        if (!posterNameEntered || !posterTitleEntered)
        {
           if (!posterNameEntered) {
            %>
               <center><font size="+2" color="red">Please go back and enter the filename for the poster.</font></center>

             <%
                     }
                     }
                     else
                     {
                         
                         // ensure the posterDir exists
                         new File(posterDir).mkdirs();

                         File f = new File(posterDir+dfile);
                         boolean fileExists = f.exists();  // we want to check before writing into rc.data so we don't fail.
                         if (!fileExists) {
                           // Make name more unique
                           //generate a unique filename to save as (uploadedimage-group-date format)
                            GregorianCalendar gc = new GregorianCalendar();
                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
                            String date = sdf.format(gc.getTime());
                            posterName=posterName+"_"+groupName+ "_" + eLab+"_"+date;
                            dfile=posterName+".data";
                            f = new File(posterDir+dfile);
                            // Add entry to rc.data for this file
                             boolean rcupdated = addRC(dfile, posterDir + dfile);
                             }   //if file exists
                          PrintWriter pw = new PrintWriter(new FileWriter(f));
                          pw.println(pdata);
                          pw.close();
                              
                          //get metadata 
                          String author=request.getParameter("PARA:AUTHORS");
                          author=author.replace('\n',' ');

                          boolean metaSuccess = false;
                          //start a new array
                          ArrayList meta = new ArrayList();


                          meta.add("year string " + groupYear);
                          meta.add("state string " + groupState);
                          meta.add("city string " + groupCity);
                          meta.add("school string " + groupSchool);
                          meta.add("teacher string " + groupTeacher);
                          meta.add("project string " + eLab);
                          meta.add("group string " + session.getAttribute("login"));
                          meta.add("type string " + "poster");
                          meta.add("title string "+ request.getParameter("WORDS:TITLE"));
                          meta.add("author string "+ author);
                          meta.add("date date " + dateString);
                          meta.add("name string " + dfile);
                          meta.add("plotURL string " + plotDirURL);

                          if(meta != null && dfile != null){
                              metaSuccess = setMeta(dfile, meta);
                           }
                     }   //if poster name and title entered
                 }   //try
                 catch (Exception e) { throw new ElabException("While saving poster",e); }
             }

             // For all requests, render the page from the current template.html and poster.data file
             // template.html determines fields to show on form, and the fiel types
             // poster.data supplies field values. If file not present, fields are empty
             // GRAPH and DATA files in poster directory determine drop-down menu values for figures

             // Read poster template

             String tfile = "template_poster.htmt";
             String template = "";
             try {

                 //      FileReader fr = new FileReader(pdir+tfile);
                 FileReader fr = new FileReader(templateDir+tfile);
                 int count = 0;
                 char buf[] = new char[100000];
                 count=fr.read(buf, 0, 100000);
                 fr.close();
                 template = String.valueOf(buf,0,count);
             }
             catch (Exception e) {
                 throw new ElabException("reading template", e);
             }

             // Read and store tags from poster data file if it exists - this can't work if you have no posterName in entry
             if (posterNameEntered && posterTitleEntered)  // if not entered, then we will use pdata that we built from input parameters.
             {
                 File physicalF = new File(posterDir+dfile);
                 pdata = "";
                 if(physicalF.exists()) {

                     // Read the poster data file

                     try {
                         FileReader fr = new FileReader(posterDir+dfile);
                         int count = 0;
                         char buf[] = new char[100000];
                         count=fr.read(buf, 0, 100000);
                         fr.close();
                         pdata = String.valueOf(buf,0,count);
                     }
                     catch (Exception e) {
                         throw new ElabException("reading template", e);
                     }
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
             }

             // Find files posted to plot directory

              
                    ArrayList figureObj = new ArrayList();
             String plotQuery="type=\'plot\' OR type=\'uploadedimage\' AND project=\'"+eLab+"\' AND group=\'" + groupName + "\'";
             ArrayList mylfnsmeta = null;
             mylfnsmeta = getLFNsAndMeta(out, plotQuery);
             if(mylfnsmeta != null) {
             String order = "name";
             MetaCompare mc = new MetaCompare();
             mc.setSortKey(order);
             Collections.sort(mylfnsmeta, mc);

             //       String[] lfnpfn = new String[2];
                   int fileNumber=0;
                   ArrayList lfnpfn = new ArrayList(2);
                     for(Iterator i=mylfnsmeta.iterator(); i.hasNext(); ){
                         ArrayList pair = (ArrayList)i.next();
                         String pfn = (String)pair.get(0);   // physical name
                         ArrayList metaTuples = (ArrayList)pair.get(1);

                         for(Iterator j=metaTuples.iterator(); j.hasNext(); ){
                             Tuple t = (Tuple)j.next();
                             String key = (String)t.getKey();
                             Object value = t.getValue();
                             if (key.equals("name")) {
                             //get this value for the logical name
                             //set the array elements for the figureObject
                              String lfn = (String)value;
                              if (pfn.endsWith(".gif") || pfn.endsWith(".jpg") || pfn.endsWith(".png") || pfn.endsWith(".jpeg")){
                                 lfnpfn.add(0,lfn);
                                lfnpfn.add(1,pfn);
                               //    out.write(fileNumber+ " lfn="+lfn+" pfn="+ pfn + "<BR>");
                                  figureObj.add(fileNumber,lfnpfn);
                                  lfnpfn = new ArrayList(2);
                                 fileNumber++;
                                 
                                }
                              }
                              
                             } // end of iteration through the metadata for the physical name associated with the logical name
                             
                         } //end of the iteration for each logical name


             } // end of test if query produced results
             %>
<!--
Show instructions
-->
<P>
<span class="displayArial">
                   <table width="600"><tr><td>
                                   <UL><font size="-1">
                                      <LI>Fill in all the fields including Poster File Name if it is missing. Your group name, e-Lab and date will be appended to this name and used as the name of the file on the server. Try to use a different name for each poster you make. To
                                       see the posters you have made, click <b>Edit Posters</b> above.
                                      <LI>To view the plots that you might want to include for the figures in your poster, click <B>View Plots</B> in the navigation bar. You can fill in fields for up to five figures. You don't have to fill them all in.
                                      <LI>Click <B>Make Poster</b> to save the data for the poster.
                                      </font></UL>
                                      </td></tr></table>
                                      </span>
 


<!--
Emit input form for replacement tags found in poster template
-->

<center>   <span class="displayArial">

        <FORM method=post>
           <TABLE width="650">
<%
                if (posterName==null) {posterName="";}
%>
                <TR><TD valign="top" align="right">Poster Filename:<br>(e.g.,lifetime_analysis)</td><td valign="top"><input type="text" size=50  name="posterName" value="<%=posterName%>"></td></tr>
      
<%
                RE re = new RE("%(PARA|FIG|WORDS):([A-Z0-9]+)%");
                int p=0; // search pointer
                String ht="";
                while (re.match(template,p)) {
                    String type = re.getParen(1);
                    String name = re.getParen(2);
                    String lowerPart= (name.substring(1,name.length())).toLowerCase();
                    String fixedName = name.substring(0,1)+ lowerPart;
                    String val = (String) tags.get(type+":"+name);
                    if ( (val == null) || (val.length()==0)) {
                        if (name.equals("DATE")) {
                            val=dateString;}
                        else {
                            val = "";
                        }
                    }
                    ht += "<TR>";
                    ht += "<TD align=right valign=top>" + fixedName + ":</TD>";
                    if (type.equals("PARA")) {
                        ht += "<TD><TEXTAREA name=" + type + ":" + name + " rows=6 cols=80>";
                        ht += val;
                        ht += "</TEXTAREA></TD></tr>";
                    }
                    else if (type.equals("WORDS")) {
                        val=val.replaceAll("\"", doubleQuote);
                        ht += "<TD><INPUT size=50 maxlength=1000 name=\"" + type + ":" + name + "\" value=\"" + val + "\"></TD></tr>\n";
                    }
                    else if (type.equals("FIG")) {
                        ht += "<TD><SELECT size=1 name=" + type + ":" + name + ">\n";
                        ht += "<OPTION>" + selectDefault + "\n";
                      ArrayList fo = new ArrayList();
                        if (figureObj.size() > 0) {
                            for (int i=0; i<figureObj.size(); i++) {
  
                            fo = (ArrayList)figureObj.get(i);
                              String optionLfn=(String)fo.get(0);
                             String optionPfn=(String)fo.get(1);
                               
                                String selected = ((optionPfn).equals(val) ? " SELECTED" : "");
                                ht += "<OPTION" + selected + " value=" + optionPfn + ">" + optionLfn  + "\n";
                            }
                        }

                        ht += "</SELECT></TD></tr>\n";
                    }
                    p = re.getParenEnd(0);
                }
                out.println(ht);

%> 
            <tr><td colspan="2" align="center">
            <INPUT type="submit" name="button" value="Make Poster"> <FONT SIZE="-1">To see poster, don't block popups!</FONT></td></tr>
            
        </FORM>
</TABLE>
</span></center>


<%
//this functionality is not working as of 8-19-04. Must go through search.jsp to view it...

if (reqType != null && reqType.equals("Make Poster")) {

//if (reqType != null && reqType.equals("View Poster")) {
    if (posterNameEntered && posterTitleEntered)
    {


        // If "Make Poster" request, merge tag values into html template, by iterating over hash
        // of tag values and inserting them into the template string;
        // then write template into (user's) poster_mgb.html file XXXX

        Iterator it = tags.keySet().iterator();
        while (it.hasNext()) {
            String key = (String) it.next();
            template = template.replaceAll("%"+key+"%", (String)tags.get(key));
        }

        // Write out the new poster

        try {
            String htmlName = posterName+".html";
            String fullPath=posterDir+htmlName;
            File f = new File(fullPath);
            PrintWriter pw = new PrintWriter(new FileWriter(f));
            pw.println(template);
            pw.close();
            // Add metadata to LFN for data file

            //String posterURL="http://blacknuss.cs.uchicago.edu:8082/cosmic/displayPoster.jsp?type=poster&posterName="+posterName;
            String posterURL="displayPoster.jsp?type=poster&posterName="+dfile;

            //String posterURL = posterDirURL + htmlName;
%>
            <SCRIPT LANGUAGE="JAVASCRIPT">openPopup("<%=posterURL%>","poster",700,900)</script>
<%
        }
        catch (Exception e) { throw new ElabException("writing poster",e); }
    }
}


%>

<hr></center>
</BODY>
</HTML>
