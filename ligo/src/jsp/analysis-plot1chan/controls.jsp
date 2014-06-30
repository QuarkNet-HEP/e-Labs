<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="java.util.*" %>

<div id="analysis-controls">
	<form method="post" action="../analysis-plot1chan/analysis.jsp">
		<e:trinput type="hidden" name="continuation"/>
		<e:trinput type="hidden" name="onError"/>
		<input type="hidden" name="provider" value="swift" />
		<input type="hidden" name="runMode" value="grid" />
		
		<p>
			GPS Start Time: <e:trinput name="GPS_start_time" default="877543100" />
		</p>
		<p>
			GPS End Time: <e:trinput name="GPS_end_time" default="877543210" />
		</p>
		<p>
			Channel name: <e:trinput name="channelName" default="H0:DMT-BRMS_PEM_LVEA_SEISZ_0.1_0.3Hz.mean" />
		</p>
		<p>
			Time format: <e:trinput name="timeFormat" default="GMT" />
		</p>
		
		<p>
			<e:trsubmit/>
		</p>
	</form>
</div>