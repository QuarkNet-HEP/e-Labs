<P>
<TABLE BORDER=1 WIDTH=550 CELLPADDING=20 bgcolor="#F6F6FF">
    <tr>
        <td colspan="1" valign="top" width="65%">
            Click 
            <b>
                Analyze 
            </b>
            to use the default parameters. 
            Control the analysis by expanding the options below.</i> 
        <p>
        <p>
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
                                    <td align="right" width="40% valign="bottom"><a href="javascript: describe('Quarknet.Cosmic::SingleChannel','channel','Channel Number')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Channel Number:
                                    </td>
                                    <td>
                                        <select name="singlechannel_channel" onChange="plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nChannel: ' + singlechannel_channel.value;">
                                            <% if(validChans[0]){%><option value="1">1</option> <%}%>
                                            <% if(validChans[1]){%><option value="2">2</option> <%}%>
                                            <% if(validChans[2]){%><option value="3">3</option> <%}%>
                                            <% if(validChans[3]){%><option value="4">4</option> <%}%>
                                        </select> 
                                    </td>
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
                                        <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::FluxStudyNoThresh','flux_binWidth','Bin Width')"><IMG SRC="graphics/question.gif" border="0"></A>
                                                Bin Width (seconds):
                                        </td>
                                        <td>
                                            <!--
                                            Changed this line in order to fix the plot label
<input type="text" name="flux_binWidth" value="60" size="8" onChange="{plot_ylabel.value='Flux (events/m^2/' + flux_binWidth.value + ') seconds';}" >
                                        	<input type="text" name="flux_binWidth" value="60" size="8" onChange="{plot_ylabel.value='Flux (counts/m^2/second)';}" >
                                        	-->
                                        	<input type="text" name="flux_binWidth" value="60" size="8">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowX','X-min')"><IMG SRC="graphics/question.gif" border="0"></A>
                                                X-min: 
                                        </td>
                                        <td>
                                            <input type="text" name="plot_lowX" value="" size="19" maxlength="19"><font size=-1>e.g. 10/28/2004 3:00
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highX','X-max')"><IMG SRC="graphics/question.gif" border="0"></A>
                                                X-max: 
                                        </td>
                                        <td>
                                            <input type="text" name="plot_highX" value="" size="19" maxlength="19"><font size=-1>e.g. 10/29/2004 18:00
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowY','Y-min')"><IMG SRC="graphics/question.gif" border="0"></A>
                                                Y-min: 
                                        </td>
                                        <td>
                                            <input type="text" name="plot_lowY" value="" size="8" maxlength="8">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highY','Y-max')"><IMG SRC="graphics/question.gif" border="0"></A>
                                                Y-max: 
                                        </td>
                                        <td>
                                            <input type="text" name="plot_highY" value="" size="8" maxlength="8">
                                        </td>
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
                                        <td align="right">
                                            
                                                Plot Title: 
                                            
                                        </td>
                                        <td>
                                            <input type="text" name="plot_title" value="Flux Study" size="40" maxlength="100">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right">
                                            
                                                Figure caption: 
                                            
                                        </td>
                                        <td>
<%                                 int chan=0 ;
                                                      if (validChans[3] ){chan=4;}
                                                      if (validChans[2] ){chan=3;}
                                                      if (validChans[1] ){chan=2;}
                                                      if (validChans[0] ){chan=1;}
 %>
<textarea name="plot_caption" rows="5" cols="30"><%=rawDataString%>
<%=detectorIDString%>
Channel: <%=chan%></textarea>
                                        </td>
                                    </tr>
                                </table>
                        </div>
                    </td>
                </tr>
            </table>
            <input type="hidden" name="sort_sortKey1" value="2">
            <input type="hidden" name="sort_sortKey2" value="3">
            <input type="hidden" name="freq_binType" value="1">
            <input type="hidden" name="freq_col" value="3">
            <input type="hidden" name="flux_geoDir" value="<%=dataDir%>">
            <input type="hidden" name="plot_extraFunctions" value="">
            <input type="hidden" name="plot_plot_type" value="1">
            <input type="hidden" name="plot_xlabel" value="Time (hours)">
            <input type="hidden" name="plot_ylabel" value="Flux (counts/m^2/second)">
            <input type="hidden" name="plot_highZ" value="">
            <input type="hidden" name="plot_lowZ" value="">
            <input type="hidden" name="plot_zlabel" value="">
            <input type="hidden" name="html_title" value="Flux">

            <div align="center">
                <input name="Analyze" type="submit" value="Analyze">
            </div>
        </td>
    </tr>
</table>
