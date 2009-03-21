<!-- a -->
<!-- Login Check: if not logged in, redirect to display error message with "close" option  -->

<%
if (session.getAttribute("login") != null ) {
%>
    <table width=400>
        <tr>
            <td>
                Logged in as group: <A href="userinfo.jsp"><%= session.getAttribute("login") %></A>
            </td>
            <td align="right">
                Click <A href="logout.jsp"> here to logout</A>
            </td>
        </tr>
    </table>
<%
}
%>
