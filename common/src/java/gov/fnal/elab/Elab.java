/*
 * Created on Mar 4, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.analysis.AnalysisExecutor;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.util.URLEncoder;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.PageContext;

public class Elab {
    private static Map elabs;
    private static Elab global;

    public static Elab getElab(PageContext context, String name) throws ElabInstantiationException {
        return getElab(context, name, "elab.properties." + name);
    }

    public static synchronized Elab getElab(PageContext context, String name, String properties)
            throws ElabInstantiationException {
        if (global == null) {
            global = Elab.newElab(context, "global", "elab.properties");
        }
        if (elabs == null) {
            elabs = new HashMap();
        }
        Elab elab = (Elab) elabs.get(name);
        if (elab == null) {
            elab = Elab.newELab(context, name, properties, global.getProperties());
            elab.init();
            elabs.put(name, elab);
        }
        return elab;
    }

    public static Elab newElab(PageContext context, String name, String properties)
            throws ElabInstantiationException {
        return newELab(context, name, properties, null);
    }

    public static Elab newELab(PageContext context, String name, String properties,
            Properties inherited) throws ElabInstantiationException {
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
    private String id;
    private ElabFAQ faq;
    private ServletContext context;
    private ServletConfig config;

    protected Elab(PageContext pc, String name) {
        this.name = name;
        this.properties = new ElabProperties(name);
        this.context = pc.getServletContext();
        this.config = pc.getServletConfig();
    }
    
    public ServletContext getServletContext() {
        return context;
    }
    
    public ServletConfig getServletConfig() {
        return config;
    }

    public void init() throws ElabInstantiationException {
        properties.resolve();
        try {
            updateId();
        }
        catch (Exception e) {
            throw new ElabInstantiationException(e);
        }
    }

    protected void updateId() throws SQLException, ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(properties);
            s = conn.createStatement();
            ResultSet rs;
            rs = s.executeQuery("SELECT id from project where "
                    + "project.name='" + ElabUtil.fixQuotes(name) + "';");
            if (rs.next()) {
                this.id = rs.getString(1);
            }
            else {
                throw new ElabException("The project (" + name
                        + ") was not found in the database");
            }
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public ElabProperties getProperties() {
        return properties;
    }

    public ElabUser authenticate(String username, String password,
            String project) throws AuthenticationException {
        ElabUserManagementProvider p = ElabFactory.getUserManagementProvider(this);
        ElabUser user = p.authenticate(username, password, id);
        if (username != null && username.equals(properties.getGuestUserName())) {
            user.setGuest(true);
        }
        return user;
    }
    
    public ElabUserManagementProvider getUserManagementProvider() {
        return ElabFactory.getUserManagementProvider(this);
    }
    
    public String css(String css) {
        String path = getName() + "/" + css;
        return "<link rel=\"stylesheet\" type=\"text/css\" href=\"/elab/" + path + "\"/>";
    }

    public String css(HttpServletRequest request, String css) {
        ServletContext context = request.getSession().getServletContext();
        String path = getName() + "/" + css;
        String ua = request.getHeader("User-Agent");
        ua = getCanonicalUA(ua);
        System.out.println(ua);
        String uapath = path;
        if (path.endsWith(".css")) {
            int i = path.length() - 4;
            uapath = path.substring(0, i) + "_" + ua + path.substring(i);
        }
        File f = new File(context.getRealPath(uapath));
        if (f.exists()) {
            return "<link rel=\"stylesheet\" type=\"text/css\" href=\"/elab/" + path + "\"/>\n" + 
            "<link rel=\"stylesheet\" type=\"text/css\" href=\"/elab/" + uapath + "\"/>";
        }
        else {
            return "<link rel=\"stylesheet\" type=\"text/css\" href=\"/elab/" + path + "\"/>";
        }
    }
    
    public String script(HttpServletRequest request, String script) {
        ServletContext context = request.getSession().getServletContext();
        String path = getName() + "/" + script;
        String ua = request.getHeader("User-Agent"); 
        ua = getCanonicalUA(ua);
        System.out.println(ua);
        String uapath = path;
        if (path.endsWith(".js")) {
            int i = path.length() - 3;
            uapath = path.substring(0, i) + "_" + ua + path.substring(i);
        }
        File f = new File(context.getRealPath(uapath));
        if (f.exists()) { 
            return "<script type=\"text/javascript\" src=\"/elab/" + uapath + "\"/>";
        }
        else {
            return "<script type=\"text/javascript\" src=\"/elab/" + path + "\"/>";
        }
    }
    
    protected String getCanonicalUA(String ua) {
        if (ua != null) {
            if (ua.indexOf("MSIE 6") != -1) {
                return "ie6";
            }
            if (ua.indexOf("Opera/9") != -1) {
                return "opera9";
            }
            if (ua.indexOf("Safari") != -1) {
                return "safari";
            }
        }
        return ua;
    }


    public String page(String rel) {
        return "/elab/" + name + "/" + rel;
    }
    
    /**
     * Given a path relative to the elab, construct a path that points
     * to the same file but is relative to the page of the current request. 
     */
    public String rpage(HttpServletRequest request, String rel) {
        String reqpath = request.getServletPath();
        int reqdepth = charCount(reqpath, '/');
        //add as many ../ as needed
        StringBuffer sb = new StringBuffer();
        for(int i = 0; i < reqdepth - 2; i++) {
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
    
    public String reference(String refname) {
        StringBuffer sb = new StringBuffer();
        sb.append("<a href=\"javascript:reference('");
        sb.append(refname);
        sb.append("')\"><img src=\"graphics/ref.gif\"></a>");
        return sb.toString();
    }

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
        return getProperties().getLoginURL() + prevPage + login + user + pass
                + project;
    }
    
    public synchronized ElabFAQ getFAQ() {
        if (faq == null) {
            faq = new ElabFAQ(this);
        }
        return faq;
    }
    
    public DataCatalogProvider getDataCatalogProvider() {
        return ElabFactory.getDataCatalogProvider(this);
    }
    
    public AnalysisExecutor getAnalysisExecutor() {
        return ElabFactory.getAnalysisProvider(this);
    }
}
