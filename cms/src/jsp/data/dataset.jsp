<%@
	page import="java.util.*"
		 import="gov.fnal.elab.*"
		 import="gov.fnal.elab.cms.triggerexpr.*" 
		 import="gov.fnal.elab.cms.dataset.*" 
%><%

String pdataset = request.getParameter("dataset"); 

Dataset dataset = Datasets.getDataset(elab, session, pdataset);
request.setAttribute("dataset", dataset);

%>
