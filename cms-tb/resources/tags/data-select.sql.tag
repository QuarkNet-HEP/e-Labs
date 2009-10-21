<%@ tag import="gov.fnal.elab.*" %>
<%@ tag language="java" import="java.sql.*, java.util.*" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>


      <%
      Elab elab = (Elab) request.getAttribute("elab");
      String dataSet = elab.getProperty("dataset");
      String DRIVER = "com.mysql.jdbc.Driver";
      Class.forName(DRIVER).newInstance();

      Connection con=null;
      ResultSet rst=null;
      Statement stmt=null;

      String host     = "leptoquark.hep.nd.edu";
      String database = "ogredb";
      String table    = "rundb";
      String dbuser   = "ogre";

      String url="jdbc:mysql://"+host+"/"+database+"?user="+dbuser;

      try {
		con = DriverManager.getConnection(url);
        stmt = con.createStatement();
      } 
      catch(Exception e) {
        throw new ElabJspException(e);
      }

      String column   = "runtype";
      String cut      = "where "+column+" is not NULL and dataset=\""+dataSet+"\"";
      String query    = "select "+column+" from "+table+" "+cut+" group by "+column;

      try{
        rst=stmt.executeQuery(query);
        while( rst.next() ) {
      %>
      <e:trinput type="checkbox" name="<%= rst.getString("runtype") + "_runs"%>"
        value="<%= rst.getString("runtype") %>" 
		onClick="<%="javascript:select_" + rst.getString("runtype") + "(this.checked);"%>"/>
      &nbsp; <%=rst.getString("runtype")%><BR>
    <%
    }
    } 
    catch(Exception e) {
      throw new ElabJspException(e);
    }
    %>
    <input type="checkbox" name="all_runs" onClick="javascript:select_all(this.checked)";> &nbsp;All
  </td>
    <td>
      <!-- Access the runDB and generate a list of available runs -->
	<%
	  column = "run";
	  query = "select "+column+" from "+table+" where runtype is not NULL and dataset=\""+dataSet+"\"";
	  try {
	    List runs = new ArrayList();
	    List labels = new ArrayList();
	    request.setAttribute("runs", runs);
	    request.setAttribute("labels", labels);
	    rst=stmt.executeQuery(query);
	    while( rst.next() ) {
	        runs.add(rst.getString("run"));
	        labels.add("Run " + rst.getString("run"));
	    }
	  %>
	  	<e:trselect name="run_number" multiple="true" size="5" onChange="javascript:select_single_run();"
	  		valueList="${runs}" labelList="${labels}"/>
	  <%
	    rst.close();
	    stmt.close();
	    con.close();

	  } 
	  catch(Exception e) {
	    throw new ElabJspException(e);
	  }
	  %>
    </td>
