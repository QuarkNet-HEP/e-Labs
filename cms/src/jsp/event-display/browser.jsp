<%@ include file="../include/elab.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.zip.*" %>
<%
	// alternatively set the data location manually for standalone use
	String dataLocation = elab.getProperty("event.display.data.location");
	//String dataLocation = "/home/mike/Desktop";
	String op = request.getParameter("op");
	String param = request.getParameter("param");
	
	if ("list".equals(op)) {
	    if (param == null) {
	        throw new RuntimeException("Missing directory parameter");
	    }
	    File loc = new File(dataLocation);
	    File dir = new File(loc, param);
	    if (!dir.getCanonicalPath().startsWith(loc.getCanonicalPath())) {
	        dir = loc;
	    }
	    if (!dir.exists()) {
	        dir = loc;
	    }
	    File[] fs = dir.listFiles(new FileFilter() {
	        public boolean accept(File f) {
	            return f.isDirectory() || f.getName().endsWith(".ig");
	        }
	    });
	    Arrays.sort(fs, new Comparator<File>() {
	        public int compare(File f, File g) {
	            if (f.isDirectory() == g.isDirectory()) {
	                return f.getName().compareTo(g.getName());
	            }
	            else {
	                return f.isDirectory() ? -1 : 1;
	            }
	        }
	    });
	
	    out.write("[");
	    boolean first = true;
	    if (!dir.getCanonicalPath().equals(loc.getCanonicalPath())) {
	        out.write("{ type: 1, name: \"..\"}");
	        first = false;
	    }
	    for (File f : fs) {
	        if (first) {
	            first = false;
	        }
	        else {
	            out.write(", ");
	        }
	        out.write("{ type: " + (f.isDirectory() ? 1 : 0) + ", name: \"" + f.getName() + "\" }");
	    }
	    out.write("]");
	}
	else if ("events".equals(op)) {
	    File loc = new File(dataLocation);
	    File igf = new File(loc, param);
	    if (!igf.getCanonicalPath().startsWith(loc.getCanonicalPath())) {
	        throw new RuntimeException("Invalid file: " + param);
	    }
	    ZipFile zf = new ZipFile(igf);
	    Enumeration<? extends ZipEntry> entries = zf.entries();
	    boolean first = true;
	    out.write("[");
	    while (entries.hasMoreElements()) {
	        ZipEntry e = entries.nextElement();
	        if (e.isDirectory()) {
	            continue;
	        }
	        if (e.getName().startsWith("Events")) {
	     	 	if (first) {
	     	 	    first = false;
	     	 	}
	     	 	else {
	     	 	    out.write(", ");
	     	 	}
	     	 	out.write("{ type: 2, name: \"" + e.getName().substring("Events/".length()) + "\", size: " + e.getSize() + " }");  
	        }
	    }
	    out.write("]");
	    zf.close();
	}
	else if ("get".equals(op)) {
	    String[] ps = param.split(":");
	    File loc = new File(dataLocation);
	    File igf = new File(loc, ps[0]);
	    if (!igf.getCanonicalPath().startsWith(loc.getCanonicalPath())) {
	        throw new RuntimeException("Invalid file: " + ps[0]);
	    }
	    ZipFile zf = new ZipFile(igf);
	    ZipEntry e = zf.getEntry("Events/" + ps[1]);
	    BufferedInputStream bis = new BufferedInputStream(zf.getInputStream(e));
	    out.write("(");
	    byte[] buf = new byte[16384];
	    int len = bis.read(buf);
	    while (len >= 0) {
	        for (int i = 0; i < len; i++) {
	        	byte c = buf[i];
	        	switch (c) {
	        	    case '(':
	        	        c = '[';
	        	        break;
	        	    case ')':
	        	        c = ']';
	        	    	break;
	        	}
	        	out.write(c);
	        }
	        len = bis.read(buf);
	    }
	    out.write(")");
	}
	else {
	    throw new RuntimeException("Unrecognized operation: " + op);
	}
%>