<%@ page 
	errorPage="../include/errorpage.jsp" buffer="none" 
	import="gov.fnal.elab.expression.evaluator.*"
	import="gov.fnal.elab.expression.data.engine.*" %><%!
	
	public String escape(String v) {
	    StringBuilder sb = new StringBuilder();
	    for (int i = 0; i < v.length(); i++) {
	        char c = v.charAt(i);
	        switch (c) {
	            case '\n':
	                sb.append("\\n");
	                break;
                case '\t':
	                sb.append("\\t");
	                break;
                case '\f':
	                sb.append("\\f");
	                break;
                case '\b':
	                sb.append("\\b");
	                break;
	            case '\r':
	                sb.append("\\r");
	                break;
	            case '"':
	                sb.append("\\\"");
	                break;
	            case '\\':
	                sb.append("\\\\");
	                break;
	            default:
	                sb.append(c);
	        }
	    }
	    return sb.toString();
	}
	
	public void writeString(java.io.Writer out, String name, Object value) throws java.io.IOException {
    	out.write("\"" + name + "\": \"" + escape(value.toString()) + "\",\n"); 
    }
	
	public void writeField(java.io.Writer out, String name, Object value) throws java.io.IOException {
	    writeField(out, name, value, false);
	}
  
	public void writeField(java.io.Writer out, String name, Object value, boolean last) throws java.io.IOException {
    	out.write("\"" + name + "\": " + value + (last ? "" : ", ") + "\n"); 
    }
%><%
	java.text.DecimalFormat df = new java.text.DecimalFormat("0.########");
	DataSet ds = Evaluator.getDefault().evaluate(request.getParameter("q"));
	out.write("{\n");
	writeString(out, "label", ds.getLabel());
	writeString(out, "xlabel", ds.getXLabel());
	writeString(out, "ylabel", ds.getYLabel());
	writeString(out, "xunit", ds.getXUnit());
	writeString(out, "yunit", ds.getYUnit());
	writeField(out, "xrange", ds.getXRange());
	writeField(out, "yrange", ds.getYRange());
	writeField(out, "size", ds.size());
	StringBuilder sb = new StringBuilder();
	sb.append('[');
	for (int i = 0; i < ds.size(); i++) {
	    sb.append("[");
	    Number x = ds.getX(i);
	    sb.append(x == null ? "null" : df.format(x));
	    sb.append(", ");
	    Number y = ds.getY(i);
	    sb.append(y == null ? "null" : df.format(y));
	    sb.append("]");
	    if (i < ds.size() - 1) {
	        sb.append(", ");
	    }
	}
	sb.append(']');
	writeField(out, "data", sb.toString(), true);
	
	out.write("}\n");
%>
