#include "qneteventlist.h"
#include "rikhistogram.h"
using namespace std;

int main(int argc, char *argv[]){

  rik_histogram myhistogram[4] = {128,128,128,128};
  qneteventlist mylist(argc,argv);

  while(!mylist.End()){
    int bad = mylist.GetNextEvent();
    if(!bad){  
      // always test for bad = 0, then do something with this event.
      //cout << mylist.CurrentEvent << endl;
      qnetevent mydata = mylist.CurrentEvent;
      if(mydata.Nhits()==3){
	for(int i=0; i<4; i++){
	  if(mydata.Hit(i)){
	    if(mydata.rise[i] >= 0 && mydata.fall[i] >= 0){
	      int diff = mydata.fall[i] - mydata.rise[i];
	      myhistogram[i].increment(diff);
	    }
	  }
	}
      }
      
    }
  }
  for(int i=0;i<4;i++){
    myhistogram[i].setIdnumber(i);
    myhistogram[i].write(stdout);
  }

  return 0;
}
