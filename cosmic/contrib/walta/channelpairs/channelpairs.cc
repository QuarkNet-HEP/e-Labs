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
#include "qneteventlist.h"
#include "rikhistogram.h"

int main(int argc, char *argv[])
{
  // there are six pairs of two-channels.
  // in order 01 02 03 12 13 23
  int numbins = 4096;
  rik_histogram myhistogram[6]={numbins,numbins,numbins,numbins,numbins,numbins};
  qneteventlist mylist(argc,argv);

  while(!mylist.End()){
    int bad = mylist.GetNextEvent();
    if(!bad){
      // always test for bad = 0, then do something with this event.
      qnetevent mydata;
      mydata = mylist.CurrentEvent;
      if(mydata.Nhits() >= 3){
	int diff = 0;
	int offset = numbins/2; // this is 128/2, so bin "0" is at 64.
	
	if(mydata.rise[0] >=0 && mydata.rise[1] >= 0){
	  diff = mydata.rise[1] - mydata.rise[0];
	  myhistogram[0].increment(diff+offset);
	}
	if(mydata.rise[0] >=0 && mydata.rise[2] >= 0){
	  diff = mydata.rise[2] - mydata.rise[0];
	  myhistogram[1].increment(diff+offset);
	}
	if(mydata.rise[0] >=0 && mydata.rise[3] >= 0){
	  diff = mydata.rise[3] - mydata.rise[0];
	  myhistogram[2].increment(diff+offset);
	}
	if(mydata.rise[1] >=0 && mydata.rise[2] >= 0){
	  diff = mydata.rise[2] - mydata.rise[1];
	  myhistogram[3].increment(diff+offset);
	}
	if(mydata.rise[1] >=0 && mydata.rise[3] >= 0){
	  diff = mydata.rise[3] - mydata.rise[1];
	  myhistogram[4].increment(diff+offset);
	}
	if(mydata.rise[2] >=0 && mydata.rise[3] >= 0){
	  diff = mydata.rise[3] - mydata.rise[2];
	  myhistogram[5].increment(diff+offset);
	}
      }
    }
  }


  for(int i=0;i<6;i++){
    myhistogram[i].setIdnumber(i);
    myhistogram[i].write(stdout);
  }

  return 0;
}
