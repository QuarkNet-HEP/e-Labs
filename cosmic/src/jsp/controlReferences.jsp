<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<html>
<head>
<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>
<%@ include file="include/jdbc_userdb.jsp" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<title>Upload/Download References</title>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>
<BR>

</head>
<body>
<div align="center">
<%

//LQ - see if admin will work here instead or else someone with admin role. July 28, 2006
//Permission to access this page restricted to development team
if (!(session.getAttribute("UserName").equals(elabRefMaker)))
{
    warn(out, "You do not have permission to access this page!");
}
else
{
%>

<%
//perform the metadata search
ArrayList lfnsmeta = null;
String q="";
String type = null;

DiskFileUpload fu = new DiskFileUpload();

if(fu.isMultipartContent(request)){
    fu.setSizeMax(10*1024*1024);    //10MB max
    //if a file is to be uploaded
    String origName=""; 
    FileItem uploadedImage = null;  //to be set in the loop
    boolean Set_Database = true;
    try {
    java.util.List fileItems = fu.parseRequest(request);
    for(Iterator i=fileItems.iterator(); i.hasNext(); ){
        FileItem fi = (FileItem)i.next();
        if(fi.isFormField()){
            String fieldName = fi.getFieldName();
            /*if(fieldName.equals("filename_upload")){
                origName = fi.getString();
                if(origName.equals("")){
                    throw new IOException("Please enter the name of your file.");
                }
            } */ //Disabled Functionality, now is just type.t
            /* if(fieldName.equals("database_chk")){
                if (fi.getString().equals("checked"))
                {
                    Set_Database = true;
            
                }
             } */ //Disabled Functionality, Set Database is now always true
            if(fieldName.equals("htype")){
                type = fi.getString();
            }
        }
        else{   //it's the uploaded file
            uploadedImage = fi;
           // FileReader toload =new FileReader(new File(fi.getName()));
           //File cfile = new File(fi.getName());
            if(fi.getSize() <= 0){
                throw new IOException( "Your image is 0 bytes in size.  You must upload an image which contains some data!");
            }
        }
    }
            if (!(type.equals("reference")||type.equals("FAQ")||type.equals("glossary")||type.equals("news")))
                throw new IOException("Unable to determine type.  Please select glossary or reference.");
    
            q="type=\'" + type + "\'  and  project=\'" + eLab + "\'";
            lfnsmeta = getLFNsAndMeta(out, q);
            origName = type + ".t";
            // instead of writing this file in cosmic for all e-Labs, we should use the eLab variable to set the proper directory; LQ 7/27/2006
           // String fpath = application.getRealPath("/")+"cosmic/"+origName;
            String fpath = application.getRealPath("/")+ eLab + "/"+origName;
            File tosave=new File(fpath);
            uploadedImage.write(tosave);
    
            %><font color = 'green' size='14'>Written Successfully to <%=origName%>!</font><br><%
            //cfile.close();
            if (Set_Database)
            {
                //Clears database
                if (lfnsmeta != null)
                {
                    for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
                        ArrayList pair = (ArrayList)i.next();
                        String lfn = (String)pair.get(0);
                        deleteLFNMeta(lfn);
                        out.println(lfn+" deleted.<br>");
                    } // lfnsmeta, i
                } //else already cleared
                %>Deletion successful!!<br><%
         
                //reads the newly created file into the Database
                    FileReader fin = new FileReader(fpath);
                    BufferedReader br = new BufferedReader(fin);
          
                    String line = null;
                    while( (line = br.readLine()) != null)
                    {
                        String name = line;
                        // setup
                        ArrayList metaAdd = null;
                        metaAdd = new ArrayList();
                        metaAdd.add("type string "+type);
                        metaAdd.add("project string "+eLab);

                        metaAdd.add("name string "+name);
                        //metaAdd.add("height string "+br.readLine());

                        String info = "";
                        boolean isFirst = true;
                        line = br.readLine();
                        while(!line.equals("-END-"))
                        {
                            if (isFirst)
                                isFirst = false;
                            else
                                info += "\n";
                            info += line;
                            line = br.readLine();
                        }
                        metaAdd.add("description string "+ info); 
                        
                        boolean metaSuccess = setMeta(name, metaAdd);
                        if (!metaSuccess) throw new IOException("Problem entering " + name + "  into database.");
                    }
                    %><font color = 'green' size='14'>Written Successfully to <%=type%> Database!</font><br><%
                } 
            }catch (IOException e) 
                {
                    %> <font color='red'>Cannot write to <%=type%> Database! <%=e%></font><%
                    //warn(out, "Exception: " + e);
                }
            
}

if (type == null)
    type = request.getParameter("type");
if (type == null)
    type = "NA";
String format = request.getParameter("format");
%>
				<table width="800" cellpadding="4">
					<tr>
						<td>
							&nbsp;
						</td>
					</tr>
					<tr>
						<td class="library_header">
							
									Enter/Update References/Glossary/FAQ/News items.
								
						</td>
					</tr>
				</table>

<table width="700"><tr><th><FONT FACE=ARIAL>Select an action and item type from the pull-downs and click <B>Go!</b>.</FONT></th></tr>
<tr><td><UL>
<LI>Download- means to copy data from the server to your local computer. You can download all the references you have defined.
<LI>Upload - means copy data in a local file on your computer to the database on the server. You can upload multiple item definitions at once instead of using <B>Add</B> to work with one at at time. Choose the item type with the radio buttons and use the last form on this page to browse your computer for the file and click <b>Upload</b>.  It is important to have the references in your file in standard format.  Use with caution because it will delete any current references you have. 
</UL></td></tr></table>
<center>
<form action='searchReference.jsp' name='action_form' method=get>
<select name="f">
<option value="view"<%if (type.equals("NA")) out.print(" selected"); %>>View
<option value="delete">Delete
<option value="upload">Upload
<option value="download"<%if (!type.equals("NA")) out.print(" selected"); %>>Download
<option value="add">Add
</select>
<select name="t">
<option value="reference"<%if (type.equals("reference")) out.print(" selected"); %>>Reference
<option value="glossary"<%if (type.equals("glossary")) out.print(" selected"); %>>Glossary
<option value="FAQ"<%if (type.equals("FAQ")) out.print(" selected"); %>>FAQ 
<option value="news"<%if (type.equals("news")) out.print(" selected"); %>>News
</select>
Item(s).<br>
<input type='submit' name='submit' value='Go!'>
</form>
</center>
<br><Br><%
if (type == "NA") {
     %>
     <HR> Content Developers: Do not select "SQL"! It's here for the developers of the new User Database. <HR>
    <form name ="file_form" method =" get">
    <label><input type = 'radio' name = 'type' value='reference' onChange="document.upform.htype.value = this.value" checked='true'> References</label>
    <label><input type = 'radio' name = 'type' value='FAQ' onChange="document.upform.htype.value = this.value"> FAQ</label>
    <label><input type = 'radio' name = 'type' value='news' onChange="document.upform.htype.value = this.value"> News</label>
    <label><input type = 'radio' name = 'type' value='glossary' onChange="document.upform.htype.value = this.value"> Glossary</label><br><hr>
    Download data from Server<br><br>
    <% //<label>Please enter a filename (e.g. data.dat)
    //<input type='text' name='filename'i value='data.t'></label><br><br>%>
    <label><input type="radio" checked="checked" name="format" value="Normal">Normal</label><br>
    <label><input type="radio" name="format" value="SQL">SQL</label><br>
    <input type='submit' value="Download"><br>
    <hr>
    </form>
    <form name ="upform" method ="post" enctype="multipart/form-data">
    Upload data onto Server (make sure your file has the correct format.)<br><br>
    <label>Choose a local file 
    <input type='file' name='filename_user'></label><br><br>
    <% //<label>Please enter a filename (e.g. data.dat)
    //<input type='text' name='filename_upload' value='data.t'></label><br><br>
    //<label>Load into the Database <input type='checkbox' name='database_chk' value="checked"></label><br><br> %>
    <input type='hidden' name='htype' value='reference'>
    <input type='submit' value="Upload"><br>
    </form>
    <%
} 
else {
    try {
        // BufferedWriter myout = new BufferedWriter(new FileWriter("ref.dat"));
        if (!(type.equals("reference")||type.equals("FAQ")||type.equals("glossary")||type.equals("news")))
            throw new IOException("Unable to determine type.  Please select glossary, FAQ, news, or reference.");       
        String filename = type+".t"; // request.getParameter("filename"); // Disabled feature
        // instead of writing this file in cosmic for all e-Labs, we should use the eLab variable to set the proper directory; LQ 7/27/2006
       // String fpath = application.getRealPath("/")+"cosmic/"+filename;
        String fpath = application.getRealPath("/")+ eLab +"/"+filename;
        FileWriter myout = new FileWriter(fpath,false);


        q="type=\'" + type + "\'  and  project=\'" + eLab + "\'";
       // q="type=\'" + type + "\'";
        lfnsmeta = getLFNsAndMeta(out, q);
        
        if (lfnsmeta == null)
        {
            warn(out, "There are no items to save to file!");
        }
        else
        {
        for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
            ArrayList pair = (ArrayList)i.next();
            String lfn = (String)pair.get(0);
            ArrayList metaTuples = (ArrayList)pair.get(1);
            String refHeight = "250";
            String info = " ";

            //create the HashMap of metadata Tuple values
            for(Iterator j=metaTuples.iterator(); j.hasNext(); ){
                Tuple t = (Tuple)j.next();
                if ((t.getKey()).equals("description")) info= (String) t.getValue();
                //if ((t.getKey()).equals("height")) refHeight= (String) t.getValue();
 
            } // metaTuples, j
            if (format!=null && format.equals("SQL"))
            {
                if (type.equals("glossary"))
                {
                    myout.write("alter table set default id=MAX(id)+1;\n");
                    info = info.replaceAll("'","\\\\'");
                    lfn = lfn.replaceAll("Glossary_","");
                    info = info.replaceAll("<br>","<br/>");
                    myout.write("insert into comment (body, discriminator, is_read, title) values ('" + info + "','Glossary', 't', '" + lfn + "');\n");
                    myout.write("alter table drop default;\n");
                }
                if (type.equals("reference"))
                {
                    info = info.replaceAll("'","\\\\'");
                    info = info.replaceAll("<br>","<br/>");
                    lfn = lfn.replaceAll("Reference_","");
                    myout.write("update comment set body='"+info+"' where discriminator='Milestone' and  name='"+lfn+"';\n");
                }
             }
            else{   
                myout.write(lfn);
                myout.write("\n");
                //myout.write(refHeight);
                myout.write(info);
                myout.write("\n-END-\n");
                }

        } // lfnsmeta, i
            myout.close();
        %><font color = 'green' size='18'>Written Successfully to <%=filename%>!</font><br><%
                %><h2><a href = "<%=filename%>"> Open/Download</a></h2>
<br><%
        }
    } 
    catch (IOException e) {
   %> <font color='red'> ERROR! <%=e%></font> <%
       }
}
}
            %> 
</div>
</body>
</html>        
