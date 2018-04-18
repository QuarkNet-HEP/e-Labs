<%-- From http://wiki.metawerx.net/wiki/CustomErrorPagesInTomcat - JG 18Apr2018 --%>
<%@ page isErrorPage="true" %>
<h1>An error has occurred</h1>

<%
    boolean handled = false; // Set to true after handling the error
    
    // Get the PageContext
    if(pageContext != null) {
    
        // Get the ErrorData
        ErrorData ed = null;
        try {
            ed = pageContext.getErrorData();
        } catch(NullPointerException ne) {
            // If the error page was accessed directly, a NullPointerException
            // is thrown at (PageContext.java:514).
            // Catch and ignore it... it effectively means we can't use the ErrorData
        }

        // Display error details for the user
        if(ed != null) {
    
            // Output this part in HTML just for fun
            %>
                <p />Error Data is available.
            <%
    
            // Output details about the HTTP error
            out.println("<br />ErrorCode: " + ed.getStatusCode());
            out.println("<br />URL: " + ed.getRequestURI());
    
            // Error handled successfully, set a flag
            handled = true;
        }
    }
    
    // Check if the error was handled
    if(!handled) {
    %>
        <p />No information about this error was available.
    <%
    }
%>
