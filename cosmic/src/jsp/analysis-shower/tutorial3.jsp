<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Shower study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower-tutorial-3" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

		<center>	
<h1>Shower Study</h1>
				
				<table width="650" cellpadding="8">
				<tr width="341">
		 			<td valign="top">
            <table cellspacing="0" cellpadding="2" border="0">
                <tr>
                    <td align="center" width="180">
                        Event Date
                    </td>
                    <td align="center" width="61">
                        Event Coincidence
                    </td>
                    <td align="center" width="80">
                        Detector Coincidence
                    </td>
                </tr>
<tr bgcolor="#aaaafc">

                    <td align="center" >
                       Oct 19, 2004 12:07:06 AM CDT
                    </td>
                    <td align="center">
                        12
                    </td>
                    <td align="center">
                        3 (119 150 141)
                    </td>
                </tr>
<tr bgcolor="#e7eefc">

                    <td align="center">
                       Oct 19, 2004 4:32:53 PM CDT
                    </td>
                    <td align="center">
                        10
                    </td>
                    <td align="center">
                        3 (119 150 141)
                    </td>
                </tr>
<tr>

                    <td align="center">
                    	Oct 20, 2004 10:36:36 PM CDT
                    </td>
                    
                    <td align="center">
                        10
                    </td>
                    <td align="center">
                        3 (119 150 141)
                    </td>
                </tr>
<tr bgcolor="#e7eefc">

                    <td align="center">
                  	  Oct 21, 2004 10:23:49 AM CDT
                    </td>
                    
                    <td align="center">
                        12
                    </td>
                    <td align="center">
                        3 (119 150 141)
                    </td>
                </tr>

                </table>
               </td>
               
               <td valign="top" width="301">
               	We entered parameters for the event and got back the table on the left. 
               	These "candidates" satisfy our requirements for an event. What do you 
               	think we entered for the event coincidence level? What about 
               	<a href="javascript:glossary('detector',350)"> detector</a> coincidence?<p>

				The analysis software can only find 
				<a href="javascript:glossary('pulse',350)">pulses</a> that match your parameter 
				settings. You have to decide which of the candidates is an event-if any!<p>

				What will you do to make this decision? What does an event look like? 
				How will you know when you are right?
               	</td>
               </tr>
          		
          		<tr>
					
					<td>
						&nbsp
					</td>
					
					<td colspan = "2" align="right">
					    Want to <a href="tutorial4.jsp">know more?</a>
					</td>
					
				</tr>
               </table>
               
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>


