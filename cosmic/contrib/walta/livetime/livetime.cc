#include "qneteventlist.h"
using namespace std;

int main(int argc, char *argv[]){

  qneteventlist mylist(argc,argv);
  
  double testtime = 30.0;
  //qnetevent current;
  qnetevent previous;
  qnetevent first;
  qnetevent last;
  int seconds = 0;
  int nanoseconds = 0;
  int startdate = 1;
  int enddate = 99999999;
  int silent = 0;

  for(int i=1; i<argc; i++){
    if(argv[i][0] == '-'){
      if(!strncmp(&argv[i][2],"testtime",8)){
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



  while(!mylist.End()){
    int bad = mylist.GetNextEvent();
    if(!bad){  
      // always test for bad = 0, then do something with this event.
      // make sure date is not zero.
      if(mylist.CurrentEvent.date == 0)continue;

      // if I have not identified the earliest event yet, do so.
      if(first.date == 0 && mylist.CurrentEvent.date != 0){
	first = mylist.CurrentEvent;
      }

      // also make sure previous.date is okay.
      if(previous.date != 0){
	double diff;
	diff = QnetEventTimeDifference(previous,mylist.CurrentEvent);

	// identify some kinds of trouble.
	if(!silent && diff < 0.0){
	  cout << "bad diff " << diff << " " 
	       << previous.date << " " << mylist.CurrentEvent.date 
	       << endl;
	  cout << previous << endl;
	  cout << mylist.CurrentEvent << endl;
	}

	if(mylist.CurrentEvent.date >= startdate 
	   && mylist.CurrentEvent.date <= enddate
	   && previous.date >= startdate
	   && previous.date <= enddate){
	  // don't add if diff < 0.0.  Some kind of error?
	  if(diff < testtime && diff > -200.0){
	    int idiff = (int) diff;
	    seconds += idiff;
	    nanoseconds += (int) ((diff - idiff)*1.0E9);
	    if(nanoseconds >= 1E9){
	      seconds += 1;
	      nanoseconds -= (int)1E9;
	    }
	  }
	  //if(!silent){
	  //  cout << seconds << " " << nanoseconds << " " << diff << " "  
	  // << mylist.CurrentEvent << endl;
	  //}
	}
      }
      if(mylist.CurrentEvent.date != 0){
	previous = mylist.CurrentEvent;
	last = previous;
      }
    }
  }
  cout << "livetime " << (float)seconds/3600. << " " 
       << seconds << " " << nanoseconds << endl;

  double diff2;
  diff2 = QnetEventTimeDifference(first,last);
  cout << diff2 << " diff2" << endl;
  return 0;
}
