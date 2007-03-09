<P>
<TABLE BORDER=1 WIDTH=550 CELLPADDING=20 bgcolor="#F6F6FF">
    <td colspan ="1" valign="top" width="65%"> 
        Enter the analysis parameters and click Analyze to create a shower plot.
        <P>
        <center>
        <table width="100%" align="center">
            <tr>
                <td align="left"> 
                    <div id="controlap0" style="visibility:hidden; display:none">
                        <a href="javascript:void(0);" onclick="HideShow('analyzeParam0');HideShow('controlap0');HideShow('controlap1')">
                            <img src="graphics/Tright.gif" alt="" border="0"></a>
                        <strong>Analysis Controls</strong> 
                    </div>
                    <div id="controlap1" style="visibility:visible; display:">
                        <a href="javascript:void(0);" onclick="HideShow('analyzeParam0');HideShow('controlap1');HideShow('controlap0')">
                            <img src="graphics/Tdown.gif" alt="" border="0"></a>
                            <strong>Analysis Controls</strong> 
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                <div id='analyzeParam0' style="visibility:visible;display:">
                <table width="100%" align="center">
                <tr>
                <td width="40%" align="right"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','zeroZeroZeroID','Detector of 0-0-0 point')"><IMG SRC="graphics/question.gif" border="0"></A>
Detector of 0-0-0 point:</td>
                <td width="40%" align="left">
                <select name="zeroZeroZeroID" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nCoincidence: ' + coincidence.value + '\nEvent Gate: ' + gate.value + '\nDetector of 0-0-0 point: ' + zeroZeroZeroID.value}">
                        <%
                        for(Iterator i=detectorIDs.iterator(); i.hasNext(); ){
                        String detector = (String)i.next();
                        %>
                        <option value=<%=detector%>><%=detector%></option>
                        <%
                        }
                        %>
                </select></td>
            </tr>
            <tr>
                <td align="right"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','gate','Event Gate')"><IMG SRC="graphics/question.gif" border="0"></A> Event Gate (ns):</td>
                <td><input type="text" name="gate" value="100" size="8" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nCoincidence: ' + coincidence.value + '\nEvent Gate: ' + gate.value + '\nDetector of 0-0-0 point: ' + zeroZeroZeroID.value}"></td>
            </tr>
            <tr>
               <td align="right"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','coincidence','Coincidence Level')"><IMG SRC="graphics/question.gif" border="0"></A> Coincidence Level:</td>

                <td><input type="text" name="coincidence"  value="2"  size="8" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nCoincidence: ' + coincidence.value + '\nEvent Gate: ' + gate.value + '\nDetector of 0-0-0 point: ' + zeroZeroZeroID.value}"></td>
            </tr>
            <tr>
                <td align="right">Event Number:</td>
                <td><input type="text" name="eventNum"  value="1"  size="8"></td>
            </tr>
            </table>
            </div>
            </td>
            </tr>
            <tr>
                    <td>
                        <div id="controlpp0" style="visibility:visible; display:">
                            <a href="javascript:void(0);" onclick="HideShow('plotParam0');HideShow('controlpp0');HideShow('controlpp1')">
                                <img src="graphics/Tright.gif" alt="" border="0"></a>
                            <strong>Plot Controls</strong> 
                            <br>
                        </div>
                        <div id="controlpp1" style="visibility:hidden; display:none">
                            <a href="javascript:void(0);" onclick="HideShow('plotParam0');HideShow('controlpp1');HideShow('controlpp0')">
                                <img src="graphics/Tdown.gif" alt="" border="0"></a>
                            <strong>Plot Controls</strong> 
                            <br>
                        </div>
                    </td>
            </tr>
            <tr>
            <td>
            <p>
            <div id='plotParam0' style="visibility:hidden;display:none;">
            <table width="100%" align="center">
            <tr>
            <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','plot_lowX','X-min')"><IMG SRC="graphics/question.gif" border="0"></A> X-min:</td>
            <td><input type="text" name="plot_lowX" value="" size="5" maxlength="10"></td>
        </tr>
        <tr> 
            <td align="right"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','plot_highX','X-max')"><IMG SRC="graphics/question.gif" border="0"></A> X-max:</td>
            <td><input type="text" name="plot_highX"  value=""  size="5" maxlength="10"></td>
        </tr>
        <tr> 
            <td align="right"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','plot_lowY','Y-min')"><IMG SRC="graphics/question.gif" border="0"></A> Y-min:</td>
            <td><input type="text" name="plot_lowY"  value=""  size="5" maxlength="10"> </td>
        </tr>
        <tr> 
            <td align="right"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','plot_highY','Y-max')"><IMG SRC="graphics/question.gif" border="0"></A> Y-max:</td>
            <td><input type="text" name="plot_highY"  value=""  size="5" maxlength="10"> </td>
        </tr>
        <tr> 
            <td align="right"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','plot_lowZ','Z-min')"><IMG SRC="graphics/question.gif" border="0"></A> Z-min:</td>
            <td><input type="text" name="plot_lowZ"  value=""  size="5" maxlength="10"></td>
        </tr>
        <tr> 
            <td align="right"><a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','plot_highZ','Z-max')"><IMG SRC="graphics/question.gif" border="0"></A> Z-max:</td>
            <td><input type="text" name="plot_highZ"  value=""  size="5" maxlength="10"></td>
        </tr>
        <tr>
            <td align="right" width="40%">
                    Plot Size: 
            </td>
            <td>
                    <select name="plot_size">
                        <option value="300">Small</option>
                        <option value="600" selected>Medium</option>
                        <option value="800">Large</option>
                    </select>
            </td>
        </tr>
        <tr> 
            <td align="right">Plot Title:</td>
            <td><input type="text" name="plot_title" value="Shower Study" size="40" maxlength="120"> </td>
        </tr>
        <tr>
            <td align="right">Figure caption:</td>
            <td>
                <textarea name="plot_caption" rows="5" cols="30"><%=rawDataString%>
<%=detectorIDString%>
Coincidence: 2
Event Gate: 100
Detector of 0-0-0 point: <%=(String)detectorIDs.iterator().next()%></textarea>
        </tr>
        </table>
        </div>
        </td>
        </tr>
        </center>
    </table>
    <INPUT type="hidden" name="key1" value="2">
    <INPUT type="hidden" name="key2" value="3">
    <INPUT type="hidden" name="geoDir" value="<%=dataDir%>">
    <INPUT type="hidden" name="plot_extraFunctions" value="">
    <INPUT type="hidden" name="plot_plot_type" value="2">
    <INPUT type="hidden" name="plot_xlabel" value="East/West (meters)">
    <INPUT type="hidden" name="plot_ylabel" value="North/South (meters)">
    <INPUT type="hidden" name="plot_zlabel" value="Time (nanosec)">
    <INPUT type="hidden" name="html_title" value="Graph of the muon shower">
    <div align="center">
        <input name="Analyze" type="submit" value="Analyze">
    </div>
    </TD></TR>
</TABLE>
