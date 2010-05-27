/*
 * Created on May 25, 2010
 */
package gov.fnal.elab.cms.dataset;

import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

public class Trigger {
    private String name, id, description, level, group, displayName;

    public Trigger(NamedNodeMap attrs) {
        this.name = getAttr(attrs, "name");
        this.displayName = getAttr(attrs, "displayname");
        this.id = getAttr(attrs, "id");
        this.description = getAttr(attrs, "description");
        this.level = getAttr(attrs, "level");
        this.group = getAttr(attrs, "group");
    }
    
    private String getAttr(NamedNodeMap attrs, String name) {
        Node n = attrs.getNamedItem(name);
        if (n == null) {
            return null;
        }
        else {
            return n.getNodeValue();
        }
    }

    public String getName() {
        return name;
    }

    public String getId() {
        return id;
    }

    public String getDescription() {
        return description;
    }

    public String getLevel() {
        return level;
    }

    public String getGroup() {
        return group;
    }

    public String getDisplayName() {
        return displayName;
    }
}
