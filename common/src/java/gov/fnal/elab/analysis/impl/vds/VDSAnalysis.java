/*
 * Created on Apr 9, 2007
 */
package gov.fnal.elab.analysis.impl.vds;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.analysis.AbstractAnalysis;
import gov.fnal.elab.analysis.AnalysisParameterTransformer;
import gov.fnal.elab.analysis.AnalysisTools;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.beans.ElabBean;
import gov.fnal.elab.beans.vds.VDSElabBean;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.FQN;

import java.sql.SQLException;
import java.util.AbstractMap;
import java.util.AbstractSet;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.griphyn.vdl.classes.Declare;
import org.griphyn.vdl.classes.Definition;
import org.griphyn.vdl.classes.Derivation;
import org.griphyn.vdl.classes.LFN;
import org.griphyn.vdl.classes.Pass;
import org.griphyn.vdl.classes.Scalar;
import org.griphyn.vdl.classes.Text;
import org.griphyn.vdl.classes.Transformation;
import org.griphyn.vdl.classes.Value;
import org.griphyn.vdl.dbschema.DatabaseSchema;
import org.griphyn.vdl.dbschema.VDC;
import org.griphyn.vdl.directive.Connect;
import org.griphyn.vdl.util.ChimeraProperties;

/**
 * This is an implementation of an <code>ElabAnalysis</code> on top of the
 * generic <code>ElabBean</code> (which is only used for a few convenience
 * methods).
 */
public class VDSAnalysis extends VDSElabBean implements ElabAnalysis {
    //grr. I want multiple inheritance. Or mixins.
    private String type;
    private DatabaseSchema dbschema;
    private VDC vdc;
    private Map arguments, defaults, attributes;
    private int connected;
    private AnalysisParameterTransformer parameterTransformer;
    private Elab elab;
    private ElabGroup user;

    public VDSAnalysis() {
        defaults = new HashMap();
    }
    
    public void initialize(String param) {
        
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        setType(type, null);
    }
    
    public String getName() {
        String[] ts = type.split("::");
        return ts[ts.length - 1];
    }

    public void setType(String type, Derivation pdv) {
        this.type = type;
        connect();
        try {
            FQN fqn = new FQN(type);
            tr = (Transformation) vdc.loadDefinition(fqn.getNamespace(), fqn
                    .getName(), fqn.getVersion(), Definition.TRANSFORMATION);
            if (tr == null) {
                throw new RuntimeException("Definition of " + type
                        + " not found in the VDC");
            }
            if (pdv != null) {
                dv = pdv;
            }
            else {
                dv = new Derivation(fqn.getNamespace(), String.valueOf(Math
                        .random()), fqn.getVersion(), fqn.getNamespace(), fqn
                        .getName(), fqn.getVersion(), fqn.getVersion());
            }
            arguments = new HashMap();
            List args = tr.getDeclareList();
            Iterator i = args.iterator();
            while (i.hasNext()) {
                Declare arg = (Declare) i.next();
                arguments.put(arg.getName(), arg);
                if (pdv == null) {
                    if (arg.getLink() == LFN.NONE) {
                        dv.setPass(new Pass(arg.getName(), new Scalar(new Text(
                                ""))));
                    }
                    else if (arg.getLink() == LFN.INOUT) {
                        dv.addPass(new Pass(arg.getName(), new Scalar(new LFN(
                                arg.getName(), arg.getLink()))));
                    }
                }
            }
        }
        catch (SQLException e) {
            throw new RuntimeException("Failed to load definition: " + type, e);
        }
        finally {
            disconnect();
        }
    }

    private synchronized void connect() {
        if (connected > 0) {
            return;
        }
        String schemaName;
        Connect connect;
        try {
            schemaName = ChimeraProperties.instance().getVDCSchemaName();
            connect = new Connect();
            this.dbschema = connect.connectDatabase(schemaName);
        }
        catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Database connection error.", e);
        }
        this.vdc = (VDC) this.dbschema;
        connected++;
    }

    private synchronized void disconnect() {
        if (connected == 0) {
            return;
        }
        try {
            if (dbschema != null)
                dbschema.close();
            if (vdc != null)
                ((DatabaseSchema) vdc).close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            connected--;
        }
    }

    public Object getParameter(String name) {
        Declare arg = (Declare) arguments.get(name);
        if (arg == null) {
            throw new IllegalArgumentException(type + " has no " + name
                    + " argument");
        }
        else {
            Pass p = dv.getPass(name);
            if (p == null) {
                return null;
            }
            Value v = p.getValue();
            if (v == null) {
                return null;
            }
            try {
                if (v.getContainerType() == Value.LIST) {
                    return super.getDVValues(name);
                }
                else {
                    return super.getDVValue(name);
                }
            }
            catch (ElabException e) {
                throw new RuntimeException(e);
            }
        }
    }
    
    public Collection getParameterValues(String name) {
        return AbstractAnalysis.getParameterValues(this, name);
    }

    public void setParameterDefault(String name, Object value) {
        setParameter(name, value);
        defaults.put(name, value);
    }

    public boolean isDefaultValue(String name, Object value) {
        if (equals(value, defaults.get(name))) {
            return true;
        }
        Declare arg = (Declare) arguments.get(name);
        if ("".equals(value) && arg.getLink() == LFN.NONE) {
            return true;
        }
        else if (name.equals(value) && arg.getLink() == LFN.INOUT) {
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

    public boolean isParameterValid(String name) {
        return getParameter(name) != null;
    }

    public void setParameter(String name, Object value) {
        try {
            if (value instanceof List) {
                super.addToDV(name, (List) value);
            }
            else {
                if (value == null) {
                    super.addToDV(name, "");
                }
                else {
                    super.addToDV(name, value.toString());
                }
            }
        }
        catch (ElabException e) {
            throw new RuntimeException("Invalid parameter name: " + name, e);
        }
    }

    public boolean isValid() {
        Iterator i = arguments.keySet().iterator();
        while (i.hasNext()) {
            String name = (String) i.next();
            if (!isParameterValid(name)) {
                return false;
            }
        }
        return true;
    }

    public Collection getInvalidParameters() {
        List l = new ArrayList();
        Iterator i = arguments.keySet().iterator();
        while (i.hasNext()) {
            String name = (String) i.next();
            if (!isParameterValid(name)) {
                l.add(name);
            }
        }
        return l;
    }

    public Class getParameterType(String name) {
        Declare arg = (Declare) arguments.get(name);
        if (arg.getContainerType() == Value.SCALAR) {
            return String.class;
        }
        else if (arg.getContainerType() == Value.LIST) {
            return List.class;
        }
        else {
            return Object.class;
        }
    }

    public boolean hasParameter(String name) {
        return arguments.keySet().contains(name);
    }

    public String getEncodedParameters() {
        return AnalysisTools.encodeParameters(this);
    }

    public Collection getParameterNames() {
        return arguments.keySet();
    }

    public Map getParameters() {
        return new AbstractMap() {
            public Set entrySet() {
                return new AbstractSet() {
                    public Iterator iterator() {
                        final Iterator i = arguments.keySet().iterator();
                        return new Iterator() {
                            public boolean hasNext() {
                                return i.hasNext();
                            }

                            public Object next() {
                                final String name = (String) i.next();
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
                                throw new UnsupportedOperationException();
                            }
                        };
                    }

                    public int size() {
                        return arguments.size();
                    }
                };
            }
        };
    }

    public Map getTRArguments() {
        return arguments;
    }

    public AnalysisParameterTransformer getParameterTransformer() {
        return parameterTransformer;
    }

    public void setParameterTransformer(
            AnalysisParameterTransformer parameterTransformer) {
        this.parameterTransformer = parameterTransformer;
    }
    
    
    public void setAttributes(Map attributes) {
        this.attributes = attributes;
    }
    
    public void setAttribute(String name, Object value) {
        if (attributes == null) {
            attributes = new HashMap();
        }
        attributes.put(name, value);
    }
    
    public Object getAttribute(String name) {
        if (attributes == null) {
            return null;
        }
        else {
            return attributes.get(name);
        }
    }
    
    public Map getAttributes() {
        return attributes;
    }

    public Elab getElab() {
        return elab;
    }

    public void setElab(Elab elab) {
        this.elab = elab;
    }

    public ElabGroup getUser() {
        return user;
    }

    public void setUser(ElabGroup user) {
        this.user = user;
    }
}
