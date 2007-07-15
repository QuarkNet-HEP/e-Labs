<%@ tag body-content="tagdependent" description="Generates a link that will open in a popup window." %>
<%@ attribute name="href" required="true" description="The document to open in a popup." %>
<%@ attribute name="target" required="true" description="The name of the target popup window." %>
<%@ attribute name="width" required="true" description="The width of the popup window, in pixels." %>
<%@ attribute name="height" required="true" description="The height of the pupup window, in pixels." %>

<a href="#" title="Popup: ${href}" onclick="javascript:window.open('${href}', '${target}', 'width=${width}, height=${height}');">
	<jsp:doBody/>
</a>
