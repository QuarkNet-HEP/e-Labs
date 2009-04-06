/***********************************************************************\ 
 * plotNchan - Plot multiple channels
 * 
 *
 * NB. Error codes start at 10.
 *
 * @(#) $Id: plotNchan.C,v 1.8 2009/02/12 21:24:52 myers Exp $
\***********************************************************************/

#include <time.h>
#include <stdio.h>


// Maximum number of channels, at any level
//
#define MAX_CHANNELS 24


void
plotNchan(TString plot_id, TString ChannelListFile, int Nchan,
          int GPS_start_time, int GPS_end_time,
          TString ttype, TString t_axis_pref="GMT"){

  int rc, i;
  FILE *fp, *fopen();
  char *filename; 

  Int_t   frame_length = 3600;
  Int_t   GPS_block = 1e6;
  TString samp_path = "/trend/minute-trend/";
  TString filepath = "";
  TString Channel, RealChannel;
  char    *chName; 

  time_t t1, t2, t3;
  time_t t0 = time(NULL);

  unsigned long n;


  /***********
   * Begin:
   */

  printf("plotNchan(%s, %s, %d", plot_id.Data(), ChannelListFile.Data(), Nchan);
  printf(", %d, %d",  GPS_start_time, GPS_end_time);
  printf(", %s, %s)\n", ttype.Data(), t_axis_pref.Data() );
  printf("plotNchan.C: ROOT version %s as of %d \n",
	 gROOT->GetVersion(), gROOT->GetVersionDate() );
  fflush(stdout);

  // We load DMT/ROOT directly, not indirectly via rootlogin.C
  // (why is that better?  Scope problems with DaccIn? Probably not.)
  //
  gROOT->ProcessLine(".x $TLA_ROOT_DIR/dmtroot.C");

  // This is our own, not the one opened by dmtroot.C
  // (so it does not have anything to do with DMTINPUT)
  //
  extern Dacc In;

  // Load external functions
  //
  gROOT->LoadMacro("$TLA_ROOT_DIR/channels.C");
  gROOT->LoadMacro("$TLA_ROOT_DIR/util.C");


  ChannelInfo *pChInfo, *Channel_List[MAX_CHANNELS];  
  TSeries     *pTS, *Plot_Buffers[MAX_CHANNELS];
  //TODO: build an object for plot "segments" for each channel


  /***
   *  basic settings, based on trend type
   */
	
  if( ttype == "M" ) {
    frame_length = 3600;
    samp_path = "/trend/minute-trend/";
  }
  elseif( ttype == "T" ) {
    frame_length = 60;
    samp_path = "/trend/second-trend/";
  }

  elseif( ttype == "R" ) {
    frame_length = 32;
    samp_path = "/S5/L0/";
    GPS_block = 1e5;
  }
  else {
    cerr << "Unknown trend type " << ttype << endl;
    exit(19);
  } 


  Interval Dt;
  Dt = frame_length; 
  cerr << "Frame length is " << Dt << endl;

  Int_t GPS_stamp = frame_length * (int) (GPS_start_time/frame_length);
  cerr << "GPS starting timestamp: " << GPS_stamp << endl;



  /**
   * Get input channels from a file
   */

  if( ChannelListFile.Sizeof() <=0 ) {
    cerr << "Error: plotNchan() was not given a channel names file." << endl;
    exit(14);
  }

  std::ifstream channel_list_file;
  channel_list_file.open(ChannelListFile);

  if( channel_list_file.bad() ) {
    fprintf(stderr,"\n   ! Cannot open the channel list file.\n", filename);
    exit(16);
  }
  cerr << " Opened ChannelListFile " << ChannelListFile << endl;
  cerr << "  Now trying to read " << Nchan << " channel names " << endl;

  for( i=0; i<Nchan; i++){
    // TODO: Fix this to read one whole line and take first token as name
    channel_list_file >> Channel;

    cerr << "Channel read from file: " << Channel << endl;
    RealChannel = getRealChannelName(Channel,GPS_stamp);
    chName = RealChannel.Data();
    fprintf(stderr, "  plotNchan: real channel name is '%s'\n", chName);

    pChInfo = new ChannelInfo(Channel, RealChannel);
    pChInfo->set_units();
    cerr << "  Input channel units: " << pChInfo->units << endl;
    pChInfo->set_calibration();
    Channel_List[i] = pChInfo;   // copy the ptr


    // Add to the list of channels we wish to be read
    //
    if( rc = In.addChannel(chName) ) {
      cerr << "  Error:  addChannel() failed for " << chName << endl;
      exit(rc);
    }
    else {
      cerr << " Added channel " << pChInfo->name << endl;
    }

    // Add buffer for plotting this channel
    //
    pTS = new TSeries(Time(0),Dt);    
    pTS->setName(pChInfo->name);
    Plot_Buffers[i] = pTS;   
  }
  channel_list_file.close();

  cerr << "List of channels: " << endl;
  In.list(cerr);


  // make some buffers:

  TSeries in_buffer(Time(0),Dt);   // Input (frame by frame) buffer
  in_buffer.setName("in_buffer");

  TSeries out_buffer(Time(0),Dt);  // Output (plot) buffer
  out_buffer.setName("out_buffer");

  TSeries *pInBuf;

  cerr << "Buffers have been created." << endl;


  /***
   * Read in data for the channel from subsequent frame files
   */

  GPS_stamp -= frame_length;  
  Int_t Nfiles=0;

  t1 = time(NULL);	// time how long this takes...

  while(GPS_stamp < GPS_end_time) {
    GPS_stamp += frame_length;  

    // Name change required for early BLRMS DMT channels
    // TODO: try setting  In.setIgnoreMissingChannel(true) and just
    // add the channel, don't remove it.
    //
    if( GPS_stamp == 812836800 || GPS_stamp == 812840400 ) { 
      cerr << "DMT-BRMS_PEM name changed at " << GPS_stamp << endl;
      for(i=0;i<Nchan;i++){
	chName = Channel_List[i]->name;
	In.rmChannel(chName);	// remove old channel name
	RealChannel = getRealChannelName(chName,GPS_stamp); 
	chName = RealChannel.Data();
	if( rc = In.addChannel(chName) ){
	  cerr << "Error:  addChannel() failed for " << chName << endl;
	  exit(rc);
	}
	In.list(cerr);
      }
    }


    // Open frame file (to verify it exists) and add it to the input list

    TString TLA_DATA_DIR = gSystem->Getenv("TLA_DATA_DIR");

    TString frame_name = TLA_DATA_DIR + frame_filepath(GPS_stamp, ttype);
    cerr << "Frame file: " << frame_name ;

    filename=frame_name.Data();
    if( (fp = fopen(filename, "r")) == NULL ){
      fprintf(stderr,"\n   ! Cannot open the file.  Skip it.\n", filename);
      continue;
    }
    else {
      cerr << " OK." << endl;
      fclose(fp);
    }
    In.addFile(filename);


    /**********************
     * Initialization (for just first file read)
     */

    if ( !In.isOpen() ) {// Initialize when we find a first file
      cerr << "DaccIn not yet open.  Open it now..." << endl;
      In.open();
      if ( !In.isOpen() ) {
        cerr << "Cannot open Input Accessor.  File: " << frame_name << endl;
        continue;
      }

      if ( In.isOnline() ) {
        cerr << "Error: WE ARE ONLINE! bailing out..." << endl;
        exit(17);
      }

      //      cerr << "Reading first frame..."  << endl;
      In.nextFrame();
      if ( !In.haveFrame() ) {
        cerr << " !Cannot read first Frame." << endl;
        continue;
      }
      cerr << "Got the first frame. " << endl; 

      Dt = In.getDt();
      cerr << "Frame length Dt=" << Dt << endl;
      if( Dt != frame_length ){
	cerr << "Frame length " << Dt << " is not correct (not "
	     << frame_length << ") " << endl;
	exit(18);	
      }

      In.zeroChans(Dt);
    }// Initialization


    /*
     * fill data buffers from next frame file (all channels)
     */

    if( rc = In.fillData(Dt) ) {
      cerr << "Error ("<< rc << ") reading in frame " << GPS_stamp
	   << "for channel " << chName << endl;
      if( rc == -3 ) {
	cerr << "Error: Requested data not found in current frame" << endl;
	//	exit(rc); 
      }
      continue; 
    }


    /**********************
    /* Copy data to plot buffers */

    for(i=0; i<Nchan; i++){

      chName = Channel_List[i]->name;
      pTS = In.refData(chName);  // ptr to the data segment

      if( pTS->isEmpty() )  continue;
      if( !pTS->isGood() )  continue;

      // TODO: Adjust here the part of the buffer we append, to get
      // down to resolution inside the frame, not just to the frame boundary
      // (eg. to minute not hour for minute trend data)

      if( pTS->getStartTime() > GPS_end_time) continue;
      //cerr << "  Frame start Time: " <<  pTS->getStartTime() << endl;
      if( pTS->getEndTime()   < GPS_start_time) continue;
      //cerr << "  Frame end Time: " <<  pTS->getEndTime() << endl;

      //////////////////
      //TODO: trim down within the frame here.  
      ///////////////

      //cerr << " Number of samples: " << in_buffer.getNsample() << endl; 
      //cerr << " append... "; 
      rc = Plot_Buffers[i]->Append(*pTS);

      if(rc) {
	cerr << " Append failed! " << rc << endl;
	if( rc == -1 ){ // non-Contiguous segment
	  // Pad the missing interval with zeros.  I don't like this,
	  // we should really just not plot anything if there are no data -EAM 
	  Interval BlankTime = in_buffer.getStartTime() - out_buffer.getEndTime();
	  cerr << "Missing data interval: " << BlankTime ;
	  cerr << " Padding with zeros " << endl;
	  Plot_Buffers[i]->extend(pTS->getStartTime()); 
	  if( rc = Plot_Buffers[i]->Append(*pTS) ){
	    cerr << "Append failed AFTER padding.  I give up. " << endl;
	    break;
	  }
	}
	else { // other error
	  cerr << "Append error.  Probably time step miss-match. " << endl;
	  break;
	}
      }
    }// Loop i over channels

    Nfiles++;
  }// Reading files
     

  // cerr << "Total frames accessed:     " << In.getTotalFrames() << endl;
  cerr << "Number of frame files read:" << Nfiles << endl;

  if( Nfiles < 1 ){
    cerr << "Error: No data read.  Nothing to plot.  Aborting. " << endl;
    exit(15);
  }

  int nbin = Plot_Buffers[0]->getNSample();
  cerr << "Number of samples in first plot buffer: " << nbin << endl;

  if( Plot_Buffers[0]->isEmpty() || nbin < 1 ){
      cerr << "Error: Nothing to plot.  Aborting. " << endl;
      exit(15);
  }

  /**
  cout << "Starting time (GPS seconds) of out_buffer: "
       << int(out_buffer.getStartTime().totalS()) << endl;
  cout << "Ending time of out_buffer: "  << out_buffer.getEndTime() << endl;
  ***/


  /************************************************************\
   * Apply calibration to the timeseries based on type of channel.
   * This will also set the units.
   */

    cerr << "Apply calibration to timeseries..." << endl; 

    for(i=0; i<Nchan; i++){
      Channel_List[i]->apply_calibration(Plot_Buffers[i]);
    }


  /************************************************************\
   * Plot it.   Now the TSeries objects Plot_Buffers[i] contain
   *            the data to be plotted 
   */

  TCanvas*  cGDS = new TCanvas("cGDS", "Time Series");
  cGDS->cd();
  TPad*     padT = new TPad("padT", "Time Series", 0.00, 0.00, 1.00, 1.00);


  cout << "Plotting each channel..." << endl; 
  
  TH1F *TSpen[MAX_CHANNELS];    // array of pointers to plot objects

  TH1F* TS001;         // will be result of TPlot();

  for(i=0; i<Nchan; i++){
    cout << "  plot channel " << i << endl;

    // Plot this curve as a histogram using TPlot().  Returns TS001
    TPlot(Plot_Buffers[i]);

    // Find TS001
    TS001 = (TH1F*) gROOT->FindObject("TS001");
    if (!TS001) {
      cerr << "  ! Cannot find histogram TS001!..." << endl;
      continue;   // skip this one
    }

    // Rename to "PenXX"

    char s[2];
    sprintf(s,"%2.2d",i+1);
    TString PenName = "Pen";
    PenName.Append(s);
    TS001->SetName(PenName);

    // Now apply "adjustments" to the plotted object

    TS001->SetLineColor(i+1);

    // Range limits:
    /* Commented out so we can look at PEM data, which are negative,
        but this needs to be smarter  -EAM 02Aug2006 */
    //    TS001->SetMinimum(0.0);


    if( pChInfo->units != "" ){// set units of y-axis
      TS001->GetYaxis()->SetTitle(pChInfo->units);  
      cout << "Y-axis title set to units: " << pChInfo->units << endl;
    }
    TS001->GetYaxis()->SetTitleColor(1);
    TS001->GetYaxis()->SetTitleOffset(1.5);

    // Time axis defaults to GMT format but can be changed

    Int_t GPS_epoch = 315964800; // Unix time of the GPS epoch

    TS001->GetXaxis()->SetTimeDisplay(1);
    TS001->GetXaxis()->SetNdivisions(510);
    TS001->GetXaxis()->SetTimeFormat("#splitline{\ \ \ %H:%M}{%d %b %y}");
    TS001->GetXaxis()->SetTimeOffset(GPS_epoch, "gmt" ); // 
    TS001->GetXaxis()->SetTitle("Time (GMT)");
    TS001->GetXaxis()->SetLabelSize(0.025);
    TS001->GetXaxis()->SetTickLength(-0.015);
    TS001->GetXaxis()->SetTitleOffset(1.25);

    if(t_axis_pref=="GPS") {
      cout << "Changing t-axis to GPS seconds " << endl;
      TS001->GetXaxis()->SetNdivisions(610);
      TS001->GetXaxis()->SetTimeDisplay(0);
      TS001->GetXaxis()->SetTitle("GPS Time");
    }

    // Save a pointer to this plot object
    TSpen[i] = TS001;
  }


  t2 = time(NULL);  // Timestamp

  // Now draw all the TPlots...
  //
  TString DrawArg="";
  for(i=0; i<Nchan; i++){
      TSpen[i]->Draw(DrawArg); 
      DrawArg="SAME";
  }


  // Add a Legend for legibility
  //
  float dy = 0.02* (Nchan+1);

  leg = new TLegend(0.67,0.93-dy, .99,0.93, "blNDC");
  for(i=0; i<Nchan; i++){
    pTS = Plot_Buffers[i];
    leg->AddEntry(TSpen[i], pTS->getName(), "l");
  }
  leg->SetHeader("Legend");
  leg->Draw();


  // Overall plot title is first plot title
  //

  TSpen[0]->SetTitle("Multi-Channel Plot");


  // Save plots in several formats
  //
  save_plots(plot_id);

  t3 = time(NULL);  // Done.


  /****
   * Summary at end of plot:
   */

  double total = (double) (t3 - t0);
  cout << Nfiles << " files processed in " << total  << " seconds. " << endl;

  if( Nfiles != 0 ) {
    double startup =(double)(t1-t0);
    double readspeed = ((double)(t2-t1))/Nfiles;
    double plot_time = (double)(t3-t2);
    cout << "run time = " << startup << " sec (startup) ";
    cout << "+ (" << readspeed << "*Nfiles) sec ";
    cout << " + " << plot_time << " sec (plotting) " << endl;
  }

  cout << "End of Run " << endl;
  cerr << "Th, thu, thee, that's all, folks. " << endl;
  return;
}
