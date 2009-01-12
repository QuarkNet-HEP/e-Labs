/*
 * Created on Jan 11, 2009
 */
package gov.fnal.elab.statistics;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class MonthList {
    private String crtyear;
    
    public String getCrtyear() {
        return crtyear;
    }

    public void setCrtyear(String crtyear) {
        this.crtyear = crtyear;
    }

    public List getItems() {
        List l = new ArrayList();
        NumberFormat nf = new DecimalFormat("00");
        int yr;
        if (crtyear == null || crtyear.equals("")) {
            yr = Calendar.getInstance().get(Calendar.YEAR);
        }
        else {
            yr = Integer.parseInt(crtyear);
        }
        for (int i = 1; i < 12; i++) {
            l.add(new Item("start=" + nf.format(i) + "/01/" + yr + "&end="
                    + nf.format(i + 1) + "/01/" + yr, nf.format(i)));
        }
        l.add(new Item("start=12/01/" + yr + "&end=01/01/" + (yr + 1), "12"));
        return l;
    }

    public static class Item {
        private String params;
        private String value;

        public Item(String params, String value) {
            this.params = params;
            this.value = value;
        }

        public String getParams() {
            return params;
        }

        public void setParams(String params) {
            this.params = params;
        }

        public String getValue() {
            return value;
        }

        public void setValue(String value) {
            this.value = value;
        }
    }
}
