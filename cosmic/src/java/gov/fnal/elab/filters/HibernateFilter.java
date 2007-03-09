package gov.fnal.elab.filters;

import org.apache.commons.logging.*;

import javax.servlet.*;
import java.io.IOException;
import gov.fnal.elab.db.HibernateUtil;

/**
 * A servlet filter that opens and closes a Hibernate Session for each request.
 * <p>
 * This filter guarantees a sane state, committing any pending database
 * transaction once all other filters (and servlets) have executed. It also
 * guarantees that the Hibernate <tt>Session</tt> of the current thread will
 * be closed before the response is send to the client.
 * <p>
 * Use this filter for the <b>session-per-request</b> pattern and if you are
 * using <i>Detached Objects</i>.
 *
 * http://www.hibernate.org/43.html
 *
 * @see HibernateUtil
 * @author Christian Bauer <christian@hibernate.org>
 */
public class HibernateFilter implements Filter {

    private static Log log = LogFactory.getLog(HibernateFilter.class);

    public void init(FilterConfig filterConfig) throws ServletException {
        log.info("Servlet filter init, now opening/closing a Session for each request.");
    }

    public void doFilter(ServletRequest request,
            ServletResponse response,
            FilterChain chain)
        throws IOException, ServletException {


        //DONT put this in the try block
        chain.doFilter(request, response);

        try {
            // Commit any pending database transaction.
            HibernateUtil.commitTransaction();
        } 
        catch(Exception e) {
        }
        finally {

            // No matter what happens, close the Session.
            try{
                HibernateUtil.closeSession();
            } catch(Exception e){}

        }
    }

    public void destroy() {}

}
