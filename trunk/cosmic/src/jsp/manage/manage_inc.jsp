<%!
public String headerString(String s){
    String ss = "<font size=+1>" + s + "</font>";
    return ss;
}
%>

<%!
/**
 * Format a Set of Strings as a html gray list
 */
public String formatGraySet(java.util.Set set){
    String ss = "<font color=grey>";
    for(Iterator i=set.iterator(); i.hasNext(); ){
        ss += (String)i.next() + " - ";
    }
    ss = ss.substring(0, ss.length()-3);    //remove last " - "
    ss += "</font>";
    return ss;
}
%>
