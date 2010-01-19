/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

import gov.fnal.elab.expression.evaluator.Interpreter;

public abstract class Function {
    private Interpreter interpreter;
    
    public Function() {
        
    }
    
    public Function(Interpreter interpreter) {
        this.interpreter = interpreter;
    }
    
    protected Interpreter getInterpreter() {
        return interpreter;
    }

    public abstract Value invoke(Value[] args);

    protected void checkArgs(Value[] args, int[] expectedTypes) {
        if (args.length != expectedTypes.length) {
            throw new TypeException("Argument size mismatch. Expected: " + niceTypes(expectedTypes) + ", actual: "
                    + niceArgs(args));
        }
    }

    private String niceArgs(Value[] args) {
        StringBuffer sb = new StringBuffer();
        sb.append("(");
        for (int i = 0; i < args.length; i++) {
            if (args[i].getType() == Value.DATASET) {
                sb.append("<data>");
            }
            else {
                sb.append(args[i].getValue());
            }
            if (i < args.length - 1) {
                sb.append(", ");
            }
        }
        sb.append(")");
        return sb.toString();
    }

    private String niceTypes(int[] t) {
        StringBuffer sb = new StringBuffer();
        sb.append("(");
        for (int i = 0; i < t.length; i++) {
            sb.append(Value.niceType(t[i]));
            if (i < t.length - 1) {
                sb.append(", ");
            }
        }
        sb.append(")");
        return sb.toString();
    }

}
