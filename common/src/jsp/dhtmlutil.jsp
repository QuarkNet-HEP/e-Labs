<%@ page import="java.io.IOException" %>

<%!
public static void visibilitySwitcher(JspWriter out, String name, String divName, 
		String caption, boolean visible) throws IOException {
	visibilitySwitcher(out, name, divName, caption, caption, visible);
}

%>

<%!
public static final String STYLE_H = "visibility:hidden; display: none";
public static final String STYLE_V = "visibility:visible; display:";

public static void visibilitySwitcher(JspWriter out, String name, String divName, 
		String captionVisible, String captionHidden, boolean visible) throws IOException {
	
	out.println("<div id=\"" + name + "0\" style=\"" + (visible ? STYLE_H : STYLE_V) + "\">");
	out.print  ("	<a href=\"javascript:void(0);\" onclick=\"HideShow('" + divName + "');HideShow('" + name + "0');HideShow('" + name + "1')\">");
	out.println("<img src=\"graphics/Tright.gif\" alt=\"\" border=\"0\"></a>");
	out.println("	<strong>" + captionHidden + "</strong>");
	out.println("</div>");
	out.println("<div id=\"" + name + "1\" style=\"" + (visible ? STYLE_V : STYLE_H) + "\">");
	out.print  ("	<a href=\"javascript:void(0);\" onclick=\"HideShow('" + divName + "');HideShow('" + name + "1');HideShow('" + name + "0')\">");
	out.println("<img src=\"graphics/Tdown.gif\" alt=\"\" border=\"0\"></a>");
	out.println("	<strong>" + captionVisible + "</strong>");
	out.println("</div>");
}

%>
