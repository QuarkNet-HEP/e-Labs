/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;


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

    public String getFormalName() {
        return getProperty(ElabProperties.PROP_ELAB_FORMAL_NAME, elabName);
    }

    public String getLoginURL() {
        return getRequired(ElabProperties.PROP_ELAB_LOGIN_URL);
    }

    public String getGuestUserName() {
        return getProperty(ElabProperties.PROP_ELAB_GUEST_USERNAME, "guest");
    }

    public String getGuestUserPassword() {
        return getProperty(ElabProperties.PROP_ELAB_GUEST_PASSWORD, "guest");
    }

    public String getLoggedInHomePage() {
        return getProperty(ElabProperties.PROP_ELAB_LOGGED_IN_HOME_PAGE, "/elab/"
                + elabName + "/jsp/loggedinhome.jsp");
    }
    
    public String getLoggedOutHomePage() {
        return getProperty(ElabProperties.PROP_ELAB_LOGGED_OUT_HOME_PAGE, "/elab/"
                + elabName + "/jsp/loggedouthome.jsp");
    }
    
    public String getHost() {
        return getRequired(ElabProperties.PROP_HOST);
    }
    
    public String getPort() {
        return getRequired(ElabProperties.PROP_PORT);
    }
    
    public String getDataDir() {
        return getRequired(ElabProperties.PROP_DATA_DIR);
    }
}
