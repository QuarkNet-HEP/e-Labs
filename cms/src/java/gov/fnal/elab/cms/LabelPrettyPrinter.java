/*
 * Created on May 14, 2010
 */
package gov.fnal.elab.cms;

public class LabelPrettyPrinter {
    
    /**
     * Applies some limited LaTeX like subscript and
     * superscript annotation and produces html from it.
     */
    public static String formatLabel(String label) {
        StringBuilder sb = new StringBuilder();
        boolean scanning = false;
        String close = null;
        for (int i = 0; i < label.length(); i++) {
            char c = label.charAt(i);
            switch (c) {
                case '_':
                    sb.append("<sub>");
                    close = "</sub>";
                    scanning = true;
                    break;
                case '^':
                    sb.append("<sup>");
                    close = "</sup>";
                    scanning = true;
                    break;
                case ' ':
                    if (scanning) {
                        sb.append(close);
                        scanning = false;
                    }
                    else {
                        sb.append(c);
                    }
                    break;
                case '\\':
                    sb.append('&');
                    close = ";";
                    scanning = true;
                    break;
                default:
                    sb.append(c);
            }
        }
        if (scanning) {
            sb.append(close);
        }
        return sb.toString();
    }
}
