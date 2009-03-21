/*
 * Created on Apr 21, 2007
 */
package gov.fnal.elab.analysis;

import java.lang.reflect.Method;
import java.util.AbstractCollection;
import java.util.AbstractMap;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * An adaptor implementing <code>ElabAnalysis</code> on top of an
 * <code>ElabBean</code>. This is not needed any more, but kept just in case.
 */
public class BeanWrapper extends AbstractAnalysis {
    private Object bean;
    private Class beanClass;
    private String type;
    private Set properties;
    private Map defaults;

    public BeanWrapper() {
        defaults = new HashMap();
    }

    public BeanWrapper(Object bean) {
        this();
        this.bean = bean;
        setBeanClass(bean.getClass());
    }

    public void initialize(String param) throws InitializationException {
        try {
            setBeanClass(param);
        }
        catch (Exception e) {
            throw new InitializationException(e);
        }
    }

    public void setBeanClass(String cls) throws InstantiationException,
            IllegalAccessException, ClassNotFoundException {
        this.bean = BeanWrapper.class.getClassLoader().loadClass(cls)
                .newInstance();
        this.beanClass = bean.getClass();
        discoverProperties();
    }

    public void setBeanClass(Class cls) {
        this.beanClass = cls;
        discoverProperties();
    }

    public Collection getInvalidParameters() {
        return (Collection) invoke("getInvalidKeys", Collection.class);
    }

    public Object getBean() {
        return bean;
    }

    public Object getParameter(String name) {
        return invoke(getterName(name), null);
    }

    public void setParameterDefault(String name, Object value) {
        setParameter(name, value);
        defaults.put(name, value);
    }

    public boolean isDefaultValue(String name, Object value) {
        if (equals(value, defaults.get(name))) {
            return true;
        }
        if ("".equals(value)) {
            return true;
        }
        else {
            return false;
        }
    }

    private boolean equals(Object o1, Object o2) {
        if (o1 == null) {
            return o2 == null;
        }
        else {
            return o1.equals(o2);
        }
    }

    public Collection getParameterNames() {
        return properties;
    }

    public boolean isParameterValid(String name) {
        try {
            return ((Boolean) invoke(isValidName(name), Boolean.class))
                    .booleanValue();
        }
        catch (RuntimeException e) {
            if (e.getCause() instanceof NoSuchMethodException) {
                return true;
            }
            else {
                throw e;
            }
        }
    }

    public boolean isValid() {
        return ((Boolean) invoke("isValid", Boolean.class)).booleanValue();
    }

    public void setParameter(String name, Object value) {
        set(setterName(name), value);
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getType() {
        return type;
    }

    public static final Class[] CLS_NO_PARAMS = new Class[0];
    private static final Map setters = new HashMap();

    private void set(String name, Object value) {
        try {
            Method m = getSetter(name);
            m.invoke(bean, new Object[] { value });
        }
        catch (Exception e) {
            throw new RuntimeException("Exception setting " + name
                    + " for class " + bean.getClass(), e);
        }
    }

    private Method getSetter(String name) throws NoSuchMethodException {
        Method setter = null;
        synchronized (setters) {
            setter = (Method) setters.get(name);
            if (setter == null) {
                Method[] methods = beanClass.getDeclaredMethods();
                for (int i = 0; i < methods.length; i++) {
                    if (methods[i].getName().equals(name)) {
                        setter = methods[i];
                        setters.put(name, setter);
                        break;
                    }
                }
            }
        }
        if (setter == null) {
            throw new NoSuchMethodException(name);
        }
        return setter;
    }

    private Object invoke(String methodName, Class ret) {
        try {
            Method m = beanClass.getMethod(methodName, CLS_NO_PARAMS);
            Object val = m.invoke(bean, (Object[]) null);
            if (ret != null && val != null) {
                if (!ret.isAssignableFrom(val.getClass())) {
                    throw new RuntimeException("Invalid bean: the method '"
                            + methodName + "' does not return a '" + ret + "'");
                }
            }
            return val;
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void discoverProperties() {
        Method[] methods = bean.getClass().getDeclaredMethods();
        Set getters = new HashSet();
        Set setters = new HashSet();
        for (int i = 0; i < methods.length; i++) {
            String name = methods[i].getName();
            if (name.startsWith("get")) {
                getters.add(decapitalize(name.substring(3)));
            }
            else if (name.startsWith("set")) {
                setters.add(decapitalize(name.substring(3)));
            }
        }
        getters.retainAll(setters);
        properties = getters;
    }

    private String decapitalize(String s) {
        return Character.toLowerCase(s.charAt(0)) + s.substring(1);
    }

    private String name(String name, String prefix, String suffix) {
        StringBuffer sb = new StringBuffer(name.length() + 3);
        if (prefix != null) {
            sb.append(prefix);
        }
        sb.append(Character.toUpperCase(name.charAt(0)));
        sb.append(name.substring(1));
        if (suffix != null) {
            sb.append(suffix);
        }
        return sb.toString();
    }

    private String getterName(String name) {
        return name(name, "get", null);
    }

    private String setterName(String name) {
        return name(name, "set", null);
    }

    private String isValidName(String name) {
        return name(name, "is", "Valid");
    }

    public Class getParameterType(String name) {
        try {
            Method m = beanClass.getMethod(getterName(name), CLS_NO_PARAMS);
            return m.getReturnType();
        }
        catch (NoSuchMethodException e) {
            return null;
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public boolean hasParameter(String name) {
        try {
            Method m = beanClass.getMethod(getterName(name), CLS_NO_PARAMS);
            return true;
        }
        catch (NoSuchMethodException e) {
            return false;
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public Map getParameters() {
        return new BeanMap();
    }

    public String getEncodedParameters() {
        return AnalysisTools.encodeParameters(this);
    }

    private class BeanMap extends AbstractMap {

        public BeanMap() {

        }

        public Set entrySet() {
            return new EntrySet();
        }

        private class EntrySet extends AbstractCollection implements Set {
            public Iterator iterator() {
                return new Iterator() {
                    private Iterator it = properties.iterator();

                    public boolean hasNext() {
                        return it.hasNext();
                    }

                    public Object next() {
                        final String name = (String) it.next();
                        return new Map.Entry() {
                            public Object getKey() {
                                return name;
                            }

                            public Object getValue() {
                                return getParameter(name);
                            }

                            public Object setValue(Object value) {
                                Object old = getParameter(name);
                                setParameter(name, value);
                                return old;
                            }
                        };
                    }

                    public void remove() {
                        throw new UnsupportedOperationException("remove");
                    }
                };
            }

            public int size() {
                return properties.size();
            }
        }
    }
}