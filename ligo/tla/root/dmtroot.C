/***********************************************************************\
 *  dmtroot.C - load shared objects and macros for dmtroot
 * 
 *  Originally dmtrootLogon.C when it was expected to be loaded automatically
 *  via the ltroot script.  
 *
 *  Eric Myers <myers@spy-hill.net>  - 14 March 2006
 *  @(#) $Id: dmtroot.C,v 1.6 2007/07/25 15:59:24 myers Exp $
\***********************************************************************/
{
  /***********************************************************************
   * ROOT include path(s)
   *
   * THIS DOES NOT SEEM TO MATTER!
   */
 
  // #include <iostream> // already loaded

  // This fails in ROOT 4.04, it might work in ROOT 5?  Or ROOT 3?
  //FAILS!// gSystem->AddIncludePath(" -I/opt/lscsoft/dol/include ");
  // (Also, we really don't want dol anyway.)

  // This works with ROOT 4.04:
  gROOT->ProcessLine(".include /opt/ligotools/packages/dmtroot/active/macros");
  gROOT->ProcessLine(".include $TLA_ROOT_DIR");
  //  cerr << "* Add dmtroot/macros to the INCLUDES list..." << endl;


  //TODO: use LIGOTOOLS from the environment...
  // Order matters: $TLA_ROOT_DIR contains our modified versions, and so should
  //  come before $LIGOTOOLS 
  //  gROOT->ProcessLine(".include $TLA_ROOT_DIR");
  //#pragma includepath $TLA_ROOT_DIR
  //  TString LIGOTOOLS=gSystem->Getenv("LIGOTOOLS");
  //  gROOT->ProcessLine(".include $LIGOTOOLS/packages/dmtroot/active/macros");
  //#pragma includepath $LIGOTOOLS/packages/dmtroot/active/macros

  /******************************************************/

  printf("dmtroot: ROOT %s as of %d \n",
	 gROOT->GetVersion(), gROOT->GetVersionDate() );
  fflush(stdout);

  /***********************************************************************
   * Loading Shared Libraries
   *
   * Libraries are loaded from LD_LIBRARY_PATH, even if you
   * try to specify a full path name to gSystem->Load() 
   * Live with it.  
   *
   * The order in which these are loaded seems to matter.  Don't move
   * these around lightly.
   */

  // basegdsroot:

  cerr << "* Loading stuff from basegdsrootLogin.C..." << endl;
  cerr << "  libgdsbase.so, ";
  gSystem->Load("libgdsbase.so");

  cerr << " libgdscntr.so, ";
  gSystem->Load("libgdscntr.so");

  cerr << " libxsil.so ";
  gSystem->Load("libxsil.so");

  cerr << " - DONE \n";

  // General dmtroot libraries:

  cerr << "* Loading stuff that is in dmtrootLogon.C..." << endl;

  cerr << "  libgeneral.so, ";
  gSystem->Load("libgeneral.so");

  cerr << " libframecpp.so, ";
  gSystem->Load("libframecpp.so");

  cerr << " libframeio.so, ";
  gSystem->Load("libframeio.so");

  cerr << " libdmtsigp.so ";
  gSystem->Load("libdmtsigp.so");

  cerr << "  - DONE \n";


  /**********
  // eventoolLogin:   IS THIS NEEDED?  Maybe eventually, or maybe metaio

  cerr << "* Loading stuff from eventoolLogon.C..." << endl;
  cerr << " libgdsevent.so ";
  gSystem->Load("libgdsevent.so");
  cerr << " - DONE \n";
 

  /**************  THIS FAILS FOR NOW. GDS does not now build libFrvXXXX.so?
  // Frv

  cerr << "  *  Loading stuff from FrvLogin.C..." << endl;
  gSystem->Load("libFrvROOT.so");
  cerr << " libFrvROOT.so: " ;
  gInterpreter->SaveGlobalsContext();
  FrvLibVersion(stdout);

  cerr << " DONE \n";
  /***************/


  /***********************************************************************
   * DMT ROOT Macros
   *
   * The way these are loaded is awkward.  It would be nice if we could
   * instead load by just the name, with a list of paths to check.
   * But I'm not sure if that works, or if it works with ROOT v3, or v4?
   *
   * We'd probably have to write a .rootrc file to the slot to alter the path.
   */

  cerr << "* Loading DMT Macros..." << endl;

  /* These are loaded from DMT_ROOT_MACROS */

  cerr << " uniqueName.cc, ";
  gROOT->LoadMacro("$DMT_ROOT_MACROS/uniqueName.cc");
  //gROOT->LoadMacro("uniqueName.cc");

  cerr << " THist.cc, "; 
  gROOT->LoadMacro("$DMT_ROOT_MACROS/THist.cc");
  cerr << "Bode.cc, ";
  gROOT->LoadMacro("$DMT_ROOT_MACROS/Bode.cc");
  cerr << "Spectrum.cc, ";
  gROOT->LoadMacro("$DMT_ROOT_MACROS/Spectrum.cc");
  cerr << "DatEnv.hh, ";
  gROOT->LoadMacro("$DMT_ROOT_MACROS/DatEnv.hh");
  //gROOT->LoadMacro("$DMT_ROOT_MACROS/DatEnv.cc");
  cerr << "pTrend.cc.";
  gROOT->LoadMacro("$DMT_ROOT_MACROS/pTrend.cc");

  /* These are loaded from TLA_ROOT_DIR (our macros, not CERN's or LIGO's) 
   * because we've made some modifications (maybe those will go back
   * to DMT some day?  Maybe not.)  */

  cerr << " TPlot.cc, ";
  gROOT->LoadMacro("$TLA_ROOT_DIR/TPlot.cc");
  //gROOT->LoadMacro("TPlot.cc");

  cerr << " - DONE \n";
  cerr << "<<<< Loaded LIGO DMT libraries and functions >>>>" << endl;

  //  printf("dmtroot: %s \n", FrLibVersionF());
  //  cerr << FrLibVersionF() << endl;


  //--------------------------------------  Create a data accessor object.

  /* Even though we do this the same way ltroot does, you likely
   * do not want to set DMTINPUT for the web based tool */

  Dacc In;

  const char* InPath = gSystem->Getenv("DMTINPUT");
  if ( InPath && *InPath ) {
    cerr << "Connecting default input accessor (In) to " << InPath << endl;

    In.addFile(InPath);
    In.open();
  }
  else {
    cerr << "Default input accessor (In) not opened, since env variable DMTINPUT was not set" << endl;
  }

  //--------------------------------------  Create a display canvas.

  /* This is needed since some DMT display routines assume a canvas already 
   * exists. (Okay, but ROOT also creates a canvas c1 if none exists and 
   * one is needed, so this is probably redundant.) */

  if( !gROOT->IsBatch() ) {
    TCanvas canvas("canvas", "ROOT canvas");
  }

 cerr << "  dmtroot.C: loaded.  " << endl;
}
