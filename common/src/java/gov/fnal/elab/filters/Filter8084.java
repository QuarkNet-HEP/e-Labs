package gov.fnal.elab.filters;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class Filter8084 implements Filter {

    private FilterConfig config = null;
    
    public void init(FilterConfig config) throws ServletException {
        this.config = config;
    }

    public void destroy() {
        config = null;
    }

    public void doFilter(
        ServletRequest request,
        ServletResponse response,
        FilterChain chain) 
    throws java.io.IOException{

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String requestURL = httpRequest.getRequestURL().toString();
        
        // If the URL contains the port 8084, redirect to the home of the new production site.
        if (requestURL.matches(":8084")) {
           resp.sendRedirect("http://quarknet.fnal.gov/grid");
        }
    }
} 
