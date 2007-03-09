/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Properties;

public class ElabProperties extends Properties {
    public static final String PROP_ELAB_NAME = "elab.name";
    public static final String PROP_ELAB_FORMAL_NAME = "elab.formal.name";
    public static final String PROP_ELAB_LOGIN_URL = "elab.login.url";
    public static final String PROP_ELAB_GUEST_USERNAME = "elab.guest.username";
    public static final String PROP_ELAB_GUEST_PASSWORD = "elab.guest.password";
    public static final String PROP_USERDB_DB = "userdb.db";
    public static final String PROP_USERDB_USERNAME = "userdb.username";
    public static final String PROP_USERDB_PASSWORD = "userdb.password";
    public static final String PROP_ELAB_LOGGED_IN_HOME_PAGE = "elab.logged.in.home.page";
    public static final String PROP_HOST = "host";
    public static final String PROP_PORT = "port";

    private String elabName;

    public ElabProperties(String elabName) {
        this.elabName = elabName;
    }

    protected void load(Properties inherited) {
        putAll(inherited);
    }

    public void load(String propertiesFile) throws IOException {
        URL url = Elab.class.getClassLoader().getResource(propertiesFile);
        InputStream is = null;
        if (url != null) {
            is = url.openStream();
        }
        if (url == null || is == null) {
            throw new FileNotFoundException("Elab properties file ("
                    + propertiesFile + ") not found");
        }
        load(url.openStream());
    }

    protected void resolve() {
        Collection stack = new LinkedList();
        Iterator i = new HashSet(keySet()).iterator();
        while (i.hasNext()) {
            String name = (String) i.next();
            stack.clear();
            replaceRefs(name, stack);
        }
    }

    protected void replaceRefs(String pname, Collection stack) {
        if (stack.contains(pname)) {
            throw new CircularPropertyReferenceException(stack, elabName);
        }
        try {
            String value = getProperty(pname);
            stack.add(pname);
            if (value.indexOf("${") == -1) {
                return;
            }
            else {
                StringBuffer sb = new StringBuffer();
                int index = 0, last = 0;
                while (index >= 0) {
                    index = value.indexOf("${", index);
                    if (index >= 0) {
                        if (last != index) {
                            sb.append(value.substring(last, index));
                            last = index;
                        }
                        int end = value.indexOf("}", index);
                        if (end == -1) {
                            sb.append(value.substring(index));
                            break;
                        }
                        else {
                            String name = value.substring(index + 2, end);
                            replaceRefs(name, stack);
                            String pval = getProperty(name);
                            index = end + 1;
                            if (pval == null) {
                                continue;
                            }
                            else {
                                sb.append(pval);
                                last = index;
                            }
                        }
                    }
                }
                sb.append(value.substring(last));
                put(pname, sb.toString());
            }
        }
        finally {
            stack.remove(pname);
        }
    }

    protected String getRequired(String prop) {
        String value = getProperty(prop);
        if (value == null) {
            throw new MissingPropertyException(prop, elabName);
        }
        else {
            return value;
        }
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
                + elabName + "/loggedinhome.jsp");
    }
    
    public String getHost() {
        return getRequired(ElabProperties.PROP_HOST);
    }
    
    public String getPort() {
        return getRequired(ElabProperties.PROP_PORT);
    }
}
