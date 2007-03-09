<!-- still in an encompasing <table> in doAnalysis.jsp -->

<tr>
    <td align="center">To save this plot permanently, enter the new name you want.<BR>Then click <b>Save Plot</b>.<br>
        <FORM name="SaveForm" ACTION="save.jsp"  method="post" target="saveWindow" onsubmit='return openPopup("",this.target,500,200);'>
<%
        //Metadata section
        //there seems to be an unwritten rule to use lowercase for metadata...
        //pass any arguments to write as metadata in the "metadata" form variable as tuple strings
%>

<%@ include file="doAnalysis_common_metadata.jsp" %>

<%
        //shower-specific metadata:
        String m_study = "study string shower";
        String m_type = "type string plot";

        String m_coincidence = "coincidence int " + request.getParameter("coincidence");

        String m_gate = "gate int " + request.getParameter("gate");

        //TODO
        //String m_radius = request.getParameter("radius");
        String m_radius = "-1";

        String m_plot_title = request.getParameter("plot_title");
        String m_plot_caption = request.getParameter("plot_caption");
        m_plot_caption = m_plot_caption.replaceAll("\r\n?", "\\\\n");   //replace new lines from text box with "\n"
%>

        <input type="hidden" name="metadata" value="<%=m_type%>" >
        <input type="hidden" name="metadata" value="<%=m_study%>" >

        <input type="hidden" name="metadata" value="<%=m_coincidence%>" >
        <input type="hidden" name="metadata" value="<%=m_gate%>" >
        <input type="hidden" name="metadata" value="<%=m_radius%>" >

        <input type="hidden" name="metadata" value="<%="title string " + m_plot_title%>" >
        <input type="hidden" name="metadata" value="<%="caption string " + m_plot_caption%>" >

        <input type="hidden" name="scratchFile" value="<%=scratchPlot%>" >
        <input type="hidden" name="thumbnail" value="<%=thumbnail%>" >
        <input type="text" name="permanentFile"  size="20" maxlength="30">.png
        <input type="hidden" name="fileType" value="png" >
        <input name="save" type="submit" value="Save Plot">
        </form>
    </td>
</tr>
