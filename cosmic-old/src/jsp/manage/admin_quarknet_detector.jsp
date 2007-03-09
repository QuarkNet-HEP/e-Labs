<%@ page import="gov.fnal.elab.db.*" %>
<%@ page import="gov.fnal.elab.cosmic.db.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../common.jsp" %>
<%@ include file="manage_inc.jsp" %>

<%
User me = User.findByUsernameAndPassword("paul", "junk");
%>

<html>
<head>
    <title>Admin QuarkNet Detector</title>
</head>

<body>

<%=headerString("QuarkNet Detector Administration")%>
<hr>

<%
String submitType = request.getParameter("submitType");
String action = request.getParameter("a");
if(submitType != null){
    if(submitType.equals("create")){
        /**
         * Create a new detector
         */
        QuarkNetDetector newDetector = new QuarkNetDetector();

        String serialNumber = request.getParameter("serialNumber");

        newDetector.setSerialNumber(Integer.parseInt(serialNumber));

        newDetector.save();
%>
        <font color="green"><a href="admin_quarknet_detector.jsp?a=edit&n=<%=serialNumber%>">New detector created (click to continue)</a><br>
<%
    }
    if(submitType.equals("set_teacher")){
        /**
         * Set the teacher who owns a detector
         */
        String serialNumber = request.getParameter("serialNumber");
        QuarkNetDetector detector = QuarkNetDetector.findByNumber(serialNumber);
        
        String[] f = request.getParameterValues("set");
        if(f != null){
            Set set = new HashSet();
            for(int i=0; i<f.length; i++){
                QuarkNetTeacher t = QuarkNetTeacher.findById(f[i]);
                if(t != null){
                    set.add(t);
                }
            }
            detector.setOwners(set);
            detector.save();
        }
        else{
            detector.setOwners(new HashSet());  //set no projects
        }
%>
        <font color="green"><a href="show_detector.jsp?serialNumber=<%=serialNumber%>">New owners of this detector set (click to continue)</a><br>
<%
    }           
}

//else this is a new detector creation or edit detector action
else{
    submitType = "create";

    //variables which are set if we're editing a detector in the database
    String serialNumber = "";
    Set owners = null;
    String owner_str = "You can set the owner of this detector once a number is chosen";
    if(action.equals("edit")){
        submitType = "set_teacher";
        serialNumber = request.getParameter("serialNumber");
        QuarkNetDetector updateDetector = QuarkNetDetector.findByNumber(serialNumber);
        if(updateDetector != null){
            serialNumber = Integer.toString(updateDetector.getSerialNumber());
            owners = updateDetector.getOwners();
            if(owners == null){
                owner_str = "No teacher owns this detector. <a href=list_users.jsp?t=teacher&a=choose_multiple&lp=admin_quarknet_detector&lid=set&pt=serialNumber=" + serialNumber + ">Set owner</a>";
            }
            else{
                owner_str = "";
                for(Iterator i=owners.iterator(); i.hasNext(); ){
                    QuarkNetTeacher teacher = (QuarkNetTeacher)i.next();
                    owner_str += teacher.getFirstName() + " " + teacher.getLastName() + " (" + teacher.getUsername() + ") ";
                }
                if(owner_str.equals("")){
                    owner_str = "<font color=gray>No owners of this detector set yet</font> ";
                }
                owner_str += "(<a href=list_users.jsp?t=teacher&a=choose_multiple&lp=admin_quarknet_detector&lid=set&pt=serialNumber=" + serialNumber + ">change</a>)";
            }
        }
        else{
            out.println("No detector found in database with the serial number: " + serialNumber);
        }
    }
%>
    <form method="post">
    <table>
        <tr>
           <td>Detector Serial Number: 
<%
           if(action.equals("edit")){
               out.println(serialNumber + "</td>");
               out.println("<input type=hidden name=serialNumber value=" + serialNumber + "></td>");
           }
           else{
               out.println("<td><input type=text name=serialNumber size=4></td>");
           }
%>
       </tr>
       <tr>
           <td><%=owner_str%></td>
       </tr>
       <tr>
           <td><input type="submit" name="submit" value="Submit"></td>
           <td><input type="hidden" name="submitType" value="<%=submitType%>"></td>
       </tr>
   </table>
   </form>
<%
   //end section of new/edit user
}
%>

<hr>

</body>
</html>
