/*
 *  Based on rawread.cc
 *  This does not use the qneteventlist because it extracts event information
 *  and also singles and other information out of the data stream, something
 *  that qneteventlist is not capable of doing at present.
 */


#include <iostream>
#include <fstream>
#include <string>
#include <list>

using namespace std;
#define DEBUG 0
#include "qnetevent.h"
#include "qnetsingles.h"

int main(int argc, char *argv[])
{
  int oneline=0;  //toggle between oneline output and plain.

  double TotalLivetime = 0.0;
  int Hits2plus = 0;
  int Hits4 = 0;
  
  int hittaghistogram[17];
  for(int i=0; i<17; i++)hittaghistogram[i] = 0;

  int hitshistogram[5];
  for(int i=0; i<5; i++)hitshistogram[i] = 0;
  
  int orphans = 0;
  int nstrings = 0;

  // take the filename from the command line.
  list<string> filenames;
  string onefilename;
  
  if(argc == 1){
    cerr << "usage: simpleread.exe filenames..." << endl;
    return 1;
  }


  for(int name=1; name < argc; name++){
    onefilename = argv[name];
    filenames.push_back(onefilename);
    //cout << onefilename << endl;
  }

  int evnum = 0;
  qnetevent previousdata;
  qnetevent firstdata;
  qnetevent lastdata;


  list<string>::iterator pfilename;
  for(pfilename = filenames.begin(); pfilename != filenames.end(); pfilename++){
    ifstream in;

    //cout << "About to open " << *pfilename << endl;
    in.open(pfilename->c_str(), ios::in);
    
    if( in.is_open() ){
      qnetevent mydata;
      qnetevent savedata;
      qnetevent previousdata;
      qnetsingles firstsingles;
      qnetsingles mysingles;
      previousdata.Clear();
      int filled_first_singles = 0;
      
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
	  
	  // otherwise do any analysis things on complete event here.
	  
	  if(mydata.Nhits()){
	    if(evnum == 1)firstdata = mydata;
	    evnum++;
	    nstrings += mydata.nstrings;
	    hittaghistogram[mydata.hittag]++;
	    hittaghistogram[16]++;
            hitshistogram[mydata.Nhits()]++;
	    savedata = mydata;

	    if(!filled_first_singles && savedata.seconds >= 0){
	      mysingles.FillTime(savedata);
	      firstsingles = mysingles;
	      filled_first_singles = 1;
	    }
	  }
	  
	  
	  // increment a count of events that have passed to here.
	  
	  // Save or clear the complete event to start a new one.
	  previousdata = mydata;
	  mydata.Clear();
	  
	}
	
	// now send this data string to be processed.
	// cout << line << endl;
	error = mydata.ReadLine(line);
	if(error){
	  if(error==7)orphans++;
	  int newerr = mysingles.FillData(line);
	  mysingles.FillTime(savedata);
	}
	
	
      }
      lastdata = previousdata;
      
      double rate[5];
      double time;
      qnetsinglesrate(firstsingles, mysingles, rate, time);

      if(oneline){
      // Print out the run summary in one line.
      cout << *pfilename  
	   << " events " << evnum 
	   << " time " << time ;//QnetTimeDifference(firstdata,lastdata);
      //   << " hittag ";
      // for(int i=0; i<8; i++)cout << hittaghistogram[i] << " ";
      cout << " rate ";
      for(int i=0; i<5; i++)cout << rate[i] << " ";
      cout.fill('0');
      cout.width(6);
      cout << firstdata.date << " ";
      cout.fill('0');
      cout.width(6);
      cout << (int)firstdata.utc;      
      cout  << endl;
      }      
      else {
      cout << "<runsummary>" << endl;
      cout << "file " << *pfilename << endl;
      cout << "events " << evnum << endl;
      cout << "starttime " << firstdata.date 
	<< " " << firstdata.utc << endl;
      cout << "endtime " << lastdata.date 
	<< " " << lastdata.utc << endl;
      double livetime = QnetEventTimeDifference(firstdata,lastdata);
      cout << "livetime "<< livetime << endl;
      cout << "hits " << hitshistogram[1] << " " << hitshistogram[2]
	<< " " << hitshistogram[3] << " " << hitshistogram[4] << endl;
      cout << "singlesrate " << rate[0] << " " << rate[1] << " " << rate[2]
      	<< " " << rate[3] << " " << rate[4] << endl;
      cout << "rate2+ " 
	   << (double)(hitshistogram[2]+hitshistogram[3]+hitshistogram[4])/livetime 
	   << " rate4 " << (double)(hitshistogram[4])/livetime
	   << endl;
      cout << "orphans " << orphans << endl;
      cout << "nstrings " << nstrings << " perevent " 
	   << (double)nstrings/(double)evnum << endl;
      cout << "</runsummary>" << endl;
      cout << endl;
      TotalLivetime += QnetEventTimeDifference(firstdata,lastdata);
      Hits2plus += hitshistogram[2] + hitshistogram[3] + hitshistogram[4];
      Hits4 += hitshistogram[4];
      }

      in.clear();  // Gotcha!  The stream's eof() is not cleared by close()
      in.close(); 
      evnum = 0;
      for(int i=0; i<16; i++)hittaghistogram[i] = 0;
      for(int i=0; i<5; i++)hitshistogram[i] = 0;
      orphans = 0;
      nstrings = 0;
    }
    else{ // If I could not open the file.  Probably the filename is wrong.
      cout << "Error opening " << *pfilename << endl;
    }
    
  }  //end of for(pfilename = filenames.begin()...

  if(!oneline){
    cout << "livetime " << (int) TotalLivetime << " " 
	 << (int)(TotalLivetime/3600.) 
	 << " Hits2plus " << Hits2plus << " Hits4 " << Hits4 
	 << " Rate2plus " << (double)Hits2plus/TotalLivetime 
	 << " Rate4 " << (double)Hits4/TotalLivetime
	 << endl;
  }

  return 0;
}

