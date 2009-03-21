#include "qneteventlist.h"
#include "rikhistogram.h"

using namespace std;

int main(int argc, char *argv[]){

  qneteventlist mylist(argc,argv);
  qnetevent previous;
  rik_histogram myhistogram(256);
  while(!mylist.End()){
    int bad = mylist.GetNextEvent();
    if(!bad){  
      if(previous.date == 0)previous = mylist.CurrentEvent;
      qnetevent mydata = mylist.CurrentEvent;
      // always test for bad = 0, then do something with this event.
      if(mydata.Nhits()){
	double diff = QnetEventTimeDifference(previous,mydata);
	//cout << "diff " << diff * 1000. << endl;  // milliseconds
	if(diff >= 0)myhistogram.increment(diff * 1000.);
	previous = mydata;
      }
    }
  }

  myhistogram.write(stdout);

  return 0;
}
