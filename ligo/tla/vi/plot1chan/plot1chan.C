/***********************************************************************\ 
 * plot1chan - Plot a single detector channel
 * 
 * This is the first transformation, and as such it will need to be 
 * broken up into pieces, one to read inte frames for channel(s), the
 * other to do the plotting.
 * 
 * TODO: break this up into two pieces.   The first takes a LIST of
 * channel names, and returns a list of TSeries objects or segments.
 * The second plots those segments.
 * 
 * Each segment has a TSeries of data, a pen color , a channel name,
 * and start and stop times. 
 *
 * NB. Error codes start at 10.
 *
 * @(#) $Id: plot1chan.C,v 1.36 2009/02/11 20:00:41 myers Exp $
\***********************************************************************/

#include "TFile.h"
#include <time.h>
#include <stdio.h>

void
plot1chan(TString plot_id, TString Channel,
          int GPS_start_time, int GPS_end_time,
          TString ttype, TString t_axis_pref="GMT"){

  int rc;
  Int_t i;
  FILE *fp, *fopen();
  char *filename; 

  Int_t   frame_length = 3600;
  Int_t   GPS_block = 1e6;
  TString samp_path = "/trend/minute-trend/";
  TString filepath = "";

  time_t t1, t2, t3;
  time_t t0 = time(NULL);


  //////////
  // Begin:

  //  gROOT->Reset();// DO WE REALLY NEED THIS?  SEEMS NOT.

  printf("plot1chan(%s, %s", plot_id.Data(), Channel.Data());
  printf(", %d, %d",  GPS_start_time, GPS_end_time);
  printf(", %s, %s)\n", ttype.Data(), t_axis_pref.Data() );
  printf("plot1chan.C: ROOT version %s as of %d \n",
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

  // Functions and methods for dealing with channels
  //
  gROOT->LoadMacro("$TLA_ROOT_DIR/channels.C");
  gROOT->LoadMacro("$TLA_ROOT_DIR/util.C");


  /***
   *  basic settings, based on trend type
   */
	
  if( ttype == "M" ) {
    frame_length = 3600;
    samp_path = "/trend/minute-trend/";
  }

  if( ttype == "T" ) {
    frame_length = 60;
    samp_path = "/trend/second-trend/";
  }

  if( ttype == "R" ) {
    frame_length = 32;
    samp_path = "/S5/L0/";
    GPS_block = 1e5;
  }

  Int_t GPS_stamp = frame_length * (int) (GPS_start_time/frame_length);
  cerr << "GPS starting timestamp: " << GPS_stamp << endl;


  /***
   * Input Channel:
   */

  if( Channel.Sizeof() <=0 ) {
    cerr << "Error: plot1chan() was not given a channel name." << endl;
    exit(14);
  }

  TString RealChannel = getRealChannelName(Channel,GPS_stamp);

  char* chName = RealChannel.Data();
  printf("plotchan: real channel name is '%s'\n", chName);

  if( rc = In.addChannel(chName) ) {
    cerr << "Error:  addChannel() failed for " << chName << endl;
    exit(rc);
  }


  // Channel units and calibration

  ChInfo = new ChannelInfo(RealChannel);
  ChInfo->set_units();
  cout << "Input channel units: " << ChInfo->units << endl;
  ChInfo->set_calibration();


  /***
   * Read in data for the channel from subsequent frame files
   */

  GPS_stamp -= frame_length;  
  Int_t Nfiles=0;
  Interval Dt;
  Dt = frame_length; 


  TSeries ts_bufr(Time(0),Dt);   // Input (frame by frame) buffer
  ts_bufr.setName("ts_bufr");

  TSeries ts_2plot(Time(0),Dt);  // Output (plot) buffer
  ts_2plot.setName("ts_2plot");

  cerr << "Buffers have been created." << endl;

  t1 = time(NULL);	// time how long this takes...

  while(GPS_stamp < GPS_end_time) {
   GPS_stamp += frame_length;  

   // Name change required for early BLRMS DMT channels
   // TODO: try setting  In.setIgnoreMissingChannel(true) and just
   // add the channel, don't remove it.

   if( GPS_stamp == 812836800 || GPS_stamp == 812840400 ) { 
      cerr << "DMT-BRMS_PEM name changed at " << GPS_stamp << endl;
      // TODO: do we really have to remove the old name?
      In.rmChannel(RealChannel.Data());	// remove old channel name
      //In.close();  // will open again below
      RealChannel = getRealChannelName(Channel,GPS_stamp); 
      chName = RealChannel.Data();
      if( rc = In.addChannel(RealChannel.Data()) ) {
	cerr << "Error:  addChannel() failed for " << chName << endl;
	exit(rc);
      }
      In.list(cerr);
    }


   // Open frame file, add it to the list

    TString TLA_DATA_DIR = gSystem->Getenv("TLA_DATA_DIR");

    TString frame_name = TLA_DATA_DIR + frame_filepath(GPS_stamp, ttype);
    cerr << "Frame file: " << frame_name ;

    filename=frame_name.Data();
    if( (fp = fopen(filename, "r")) == NULL ){
      fprintf(stderr,"\n   !Cannot open the file.  Skip it.\n", filename);
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

    // ptr to read buffer for the requested channel
    ts_bufr = In.refData(chName); 

    if( ts_bufr.isEmpty() )  continue;

    // TODO: Adjust here the part of the buffer we append, to get
    // down to resolution inside the frame, not just to the frame boundary
    // (eg. to minute not hour for minute trend data)

    if(ts_bufr.getEndTime()   < GPS_start_time) continue;
    if(ts_bufr.getStartTime() > GPS_end_time) break;



    // Append input to accumulated plot item.

    /*********************
    // Trim beginnning or end of frame if it's outside interval of interest.
    // This is complicated by the fact that there are several data types used
    // for times and time intervals. 


    dT =  ((Time)GPS_start_time) - ts_bufr.getStartTime() ;
    if( dT > 0 ){ 
      ts_bufr.eraseStart(dT);
      rc = ts_2plot.Append(ts_bufr,1);
    }
    elseif( (dT = ts_bufr.getEndTime() - GPS_end_time)>0 ){ // trim finish
      rc = ts_2plot.Append( ts_bufr.extract(ts_bufr.getStartTime(), dT) );
    }
    **************/

    //TODO: Start new segments here if there is a time gap. 

    rc = ts_2plot.Append(ts_bufr,1);
    if(rc) {
      cerr << " Append failed! " << rc << endl;
      if(rc == -1){ // non-Contiguous segment
        // Pad the missing interval with zeros.  I don't like this,
        // we should really just not plot anything if there are no data -EAM 
        Interval BlankTime = ts_bufr.getStartTime() - ts_2plot.getEndTime();
        cerr << "Missing data interval: " << BlankTime ;
        cerr << " Padding with zeros " << endl;
        ts_2plot.extend(ts_bufr.getStartTime()); 
        if(rc = ts_2plot.Append(ts_bufr,1)) {
          cerr << "Append failed AFTER padding.  I give up. " << endl;
          break;
        }
      }
      else { // other error
        cerr << "Append error.  Probably time step miss-match. " << endl;
        break;
      }
    }
    Nfiles++;
  }
     
  // cerr << "Total frames accessed:     " << In.getTotalFrames() << endl;
  cerr << "Number of frame files read:" << Nfiles << endl;

  if( Nfiles < 1 ){
    cerr << "Error: No data read.  Nothing to plot.  Aborting. " << endl;
    exit(15);
  }

  int nbin = ts_2plot.getNSample();
  cerr << "Number of samples in timeseries ts_2plot: " << nbin << endl;

  if(ts_2plot.isEmpty() || nbin < 1 ){
    cerr << "Error: Nothing to plot.  Aborting. " << endl;
    exit(15);
  }

  /***/
  cout << "Starting time (GPS seconds) of ts_2plot: "
       << int(ts_2plot.getStartTime().totalS()) << endl;
  cout << "Ending time of ts_2plot: "  << ts_2plot.getEndTime() << endl;
  /***/


  /************************************************************\
   * Apply calibration to the timeseries
   */

    cout << "Apply calibration to timeseries..." << endl; 

    ChInfo->apply_calibration(&ts_2plot);


  /************************************************************\
   * Plot it.   Now the TSeries object ts_2plot contains the data
   *            to be plotted 
   */

  c1 = new TCanvas("c1", "Time Series");
  c1->cd();

  // Set the plot name to be the channel name

  ts_2plot.setName(chName);  

  TPlot(&ts_2plot);


  // Now apply "adjustments" to the plotted object

  TH1F* TS001  = (TH1F*) gROOT->FindObject("TS001");
  if (!TS001) {
    cerr << "Cannot find histogram TS001!..." << endl;
    // TODO: and so we should just exit!
  }
  else {

    // Change the name of the plot
    TS001->SetName("Pen01");  

    // Range limits:
    /* Commented out so we can look at PEM data, which are negative,
        but this needs to be smarter  -EAM 02Aug2006 */
    //    TS001->SetMinimum(0.0);

    if( ChInfo->units != "" ){// set units of y-axis
      TS001->GetYaxis()->SetTitle(ChInfo->units);  
      cerr << "Y-axis title set to units: " << ChInfo->units << endl;
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
      cerr << "Changing t-axis to GPS seconds " << endl;
      TS001->GetXaxis()->SetNdivisions(610);
      TS001->GetXaxis()->SetTimeDisplay(0);
      TS001->GetXaxis()->SetTitle("GPS Time");
    }

  }

  t2 = time(NULL);

  // Save plot in variety of formats
  //
  save_plots(plot_id);

  t3 = time(NULL);


  /****
   * Summary at end of plot:
   */

  double total = (double) (t3 - t0);
  cout << Nfiles << " files processed in " << total  << " seconds. " << endl;

  if( Nfiles != 0 ) {
    double startup =(double)(t1-t0);
    double readspeed = ((double)(t2-t1))/Nfiles;
    double plot_time = (double)(t3-t2);
    cout << "Time = " << startup << " sec (startup) ";
    cout << "+ (" << readspeed << "*Nfiles) sec ";
    cout << " + " << plot_time << " sec (plotting) " << endl;
  }

  cout << "End of Run " << endl;
  cerr << "That's all, folks. " << endl;
  return;
}
