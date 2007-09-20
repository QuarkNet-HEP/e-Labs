<%@ tag body-content="tagdependent" description="Opens a reference entry in a popup window." %>
<%@ attribute name="name" required="true" description="The name of the reference." %>
<%@ attribute name="width" required="false" description="The width of the popup window, in pixels." %>
<%@ attribute name="height" required="false" description="The height of the pupup window, in pixels." %>


<a href="#" title="Reference: ${ref}" onclick="javascript:window.open('../references/display.jsp?type=reference&name=${name}', 'reference', 'width=${width != null ? width : 300}, height=${height != null ? height : 250}, scrollbars=false, toolbar=false, menubar=fale, status=false, resizable=true, title=true');">
	<img src="../graphics/ref.gif" />
</a>
