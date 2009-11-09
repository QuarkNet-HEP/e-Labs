/*
 * Created on Aug 5, 2008
 */
package gov.fnal.elab.cms;

import gov.fnal.elab.analysis.AnalysisParameterTransformer;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class OGREParameterTransformer implements AnalysisParameterTransformer {

    private static final Set SKIP;

    static {
        SKIP = new HashSet();
        SKIP.add("color");
        SKIP.add("cut");
        SKIP.add("colorf");
        SKIP.add("cutf");
        SKIP.add("cuttype");
        SKIP.add("leaf");
        SKIP.add("formula");
        SKIP.add("logx");
        SKIP.add("logy");
        SKIP.add("logz");
        SKIP.add("allonone");
    }

    public Map transform(Map params) {
        Map n = new HashMap();
        int leaf = bitmask(params.get("leaf"));
        int formula = bitmask(params.get("formula"));
        n.put("leaf", Integer.valueOf(leaf));
        n.put("formula", Integer.valueOf(formula));
        n.put("color", join(leaf, params.get("color")));
        List cuts = new ArrayList();
        cuts.addAll(trcuts(leaf, params.get("root_leaf"),
                params.get("cuttype"), params.get("cut")));
        cuts.addAll(trcuts(formula, params.get("cutf")));
        n.put("cut", join(cuts));
        n.put("colorf", join(formula, params.get("colorf")));
        flag("logx", "-x", n, params);
        flag("logy", "-y", n, params);
        flag("logz", "-z", n, params);
        flag("allonone", "-a", n, params);
        Iterator i = params.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            if (!SKIP.contains(e.getKey())) {
                n.put(e.getKey(), e.getValue());
            }
        }
        return n;
    }
    
    private void flag(String name, String subst, Map n, Map o) {
        Object value = o.get(name);
        if (value != null && !value.equals("")) {
            n.put(name, subst);
        }
    }

    private List trcuts(int bitmask, Object root, Object types, Object values) {
        List r = listify(root);
        List t = listify(types);
        List v = listify(values);
        List l = new ArrayList();
        if (t.size() != v.size()) {
            throw new IllegalArgumentException("Lists have different sizes: "
                    + types + ", " + values);
        }
        for (int i = 0; i < t.size(); i++) {
            if ((bitmask & (1 << i)) != 0) {
                Object crt = t.get(i);
                if ("0".equals(crt)) {
                    l.add("1");
                }
                else if ("1".equals(crt)) {
                    l.add(r.get(i) + "<" + v.get(i));
                }
                else {
                    l.add(r.get(i) + ">" + v.get(i));
                }
            }
        }
        return l;
    }

    private List trcuts(int bitmask, Object values) {
        List v = new ArrayList(listify(values));
        List l = new ArrayList();
        for (int i = 0; i < v.size(); i++) {
            Object crt = v.get(i);
            if ((bitmask & (1 << i)) != 0) {
                if (crt == null || crt.equals("")) {
                    l.add("1");
                }
                else {
                    l.add(v.get(i));
                }
            }
        }
        return v;
    }

    public int bitmask(Object value) {
        List l = listify(value);
        int x = 0;
        Iterator i = l.iterator();
        while (i.hasNext()) {
            Object v = i.next();
            if (v != null && !"".equals(v)) {
                x += (1 << (Integer.parseInt((String) v) - 1));
            }
        }
        return x;
    }

    public String join(int bitmask, Object value) {
        List l = listify(value);
        StringBuffer sb = new StringBuffer();
        Iterator i = l.iterator();
        boolean first = true;
        int cursor = 1;
        while (i.hasNext()) {
            Object v = i.next();
            if ((bitmask & cursor) != 0) {
                if (first) {
                    first = false;
                }
                else {
                    sb.append(",");
                }
                sb.append(v);
            }
            cursor <<= 1;
        }
        return sb.toString();
    }

    public String join(Object value) {
        List l = listify(value);
        StringBuffer sb = new StringBuffer();
        Iterator i = l.iterator();
        boolean first = true;
        while (i.hasNext()) {
            Object v = i.next();
            if (first) {
                first = false;
            }
            else {
                sb.append(",");
            }
            sb.append(v);
        }
        return sb.toString();
    }

    private List listify(Object value) {
        if (value instanceof List) {
            return (List) value;
        }
        else if (value == null || "".equals(value)) {
            return Collections.EMPTY_LIST;
        }
        else {
            return Collections.singletonList(value);
        }
    }
}
