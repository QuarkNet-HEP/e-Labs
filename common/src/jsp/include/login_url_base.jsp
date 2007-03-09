
<%
// base of URL for login page - https if sslport defined, otherwise http

String loginURLBase;

if(System.getProperty("sslport") != null) {
    loginURLBase = "https://" + System.getProperty("host") + System.getProperty("sslport");
} else {
    loginURLBase = "http://" + System.getProperty("host") + System.getProperty("port");
}

%>

