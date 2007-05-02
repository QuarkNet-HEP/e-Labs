/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

/**
 * This class contains properties associated with an elab. Typically the
 * properties are loaded automatically when an elab is instantiated through one
 * of the <code>Elab.getElab()</code> methods.
 */
public class ElabProperties extends AbstractProperties {
    public static final String PROP_ELAB_NAME = "elab.name";
    public static final String PROP_ELAB_FORMAL_NAME = "elab.formal.name";
    public static final String PROP_ELAB_LOGIN_URL = "elab.login.url";
    public static final String PROP_ELAB_GUEST_USERNAME = "elab.guest.username";
    public static final String PROP_ELAB_GUEST_PASSWORD = "elab.guest.password";
    public static final String PROP_USERDB_DB = "userdb.db";
    public static final String PROP_USERDB_USERNAME = "userdb.username";
    public static final String PROP_USERDB_PASSWORD = "userdb.password";
    public static final String PROP_ELAB_LOGGED_IN_HOME_PAGE = "elab.logged.in.home.page";
    public static final String PROP_ELAB_LOGGED_OUT_HOME_PAGE = "elab.logged.out.home.page";
    public static final String PROP_HOST = "host";
    public static final String PROP_PORT = "port";
    public static final String PROP_RUN_DIR = "run.dir";
    public static final String PROP_USER_DIR = "user.dir";
    public static final String PROP_DATA_DIR = "data.dir";

    private String elabName;

    public ElabProperties(String elabName) {
        super(elabName + " elab");
        this.elabName = elabName;
    }

    /**
     * Returns the formal name of an elab (elab.formal.name).
     */
    public String getFormalName() {
        return getProperty(ElabProperties.PROP_ELAB_FORMAL_NAME, elabName);
    }

    /**
     * Returns the login URL of an elab (elab.login.url)
     */
    public String getLoginURL() {
        return getRequired(ElabProperties.PROP_ELAB_LOGIN_URL);
    }

    /**
     * Returns the guest user name (elab.guest.username). Defaults to "guest".
     */
    public String getGuestUserName() {
        return getProperty(ElabProperties.PROP_ELAB_GUEST_USERNAME, "guest");
    }

    /**
     * Returns the guest password (elab.guest.password). Defaults to "guest".
     */
    public String getGuestUserPassword() {
        return getProperty(ElabProperties.PROP_ELAB_GUEST_PASSWORD, "guest");
    }

    /**
     * Returns the default logged-in page (elab.logged.in.home.page). Defaults
     * to "/elab/${elab.name}/home/logged-in-home.jsp".
     */
    public String getLoggedInHomePage() {
        return getProperty(ElabProperties.PROP_ELAB_LOGGED_IN_HOME_PAGE,
                "/elab/" + elabName + "/home/logged-in-home.jsp");
    }

    /**
     * Returns the default logged-out page (elab.logged.out.home.page). Defaults
     * to "/elab/${elab.name}/home/logged-out-home.jsp".
     */
    public String getLoggedOutHomePage() {
        return getProperty(ElabProperties.PROP_ELAB_LOGGED_OUT_HOME_PAGE,
                "/elab/" + elabName + "/home/logged-out-home.jsp");
    }

    /**
     * Returns the host name (host).
     */
    public String getHost() {
        return getRequired(ElabProperties.PROP_HOST);
    }

    /**
     * Returns the port (port).
     */
    public String getPort() {
        return getRequired(ElabProperties.PROP_PORT);
    }

    /**
     * Returns the data directory (data.dir).
     */
    public String getDataDir() {
        return getRequired(ElabProperties.PROP_DATA_DIR);
    }
}
