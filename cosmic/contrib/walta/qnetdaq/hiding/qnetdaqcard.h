/*
 * code that analyzes qnet data.
 *
 * takes the input as it comes and takes care of the gory details of
 * sorting out what line is well-formed or not.
 *
 * stores completed and incomplete events which can later be extracted
 * with lines like cout << *(mydata.completeevent) << endl;
 *
 * the user only needs to analyze the value of linestatus for useful pieces
 * encoded in enum qnetdaqline.
 *
 * There are many things waiting to be implemented (most unimportant).
 *
 * This code automatically does adjust the absolute time calculation
 * based on the frequency if it is found in the data file or if it is 
 * given by the user.
 *
 */

#include "qnetevent.h"
#include "qnetsingles.h"
using namespace std;

// this enum is all the possible kinds of lines.

class qnetdaqcard{
 public:
  qnetdaqcard(void);
  ~qnetdaqcard(void);

  // save some data internally as I go along.
  // caution, all these members are public.
  qnetevent *buildevent;
  qnetevent *completeevent;

  qnetsingles *singlescount;

  //qnetdaqline linestatus;

  // for more accurate time-matching, save the frequency, if it appears.
  int frequency;
  int tmcdelay;        // not implemented yet.
  
  // save current time here?

  // methods 
  void ReadLine(char *line);
  void Clear(void);

  enum qnetdaqline { lineerror, newevent, dataline, singles, lastsingles,
                   cpldregister, dgline, unknown, allclear };

  qnetdaqline linestatus;

  // also consider if the event->ReadLine returned an error.
  int eventstatus;

};

qnetdaqcard::qnetdaqcard(void){
  buildevent = new qnetevent;
  completeevent = new qnetevent;
  singlescount = new qnetsingles;
  Clear();
  return;
}

qnetdaqcard::~qnetdaqcard(void){
  delete buildevent;
  delete completeevent;
  delete singlescount;
  return;
}

void qnetdaqcard::Clear(void){
  buildevent->Clear();
  completeevent->Clear();
  singlescount->Clear();
  linestatus = unknown;
  frequency = 41666666;
  tmcdelay = 6;
}

void qnetdaqcard::ReadLine(char *line){
  char *linestart = line;
  if(line[0] == '>')linestart = &line[1];

  int length = strlen(linestart);
  //cout << "length " << length << endl;

  //
  // data line
  //
  // lentgh can be 72 or 73, depending on what line ending user has.
  if(length == 73 || length == 72){    // or length == line with no gps.
    int is_newevent = 0;
    // test if this is valid line
    if(QnetEventLineNotValid(linestart)){linestatus = lineerror; return;}
    // test if it is the first line.
    if(QnetEventFirstStringFlag(linestart)){
      qnetevent *tempevent;
      tempevent = completeevent;
      completeevent = buildevent;
      buildevent = tempevent;
      buildevent->Clear();
      // if the former buildevent is not empty, then it really is a new event.
      if(completeevent->nstrings)is_newevent = 1;
    }
    
    eventstatus = buildevent->ReadLine(linestart, frequency);
    
    if(!eventstatus){
      if(is_newevent){linestatus = newevent; return;}
      else {linestatus = dataline; return;}
    }
    else {linestatus = lineerror; return;}
  } // end data line

  //
  // singles counts or register
  //
  else if(linestart[0] == '@'){
    if(linestart[3] == ' '){
      // singles information starts with @00
      int channel = singlescount->ReadLine(linestart);
      // we should give the singles data the most recent timestamp.
      singlescount->FillTime(*buildevent);
      if(channel == 5){linestatus = lastsingles; return;}
      else {linestatus = singles; return;}
    }
    else if(linestart[5] == '='){
      linestatus = cpldregister; return;
    }
  } // end single counts or register

  //
  // Things from DG.
  //
  else if(!strncmp(&linestart[1],"CPLD",4)){
    if(!strncmp(&linestart[6],"freq",4)){
      frequency = atoi(&linestart[12]);
      cout << "frequency " << frequency << endl;
      linestatus =  dgline; return;
    }
  }

  else if(!strncmp(linestart,"WC 06",5)){
    linestatus = allclear; return;
  }

  else {linestatus =  unknown; return;};
}


/*
>DG
 Date+Time: 08/08/03 21:04:18.959
 Status:    A (valid)
 PosFix#:   1
 Latitude:   47:39.2272 N
 Longitude: 122:18.6826 W
 Altitude:  1.003m
 Sats used: 05
 PPS delay: -0125 msec  [5B24-5C19]
 CPLD time: B8B1889A    [last 2: B635C066,B3B9F830]
 CPLD freq: 41666612 Hz [2-sec:  41666613 Hz]
*/
