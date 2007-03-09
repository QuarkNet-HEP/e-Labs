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
                                    <td align="right" width="40%"><a href="javascript: describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','lifetime_coincidence','Coincidence Level')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Coincidence level: 
                                    </td>
                                    <td>
																<select name="lifetime_coincidence" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nCoincidence: ' + lifetime_coincidence.value;}">
																	<option value="1">
																		1 
																	</option>
																
																	<option value="2">
																		2 
																	</option>
																		
																	<option value="3">
																		3
																	</option>
																	
																	<option value="4">
																		4
																	</option>
																</select>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript: describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','lifetime_energyCheck','Check Energy of Second Pulse')"><IMG SRC="graphics/question.gif" border="0"></A>
                                       Check energy of 2<sup>nd</sup> pulse: 
                                    </td>
                                    <td>
                                        <select name="lifetime_energyCheck">
                                            <option value="1">
                                            yes 
                                            </option>
                                            <option value="0">
                                            no 
                                            </option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript: describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','lifetime_gatewidth','Gate width (seconds)')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            
                                            Gate width (seconds): 
                                        
                                    </td>
                                    <td>
                                        <input type="text" name="lifetime_gatewidth" value="1e-5" size="8">
                       </td></tr>
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
                                        <td align="right" width="40%"><a href="javascript: describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','freq_binValue','Number of Bins')"><IMG SRC="graphics/question.gif" border="0"></A>
                                                Number of Bins: 
                                            
                                        </td>
                                        <td>
                                            <input type="text" name="freq_binValue" value="40" size="8">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowX','X-min')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            
                                                X-min: 
                                            
                                        </td>
                                        <td>
                                            <input type="text" name="plot_lowX" value="" size="8" maxlength="8">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highX','X-max')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            
                                                X-max: 
                                            
                                        </td>
                                        <td>
                                            <input type="text" name="plot_highX" value="" size="8" maxlength="8">
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
                                            <input type="text" name="plot_title" value="Lifetime Study" size="40" maxlength="100">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right">
                                            
                                                Figure caption:
                                            
                                        </td>
                                        <td>
                                        <textarea name="plot_caption" rows="5" cols="30"><%=rawDataString%>
<%=detectorIDString%>
Coincidence: 1</textarea>
                                        </td>
                                    </tr>
                                </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <tr>
                        <td> 
                            <div id="controlfp0" style="visibility:visible; display:">
                                <a href="javascript:void(0);" onclick="HideShow('fitParam0');HideShow('controlfp0');HideShow('controlfp1')">
                                    <img src="graphics/Tright.gif" alt="" border="0"></a>
                               
                                    <strong>Fit Controls</strong>
                             
                                <br>
                            </div>
                            <div id="controlfp1" style="visibility:hidden; display:none">
                                <a href="javascript:void(0);" onclick="HideShow('fitParam0');HideShow('controlfp1');HideShow('controlfp0')">
                                    <img src="graphics/Tdown.gif" alt="" border="0"></a>
                            
                                    <strong>Fit Controls</strong>
                               
                                <br>
                            </div>
                        </td>
                    </tr>
                </tr>
                <tr>
                    <td>
                        <p>
                        <div id='fitParam0' style="visibility:hidden;display:none;">
                            <table width="100%" align="center"> 
                                    <tr>
                                        <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_turnedOn','Fitting Turned On')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Fitting Turned On:
                                        </td>
                                        <td><select name="extraFun_turnedOn">
                                                <option value="1">
                                                yes 
                                                </option>
                                                <option selected value="0">
                                                no 
                                                </option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_minX','X-min of fit')"><IMG SRC="graphics/question.gif" border="0"></A>
                                                X-min of fit: 
                                            
                                        </td>
                                        <td>
                                            <input type="text" name="extraFun_minX" value="0.1" size="8" maxlength="10">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_maxX','X-max of fit')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            
                                                X-max of fit: 
                                            
                                        </td>
                                        <td>
                                            <input type="text" name="extraFun_maxX" value="10" size="8" maxlength="10">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_alpha_variate','Fit Y-intercept')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Fit Y-intercept:
                                            <select name="extraFun_alpha_variate">
                                                <option value="yes">
                                                yes 
                                                </option>
                                                <option value="no">
                                                no 
                                                </option>
                                            </select>
                                        </td>
                                        <td><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_alpha_guess','Alpha')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Alpha: 
                                            <input type="text" name="extraFun_alpha_guess" value="" size="8" maxlength="">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_lifetime_variate','Fit Lifetime')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Fit Lifetime:
                                            <select name="extraFun_lifetime_variate">
                                                <option value="yes">
                                                yes 
                                                </option>
                                                <option value="no">
                                                no 
                                                </option>
                                            </select>
                                        </td>
                                        <td><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_lifetime_guess','Lifetime')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Lifetime: 
                                            <input type="text" name="extraFun_lifetime_guess" value="1" size="8" maxlength="">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right"><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_constant_variate','Fit Background')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Fit Background:
                                            <select name="extraFun_constant_variate">
                                                <option value="yes">
                                                yes 
                                                </option>
                                                <option value="no">
                                                no 
                                                </option>
                                            </select>
                                        </td>
                                        <td><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_constant_guess','Background')"><IMG SRC="graphics/question.gif" border="0"></A>
                                            Background: 
                                            <input type="text" name="extraFun_constant_guess" value="10" size="8" maxlength="">
                                        </td>
                                </tr>
                                </div>
                            </table>
                        </center>
                    </td>
                </tr>
            </table>
            <input type="hidden" name="extraFun_alpha_variate" value="">
            <input type="hidden" name="extraFun_type" value="0">
            <input type="hidden" name="sort_sortKey1" value="2">
            <input type="hidden" name="sort_sortKey2" value="3">
            <input type="hidden" name="freq_binType" value="0">
            <input type="hidden" name="freq_col" value="3">
            <input type="hidden" name="geoDir" value="<%=dataDir%>">
            <input type="hidden" name="plot_extraFunctions" value="">
            <input type="hidden" name="plot_plot_type" value="3">
            <input type="hidden" name="plot_xlabel" value="Decay length (microsec)">
            <input type="hidden" name="plot_ylabel" value="Number of Decays">
            <input type="hidden" name="plot_highZ" value="">
            <input type="hidden" name="plot_lowZ" value="">
            <input type="hidden" name="plot_zlabel" value="">
            <input type="hidden" name="html_title" value="Muon Lifetime">
            <div align="center">
                <input name="Analyze" type="submit" value="Analyze">
            </div>
        </td>
    </tr>
</table>
