/*
 *  A simple read program to exercise the qnet classes
 *  It really just prints out complete events, does some error checking.
 *  No analysis is here in this example, but take this skeleton and add some.
 */


#include <iostream>
#include <fstream>
#include <list>
#include <string>

using namespace std;
#include "qnetdaqcard.h"

int main(int argc, char *argv[])
{

  qnetevent myevent;
  qnetdaqcard mydata;

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

    cout << "About to open " << *pfilename << endl;
    in.open(pfilename->c_str(), ios::in);

    if( in.is_open() ){

      while(!in.eof()){
        char line[256*4];
        int error;
        in.getline(line,256*4);

	//cout << line << endl;
	mydata.ReadLine(line);

	// put your code here.
	// you will probably want a switch or a bunch of if elseifs.

	if(mydata.linestatus == mydata.newevent){
	  // do this if mydata reports a newly complete event.
	  if(mydata.completeevent->Nhits()){
	    evnum++;
	    cout << *(mydata.completeevent) << endl;
	  }
	}
	if(mydata.linestatus == mydata.lastsingles){
	  // do this if mydata reports that all singles entries are complete.
	  mydata.singlescount->Print();
	}
      }

    }
    in.clear();
    in.close();
    // do end of file things here

  } // end of for(pfilename = filenames.begin()...

  cout << "events " << evnum << endl;
  return 0;

}
