/*
 * Created on May 25, 2010
 */
package gov.fnal.elab.cms.dataset;

import gov.fnal.elab.cms.LabelPrettyPrinter;

import org.w3c.dom.Node;

public class Leaf {
    private String id, title, labelx, labely, units, description;

    public Leaf(String id, Node n) {
        this.id = id;
        this.title = getAttr(n, "title");
        this.labelx = getAttr(n, "labelx");
        this.labely = getAttr(n, "labely");
        this.units = getAttr(n, "units");
        this.description = getAttr(n, "description");
    }

    private String getAttr(Node n, String name) {
        return LabelPrettyPrinter.formatLabel(n.getAttributes()
                .getNamedItem(name).getNodeValue());
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getLabelx() {
        return labelx;
    }

    public String getLabely() {
        return labely;
    }

    public String getUnits() {
        return units;
    }

    public String getDescription() {
        return description;
    }
}
