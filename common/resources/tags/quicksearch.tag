<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ tag body-content="scriptless" description="Generates a quick metadata search link of the form <code>&lt;key&gt;=&lt;value&gt;." %>
<%@ attribute name="key" required="true" description="The metadata key to be used for the search." %>
<%@ attribute name="value" required="true" description="The value to be searched." %>
<%@ attribute name="label" required="false" description="The label for the anchor." %>
<%@ attribute name="suffix" required="false" description="Suffix to add to the URL" %>

<a href="?submit=true&key=${key}&value=${value}${suffix}">${(empty label)?value:label}</a>
	

