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

public class AbstractProperties extends Properties {
    private String name;
    
    public AbstractProperties(String name) {
        this.name = name;
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
            throw new FileNotFoundException("Properties file ("
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
            throw new CircularPropertyReferenceException(stack, name);
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
            throw new MissingPropertyException(prop, name);
        }
        else {
            return value;
        }
    }
    
    public String getName() {
        return name;
    }
}
