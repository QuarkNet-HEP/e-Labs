/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.data.engine;

public abstract class AbstractDataSet implements DataSet {

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("data(\n");
        sb.append("\tlabel: ");sb.append(getLabel());sb.append("\n");
        sb.append("\txlabel: ");sb.append(getXLabel());sb.append("\n");
        sb.append("\tylabel: ");sb.append(getYLabel());sb.append("\n");
        sb.append("\txunit: ");sb.append(getXUnit());sb.append("\n");
        sb.append("\tyunit: ");sb.append(getYUnit());sb.append("\n");
        sb.append("\txrange: ");sb.append(getXRange());sb.append("\n");
        sb.append("\tyrange: ");sb.append(getYRange());sb.append("\n");
        sb.append("\tsize: ");sb.append(size());sb.append("\n");
        sb.append("\tdata: [");
        for (int i = 0; i < size(); i++) {
            sb.append("(");
            sb.append(String.valueOf(getX(i)));
            sb.append(", ");
            sb.append(String.valueOf(getY(i)));
            sb.append(")");
            if (i < size() - 1) {
                sb.append(", ");
            }
        }
        sb.append("\n");
        sb.append(")");
        return sb.toString();
    }
}
