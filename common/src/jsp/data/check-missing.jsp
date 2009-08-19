<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>VDC Missing Files</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="analysis-list" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<%
	
	Equals eq = new Equals("project", "cosmic");
	ResultSet rs = elab.getDataCatalogProvider().runQuery(eq);
	ResultSet nrs = new ResultSet();
	rs.sort("type", false);
	request.setAttribute("rs", nrs);
	
	Map pfns = new HashMap();
	Map groupCache = new HashMap();
	
	ElabUserManagementProvider mp = elab.getUserManagementProvider();
	RawDataFileResolver dfr = RawDataFileResolver.getDefault();
	int count = 0;
	Iterator i = rs.iterator();
	while (i.hasNext()) {
		CatalogEntry e = (CatalogEntry) i.next();
		String type = (String) e.getTupleValue("type");
		String eusername = (String) e.getTupleValue("group");
		String name = (String) e.getTupleValue("name");
		String pfn = null;
		String error = null;
		ElabGroup euser = null;
		if (eusername != null) {
			try {
			    euser = (ElabGroup) groupCache.get(eusername);
			    if (euser == null) {
			        if (!groupCache.containsKey(eusername)) {
			    		euser = mp.getGroup(eusername);
			    		groupCache.put(eusername, euser);
			        }
			        else {
			            error = "Error: group specified in metadata does not exist: \"" + eusername + "\"";
			        }
			    }
			}
			catch (Exception ex) {
				error = "Error retrieving group details for \"" + eusername + "\": " + ex.toString();
				groupCache.put(eusername, null);
			}
		}
		if ("poster".equals(type)) {
		    if (eusername == null) {
		        error = "Error: missing group name metadata";
		    }
		    else if (name == null) {
		        error = "Error: missing name metadata";
		    }
		    else if (euser != null) {
		    	pfn = new File(euser.getDir("posters"), name).getAbsolutePath();
		    }
		}
		else if ("split".equals(type)) {
			pfn = dfr.resolve(elab, e.getLFN());
		}
		else if ("plot".equals(type)) {
		    if (eusername == null) {
		        error = "Error: missing group name metadata";
		    }
		    else if (name == null) {
		        error = "Error: missing name metadata";
		    }
		    else if (euser != null) {
		    	pfn = new File(euser.getDir("plots"), name).getAbsolutePath();
		    }
		}
		else {
		    i.remove();
		    continue;
		}
		
		if (error != null) {
		    pfns.put(e.getLFN(), error);
		    nrs.addEntry(e);
		}
		else if (pfn == null) {
		    throw new ElabJspException("Internal error: pfn null for " + e); 
		}
		else {
		    if (!new File(pfn).exists()) {
		        pfns.put(e.getLFN(), "PFN: " + pfn);
		        nrs.addEntry(e);
		    }
		}
		count++;
		if (count % 1000 == 0) {
		    System.out.println(count);
		}
		if (count > 200) {
		    break;
		}
	}
	
	request.setAttribute("pfns", pfns);
%>
	<script language="JavaScript">
		function selectAll(cls) {
			var checked = document.getElementById("select-all-" + cls).checked;
			var cbs = document.getElementsByTagName("input");
			for (var cb in cbs) {
				if (cbs[cb].className == cls) {
					cbs[cb].checked = checked;
				}
			}
		}
	</script>
	<form method="POST" action="../data/remove-entries.jsp">
		<input type="submit" value="Remove Selected" />
		<c:set var="currentType" value="${null}"/>
		<c:set var="first" value="true"/>
		<c:forEach items="${rs}" var="entry">
			<c:set var="type" value="${entry.tupleMap['type']}"/>
			<c:if test="${currentType != type}">
				<c:set var="currentType" value="${type}"/>
				<c:if test="${!first}">
					</table>
				</c:if>
				<h2>Type: ${type}</h2>
				<c:if test="${first}">
					<c:set var="first" value="false"/>
				</c:if>
				<table id="analysis-table">
					<tr>
						<th><input type="checkbox" id="select-all-${type}" onchange="selectAll('${type}');"></input></th>
						<th>LFN</th>
						<th>Issue</th>
					</tr>
			</c:if>
			<tr>
				<td><input type="checkbox" name="remove-${entry.LFN}" class="${type}" /></td>
				<td><a href="../data/view-metadata.jsp?filename=${entry.LFN}">${entry.LFN}</a></td>
				<td>${pfns[entry.LFN]}</td>
			</tr>
		</c:forEach>
		<c:if test="${!first}">
			</table>
		</c:if>
		<input type="submit" value="Remove Selected" />
	</form>

		 	</div>
		</div>
	</body>
</html>