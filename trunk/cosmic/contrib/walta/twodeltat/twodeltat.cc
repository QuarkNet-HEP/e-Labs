#include "qneteventlist.h"
using namespace std;

int main(int argc, char *argv[]){

  qneteventlist mylist(argc,argv);

  while(!mylist.End()){
    int bad = mylist.GetNextEvent();
    if(!bad){  
      // always test for bad = 0, then do something with this event.
      qnetevent mydata = mylist.CurrentEvent;
  
      if(mydata.Nhits() >= 3){
	// find the earliest two rise times.
	int times[4] = {999999,9999999,9999999,999999};
	int channel[4] = {0,1,2,3};  //channel names -- for careful test.
	//int offset[4] = {0,157,1,4};
	//int offset[4] = {157,1,0,0};
        int offset[4] = {0,0,0,0};
	int nrise = 0;
	for(int i=0; i<4; i++){
	  if(mydata.rise[i] >= 0){
	    times[i] = mydata.rise[i] - offset[i];
	    nrise++;
	  }
	}
	
	if(nrise == 3)
	  {
	    // now sort these four.
	    for(int i=0; i<4; i++){
	      for(int j=i+1; j<4; j++){
		if(times[j] < times[i]){
		  int temp = times[j];
		  times[j] = times[i];
		  times[i] = temp;
		}
	      }
	    }
	    //cout << " times " << times[0] << " " << times[1] 
	    // << " " << times[2] << " " << times[3] << endl;
	    
	    //cout << mydata << endl;
	    int diff1 = times[1] - times[0];
	    int diff2 = times[2] - times[1];
            
	    // look to see if 123 behave like 012 for four-fold.
	    // for a kind of careful test.
	    //int diff1 = times[2] - times[1];
            //int diff2 = times[3] - times[2];

	    //cout << times[0] << " " << times[1] << " "
	    //     << times[2] << " " << times[3] << endl;

	    // careful test for systematic effect.
	    // only write this if time[2] corresponds to special channel
	    //int specialchannel = 2;
	    //if(channel[2] == specialchannel)
	    cout << diff1 << " " << diff2 << endl;
	    // << channel[0] << " " << channel[1] << " " << channel[2]
	    // << " last"
	    // << endl;
	  }
	//if(times[1]!= 999999 && times[0] != 999999) 
	//  myhistogram.increment(diff);
      }
    }
  }

  return 0;
}
