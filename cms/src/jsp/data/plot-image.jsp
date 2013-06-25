<%@ page
	import="java.io.*"
	import="gov.fnal.elab.cms.plot.*"
	import="gov.fnal.elab.cms.dataset.*"
%><%@
	include file="../include/elab.jsp"
%><%
	String pdataset = request.getParameter("dataset");
	String runs = request.getParameter("runs");
	String plot = request.getParameter("plots");
	String thumbnail = request.getParameter("thumbnail");
	
	Dataset dataset = Datasets.getDataset(elab, session, pdataset);
	int index = "true".equals(thumbnail) ? 1 : 0;

	try {
		File[] imgs = PlotTool.getOrCreatePlot(elab, dataset, runs, plot);
		
		out.clear();
		response.setContentType("image/png");
		OutputStream os = response.getOutputStream();
		try {
			InputStream is = new FileInputStream(imgs[index]);
			byte[] buf = new byte[16394];
			int len = is.read(buf);
			while (len != -1) {
				os.write(buf, 0, len);
				len = is.read(buf);
			}
			is.close();
		} catch (Exception e) {
			response.setContentType("text/html");
			PrintWriter pw = response.getWriter();
			pw.write("<p><strong>Thumbnail not available</strong></p>");
			//pw.write(e.getMessage());
			pw.close();
		} finally {
			os.close();
		}
	} catch (Exception e) {
		response.setContentType("text/html");
		PrintWriter pw = response.getWriter();
		pw.write("<p><strong>Thumbnail not available</strong></p>");
		//pw.write(e.getMessage());
		pw.close();		
	}
%>