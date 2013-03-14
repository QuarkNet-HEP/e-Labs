<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.Timestamp" %>

<%
        String filename = request.getParameter("filename");
        CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
        ElabGroup plotUser = elab.getUserManagementProvider().getGroup((String) entry.getTupleValue("group"));
        String eventCandidates = null;
        if (entry != null) {
        eventCandidates = (String) entry.getTupleValue("eventCandidates");
        if (eventCandidates != null) {
                eventCandidates = plotUser.getDirURL("plots") + '/' + eventCandidates;
                }
        }
        try {
                FileInputStream fstream = new FileInputStream("/home/quarkcat/sw/tomcat/webapps" + eventCandidates);
                DataInputStream dstream = new DataInputStream(fstream);
                BufferedReader br  = new BufferedReader(new InputStreamReader(dstream));
                String strLine;
                while ((strLine = br.readLine()) != null) {
%>
                        <p><%=strLine%></p>
<%
                }
                dstream.close();
                } catch (Exception e) {
%>
                <p>Error: <%= e.getMessage()%></p>
<%
                }
%>
  


