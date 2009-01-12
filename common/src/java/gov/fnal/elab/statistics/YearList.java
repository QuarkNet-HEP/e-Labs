/*
 * Created on Jan 11, 2009
 */
package gov.fnal.elab.statistics;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class YearList {

    public List getItems() {
        List l = new ArrayList();
        for (int i = 2004; i <= Calendar.getInstance().get(Calendar.YEAR); i++) {
            l.add(new Item("start=01/01/" + i + "&end=01/01/" + (i + 1), String.valueOf(i)));
        }
        return l;
    }
    
    public String toString() {
        return getItems().toString();
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
        
        public String toString() {
            return value;
        }
    }
}
