<script language="JavaScript" type="text/JavaScript">
<!--
function MM_swapImgRestore() { //v3.0
      var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
      var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
              var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
                      if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.01
      var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
              d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
        if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
          for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
            if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
      var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
             if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script> 
<%@ include file="javascript.jsp" %>
</head>

<%
// define separate project variable from project used in other jsp files because we may not necessarily have defined it yet or it may not be needed
String curProject = "cms";
if (!headerType.equals("Data")) {
%>
    <body onLoad="MM_preloadImages('graphics/home_button.jpg','graphics/library_button.jpg','graphics/upload_button.jpg','graphics/data_button_alt.jpg','graphics/poster_button.jpg','graphics/site_button.jpg','graphics/assess_button.jpg')">
<%
} else {
%>
    <body onLoad="dataOnLoad()">
<%
}
%>

 <div align="center">
<table width="819" style='align:center;position:varible; background-image: 
     url("graphics/cms_poster_horizontal_final.jpg"); background-repeat: no-repeat; border: 
       2 ' cellpadding=0 cellspacing=0 border=0>
    <tr height="150">
        <td valign="top" align="right">

<%
       String imageType="jpg";
       if (headerType.equals("Teacher") || headerType.equals("Project") )
       {
                   imageType="gif";

       }
       String teacherDump = "";
        String thisPage = request.getServletPath();
        // This makes Marge happy.  :)
        if (thisPage.startsWith("/"+curProject+"/teacher") || thisPage.startsWith("/"+curProject+"/notes") ||
            thisPage.startsWith("/"+curProject+"/standards") || thisPage.equals("/"+curProject+"/site-map.jsp") ||
            thisPage.startsWith("/"+curProject+"/registration") || thisPage.startsWith("/"+curProject+"/project")) {
            teacherDump = "/"+curProject+"/teacher.jsp";
        }
            if (session.getAttribute("login") != null ) {
%>
                <font color=FFFFFF  face="arial">
                    Logged in as group: <a href="userinfo.jsp" class="log"><FONT color=#CCFF66><%= session.getAttribute("login") %></FONT></a>
                    <img src="graphics/spacer.png" width="70" height="1" valign="top"><a href="logout.jsp?prevPage=<%=teacherDump%>" class="log"><FONT color=#CCFF66>Logout</FONT></a>
                    <IMG SRC="graphics/spacer.png" width="10" height="2"><br>
<%
                    if (session.getAttribute("role") != null && session.getAttribute("role").equals("teacher")) { 
                        out.write("<a href=\"javascript:openPopup('showLogbookT.jsp','log',800,600 )\">");
                    } else {
                        out.write("<a href=\"javascript:openPopup('showLogbook.jsp','log',800,600)\">");
                    }
%>
                    <FONT color="#CCFF66">My Logbook</FONT></a><IMG SRC="graphics/spacer.png" width="10" height="2">
                </font>
<%
		    }
            //do not show the "Login" message in the navbar on the home page
		    else if(!headerType.equals("Home") && !teacherDump.equals("/"+curProject+"/teacher.jsp")){
		    %>
                <font color="#CCFF66" size=-1>
                    <a href="login.jsp" class="log">Login</a>
                </font><IMG SRC="graphics/spacer.png" width="10" height="2">
<%
		    }
%>
        </td>
    </tr>
    </table>
<%@ page import="java.util.*" %>




<%
//create the arrays of images and links we're going to display in the table
ArrayList mainImages = new ArrayList();
ArrayList mainLinks = new ArrayList();
ArrayList subImages = new ArrayList();
ArrayList subLinks = new ArrayList();
if(headerType != null){
    mainImages.add("home_button");
    mainLinks.add("home.jsp");
    mainImages.add("spacer");
    mainLinks.add("");
    mainImages.add("library_button");
    mainLinks.add("library.jsp");
    mainImages.add("spacer");
    mainLinks.add("");
    
    String role = (String)session.getAttribute("role");
    //if(role != null && (role.equals("upload") || role.equals("teacher"))){
    //    mainImages.add("upload_button");
    //    mainLinks.add("upload.jsp");
   // mainImages.add("spacer");
   // mainLinks.add("");
   // }

    mainImages.add("data_button");
    mainLinks.add("search.jsp");
    mainImages.add("spacer");
    mainLinks.add("");
    mainImages.add("poster_button");
    mainLinks.add("poster.jsp");
    mainImages.add("spacer");
    mainLinks.add("");
    mainImages.add("site_button");
    mainLinks.add("site-index.jsp");
    mainImages.add("spacer");
    mainLinks.add("");
    mainImages.add("assess_button");
    mainLinks.add("rubric.html");
    if(headerType.equals("Home")){
        mainImages.set(mainImages.indexOf("home_button"), "home_button_alt");
        mainImages.set(mainImages.indexOf("library_button"), "library_button_alt");
        if(mainImages.indexOf("upload_button") != -1){
            mainImages.set(mainImages.indexOf("upload_button"), "upload_button_alt");
        }
        mainImages.set(mainImages.indexOf("data_button"), "data_button_alt");
        mainImages.set(mainImages.indexOf("poster_button"), "poster_button_alt");
        mainImages.set(mainImages.indexOf("site_button"), "site_button_alt");
        mainImages.set(mainImages.indexOf("assess_button"), "assess_button_alt");
    }
    else if(headerType.equals("Upload")){
        mainImages.set(mainImages.indexOf("upload_button"), "upload_button_alt");

        subImages.add("upload_data_button");
        subLinks.add("upload.jsp");
        subImages.add("upload_geo_button");
        subLinks.add("geo.jsp");
        subImages.add("spacer");
        subImages.add("spacer");
    }
    else if(headerType.equals("Data")){
		mainImages.set(mainImages.indexOf("data_button"), "data_button_alt");
        subImages.add("shower_depth_button");
        subLinks.add("ogre-base.jsp?analysis=shower_depth");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("lateral_size_button");
        subLinks.add("ogre-base.jsp?analysis=lateral_size");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("beam_purity_button");
        subLinks.add("ogre-base.jsp?analysis=beam_purity");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("resolution_button");
        subLinks.add("ogre-base.jsp?analysis=resolution");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("data_view_button");
        subLinks.add("search.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("data_view_plots_button");
        subLinks.add("search.jsp?t=plot&f=view");
    }
    else if(headerType.equals("Posters")){
        mainImages.set(mainImages.indexOf("poster_button"), "poster_button_alt");

        subImages.add("poster_new_button");
        subLinks.add("makePoster.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("poster_edit_button");
        subLinks.add("editPosters.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("poster_view_button");
        subLinks.add("search.jsp?t=poster&f=view");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("poster_delete_button");
        subLinks.add("search.jsp?t=poster&f=delete");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("poster_view_plots_button");
        // No better way...we parse...userArea...sad...
        String groupName2 = null;
        String userArea2 = (String) session.getAttribute("userArea");
        String eLab2 = (String) session.getAttribute("appName");
        if (userArea2 != null){
            String[] sp2 = userArea2.split("/");
            groupName2 = sp2[5];

            subLinks.add("search.jsp?t=plot&f=view&q=type='plot'+OR+type='uploadedimage'+AND+project='"+eLab2+"'+AND+group+CONTAINS+'"+groupName2+"'");
         }
        else
        {
            subLinks.add("search.jsp?t=plot&f=view");
        }
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("upload_image_button");
        subLinks.add("uploadImage.jsp");
    }
    else if(headerType.equals("Library")){
        mainImages.set(mainImages.indexOf("library_button"), "library_button_alt");
        subImages.add("library_basics_button");
        subLinks.add("research_basics.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("library_study_button");
        subLinks.add("milestones_map.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("library_resources_button");
        subLinks.add("resources.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("library_big_button");
        subLinks.add("first.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("library_faqs_button");
        subLinks.add("FAQ.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("library_site_button");
        subLinks.add("first_web.jsp");
    }
    else if(headerType.equals("Site Index")){
        mainImages.set(mainImages.indexOf("site_button"), "site_button_alt");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("site_index_subbutton");
        subLinks.add("site-index.jsp");
        subImages.add("spacer");
        subLinks.add("");
        subImages.add("site_overview_button");
        subLinks.add("site-map-anno.jsp");
     }
    else if(headerType.equals("Teacher")){
        //clear the main images and only display the following images on the main header bar
        mainImages.clear();
        mainLinks.clear();

        mainImages.add("teacher_home_button");
        mainLinks.add("teacher.jsp");
        mainImages.add("teacher_class_notes_button");
        mainLinks.add("notes.jsp");
        mainImages.add("teacher_standards_button");
        mainLinks.add("standards.jsp");
        mainImages.add("teacher_site_index_button");
        mainLinks.add("site-map.jsp");
        mainImages.add("teacher_registration_button");
        mainLinks.add("registration.jsp");
        mainImages.add("teacher_student_home_button");
        // mainLinks.add("http://quarknet.fnal.gov/grid/");
        mainLinks.add("home.jsp");
    }
    else if(headerType.equals("Project")){
        //clear the main images and only display the following images on the main header bar
        mainImages.clear();
        mainLinks.clear();

        mainImages.add("teacher_home_button");
        mainLinks.add("teacher.jsp");
        mainImages.add("teacher_student_home_button");
        // mainLinks.add("http://quarknet.fnal.gov/grid/");
        mainLinks.add("home.jsp");
    }
}
%>
    <table border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor=FFFFFF height=40>
        <td colspan="2" align="center">
<%
            for(int i=0; i < mainImages.size(); i++){
                String image = (String)mainImages.get(i);
                String link = (String)mainLinks.get(i);
                if(image.equals("spacer")){
%><img src="graphics/spacer_button.jpg" width=45 height=40 border=0><%}else{

%><a href="<%=link%>" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('<%=image%>','','graphics/<%=image%>_alt.<%=imageType%>',1)"><img src="graphics/<%=image%>.<%=imageType%>" name="<%=image%>" border=0></a><%}
            }
%>
        </td>
    </tr>
<%
    //if we have sub menu images to display...
    if(subImages.size() != 0){
%>
        <tr bgcolor=FFFFFF height=22>
            <td colspan="2" align="center">
<%
                for(int i=0; i < subImages.size(); i++){
                    String image = (String)subImages.get(i);
                    if(image.equals("spacer")){
%><img src="graphics/spacer_button.jpg" width=45 height=40 border=0><%
                    }
                    else{
                        String link = (String)subLinks.get(i);
%><a href="<%=link%>" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('<%=image%>','','graphics/<%=image%>_alt.jpg',1)"><!-- <img src="images/button_images/<%=image%>.jpg" name="<%=image%>" width=100 height=19 border=0></a> --><img src="graphics/<%=image%>.jpg" name="<%=image%>" border=0></a><%
                    }
                }
%>
        </td>
    </tr>
<%
    }   //if we have sub menu images to display
%>
</table>
</div>