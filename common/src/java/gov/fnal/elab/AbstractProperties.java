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
				// This is Hashtable.keySet() via inheritance, not RealPathMap.keySet()
        Iterator i = new HashSet(keySet()).iterator();
        while (i.hasNext()) {
            String name = (String) i.next();
            stack.clear();
            replaceRefs(name, stack);
        }
    }

    protected void replaceRefs(String pname, Collection stack) {
				/** Adds the Property name 'pname' to the Collection 'stack' if it's not 
						already there. **/
				/* All comments added 1Aug2019 - JG */
        /* Property names and Property values act as k:v pairs */
				if (stack.contains(pname)) {
            throw new CircularPropertyReferenceException(stack, name);
        }
        try {
						/* If the Property name isn't already in the stack, add it */
            String value = getProperty(pname);
            stack.add(pname);
						/* If the Property value does not contain "${", all is well. 
						 * The Property name has been added to the stack, and we exit the 
						 * method. */
            if (value.indexOf("${") == -1) {
                return;
            }
						/* The rest of the method handles the case where the Property 
						 * value does contain at least one "${".  We allow for it to 
						 * contain more than one instance of "${". */
            else {
                StringBuffer sb = new StringBuffer();
                int index = 0, last = 0;
                while (index >= 0) {
										/* Advance 'index' to the beginning of the first "${" at
										 * or after the current index */
                    index = value.indexOf("${", index);
                    if (index >= 0) {
												/* NB 'last' <= 'index' always. */
                        if (last != index) {
														/* If this location exists and is advanced from the 
														 * last location of the index, write the substring
														 * between the two points to the StringBuffer. */
                            sb.append(value.substring(last, index));
														/* Advance 'last' to the current position */
                            last = index;
                        }
                        int end = value.indexOf("}", index);
                        if (end == -1) {
														/* If there's no closing "}", write "${" and 
														 * everything after it to the StringBuffer, 
														 * then exit the 'while' loop. */
                            sb.append(value.substring(index));
                            break;
                        }
                        else {
														/* If there is a closing "}", extract everything 
														 * between "${" and "}" */
														String name = value.substring(index + 2, end);
														/* Although 'value' is a Property value and 'name' 
														 * a substring of it, we take 'name' to be a 
														 * Property name and recurse it back into this 
														 * method. This may alter 'stack'. */
														replaceRefs(name, stack);
														/* Get the Property value associated with this new
														 * Property name: */
                            String pval = getProperty(name);
														/* Advance 'index' to just past "}".  This is the 
														 * only time 'index' changes in the loop. */
														index = end + 1;
                            if (pval == null) {
																/* If there's no Property value associated with
																 * this Property name, continue the 'while' loop
																 * to look for additional instances of "${". */
																continue;
                            }
                            else {
																/* If a valid Property value exists, write it 
																 * to the StringBuffer and advance 'last' to the
																 * current 'index', which is just past "}" in 
																 * all cases. */
                                sb.append(pval);
                                last = index;
                            }
                        } // END else if "}" exists
                    } // END if subsequent "$}" exists
										/* If one does not exist, then 'index' = -1, the 'if' 
										 * condition fails, and the outer 'while' loop is exited: */
                }  // END while "${" exists
								/* At this point, the Property value has been found to 
								 * contain at least one "${".
								 * If there was no closing "}", 'sb' may already have some 
								 * content. */
                sb.append(value.substring(last));
								/* Hashtable.put(key, value) */
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
