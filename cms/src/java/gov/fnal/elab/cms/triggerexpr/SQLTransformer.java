/*
 * Created on May 7, 2010
 */
package gov.fnal.elab.cms.triggerexpr;

import java.util.Arrays;
import java.util.HashSet;

public class SQLTransformer {
    public SQLTransformer() {
        
    }
    
    public String transform(Node expr) {
        StringBuilder sb = new StringBuilder();
        transform(sb, expr);
        return sb.toString();
    }

    private void transform(StringBuilder sb, Node n) {
        switch (n.type) {
            case Node.TRIGGER:
                sb.append(n.value);
                sb.append("=1");
                break;
            case Node.NOT:
                sb.append("NOT ");
                transform(sb, n.children.get(0));
                break;
            default:
                sb.append('(');
                transform(sb, n.children.get(0));
                sb.append(' ');
                sb.append(n.strType());
                sb.append(' ');
                transform(sb, n.children.get(1));
                sb.append(')');
        }
    }
    
    public static void main(String[] args) {
        try {
            System.out.println(new SQLTransformer().transform(new Parser(new HashSet<String>(Arrays.asList("a", "b", "c",
                        "d"))).parse("b and (c or d) and not a")));
        }
        catch (ParsingException e) {
            e.printStackTrace();
        }
    }
}
