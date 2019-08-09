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


		/* All comments added Aug2019 - JG */
		/** In many cases, the value of a Property can depend on the value of a 
		 *	different Property.  For example, the e-Labs `elab.properties` file 
		 *  contains entries of the form
		 *
		 *    i2u2.home=/home/quarkcat/sw
		 *    source=${i2u2.home}/i2u2svn
		 *
		 *  where the value of the Property 'source' contains a reference to the 
		 *  value of the Property 'i2u2.home', as indicated by the '${}' braces.
		 *  
		 *  replaceRefs(pname, stack) takes the value associated with the Property 
		 *  name `pname` and finds all sets of replacement braces in that value.  
		 *  For each pair of replacement braces, it identifies whether the contents 
		 *  are another valid Property name, and if so it replaces that Property
		 *  name (and the braces) with the corresponding Property value.
		 *
		 *  For example, given the Properties Set above, replaceRefs("source", stack)
		 *  would produce a Properties Set equivalent to
		 *
		 *    i2u2.home=/home/quarkcat/sw
		 *    source=/home/quarkcat/sw/i2u2svn
		 *
		 *  replaceRefs() calls itself recursively; the Collection 'stack' is used 
		 *  only to carry information between recursions and should be empty when 
		 *  this method is called from external code.
		 **/
    protected void replaceRefs(String pname, Collection stack) {
				/* The following error is thrown for the Properties case `x=${x}`,
				 * where attempted replacement would produce an infinite loop. */
				if (stack.contains(pname)) {
            throw new CircularPropertyReferenceException(stack, name);
        }
				/* Assuming that doesn't happen, */
        try {
						/* For the input Property name, find the corresponding value and 
						 * also add the name to the stack */
            String value = getProperty(pname);
            stack.add(pname);
						/* If the Property value does not contain "${", there's nothing to 
						 * replace.  All is well; exit the method. */
            if (value.indexOf("${") == -1) {
                return;
            }
						/* The remaining code handles the case where the Property 
						 * value contains one (or more) "${". */
            else {
								/* We divide 'value' into segments at each instance of "${" or 
								 * "}".  We examine each segement in turn, substituting 
								 * replacement braces with Property values when appropriate.  
								 * When we finish with a segment, we append it to a StringBuffer
								 * to construct the resulting Property value segment-by-segment. */ 
                StringBuffer sb = new StringBuffer();
								/* We track segments by defining two cursors, 'index' and 'last',
								 * to record starting and ending String indices of the segment 
								 * within 'value'. */
								/* 'last' <= 'index' always. */
                int index = 0, last = 0;
                while (index >= 0) {
										/* Advance 'index' to the beginning of the first "${" at
										 * or after the current index */
                    index = value.indexOf("${", index);
                    if (index >= 0) {
                        if (last != index) {
														/* If 'last' trails the current 'index', write the
														 * interval between them to the StringBuffer and 
														 * advance 'last' to meet 'index' at the current "${" */
                            sb.append(value.substring(last, index));
                            last = index;
                        }
                        int end = value.indexOf("}", index);
                        if (end == -1) {
														/* If there's no closing "}", then we can't define a  
														 * replacement.  Write "${" and everything after it
														 * to the StringBuffer, then exit the 'while' loop. */
                            sb.append(value.substring(index));
                            break;
                        }
                        else {
														/* If there is a closing "}", extract everything 
														 * between "${" and "}" as a presumed Property name */
														String name = value.substring(index + 2, end);
														/* This Property name might itself contain replacement 
														 * braces that reference a valid Property name.  Call
														 * the current method recursively to handle those 
														 * replacements */
														replaceRefs(name, stack);
														/* Get the Property value associated with this new
														 * Property name: */
                            String pval = getProperty(name);
														/* Advance 'index' to just past "}". */
														index = end + 1;
                            if (pval == null) {
																/* If there's no Property value associated with
																 * this Property name, continue the 'while' loop
																 * to look for additional instances of "${". 
																 * The current replacement braces and their 
																 * contents will be left as-is in 'value'. */
																continue;
                            }
                            else {
																/* If a valid Property value exists, write it 
																 * to the StringBuffer in lieu of the replacement 
																 * braces and their contents. */
                                sb.append(pval);
																/* Advance 'last' to the current 'index', which 
																 * is just past "}" in all cases. */
                                last = index;
                            }
                        }
                    }
                } // END of 'while' loop
								/* At this point, the Property value has been found to contain at
								 * least one "${".  Append the remaining segement of 'value', */
                sb.append(value.substring(last));
								/* and then put() the Property name and new Property value String 
								 * to the current Properties object */
								/* Hashtable.put(key, value) */
								put(pname, sb.toString());
            }
        }
        finally {
						/* All recursion is resolved, so remove 'pname' from 'stack' */
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
