#include "qneteventlist.h"
using namespace std;

int main(int argc, char *argv[]){

  qneteventlist mylist(argc,argv);

  int threehits = 0;
  int fourhits = 0;

  while(!mylist.End()){
    int bad = mylist.GetNextEvent();
    if(!bad){  
      // always test for bad = 0, then do something with this event.
      //      cout << mylist.CurrentEvent << endl;
      //if(mylist.CurrentEvent.Nhits() >= 3)cout << "34 hts " <<  mylist.CurrentEvent.hittag << endl;
      if(mylist.CurrentEvent.hittag >= 14)threehits++;
      if(mylist.CurrentEvent.hittag >= 15)fourhits++;
      
    }
  }

  cout << threehits << " " << fourhits << " " 
       << (float)threehits/(float)fourhits << endl;

  return 0;
}
