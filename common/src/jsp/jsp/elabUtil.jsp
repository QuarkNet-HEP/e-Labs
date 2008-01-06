<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedList" %>
<%@ page import="java.util.HashSet" %>

<%!

public static List removeAll(List initial, Object[] remove) {
	HashSet r = new HashSet();
    for (int i = 0; i < remove.length; i++) {
       	r.add(remove[i]);
    }
	
    //array lists are poor at removal of elements
    LinkedList newFileList = new LinkedList(initial);
    newFileList.removeAll(r);
   	return newFileList;
}

%>
