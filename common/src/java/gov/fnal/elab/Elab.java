/*
 * Created on Mar 4, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.analysis.AnalysisExecutor;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.survey.ElabSurveyProvider;
import gov.fnal.elab.test.ElabTestProvider;
import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.usermanagement.impl.DatabaseUserManagementProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.URLEncoder;

import java.io.IOException;
import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.PageContext;

/**
 * This class provides a centralized access point for an elab, including
 * properties and providers.
 */
public class Elab implements Serializable {
    private static Map<String, Elab> elabs;
    private static Elab global;

    private static int sid = 0;

    /**
     * Retrieves the Elab object associated with the given name or instantiates
     * a new one if it does not already exist. The elab will be initialized with
     * two properties files: <code>elab.properties</code> and
     * <code>elab.properties.&lt;name&gt</code>. This method will look for
     * the properties file in the classpath (i.e. elab/WEB-INF).
     * 
     * @param context
     *            A PageContext object used to retrieve information about the
     *            current servlet
     * @param name
     *            The name of the elab (i.e. "cosmic").
     * @return An elab for the supplied project name
     * @throws ElabInstantiationException
     *             if the elab cannot be instantiated
     */
    public static Elab getElab(PageContext context, String name)
            throws ElabInstantiationException {
        return getElab(context, name, "elab.properties." + name);
    }

    /**
     * Retrieves the Elab object associated with the given name or instantiates
     * a new one if it does not already exist. The elab will be initialized with
     * two properties files: <code>elab.properties</code> and
     * <code>&lt;properties&gt</code>. This method will look for the
     * properties file in the classpath (i.e. elab/WEB-INF).
     * 
     * @param context
     *            A PageContext object used to retrieve information about the
     *            current servlet
     * @param name
     *            The name of the elab (i.e. "cosmic").
     * @param properties
     *            The name of a properties file to be loaded in addition to the
     *            <code>elab.properties</code> shared properties file.
     * @return An elab for the supplied project name
     * @throws ElabInstantiationException
     *             if the elab cannot be instantiated
     */
    public static synchronized Elab getElab(PageContext context, String name,
            String properties) throws ElabInstantiationException {
        if (global == null) {
            global = Elab.newElab(context, "global", "elab.properties");
        }
        if (elabs == null) {
            elabs = new HashMap();
        }
        Elab elab = elabs.get(name);
        if (elab == null) {
            elab = Elab.newELab(context, name, properties, global
                    .getProperties());
            elab.init();
            elabs.put(name, elab);
        }
        return elab;
    }

    /**
     * Instantiates a new Elab object. In order to get a singleton Elab object
     * for a given project, use one of the <code>getElab</code> methods above.
     * The elab will be initialized with two properties files:
     * <code>elab.properties</code> and <code>&lt;properties&gt</code>.
     * This method will look for the properties file in the classpath (i.e.
     * elab/WEB-INF).
     * 
     * @param context
     *            A PageContext object used to retrieve information about the
     *            current servlet
     * @param name
     *            The name of the elab (i.e. "cosmic").
     * @param properties
     *            The name of a properties file to be loaded in addition to the
     *            <code>elab.properties</code> shared properties file.
     * @return An elab for the supplied project name
     * @throws ElabInstantiationException
     *             if the elab cannot be instantiated
     */
    public static Elab newElab(PageContext context, String name,
            String properties) throws ElabInstantiationException {
        return newELab(context, name, properties, null);
    }

    private static Elab newELab(PageContext context, String name,
            String properties, Properties inherited)
            throws ElabInstantiationException {
        Elab elab = new Elab(context, name);
        ElabProperties props = elab.getProperties();
        if (inherited != null) {
            props.load(inherited);
        }
        try {
            props.load(properties);
        }
        catch (IOException e) {
            throw new ElabInstantiationException(
                    "Failed to load elab properties (" + properties + ")", e);
        }
        props.setProperty(ElabProperties.PROP_ELAB_NAME, name);
        return elab;
    }

    private String name;
    private ElabProperties properties;
    private int id;
    private ElabFAQ faq;
    private ServletContext context;
    private ServletConfig config;
    private PageContext pageContext;
    private Map<String, Object> attributes;

    /**
     * Instantiates a new Elab object using the specified
     * <code>PageContext</code> and the specified name.
     * 
     * @param pc
     *            A <code>PageContext</code> object that is used to obtain
     *            various servlet configuration parameters
     * @param name
     *            The name of the elab
     */
    protected Elab(PageContext pc, String name) {
        this.name = name;
        this.properties = new ElabProperties(name);
        this.pageContext = pc;
        if (pc != null) {
            this.context = pc.getServletContext();
            this.config = pc.getServletConfig();
        }
        this.attributes = new HashMap();
    }
    
    

    /**
     * Retrieves the <code>ServletContext</code> in which this
     * <code>Elab</code> object was created
     */
    public ServletContext getServletContext() {
        return context;
    }

    /**
     * Retrieves the <code>ServletConfig</code> of the servlet in which this
     * <code>Elab</code> object was created
     */
    public ServletConfig getServletConfig() {
        return config;
    }

    /**
     * Returns an absolute path that represents the given path relative to the
     * web application.
     */
    public String getAbsolutePath(String webappPath) {
        return context.getRealPath(webappPath);
    }

    protected void init() throws ElabInstantiationException {
        properties.resolve();
        try {
            updateId();
        }
        catch (Exception e) {
            throw new ElabInstantiationException(e);
        }
    }

    protected void updateId() throws SQLException, ElabException {
        // this should perhaps be moved somewhere else?
        PreparedStatement ps = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(properties);
            ps = conn.prepareStatement("SELECT id FROM project WHERE name = ?;");
            ps.setString(1, name);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                this.id = rs.getInt(1);
                int id = this.id;
                sid = Math.max(sid, id + 1);
            }
            else {
                throw new ElabException("The project (" + name
                        + ") was not found in the database");
            }
        }
        catch (Exception e) {
            System.out.println("Failed to update elab id for " + name
                    + ". Using elab name as ID.");
            e.printStackTrace();
            this.id = sid++;
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }
    
    private static final Elab[] ELAB_ARRAY = new Elab[0];
    
    public Elab[] getAllElabs() {
        List elabs = new ArrayList();
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(properties);
            s = conn.createStatement();
            ResultSet rs;
            rs = s.executeQuery("SELECT name from project;");
            while (rs.next()) {
                String name = rs.getString(1);
                elabs.add(getElab(null, name));
            }
        }
        catch (Exception e) {
            System.out.println("Failed to retrieve elab list");
            e.printStackTrace();
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
        return (Elab[]) elabs.toArray(ELAB_ARRAY);
    }

    /**
     * Returns this elab's ID.
     */
    public int getId() {
        return id;
    }

    /**
     * Sets the ID of this elab
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * Returns the name of this elab
     */
    public String getName() {
        return name;
    }

    /**
     * Returns this elab's combined properties.
     */
    public ElabProperties getProperties() {
        return properties;
    }

    /**
     * Authenticates a user and returns the <code>ElabUser</code> object
     * describing the authenticated user. If the authentication fails,
     * <code>AuthenticationException</code> is thrown.
     * 
     * @param username
     *            The user name
     * @param password
     * @return An <code>ElabUser</code> object containing the details for the
     *         authenticated user
     * @throws AuthenticationException
     *             if the authentication fails
     */
    public ElabGroup authenticate(String username, String password)
            throws AuthenticationException {
        ElabUserManagementProvider p = ElabFactory
                .getUserManagementProvider(this);
        ElabGroup user = p.authenticate(username, password);
        if (username != null && username.equals(properties.getGuestUserName())) {
            user.setGuest(true);
        }
        return user;
    }
    
    public ElabGroup adminAuthenticateAsOther(String adminUsername, String adminPassword, String usergroup) 
    	throws AuthenticationException {
    	DatabaseUserManagementProvider p = (DatabaseUserManagementProvider) ElabFactory.getUserManagementProvider(this); 
    	ElabGroup user = p.adminAuthenticateAsOtherUser(adminUsername, adminPassword, usergroup); 
    	if (usergroup != null && usergroup.equals(properties.getGuestUserName())) {
    		user.setGuest(true);
    	}
    	return user;
    }

    /**
     * Returns an instance of an <code>ElabUserManagementProvider</code> that
     * implements user management functionality for this elab.
     * 
     * @throws ElabInstantiationException
     */
    public ElabUserManagementProvider getUserManagementProvider() {
        return ElabFactory.getUserManagementProvider(this);
    }

    /**
     * Given a path relative to the elab, construct a path that points to the
     * same file but is relative to the page of the current request.
     */
    public String rpage(HttpServletRequest request, String rel) {
        String reqpath = request.getServletPath();
        int reqdepth = charCount(reqpath, '/');
        // add as many ../ as needed
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < reqdepth - 2; i++) {
            sb.append("../");
        }
        sb.append(rel);
        return sb.toString();
    }

    private int charCount(String str, char c) {
        int count = 0;
        for (int i = 0; i < str.length(); i++) {
            if (str.charAt(i) == c) {
                count++;
            }
        }
        return count;
    }

    /**
     * Builds a link that would log in a user as guest based on information from
     * the elab properties. Additionally, the link may contain a redirection
     * request that takes place after the login if the request containes a
     * parameter named "prevPage"<br>
     * Note: this looks hackish
     */
    public String getGuestLoginLink(HttpServletRequest request) {
        String prevPage = request.getParameter("prevPage");
        if (prevPage == null) {
            prevPage = properties.getLoggedInHomePage();
        }

        prevPage = "?prevPage=" + URLEncoder.encode(prevPage);
        String login = "&login=Login";
        String user = "&user=" + getProperties().getGuestUserName();
        String pass = "&pass=" + getProperties().getGuestUserPassword();
        String project = "&project=" + getName();
        return '/' + properties.getWebapp() + '/' + getName() + '/'
                + properties.getRequired("elab.login.page") + prevPage + login
                + user + pass + project;
    }

    /**
     * Return an <code>FAQ</code> instance for this elab
     */
    public synchronized ElabFAQ getFAQ() {
        if (faq == null) {
            faq = new ElabFAQ(this);
        }
        return faq;
    }

    /**
     * Returns an instance of the <code>DataCatalogProvider</code> that
     * implements data catalog functionality for this elab.
     * 
     * @throws ElabInstantiationException
     */
    public DataCatalogProvider getDataCatalogProvider() {
        return ElabFactory.getDataCatalogProvider(this);
    }
    
    /**
     * Returns an instance of the <code>AnalysisCatalogProvider</code> that
     * implements data catalog functionality for this elab.
     * 
     * @throws ElabInstantiationException
     */
    public DataCatalogProvider getAnalysisCatalogProvider() {
        return ElabFactory.getAnalysisCatalogProvider(this);
    }

    /**
     * Returns an instance of the <code>AnalysisExecutor</code> that
     * implements analysis execution functionality for this elab.
     * 
     * @throws ElabInstantiationException
     */
    public AnalysisExecutor getAnalysisExecutor() {
        return ElabFactory.getAnalysisProvider(this);
    }

    public ElabTestProvider getTestProvider() {
        return ElabFactory.getTestProvider(this);
    }

    /**
     * Convenience method. Same as
     * <code>Elab.getProperties().getProperty(name)</code>
     */
    public String getProperty(String name) {
        return properties.getProperty(name);
    }
    
    public ElabSurveyProvider getSurveyProvider() { 
    	return ElabFactory.getSurveyProvider(this);
    }

    /**
     * Returns a secure URL for the given page. This depends on the values in
     * <code>elab.properties</code>. The page is specified relative to the
     * elab. Consequently it should not include the elab name or the web
     * application name.
     * 
     * @param page
     *            The page to provide a secure URL for
     * @return A secure URL to access the specified page
     */
    public String secure(String page) {
        return properties.getRequired("elab.secure.url") + '/'
                + properties.getWebapp() + '/' + getName() + '/' + page;
    }
    
    public String nonSecure(String page) {
    	return getURL() + '/' + properties.getWebapp() + '/' + getName() + '/' + page;
    }
    
    private String getURL() {
    	String url = properties.getProperty("elab.url");
    	if (url == null || url.equals("")) {
    		url = "http://" + properties.getRequired("elab.host");
    		/*String port = properties.getProperty("elab.port");
    		if (port != null) {
    			url = url + ":" + port;
    		}*/
    	}
    	return url;
    }

    public Map<String, Object> getAttributes() {
        return attributes;
    }

    public void setAttribute(String name, Object value) {
        attributes.put(name, value);
    }

    public Object getAttribute(String name) {
        return attributes.get(name);
    }

    private Map<Elab, ServletContext> realPaths;

    /**
     * Returns a lazy map that can be used to figure out the absolute paths of
     * files relative to an elab.
     */
    public synchronized Map<Elab, ServletContext> getRealPaths() {
        if (realPaths == null) {
            realPaths = new RealPathMap(this, context);
        }
        return realPaths;
    }
    
    public HttpSession getSession() {
        return pageContext.getSession();
    }
}
