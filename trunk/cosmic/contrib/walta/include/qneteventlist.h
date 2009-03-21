/*
 * Manage a long list of events, possibly from one or a sequence of files.
 *
 * Behaves like a list, with End, GetNextEvent
 * Does not have a lot of error correction.
 * Has three ways of initializing it.
 *
 */

#ifndef QNETEVENTLIST_H
#define QNETEVENTLIST_H

#include <iostream>
#include <fstream>
#include <string>
#include <list>
#include "qnetevent.h"
//#include <cstring>
//#include <cstdlib>

using namespace std;

class qneteventlist{
 public:
  // method zero, give nothing, must wait to get a file.
  qneteventlist(){ Clear(); };
  // method one, give argc and argv from command line.
  qneteventlist(int argc, char *argv[]);
  // method two, give a string which is filename (list = 0)
  //             or a string which is text file with list of files (list=1)
  qneteventlist(string File,int list=0);
  //qneteventlist(list<string> filenames);
  ~qneteventlist() {};

  qnetevent IncompleteEvent;
  qnetevent CurrentEvent;

  // acts as an iterator, returns 0 if CurrentEvent is good.
  int GetNextEvent(void);

  int End() {return theend;};

  int NumEvents;

  int GiveFile(string File, int list=0);

  string ThisFileName;
  string ShortFileName;

  int Silent;

 private:
  void Clear(void);
  list<string> filenames;
  list<string>::iterator pfilename;

  ifstream myfile;
  int theend;

};

qneteventlist::qneteventlist(int argc, char *argv[]){
  // assumes that anything not-beginning with '-' is a filename
  // the intention is to take the command-line arguments verbatim.

  for(int word=1; word<argc; word++){
    //cout << argv[word] << endl;
    if(argv[word][0] != '-'){
      string tempfilename = argv[word];
      filenames.push_back(tempfilename);
      //cout << "File " << tempfilename << endl;
    }
  }
  pfilename = filenames.begin();
  Clear();
  //GetNextEvent();
}

qneteventlist::qneteventlist(string File, int list){
  Clear();
  GiveFile(File, list);
}

int qneteventlist::GiveFile(string File, int list){
  if(list==1){
    //this text file contains an ordered list of files.
    ifstream in;
    
    //open the file, and unpack the list.
    in.open(File.c_str(),ios::in);
    while(!in.eof()){
      string tempfilename;
      in >> tempfilename;
      //cout << tempfilename << endl;
      filenames.push_back(tempfilename);
    }
  }
  else {
    // This is just a single filename
    filenames.push_back(File);
  }

  pfilename = filenames.begin();
  //GetNextEvent();
}

void qneteventlist::Clear(void){
  theend = 0;
  NumEvents = 0;
  return;
}

int qneteventlist::GetNextEvent(void){
  // This is written assuming that I am streaming the file.
  CurrentEvent.Clear();

  if( !myfile.is_open() || myfile.eof() ){
    // must open (next) file before reading event.
    if(myfile.is_open()){myfile.close(); myfile.clear();};
    if(pfilename == filenames.end()){
      theend = 1;
      return 1;
    }
    ThisFileName = *pfilename;
    {
      int length = ThisFileName.size();
      for(int i=length-1; i>=0; i--){
	// This tests only for unix-style paths.  Not DOS or old MAC.
	if(ThisFileName.c_str()[i]=='/'){
	  ShortFileName = &ThisFileName.c_str()[i+1];
	  break;
	}
	//cout << ShortFileName << endl;
      }
    }
    if(!Silent)cout << "Opening " << ThisFileName << endl;      
    myfile.open(ThisFileName.c_str(),ios::in);
    // increment iterator, current filename is ThisFileName.
    pfilename++; 
    // test for failure, spit an error and redo, if necessary.
    //brandnewfile = 1;
    if(!myfile.is_open())return 1;
  }

  // Now the file is certainly open.  Read in the next event as usual.
  // I may or may not have the first string already read.
  while(!myfile.eof() && (!CurrentEvent.date && !CurrentEvent.nogps)){
    char line[512];
    int error;
    myfile.getline(line,512);

    // first test if this is a first string.
    if(!QnetEventLineNotValid(line) && QnetEventFirstStringFlag(line)){
      // probably I want to reject the zeroth event.
      
      // otherwise do any analysis things on complete event here.
      
      // increment a count of events that have passed to here.
      // evnum++;
      
      // Save or clear the complete event to start a new one.
      //mydata[myfile].push_back(tempdata);
      CurrentEvent = IncompleteEvent;      
      IncompleteEvent.Clear();
      
    }
    
    // now send this data string to be processed.
    error = IncompleteEvent.ReadLine(line);

  }

  // Now CurrentEvent is done, and a new IncompleteEvent is started
  // TO DO:  trap eof and rerun to get a real event!
  // Trap non-sensical dates and return "bad".

  if(!CurrentEvent.nogps){
    if(CurrentEvent.date <= 20030000)return 1;
    if(CurrentEvent.date >= 20500000)return 1;
  }
  // Trap other kinds of garbling and return "bad".
  // Nothing more yet.
  NumEvents++;
  return 0; //CompleteEvent;

}


#endif

/*
// Sample simpleread code to use this class.
#include "qneteventlist.h"
using namespace std;

int main(int argc, char *argv[]){

  qneteventlist mylist(argc,argv);

  while(!mylist.End()){
    int bad = mylist.GetNextEvent();
    if(!bad){  
      // always test for bad = 0, then do something with this event.
      cout << mylist.CurrentEvent << endl;
    }
  }

  return 0;
}
*/
