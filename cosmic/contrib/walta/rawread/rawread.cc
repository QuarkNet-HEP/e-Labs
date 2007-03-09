/*
 *  A simple read program to exercise the waltadataclass
 *  It really just prints out complete events, does some error checking.
 *  No analysis is here in this example, but take this skeleton and add some.
 */


#include <iostream>
#include <fstream>
#include <string>
#include <list>

using namespace std;
#define DEBUG 0
#include "qnetevent.h"

int main(int argc, char *argv[])
{

  qnetevent mydata;

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
      list<qnetevent> mylist;
	  
      while(!in.eof()){
	char line[256*4];
	int error;
	in.getline(line,256*4);
	
	// the loop here goes like this:
	// Test the new string to see if it is the start of new event
	// If yes, then process the previous now-complete event
	//         and then clear mydata, and then start filling new.
	// Otherwise, just send the string to mydata.    
	
	
	// first test if this is a first string.
	if(!QnetEventLineNotValid(line) && QnetEventFirstStringFlag(line)){
	  // probably I want to reject the zeroth event.
	  //cout << "Yes, it is first string in event!" << endl;
	  
	  // otherwise do any analysis things on complete event here.
	  //cout << "Found first string, I should analyze now" << endl;
	  
	  if(mydata.Nhits()){
	    cout << mydata << endl; 
	  }

	  // increment a count of events that have passed to here.
	  evnum++;
	  
	  // Save or clear the complete event to start a new one.
	  
	  mydata.Clear();
	  
	}

	// now send this data string to be processed.
	cout << line << endl;
	error = mydata.ReadLine(line);
	
	// check to see what error I had.  I'm basically ignoring 
	// most of these errors for now, throwing out all garbled data.
	if(error==7)cout << "orphan" << endl;
	if(error)continue;
      }
      
      in.clear();  // Gotcha!  The stream's eof() is not cleared by close()
      in.close();
      
    }
    else { 
      // If I could not open the file.  Probably the filename is wrong.
      cout << "Error opening " << *pfilename << endl;
    }
      
  }  //end of for(pfilename = filenames.begin()...

  return 0;
}
