/*
 *  A simple read program to exercise the waltadataclass
 *  It really just prints out complete events, does some error checking.
 *  No analysis is here in this example, but take this skeleton and add some.

  Note April 2004
  To make this actually useful, I need to be able to input a list of files
  for each site, or be able to query a file database for an appropriate
  ordered list of filenames and keep each site separate.

  Also need to more carefully check for invalid gps, and (!) valid gps
  that happens to be out of order because it is actually crap, even though
  it has the correct format.  This sometimes happens.  Or I need to make
  reformatted files in which the crap is definitely cleared out.  At this  
  moment I tool ahead one event at the beginning of the file and simply
  hope that all the other events are okay.  

  As of August 2004 this can search an arbitrary number of files.
  As of September 2004, now I can input a list of files.

 */


#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <list>

#define DEBUG 0
using namespace std;
 
#include "qneteventlist.h"
#include "qnetevent.h"
 
int main(int argc, char *argv[])
{ 
 
  // change these three requirements and recompile.
  // maybe I'll get around to making them command-line inputs.
  double testtime = 1.0E-6;      // seconds
  int requiredcoincidences = 3;
  int requiredhits = 2;
  int filelist = 0;
  int numfiles = 0;
  int verbose = 0;
  int silent = 0;
  // startdate and enddate (yyyymmdd) are inefficient, because the program
  // still tests every event to see if it is within the range.
  int startdate = 20040400;
  int enddate = 20100000;

  if(argc == 1)
    {
      cerr << "usage: simpleread.exe filenames..." << endl;
      return 1;
    }

  for(int i=1; i<argc; i++){
    if(argv[i][0] != '-'){
      numfiles++;
    }
    else{
      if(!strncmp(&argv[i][2],"coincidence",11)){
	requiredcoincidences = atoi(&argv[i][14]);
      }
      if(!strncmp(&argv[i][2],"coincidences",13)){
	requiredcoincidences = atoi(&argv[i][15]);
      }
      else if(!strncmp(&argv[i][2],"filelist",8)){
	filelist = 1;
      }
      else if(!strncmp(&argv[i][2],"hits",4)){
	requiredhits = atoi(&argv[i][7]);
      }
      else if(!strncmp(&argv[i][2],"testtime",8)){
	testtime = atof(&argv[i][11]);
      }
      else if(!strncmp(&argv[i][2],"silent",6)){
	silent = 1;
      }
      else if(!strncmp(&argv[i][2],"startdate",9)){
	startdate = atoi(&argv[i][12]);
      }
      else if(!strncmp(&argv[i][2],"enddate",7)){
	enddate = atoi(&argv[i][10]);
      }
    }
  }

  qneteventlist mylist[numfiles];
  int j = 0;
  for(int i=1; i<argc; i++){
    if(argv[i][0] != '-'){
      mylist[j].GiveFile(argv[i],filelist);
      if(silent)mylist[j].Silent = 1;
      mylist[j].GetNextEvent();
      j++;
    }
  }


  // now go through and sort the data looking for coincidences.
  // method:  pdata points to the current data in each of the four streams.
  //          (all four data files are buffered!)
  //          decide which of the four was earliest.
  //          decide if any of the other three are coincident.
  //            if not, increment the earliest.
  //            if so, increment the earliest and the coincident.
  // this will miss some coincidences preceeded by accidentals.

  list<qnetevent>::iterator pdata[numfiles];
  int updatedata[numfiles];
  for(int myfile=0; myfile<numfiles; myfile++)updatedata[myfile] = 0;
  int is_end_all_files = 0;

  // coinlist is 1 if it participates in coincidence.
  // suppress printout of nothings.
  int coinlist[numfiles];  

  int ntests = 0;
  int event = 0;
 
  while(!is_end_all_files){
    // determine the earliest of the current events
    int earliest = -1;

    
    //for(int myfile=0; myfile<numfiles; myfile++){
    //  cout << mylist[myfile].CurrentEvent << " " 
    //   << mylist[myfile].ThisFileName << endl;
    //  if(myfile == numfiles - 1)cout << endl;
    //}

    // to start, set earliest to be the first not-ended data stream.
    for(int myfile=0; myfile<numfiles; myfile++){
      if(!mylist[myfile].End()){earliest = myfile; break;};
    }      

    // now test the other data streams to see if one of them is earlier.
    for(int myfile=0; myfile<numfiles; myfile++){
      if(mylist[myfile].End())continue;
      double diff = QnetEventTimeDifference(mylist[earliest].CurrentEvent,
					mylist[myfile].CurrentEvent);
      if(diff < 0.0)earliest=myfile;
    }

    // now take earliest, and see if the others are within testtime seconds.

   
    for(int myfile=0; myfile<numfiles; myfile++)coinlist[myfile] = 0;
    coinlist[earliest] = 1;
    for(int myfile=0; myfile<numfiles; myfile++)updatedata[myfile] = 0;
    updatedata[earliest] = 1;

    int all_have_required_hits = 1;
    if(mylist[earliest].CurrentEvent.Nhits() < requiredhits)
      all_have_required_hits = 0;

    int num_within_testtime = 1;  //always start at 1 for "earliest"
    for(int myfile=0; myfile<numfiles; myfile++){
      if(myfile == earliest)continue;
      if(mylist[myfile].End())continue;

      double diff = QnetEventTimeDifference(mylist[earliest].CurrentEvent,
					mylist[myfile].CurrentEvent);
      // because "earliest" is true, diff must be >= 0;
      //cout << " diff " <<  diff << endl;
      if(diff <= testtime){
	num_within_testtime++;
	// only consider required hits if it participates in coincidence.
	if(mylist[myfile].CurrentEvent.Nhits() < requiredhits)all_have_required_hits=0;
	// only update data file if it participates in coincidence
	// events further away will be the "earliest" next time through.
	updatedata[myfile] = 1;
      coinlist[myfile] = 1;
      }

      ntests++;
    }
 

    if(num_within_testtime >= requiredcoincidences && all_have_required_hits){
      // Also, write out time difference here.
      cout << "event " << event 
	   << " coincidence " << num_within_testtime << " " << endl;
      for(int myfile=0; myfile<numfiles; myfile++){
	double diff = 0.0;
	if(myfile == earliest)diff = 0.0;
	else if(mylist[myfile].End())diff = -999.0;
	else diff = QnetEventTimeDifference(mylist[earliest].CurrentEvent,
					mylist[myfile].CurrentEvent);
	if(coinlist[myfile]){
	  cout.width(28);
	  cout << mylist[myfile].ShortFileName;
	  if(myfile == earliest){
	    cout << " diff ";
	    cout.width(10);
	    cout << diff;
	  } else {
	    cout << " diff " << setiosflags( ios::scientific)
		 << setprecision(4) << diff << resetiosflags( ios::scientific);
	  }

	  cout << " date ";
	  cout << mylist[myfile].CurrentEvent.date;
	  cout << "  gps ";
	  cout.width(5);
	  cout << mylist[myfile].CurrentEvent.seconds << " ";
	  cout.width(9);
	  cout << mylist[myfile].CurrentEvent.nanoseconds << " " ;

  	  cout << " hits " << mylist[myfile].CurrentEvent.Nhits();

	  for(int i=0; i<4; i++){
	    cout << "  c" << i << " " ;
	    cout.width(4);
	    cout << mylist[myfile].CurrentEvent.rise[i];
	    cout << " ";
	    cout.width(4);
	    cout << mylist[myfile].CurrentEvent.fall[i];
	  }
	  cout << "  str " << setw(2) << mylist[myfile].CurrentEvent.nstrings;
	  cout << endl;
	  updatedata[myfile] = 1;
	}
      }
      event++;
    }
    else {  // There was no coincidence
      for(int myfile=0;  myfile<numfiles; myfile++){
	// No coincidence, only update the earliest, not the rest.
	if(myfile != earliest)updatedata[myfile] = 0;
      }
    }

    // Here I actually do the update of each file.
    for(int myfile=0; myfile<numfiles; myfile++){
      int bad = 1;
      while(updatedata[myfile] && !mylist[myfile].End() && bad){
	bad = mylist[myfile].GetNextEvent();
	//if(bad) cout << "was bad" << mylist[myfile].CurrentEvent << endl;
	// test to see if this event is within my date bounds.
	if(!bad  && !mylist[myfile].End() && 
	   // trap events which are beyond the requested date bounds
	   (mylist[myfile].CurrentEvent.date <= startdate 
	    || mylist[myfile].CurrentEvent.date > enddate
	    // also trap this kind of peculiar ridiculous date error.
	    // I don't know what kind of corruption causes it.
	    // Also don't know how often 2004xxxx is actually bogus.
	    || mylist[myfile].CurrentEvent.date <= 20040400)){

	  bad = 1;  // if it is out of date bounds, flag it as bad.

	}
      }
      
    }

    // Here I check to see if the files are ended.
    int num_file_ends = 0;
    for(int myfile=0; myfile<numfiles; myfile++){
      if(mylist[myfile].End())num_file_ends++;
    }
    if(num_file_ends == numfiles)is_end_all_files = 1;

  }
     
  //cout << "ntests " << ntests << endl;

  return 0;
}

 
/*
usefile things.

command line:
./coincidence.exe --filelist --coincidence=2 --testtime=1.0E-5 --silent [lists]

find /data/walta/lisa.atmos/data -name "uwatmos*.txt" > uwatmos.txt

look through the file lists and delete any trouble files.

*/
