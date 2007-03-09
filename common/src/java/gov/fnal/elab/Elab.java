/*
 * Created on Mar 4, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.usermanagement.ElabUserManagementProviderFactory;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.util.URLEncoder;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import javax.servlet.http.HttpServletRequest;

public class Elab {
    private static Map elabs;
    private static Elab global;

    public static Elab getElab(String name) throws ElabInstantiationException {
        return getElab(name, "elab.properties." + name);
    }

    public static synchronized Elab getElab(String name, String properties)
            throws ElabInstantiationException {
        if (global == null) {
            global = Elab.newElab("global", "elab.properties");
        }
        if (elabs == null) {
            elabs = new HashMap();
        }
        Elab elab = (Elab) elabs.get(name);
        if (elab == null) {
            elab = Elab.newElab(name, properties, global.getProperties());
            elab.init();
            elabs.put(name, elab);
        }
        return elab;
    }

    public static Elab newElab(String name, String properties)
            throws ElabInstantiationException {
        return newElab(name, properties, null);
    }

    public static Elab newElab(String name, String properties,
            Properties inherited) throws ElabInstantiationException {
        Elab elab = new Elab(name);
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

    protected Elab(String name) {
        this.name = name;
        this.properties = new ElabProperties(name);
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
        ElabUserManagementProvider p = ElabUserManagementProviderFactory
                .getDefault(properties);
        ElabUser user = p.authenticate(username, password, id);
        if (username != null && username.equals(properties.getGuestUserName())) {
            user.setGuest(true);
        }
        return user;
    }

    public String css(String css) {
        return "<link rel=\"stylesheet\" type=\"text/css\" href=\"/elab/"
                + getName() + "/" + css + "\"/>";
    }

    public String page(String rel) {
        return "/elab/" + name + "/" + rel;
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
}
