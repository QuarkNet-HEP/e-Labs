/*
 * Based on rawread.
 * Analyzes the error condition reported by qnetevent.
 * String Length is not a real error, because of DS and other lines.
 * Bad character usually is picking up a status line.
 * Many (more than 20) " Orphan" errors often indicates DS 
 *   has triggered the trig counter to be offset from the TMC data.
 *   an ugly problem.
 *   Orphan means that there is a line that happened more than a
 *   gate width after the previous line, but has no first-line-flag.
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
  int myhistogram[10] = {0,0,0,0,0,0,0,0,0,0};

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
	  
	  // increment a count of events that have passed to here.
	  evnum++;
	  
	  // Save or clear the complete event to start a new one.
	  
	  mydata.Clear();
	  
	}

	// now send this data string to be processed.
	//cout << line << endl;
	error = mydata.ReadLine(line);
	if(error >= 0 && error < 10)myhistogram[error]++;
	if(error==2)cout << line << endl;
	
	// check to see what error I had.  I'm basically ignoring 
	// most of these errors for now, throwing out all garbled data.
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

  for(int i=0; i<10; i++){
    cout.width(25);
    if(i==0)cout << "Good " << myhistogram[i] << endl;
    else if(i==1)cout << "String length " << myhistogram[i] << endl;
    else if(i==2)cout << "Bad character " << myhistogram[i] << endl;
    else if(i==3)cout << "Wrong spaces " << myhistogram[i] << endl;
    else if(i==4)cout << "Not first string flag " << myhistogram[i] << endl;
    //else if(i==5)cout << "Should never happen " << myhistogram[i] << endl;
    else if(i==7)cout << "Orphan " << myhistogram[i] << endl;
    //cout << myhistogram[i] << endl;
  }

  return 0;
}
