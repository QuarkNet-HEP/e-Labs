/***********************************************************************\
 * unit_test.C  - list the units and calibration for all channels
 *
\***********************************************************************/

/**
 * Construct frame filepath:
 * Given the GPS_time, trend type and source device, construct a full path to
 * a frame file starting from TLA_DATA_DIR, which is set in the environment.
 */

TString frame_filepath(Int_t GPS_time,  TString ttype="M", TString site="H"){

  Int_t   frame_length = 3600;
  Int_t   GPS_block = 1e6;
  TString samp_path = "/trend/minute-trend/";
  TString filepath = "";


  TString TLA_DATA_DIR = gSystem->Getenv("TLA_DATA_DIR");
  cerr << "frame_filepath(): TLA_DATA_DIR is " << TLA_DATA_DIR << endl;

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

  Int_t GPS_prefix = GPS_time/GPS_block;
  Int_t GPS_stamp = frame_length * (int) (GPS_time/frame_length);


  filepath = TLA_DATA_DIR+samp_path+"L"+site+"O";
  filepath += "/H-"+ttype+"-";
  filepath +=  GPS_prefix;
  filepath +=  "/H-"+ttype+"-";
  filepath += GPS_stamp;
  filepath += "-";
  filepath += frame_length;
  filepath += ".gwf";
  return filepath;
}



#include "TFile.h"
#include <stdio.h>
#include <time.h>

//#include <FrameL.h>


/***********************************************************************\ 
 * Frame test - open all frame files in a given time segement and print
 * summary status information.
 * 
\***********************************************************************/
void
unit_test(TString plot_id, TString Channel,
          int GPS_start_time, int GPS_end_time,
          TString ttype){
  int rc;
  Int_t i;
  FILE *fp, *fopen();
  char *filename; 

  time_t t0, t1, t2, t3;

  Int_t   frame_length = 3600;
  Int_t   GPS_block = 1e6;
  TString samp_path = "/trend/minute-trend/";
  TString filepath = "";

  // Begin:

  printf("BEGIN unit_test(%d, %d",  GPS_start_time, GPS_end_time);
  printf(", \"%s\")\n", ttype.Data());

  printf("unit_test.C: ROOT %s as of %d \n",
	 gROOT->GetVersion(), gROOT->GetVersionDate() );

  fflush(stdout);


  gROOT->Reset();
  t0 = time(NULL);

  /***
   *  basic settings based on trend type
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


  // We load DMT/ROOT directly, not indirectly via rootlogin.C
  // (why is that better?  Scope problems with DaccIn? Probably not.)
  //
  gROOT->ProcessLine(".x $TLA_ROOT_DIR/dmtroot.C");


  // dmtroot.C creates an Input Accessor called "In" which will 
  // access the list of files specified by DMTINPUT, if that is defined.
  // If it is not, then In exists but is not yet open.
  
  extern  Dacc In;
  Interval Dt = frame_length;

  In.setDebug(1); 
  In.setIgnoreMissingChannel(true);
  In.setStride(Dt);


  // Add a single "wildcard" channel name which matches everything
  // so we can count channels

  if( rc = In.addChannel("*") ){
    cout << "Error:  addChannel(*) failed. " << endl;
    exit(rc);
  }


  /***
   * Read and process frame files...
   */

  GPS_stamp -= frame_length;  
  Int_t Nfiles=0, Nerrf=0;

  t1 = time(NULL);	// time how long this takes...

  while(GPS_stamp < GPS_end_time) {
   GPS_stamp += frame_length;  

   // Open frame file, add it to the list

    TString frame_name = frame_filepath(GPS_stamp, ttype);

    cout << gSystem->BaseName(frame_name);

    filename=frame_name.Data();
    if( (fp = fopen(filename, "r")) == NULL ){
      cout << " FAIL! " << endl;
      Nerrf++;
      continue;
    }
    else {
      cout << " OK. " << endl;
      fclose(fp);
    }

    // Add this file to the list of files to read for the input stream

    In.addFile(filename);


    /**********************
     * Initialization (for just first file read)
     */

    if ( !In.isOpen() ) {// Initialize when we find a first file
      //  cerr << "DaccIn not yet open.  Open it now..." << endl;
      In.open();
      if ( !In.isOpen() ) {
        cerr << "Cannot open Input Accessor.  File: " << frame_name << endl;
        continue;
      }

      if ( In.isOnline() ) {
        cout << "Error: WE ARE ONLINE! bailing out..." << endl;
        exit(17);
      }

      //      cerr << "Reading first frame..."  << endl;
      In.nextFrame();
      if ( !In.haveFrame() ) {
        cerr << " !Cannot read first Frame." << endl;
        continue;
      }
      //      cerr << "Got the first frame. " << endl; 

      Dt = In.getDt();
      //      cerr << "Frame length Dt=" << Dt << endl;
      if( Dt != frame_length ){
	cerr << "Frame length is not equal to " << frame_length << endl;
	exit(18);	
      }
    }// Initialization


    /*
     * fill data buffers from next frame file (all channels)
     * This is apparently what reads the next file.
     */

    if( rc = In.fillData(Dt) ) {
      cerr << "Error ("<< rc << ") reading in frame " << GPS_stamp << endl;
      if( rc == -3 ) {
	cout << "Error: Requested data not found in current frame" << endl;
	exit(rc); 
      }
      continue; 
    }

    Nfiles++;


    const FrAdcData* adc;


    adc = In.findAdc(Channel);

  }


     
  t2 = time(NULL);

  cerr << "Total frames accessed:     " << In.getTotalFrames() << endl;
  cerr << "Number of frame files read:  " << Nfiles << endl;
  cerr << "Number of files with ERRORS: " << Nerrf << endl;

  if( Nfiles < 1 ){
    cout << "Error: No data read. " << endl;
    exit(15);
  }


  /***
   *  FINAL summary
   */ 

  t3 = time(NULL);

  double total = (double) (t3 - t0);
  cout << Nfiles << " files processed in " << total  << " seconds. " << endl;

  if( Nfiles != 0 ) {
    double startup =(double)( (t1-t0)+(t3-t2));
    double speed = ((double)(t2-t1))/Nfiles;
    cout << "Time = " << startup << " + (" << speed << "*Nfiles) sec " << endl;
  }

  cout << "End of Run " << endl;
}
