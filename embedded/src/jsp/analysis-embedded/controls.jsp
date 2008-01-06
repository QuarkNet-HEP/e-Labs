<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="java.util.*" %>

<div id="analysis-controls">
	<form method="post" action="../analysis-embedded/analysis.jsp">
		<e:trinput type="hidden" name="continuation"/>
		<e:trinput type="hidden" name="onError"/>
		
		<p>
			Text: <e:trinput name="text"/>
		</p>
		<p>
			<e:trsubmit/>
		</p>
	</form>
</div>