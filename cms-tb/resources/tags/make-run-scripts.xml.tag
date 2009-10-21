<%@ tag language="java" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/xtags-1.0" prefix="xtags" %>

<% 
   int counter = 0;
   String types[];
%>

<!-- Hide from old browsers
var runData;
      <xtags:variable id="uri" select="$cookie:xmlFile"/>
      <xtags:variable id="ds"  select="$cookie:dataSet"/>
      <xtags:parse uri="<%= uri %>"/>

      <xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
	  <xtags:forEach select="file">
            <xtags:if test="@runtype!='NULL'">
              <% counter++; %>
            </xtags:if>
	  </xtags:forEach>
	</xtags:if>
      </xtags:forEach>

	var number_of_runs = <%= counter %>;
	var runType;

      // Build lists of the various run types....

      // First up a simple list of all available runs
      <xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
          <% out.print("var runList = new Array("); %>
	  <xtags:forEach select="file">
            <xtags:if test="@runtype!='NULL'">
              <xtags:variable id="run" select="@run"/>
              <% out.print(run+","); %>
            </xtags:if>
	  </xtags:forEach>
	</xtags:if>
      </xtags:forEach>
      <% out.print("null);\n"); %>

      // Now get the available types and construct the per type lists
      <xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
          <xtags:forEach select="runs/type">
            <xtags:variable id="beam" select="@beam"/>

            // Loop over the available runs and find those matching this beam type to fill the array
            <% out.print("var "+beam+"Runs = new Array("); %>
            <xtags:forEach select="/root/dataset">
	      <xtags:if test="@name=$ds">
                <xtags:forEach select="file">
                  <xtags:if test="@runtype=$beam">
                    <xtags:variable id="run" select="@run" />
                    <% out.print(run+","); %>
                  </xtags:if>
                </xtags:forEach>

                <% out.print("null);\n"); %>

              </xtags:if>
            </xtags:forEach>

          </xtags:forEach>
        </xtags:if>
      </xtags:forEach>

      // Build a function which returns basic run data
      <% out.print("\tfunction getRunData() {\n\t\tvar runData = new Array(\n"); %>
      <xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
	  <xtags:forEach select="file">
            <xtags:if test="@runtype!='NULL'">
              <xtags:variable id="run"  select="@run"/>
              <xtags:variable id="evt"  select="@nevents"/>
              <xtags:variable id="eng"  select="@energy"/>
              <xtags:variable id="beam" select="@beam"/>
              <% out.print("\t\t  \"Run "+run+" "+evt+" events of "+eng+" GeV "+beam+"\\n\",\n"); %>
            </xtags:if>
          </xtags:forEach>
        </xtags:if>
      </xtags:forEach>
      <% out.print("\t\t  null);\n"); %>

      var text = "";
      for (var i=0; i<number_of_runs; i++) {
        if (document.getData.run_number[i].selected) {
	  text = text + runData[i];
	  if ( opener != null ) {
	    opener.document.getData.run_number[i].selected = true;
	  }
	} else {
	  if ( opener != null ) {
	    opener.document.getData.run_number[i].selected = false;
	  }
	}
      }
      document.getData.dummy.value = text;
      return true;
    }

// Remove leading/trailing whitespace & commas from the run list
String.prototype.trim = function () {
  return this.replace(/^\s*/, "").replace(/\s*$/, "").replace(/^\,*/,"").replace(/\,*$/,"");
}

// Function to generate the runDB list from the selected runs on this page
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
      <xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
          <xtags:forEach select="runs/type">
            <xtags:variable id="runtype" select="@beam"/>
          if ( opener.document.getData.<%=runtype%>_runs.checked ) {
	    document.getData.<%=runtype%>_runs.checked = true;
	    select_<%=runtype%>(true);
          }

          </xtags:forEach>
        </xtags:if>
      </xtags:forEach>
    }

  return;
}

// Generate the select_all function
    function select_all(isSelected) {
      if ( document.getData.all_runs.checked ) {
      <xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
          <xtags:forEach select="runs/type">
            <xtags:variable id="runtype" select="@beam"/>
        document.getData.<%=runtype%>_runs.checked = false;
	if ( opener != null ) {
          opener.document.getData.<%=runtype%>_runs.checked = false;
        }

          </xtags:forEach>
        </xtags:if>
      </xtags:forEach>

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

// Generate the select_single function
    function select_single_run() {
      getRunData();

      <xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
          <xtags:forEach select="runs/type">
            <xtags:variable id="runtype" select="@beam"/>
        document.getData.<%=runtype%>_runs.checked = false;
	if ( opener != null ) {
          opener.document.getData.<%=runtype%>_runs.checked = false;
        }
          </xtags:forEach>
        </xtags:if>
      </xtags:forEach>

      return;
    }

// Generate the select_{type} functions
   <xtags:forEach select="/root/dataset">
     <xtags:if test="@name=$ds">
       <xtags:forEach select="runs/type">
         <xtags:variable id="runtype" select="@beam"/>
  function select_<%=runtype%>(isSelected) {

      if ( isSelected ) {
        var j = 0;
        for ( var i=0; i<number_of_runs; i++ ) {
          if ( <%=runtype%>Runs[j] == runList[i] ) {
	    document.getData.run_number[i].selected = true;
	    j++;
          }
        }
      } else {
        var j = 0;
        for ( var i=0; i<number_of_runs; i++ ) {
          if ( <%=runtype%>Runs[j] == runList[i] ) {
	    document.getData.run_number[i].selected = false;
	    j++;
          }
        }
      }

      getRunData();
      if ( opener != null ) {
        opener.document.getData.<%=runtype%>_runs.checked = isSelected;
      }

      return;
  }
        </xtags:forEach>
      </xtags:if>
    </xtags:forEach>
//->
