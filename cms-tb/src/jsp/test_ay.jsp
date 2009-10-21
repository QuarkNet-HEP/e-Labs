		<%@ page import="java.util.Calendar" %>
		<%@ page import="java.util.GregorianCalendar" %>

	<HTML>
<HEAD>
<TITLE>Test</TITLE>
</HEAD>
<%
ServletContext context = getServletContext();
String home = context.getRealPath("").replace('\\', '/');
%>
home is: <%=home%><BR>
<%

					// Generated a default academic year. LQ - 7-24-06
                                Calendar calendar = new GregorianCalendar();
                                int year = calendar.get(Calendar.YEAR);
                                %>
                                year is <%=year%><BR>
                                
                                <%
                                 int c = calendar.get(Calendar.MONTH);
                                 if ( c < 7) {
                                     year=year-1;}
                                     
                                %>
                                year is <%=year%> because month is <%=c%>.  <BR>
                                
                                <%
 
                               
                                String ay ="AY" + year;
                                String longyear = year + "-" + (year+1);
                                %>
                                <BODY>
                                Academic Year is: <%=ay%>
                             <form name="myform" method="post" action="">
                                 <select name="ay">
                                        <option value="<%=ay%>"><%=longyear%></option>
                                        <option value="AY2004">2004-2005</option>
                                        <option value="AY2005">2005-2006</option>
                                        <option value="AY2006">2006-2007</option>
                                        <option value="AY2007">2007-2008</option>
                                    </select>
                                    </form>
</body>
</html>
