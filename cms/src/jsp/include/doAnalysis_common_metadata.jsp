<%        
//common metadata:
String m_tr = "transformation string " + tr;    //variable setup in doAnalysis.jsp

Date now = new Date();
long millisecondsSince1970 = now.getTime();
java.sql.Timestamp timestamp = new java.sql.Timestamp(millisecondsSince1970);
String m_creationdate = "creationdate date " + timestamp.toString();

String m_source="source string ";

String m_detectorIDs="string detector ";

String m_rawdate="";

String[] rawData = request.getParameterValues("thresholdAll");
for (int k=0; k<rawData.length; k++) {
    String currFile = rawData[k];
    m_source +=  currFile + " ";    //source of this plot: space delimited list of lfns

    //get metadata from raw datafile to save in the plot
    java.util.List rawMeta = getMeta(out, currFile);
    HashMap metaMap = new HashMap();
    for(Iterator metai=rawMeta.iterator(); metai.hasNext(); ){
        Tuple t = (Tuple)metai.next();
        metaMap.put(t.getKey(), t.getValue());
    }

    timestamp = java.sql.Timestamp.valueOf(metaMap.get("startdate") + "");
    m_rawdate = "rawdate date " + timestamp.toString();    //this variable is overwritten, so it'll arbitrarily be the last raw data startdate...
    m_detectorIDs += metaMap.get("detectorID") + " ";   //do we need to save this? it can be retrieved from the metadata from lfns in m_source...
}
m_source = m_source.substring(0, m_source.length()-1);  //delete last space
m_detectorIDs = m_detectorIDs.substring(0, m_detectorIDs.length()-1);  //delete last space
%>
<input type="hidden" name="metadata" value="<%=m_creationdate%>" >
<input type="hidden" name="metadata" value="<%=m_source%>" >
<input type="hidden" name="metadata" value="<%=m_detectorIDs%>" >
<input type="hidden" name="metadata" value="<%=m_rawdate%>" >
<input type="hidden" name="metadata" value="<%=m_tr%>" >

