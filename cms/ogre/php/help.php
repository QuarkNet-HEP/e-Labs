  <!-- divs for showing the context sensative help pages -->

      <div id="intro">
	<div id="text" class="text">
	  <H2>Greetings Young Scientist</H2>
	  <p>
	    Welcome to the OGRE on-line data analysis project. From here you
	    can explore data from the CMS experiment 
	    (<a href="http://cms.cern.ch/" target=_blank style="color:black;">CMS</a>). 
	    Because CMS collects so much data of such a wide variety, you must
	    choose carefully what to look at if you are to make any sense of it.
	  </p>
	  <p>
	    You can start by choosing <i>Select Data</i> from the controls. You will 
	    see a number of <i>Data Filters</i>. Each filter has a brief description of 
	    it's effect on the data in a tooltip -- let your mouse linger over the filter
	    to see it. To use a filter, simply drag it into one of the boxes above and to the left. To 
	    stop using a filter, drag it back to the filter box, or just double click on it. Experiment
	    with various combinations of filters to see what they do.
	  </p>
	  <p>
	    To build a plot for analysis choose <i>Build Plots</i>. Choose quantities to plot
	    and drag them to the <i>Make a Plot</i> box (it becomes red when you start dragging). Set the
	    color by dragging a color box onto a plot, and choose options from the selections on the right.
	    When you are sure everything is ready to go.... choose <i>Plot It!</i> to see  the results.
	  </p>
	  <p>
	    If you should get lost wandering about my forest home.... don't panic! I'll stay down here in
	    the corner, and you can get back to the controls by poking me.... Good luck, young scientist...
	    we're all counting on you.
            <button id='start' class='helpButton' onClick='javascript:dataWin.show();'>Start</button>
	  </p>
	</div> <!-- End of text div -->
      </div> <!-- end of intro div -->

<script type='text/javascript'>updateProgress(55);</script>

      <div id="cntlhelp">
	<div id="text" class="text">
	  <H2>Using the Controls</H2>
	  This is the main window for using OGRE. From here you can access all of the decisions you can make before you plot your data.
The three buttons on the top left will get you to the windows where you will choose what data you want to plot and how you want to plot it.
The "Restore" and "Previous" buttons in the upper right will both allow you access to studies that have already been started. Restore will bring up studies that have been saved so you can continue work on them. Previous will bring up studies that have been finalized.
Setting the user level controls what options you have when working with the data. Higher levels will allow more options, but these options may not be necessary for all users.
Selecting a dataset will help you sort out test beam data, monte carlo simulation data, and (when it's available) live data.
Selecting theme will allow you to toggle between two versions of OGRE's appearance. Both Standard and Simple have the same options in the same places. Simple may be useful if you are having trouble getting the Standard theme to appear on your browser. This may be especially useful in Internet Explorer.
The check boxes in the middle right of the window allow you to opt into or out of three options. Tool Tips will provide some information about options when you hover the mouse over them. Drag and drop allows you to select options with a single mouse click. Effects allows you to enable effects in the windows.
	  <button id='start' class='helpButton' onClick='javascript:cntlWin.show();'>Return</button>

	</div> <!-- End of text div -->
      </div>   <!-- End of cntlhelp div -->

      <div id="datahelp">
	<div id="text" class="text">
	  <H2>Selecting Data for Analysis</H2>
The three bins in the "Select events with:" box in the upper left corner of this window will help you sort your data. Hover over each one with your mouse for more information on each one.
The "any of" selection will use all data that fits any one of the filters you put in it. If, for example, you put "electrons" and "muons" in this bin, your data will include anything filtered for electrons plus anything filtered for muons.
The "all of" selection will use all data that fits each of the filters you put in it. If you put "electrons" and "muons" in this bin, your data will only include things that match the electron trigger and the muon trigger at the same time.
The "one of" selection will use all data that fits any one of the filters you put in it without fitting any of the others. So placing "electrons" and "muons" in this bin will only return data that fits electrons but not muons and muons but not electrons.
The "Data" box in the upper right will show you what data has been selected for your use in the plots. This will include the number of events you have to use.
	  <button id='start' class='helpButton' onClick='javascript:dataWin.show();'>Return</button>

	</div> <!-- End of text div -->
      </div>   <!-- End of datahelp div -->

<script type='text/javascript'>updateProgress(60);</script>

      <div id="varhelp">
	<div id="text" class="text">
	  <H2>Building a Plot</H2>
	  In the upper left is the "Make a Plot" box. In this box are two bins.
The left bin is for the data you wish to plot. You may plot one or multiple things at a time.
The right bin is for plot options. These options are in white in the right box. You can change the type of image file your plot is output as, the size of the plot, and whether the x- and y- axes are log or normal.
If you have applied and saved a selection cut to a plot already, this will also be available among the options.
You can also choose colors for the data you plot. Just drag a color on top of the data set you wish to be that color. When you click the "Plot It!" button in the bottom right corner, it will create your new plot and take you to a new set of windows.
	  <button id='start' class='helpButton' onClick='javascript:variWin.show();'>Return</button>

	</div> <!-- End of text div -->
      </div>   <!-- end of varhelp div -->

<script type='text/javascript'>updateProgress('65');</script>

      <div id="archhelp">
	<div id="text" class="text">
	  <H2>Study Archives</H2>
											     In the studies archives are those studies which you have been working on (accesible from the <i>Restore</i> button) or that others have completed (accessible from the <i>Previous</i> button) on the <i>Ogre Controls</i> windowlet. The particular study is previewed with a thumbnail of the most current graph. To get a better look at the graph, click the thumbnail and it will be enlarged in its own windowlet for your examination. In order to access the study, simply click on this enlarged graph and it will be restored exactly as it was when you left off. Any metadata associated with the study can be accessed by clicking the "?" button on the windowlet of the graph.
            <button id='start' class='helpButton' onClick='javascript:archWin.show();'>Return</button>
	</div> <!-- End of text div -->
      </div>   <!-- end of archhelp div -->

      <div id="prevhelp">
	<div id="text" class="text">
	  <H2>Study Archives</H2>
											     In the studies archives are those studies which you have been working on (accesible from the <i>Restore</i> button) or that others have completed (accessible from the <i>Previous</i> button) on the <i>Ogre Controls</i> windowlet. The particular study is previewed with a thumbnail of the most current graph. To get a better look at the graph, click the thumbnail and it will be enlarged in its own windowlet for your examination. In order to access the study, simply click on this enlarged graph and it will be restored exactly as it was when you left off. Any metadata associated with the study can be accessed by clicking the "?" button on the windowlet of the graph.
            <button id='start' class='helpButton' onClick='javascript:prevWin.show();'>Return</button>
	</div> <!-- End of text div -->
      </div>   <!-- end of prevhelp div -->

 <script type='text/javascript'>updateProgress(70);</script>

     <div id="credits">
        <div id="text" class="text">
          <H2>Programming Credits</H2>
          Acknowledge all the people I swiped code from
        </div> <!-- End of text div -->
      </div>   <!-- end of credits div -->
      
    </div> <!-- end of wrapper div -->
