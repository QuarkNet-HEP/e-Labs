<%@ tag language="java" import="java.sql.*" %>
<%@ tag import="gov.fnal.elab.*" %>
<!-- Hide from old browsers
var runData;
	<%
		Elab elab = (Elab) request.getAttribute("elab");
		String dataSet = elab.getProperty("dataset");
		//String DRIVER = "org.gjt.mm.mysql.Driver";
		String DRIVER = "com.mysql.jdbc.Driver";
		Class.forName(DRIVER).newInstance();
		
		Connection con=null;
		ResultSet rst=null;
		Statement stmt=null;
		
		String host     = "leptoquark.hep.nd.edu";
		String database = "ogredb";
		String table    = "rundb";
		String dbuser   = "ogre";
		String column   = "COUNT(run)";
		String cut      = "where runtype is not NULL and dataset=\""+dataSet+"\"";
		
		String url="jdbc:mysql://"+host+"/"+database+"?user="+dbuser;
		String query = "select "+column+" from "+table+" "+cut;

		try {
			con = DriverManager.getConnection(url);
	    	stmt = con.createStatement();
	    	rst = stmt.executeQuery(query);
	    	rst.next();
	  	}
	  	catch(Exception e) {
	    	throw new ElabJspException(e);
		}
	%>
	var number_of_runs = <%=rst.getInt(column)%>;
	var runType;

	// Build lists of the various run types....
	<%
	  // First up a simple list of all available runs
	  column = "run";
	  query = "select "+column+" from "+table+" "+cut;

	  try {
	    rst=stmt.executeQuery(query);
	    out.print("var runList = new Array(");
	    while ( rst.next() ) {
	      out.print(rst.getInt(column)+",");
	    }
	  } catch(Exception e) {
	    throw new ElabJspException(e);
	  }
	  out.print("null);\n");

	  // Now get the available type and construct the per type lists
	  column = "runtype";
	  cut    = "where "+column+" is not NULL";
	  query  = "select "+column+" from "+table+" "+cut+" group by "+column;
	  try {
	    rst=stmt.executeQuery(query);
	    while ( rst.next() ) {
	      String type = rst.getString(column);
	      Statement stmt2=null;
	      ResultSet rst2=null;
	      query = "select run from "+table+" where runtype=\""+type+"\" and dataset=\""+dataSet+"\"";

	      try {
	        stmt2=con.createStatement();
	        rst2=stmt2.executeQuery(query);
	        out.print("\tvar "+type+"Runs = new Array(");
	        while ( rst2.next() ) {
	          out.print(rst2.getString("run")+",");
	        }
	      } catch(Exception e) {
	        throw new ElabJspException(e);
	      }
	      out.print("null);\n");
	    }
	  } catch(Exception e) {
	    throw new ElabJspException(e);
	  }
	
	  // Build a function which returns basic run data
	  column = "run,nevents,energy,beam";
	  cut = " where runtype is not NULL and dataset=\""+dataSet+"\"";
	  query  = "SELECT "+column+" from "+table+cut;
	  try {
	    rst=stmt.executeQuery(query);
	    out.print("\tfunction getRunData() {\n\t\tvar runData = new Array(\n");
	    while ( rst.next() ) {
	      int run     = rst.getInt("run");
	      int evt     = rst.getInt("nevents");
	      int eng     = rst.getInt("energy");
	      String beam = rst.getString("beam");
	      out.print("\t\t  \"Run "+run+" "+evt+" events of "+eng+" GeV "+beam+"\\n\",\n");
	    }
	  } catch(Exception e) {
	    throw new ElabJspException(e);
	  }
	  out.print("\t\t  null);\n");

	%>

	  var text = "";
	  for (var i=0; i<number_of_runs; i++) {
	  	var selected = document.getData.run_number[i].selected;
	  	if (selected) {
	  		text = text + runData[i];
	  	}
	  	if (opener != null) {
	  		opener.document.getData.run_number[i].selected = selected; 
	  	}
	  }
	  document.getData.dummy.value = text;
	  return true;
	}

String.prototype.trim = function () {
  return this.replace(/^\s*/, "").replace(/\s*$/, "").replace(/^\,*/,"").replace(/\,*$/,"");
}

<!-- Function to generate the runDB list from the selected runs on this page -->
function get_rundb() {

  var gwidth     = 600;
  var gheight    = 600;
  var win_stat   = 0;
  var win_menu   = 0;
  var win_tool   = 0;
  var win_locate = 0;
  var win_dir    = 0;
  var win_resize = 0;
  var win_scroll = 1;
  
  var win = null;

  var run_list = new String();

  for (var i=0; i<number_of_runs; i++) {
    if ( document.getData.run_number[i].selected == true ) {
      run_list = run_list + document.getData.run_number[i].value + ",";
    }
  }
  run_list=run_list.trim();

  var page = "get-run-data.jsp?run=" + run_list;

  var win_width  = (gwidth  <= 0.9*screen.width ) ? 1.1*gwidth  : 0.9*screen.width;
  var win_height = (gheight <= 0.9*screen.height) ? 1.1*gheight : 0.9*screen.height;

  var options    = "toolbar="+ win_tool +",location="+ win_locate +",directories="+ win_dir +
    ",status="+ win_stat + ",menubar="+ win_menu +",resizeable="+ win_resize +
    ",scrollbars="+ win_scroll;

  win=window.open(page,"runData",options,false);
  win.window.focus();
  win.moveTo(0,0);

  if ( !win.opener )
    win.opener = self;

  return win;
}

<!-- Generate the select_current function -->
function select_current() {
    if ( opener != null ) {
    <%
      column   = "runtype";
      cut      = "where "+column+" is not NULL and dataset=\""+dataSet+"\"";
      query = "select "+column+" from "+table+" "+cut+" group by "+column;

      try{
        rst=stmt.executeQuery(query);
        while( rst.next() ) {
    %>

    if ( opener.document.getData.<%=rst.getString("runtype")%>_runs.checked ) {
	  document.getData.<%=rst.getString("runtype")%>_runs.checked = true;
	  select_<%=rst.getString("runtype")%>(true);
    }
    <%
    }
    } catch(Exception e) {
      throw new ElabJspException(e);
    }
    %>
    }

  return;
}

<!-- Generate the select_all function -->
    function select_all(isSelected) {
      if ( document.getData.all_runs.checked ) {
      <%
        try{
          rst=stmt.executeQuery(query);
          while( rst.next() ) {
      %>
        document.getData.<%=rst.getString("runtype")%>_runs.checked = false;
	if ( opener != null ) {
          opener.document.getData.<%=rst.getString("runtype")%>_runs.checked = false;
        }
    <%
    }
    } catch(Exception e) {
      throw new ElabJspException(e);
    }
    %>

    for ( var i=0; i<number_of_runs; i++ ) {
      document.getData.run_number[i].selected = true;
    }
  } else {
    for ( var i=0; i<number_of_runs; i++ ) {
      document.getData.run_number[i].selected = false;
    }
  }
  getRunData();
  if ( opener != null ) {
    opener.document.getData.all_runs.checked = isSelected;
  }

  return;
}

<!-- Generate the select_single function -->
    function select_single_run() {
      getRunData();
      <%
        try{
          rst=stmt.executeQuery(query);
          while( rst.next() ) {
      %>
        document.getData.<%=rst.getString("runtype")%>_runs.checked = false;
	if ( opener != null ) {
          opener.document.getData.<%=rst.getString("runtype")%>_runs.checked = false;
        }
      <%
          }
        } catch(Exception e) {
          throw new ElabJspException(e);
        }
      %>

      return;
    }

<!-- Generate the select_{type} functions -->
    <%
      try{
        rst=stmt.executeQuery(query);
        while( rst.next() ) {
    %>
    function select_<%=rst.getString("runtype")%>(isSelected) {

      if ( isSelected ) {
        var j = 0;
        for ( var i=0; i<number_of_runs; i++ ) {
          if ( <%=rst.getString("runtype")%>Runs[j] == runList[i] ) {
	    document.getData.run_number[i].selected = true;
	    j++;
          }
        }
      } else {
        var j = 0;
        for ( var i=0; i<number_of_runs; i++ ) {
          if ( <%=rst.getString("runtype")%>Runs[j] == runList[i] ) {
	    document.getData.run_number[i].selected = false;
	    j++;
          }
        }
      }
      getRunData();
      if ( opener != null ) {
        opener.document.getData.<%=rst.getString("runtype")%>_runs.checked = isSelected;
      }

      return;
    }

    <%
        }
      } catch(Exception e) {
        throw new ElabJspException(e);
      }
    %>
//->
