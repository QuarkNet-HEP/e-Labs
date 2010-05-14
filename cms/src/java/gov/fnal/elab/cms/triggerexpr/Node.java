/*
 * Created on May 7, 2010
 */
package gov.fnal.elab.cms.triggerexpr;

import java.util.LinkedList;
import java.util.List;

public class Node {
    public static final int TRIGGER = 0;
    public static final int NOT = 1;
    public static final int AND = 2;
    public static final int OR = 3;

    int type;
    String value;
    List<Node> children;

    public Node(int type) {
        this.type = type;
    }

    public Node(int type, String value) {
        this.type = type;
        this.value = value;
    }

    public void addChild(Node n) {
        if (children == null) {
            children = new LinkedList<Node>();
        }
        children.add(n);
    }

    public String toString() {
        return strType() + (value == null ? "" : "/" + value)
                + (children == null ? "" : children);
    }

    public String strType() {
        switch (type) {
            case TRIGGER:
                return "TRIGGER";
            case NOT:
                return "NOT";
            case AND:
                return "AND";
            case OR:
                return "OR";
            default:
                return "??";
        }
    }
}