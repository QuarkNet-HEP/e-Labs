/*
 * Created on May 7, 2010
 */
package gov.fnal.elab.cms.triggerexpr;


public class Tokenizer {
    private String expr;
    private int crt, last = -1;
    private String token;
    private int level;

    public Tokenizer(String expr) {
        this.expr = expr;
    }

    private void scan() {
        while (token == null && crt <= expr.length()) {
            char c;
            if (crt == expr.length()) {
                c = ' ';
            }
            else {
                c = expr.charAt(crt);
            }
            int l;
            switch (c) {
                case '(':
                case ')':
                    l = 1;
                    break;
                case ' ':
                case '\t':
                    l = 0;
                    break;
                default:
                    l = 2;
            }
            crt++;
            if (l != level) {
                if (level != 0) {
                    token = expr.substring(last - 1, crt - 1);
                }
                level = l;
                last = crt;
            }
        }
    }

    public boolean hasNext() {
        scan();
        return token != null;
    }

    public String next() throws ParsingException {
        if (token == null && !hasNext()) {
            throw new ParsingException("Unexpected end of expression");
        }
        String r = token;
        token = null;
        return r;
    }
    
    public void expect(String e) throws ParsingException {
        String tok = next();
        if (!tok.equals(e)) {
            throw new ParsingException("Expected '" + e + "'. Got '" + tok + "'");
        }
    }
    
    public String peek() throws ParsingException {
        if (token == null && !hasNext()) {
            throw new ParsingException("Unexpected end of expression");
        }
        return token;
    }
}
