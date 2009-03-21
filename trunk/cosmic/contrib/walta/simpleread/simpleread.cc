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
