/*
 *  A simple read program to exercise the qneteventclass
 *  It really just prints out complete events, does some error checking.
 *  No analysis is here in this example, but take this skeleton and add some.
 */


#include <iostream>
#include <fstream>
#include <list>
#include <string>

using namespace std;
#define DEBUG 0
#include "qnetdaqcard.h"

int main(int argc, char *argv[])
{

  qnetevent myevent;
  qnetevent firstevent;
  qnetdaqcard mydata;
  qnetsingles firstsingles;
  qnetsingles mysingles;

  int numhits[4] = {0,0,0,0};
  // take the filename from the command line.
  list<string> filenames;
  string onefilename;

  if(argc == 1)
    {
      cerr << "usage: simpleread.exe filenames..." << endl;
      return 1;
    }


  for(int name=1; name < argc; name++)
    {
      onefilename = argv[name];
      filenames.push_back(onefilename);
      cout << onefilename << endl;
    }

  int evnum = 0;

  list<string>::iterator pfilename;
  for(pfilename=filenames.begin(); pfilename!=filenames.end(); pfilename++){
    ifstream in;

    int filled_first_singles = 0;
    firstsingles.Clear();
    mysingles.Clear();

    cout << "About to open " << *pfilename << endl;
    in.open(pfilename->c_str(), ios::in);

    if( in.is_open() ){

      while(!in.eof()){
        char line[256*4];
        int error;
        in.getline(line,256*4);

	mydata.ReadLine(line);

	// put your code here.
	// you will probably want a switch or a bunch of if elseifs.

	if(mydata.linestatus == mydata.newevent){
	  // do this if mydata reports a newly complete event.

	  if(mydata.completeevent->Nhits()){
	    if(!firstevent.hittag)firstevent = *(mydata.completeevent);
	    evnum++;
	    cout << *(mydata.completeevent) << endl;
	  }
	}
	if(mydata.linestatus == mydata.allclear){
	  filled_first_singles = 0;
	  firstsingles.Clear();
	}
	
	if(mydata.linestatus == mydata.lastsingles){
	  // do this if mydata reports that all singles entries are complete.
	  // in order to count singles, I need to detect things that clear.
	  mysingles = *(mydata.singlescount);
	  if(!filled_first_singles && 
	     firstsingles.seconds < 0.0 && firstevent.hittag){
	    firstsingles = mysingles;
	    filled_first_singles = 1;
	  }
	  cout << "singles " ;
	  mydata.singlescount->Print();
	}
	cout << line << endl;
      }

    }
    in.clear();
    in.close();
    // do end of file things here
    // print out a summary of the rates for this file.
    mysingles.Print();
    double rate[5];
    double time;
    qnetsinglesrate(firstsingles, mysingles, rate, time);
    cout << *pfilename
	 << " events " << evnum
	 << " time " << time ;//QnetTimeDifference(firstdata,lastdata);
    //   << " hittag ";
    // for(int i=0; i<8; i++)cout << hittaghistogram[i] << " ";
    cout << " rate ";
    for(int i=0; i<5; i++)cout << rate[i] << " ";
    cout << " date ";
    cout << firstevent.date << " " << firstevent.seconds;
    cout  << endl;
    
    
  } // end of for(pfilename = filenames.begin()...
  
  cout << "events " << evnum << endl;
  return 0;

}
