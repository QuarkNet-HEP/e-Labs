/*
 * Created on May 7, 2010
 */
package gov.fnal.elab.cms.triggerexpr;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/*
 * expr := term moreterms
 * moreterms := "or" term moreterms | e
 * term := ["not"] factor morefactors
 * morefactors := "and" factor morefactors | e
 * factor := trigger | "(" expr ")"  
 */
public class Parser {
    private Set<String> validTriggers;

    public Parser(Set<String> validTriggers) {
        this.validTriggers = validTriggers;
    }

    public Node parse(String expr) throws ParsingException {
        Tokenizer tokens = new Tokenizer(expr);
        return expr(tokens);
    }

    private Node expr(Tokenizer tokens) throws ParsingException {
        return moreterms(term(tokens), tokens);
    }

    private Node moreterms(Node left, Tokenizer tokens) throws ParsingException {
        if (tokens.hasNext() && tokens.peek().equals("or")) {
            tokens.next();
            Node n = new Node(Node.OR);
            n.addChild(left);
            n.addChild(term(tokens));
            return moreterms(n, tokens);
        }
        else {
            return left;
        }
    }

    private Node morefactors(Node left, Tokenizer tokens) throws ParsingException {
        if (tokens.hasNext() && tokens.peek().equals("and")) {
            tokens.next();
            Node n = new Node(Node.AND);
            n.addChild(left);
            n.addChild(term(tokens));
            return moreterms(n, tokens);
        }
        else {
            return left;
        }
    }

    private Node term(Tokenizer tokens) throws ParsingException {
        if (tokens.peek().equals("not")) {
            tokens.next();
            Node n = new Node(Node.NOT);
            n.addChild(factor(tokens));
            return morefactors(n, tokens);
        }
        else {
            Node n = factor(tokens);
            return morefactors(n, tokens);
        }
    }

    private Node factor(Tokenizer tokens) throws ParsingException {
        String t = tokens.next();
        if (t.equals("(")) {
            Node n = expr(tokens);
            tokens.expect(")");
            return n;
        }
        else {
            return trigger(t);
        }
    }

    private Node trigger(String t) throws ParsingException {
        if (!validTriggers.contains(t)) {
            throw new ParsingException("Invalid trigger: " + t);
        }
        return new Node(Node.TRIGGER, t);
    }

    public static void main(String[] args) {
        try {
            System.out.println(new Parser(new HashSet<String>(Arrays.asList("a", "b", "c",
                    "d"))).parse("b and (c or d) and a"));
        }
        catch (ParsingException e) {
            e.printStackTrace();
        }
    }
}
