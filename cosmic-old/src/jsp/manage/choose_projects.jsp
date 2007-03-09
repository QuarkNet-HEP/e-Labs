<%@ page import="gov.fnal.elab.db.*" %>
<%@ page import="gov.fnal.elab.cosmic.db.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../common.jsp" %>
<%@ include file="manage_inc.jsp" %>

<%
User me = User.findByUsernameAndPassword("paul", "junk");
java.util.List p_list = Project.findAll();  //list of all projects
String action = request.getParameter("a");
%>

<html>
<head>
    <title>List Projects</title>
</head>

<body>

<%=headerString("Projects")%>
<hr>

<table width="100%" border="0">
<%
if(action.equals("cm")){
    String lid = request.getParameter("lid");       //link id
    String lp = request.getParameter("lp");         //link page
    String[] projects = request.getParameterValues("project");
    Set checkedSet = new HashSet();
    if(projects != null){
        checkedSet.addAll(Arrays.asList(projects));
    }

    out.println("<form method=get action=" + lp + ".jsp>");
    for(Iterator i=p_list.iterator(); i.hasNext(); ){
        Project p = (Project)i.next();

        String checked = "";
        if(checkedSet.contains(p.getId().toString())){
            checked = "checked";
        }
%>
        <tr>
            <td>
                <input name="<%=lid%>" value="<%=p.getId()%>" type="checkbox" <%=checked%>><%=p.getName()%>
            </td>
        </tr>
<%
    }
%>
    <tr>
        <td>
            <input type="submit" name="submit" value="Choose projects">
            <input type="hidden" name="submitType" value="set_projects">
<%
            String[] pt = request.getParameterValues("pt");     //passthrough variables
            if(pt != null){
                for(int i=0; i<pt.length; i++){
                    String[] nv = pt[i].split("=", 2);      //name-value
                    out.println("<input type=hidden name=" + nv[0] + " value=" + nv[1] + ">");
                }
            }
%>
        </td>
    </tr>
    </form>
<%
}
%>

</table>


<hr>

</body>
</html>
