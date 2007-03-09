/*
 * qnetevent class version 2.0
 * 
 * works with the new data format (multiple lines per event) as of May 2003
 * implementation of all features of the format is still a work in progress.
 *
 * The main complication with this format is that you now have to pass 
 * multiple strings to the instance of the class in order to completely
 * fill a single event.  You can continue to add raw data strings to the
 * class using the ReadLine method, and it will automatically know what
 * to do.  Or use the qnetdaqcard method which tracks it for you.
 *
 * It is set up so that a code fragment like this inside an eof loop will work.
 *
              // Read a line from the file.
	      in.getline(line,256*4);

	      // the loop here goes like this:
	      // Test the new string to see if it is the start of new event
	      // If yes, then process the previous now-complete event
	      //         and then clear mydata, and then start filling new.
	      // Otherwise, just send the string to mydata.    

	      // first test if this is a first string.
	      if(qnetevent_first_string_flag(line))
		{
		  // probably I want to reject the zeroth event.
		  cout << "Yes, it is first string in event!" << endl;

		  // otherwise do any analysis things on complete event here.
		  cout << mydata << endl;

		  // increment a count of events that have passed to here.
		  evnum++;

		  // Save or clear the complete event to start a new one.
		  cout << "And then I should save it, clear it, or start new" 
		       << endl;
		  mydata.clear();

		}

	      // now send this data string to be processed.
	      error = mydata.ReadLine(line); *

	      // and finally, test for the error.
 *
 */

/*
 *  Error flags from event reconstruction -- format.
 *  Four bytes:  upper uppermid lowermid lower 
 *  upper  ==  only the most upper bit shows a critical, pathalogical error.
 *  uppermid == errors in reconstructing the absolute time from gps
 *  lowermid == errors in reconstructing multi-line events
 *  lower  ==  the error flags passed literally from the raw data.
 *
 *  Within these categories, here are the errors:
 */

#ifndef QNETEVENT_20_H
#define QNETEVENT_20_H

#include <iostream>
#include <cstring>
#include <cstdlib>

using namespace std;

//#define MAXSTRINGS 2048

//#define DEBUG 1

int QnetEventFirstStringFlag(char *mystring);
int QnetEventLineNotValid(char *mystring);

class qnetevent{
public:
  // constructor and destructor
  qnetevent(){ Clear(); };
  ~qnetevent() {};

  // I intend this class to be primarily focused on the data.
  // Could be dangerous, but make all the data public.
  // Make sure you don't do anything silly like mydata.hittag = something
  // in your code because it will overwrite the data entries.

  int hittag;
  unsigned int triggercount;   // 32 bits ... could be unsigned int 
  int rise[4];
  int fall[4];
  int lastrise[4];
  int lastfall[4];
  unsigned int oneppscounter;  // 32 bits ... could be unsigned int
  double utc;
  int date;                    // in yyyymmdd format, not raw format.
  char satellitequality;
  int  numsatellites;
  int  gpserror;
  int  oneppserror;
  int  nstrings;
  // calculated data quantities
  int  numrise[4];    // tentatively track quantity, not values of
  int  numfall[4];    // multiple rise/fall edges.
  //double dseconds;     // seconds since midnight.
  int seconds;
  int nanoseconds;
  int errorflags;    // to track potential reconstruction errors
  int nogps;


  
  // Finally, these are some public methods for filling the data.
  // The main one is to fill it from a string.
  // Also I will want to include ways of copying it.

  // Fill the data with a single string.  Call this multiple times.
  int ReadLine(char* mystring, int frequency=41666666, int delay=6);

  // In case you want to ignore the (absent?) gps data, use this.
  // ToDo:  fix this so that it is correct again.
  int ReadLineShort(char *mystring);

  // You might need to call clear manually if you reuse an instance of this 
  // class, for example, when you have completed one event and start another.
  void Clear();

  // Utility functions for the user.
  int Nhits();  // returns the number of hits in this event (1 to 4)
  int Hit(int channel);  // returns 1 if channel is flagged as a hit.

  // useful but not complete printout of the event.
  friend ostream &operator<<(ostream &stream, qnetevent mydata);

  // produces a minimal space-delimited output for a spreadsheet/text cvs
  void WriteSpreadsheet(ostream &stream);
  void WriteSpreadsheetHeader(ostream &stream);

  // returns error, but pass three int variables to be filled.
  // this is soon to be turned into data members because it is used so often.
  int GPStime(int &iniseconds, int &innanoseconds, int frequency=41666666, int delay=6);

  //I think the subtraction operator only makes sense for absolute time.
  //friend double &operator-(qnetevent left, qnetevent right);

};


int qnetevent::GPStime(int &inseconds, int &innanoseconds, int frequency, int delay)
{
  // This method gives an approximate absolute time given the information
  // contained only in the event string.

  // For a better calculation, including full error correction,
  // you should work from a file that has already been prepared to correct
  // for the gps glitches.

  if(nogps)return 0;

  // so I don't lose precision on 32 bit machines, work with integers,
  // and split the seconds since midnight from the nanoseconds from clock.
  int error = 0;

  // calculate the utc corresponding to the 1pps pulse.
  // the 0.5 plus the truncation will do the rounding in this case.
  int iutc = (int)utc;

  double futc = utc - (double)iutc;  //the decimal fraction.
  int hours = (iutc / 10000);
  int minutes = (iutc / 100) - hours * 100;
  int tempseconds = iutc - hours * 10000 - minutes * 100;
  inseconds = tempseconds + minutes * 60 + hours * 3600;
  double dseconds = inseconds + futc + (double)oneppserror * 0.001;

  // now replace inseconds above with the 1pps pulse correction 
  // and use double to integer truncation, and the extra 0.5 to do rounding
  inseconds = (int)(dseconds + 0.5);
  
  // check for error.  The rounding above should be less than 200 ns or so.
  double utcdiff = dseconds - (double)inseconds;
  if(utcdiff < 0)utcdiff *= -1.0;
  if(utcdiff > 0.200)error = 1;    // but continue the calculation anyway.
  

  // calculate the number of nanoseconds since the 1pps pulse.
  unsigned int clockticks = 0;
  unsigned int delayticks = 0;
  int standardonepps = 41666666; // should be less than 1 / 24ns = 41666666.

  // ordinary case
  clockticks = triggercount - oneppscounter;
  // delayed case, oneppscounter is after triggercount
  delayticks = oneppscounter - triggercount;

  // choose whichever is less.
  if(delayticks < clockticks){
    clockticks = delayticks;
    // in the delay case, I should borrow one from seconds.
    inseconds -= 1;

    // now clockticks should be less than onepps, but because of delays,
    // this might not be true.  See the confusion matrix below.
    
    // I expect the difference between onepps pulses to be about 41666666
    // In the 32 bit counter, there are about 67 of these seconds.
    
    // I can anticipate that the onepps will never be ahead by more than 10.
    // so I have the following five cases to identify:
    //   triggercount value      oneppscounter value
    //       middle           >         middle        = normal
    //       middle           <         middle        = readout delay
    //         low                       high         = 32 bit rollover
    //         high                      low          = delay and rollover
    //       middle           <<        middle        = pathalogical
    //       middle           >>        middle        = pathalogical
    //    away from low and high, I expect >> to mean 5 seconds or so.
        
    unsigned int offset = (int)(clockticks / frequency);

    // test the offset to see if it is less than 6 * seconds
    // depending on the baudrate, 6 seconds delay probably indicates a
    // data rate that is much too high and fifo full data corruption
    // or grossly invalid gps information.
    
    clockticks = frequency - (clockticks - offset*frequency);
    inseconds -= offset;
    
    if(offset > 5){
      // this is the pathalogical case -- almost certainly invalid gps.
      error = offset;
    }    
  }
  else { 
    // the regular case could still have errors!
    // I measure that reasonable values are never much more than 1.0
    unsigned int offset = (int)(clockticks / frequency);
    if(offset > 0){
      inseconds += offset;
      clockticks -= frequency * offset;
      if(offset > 2){
	error = offset;
      }
    }
  }
       
  if(0)
  cout << "clockticks " << clockticks << " " 
       << triggercount << " " << oneppscounter << " " << error << endl;

  // this precision is fine on 32 bit machines IF
  // triggercount and oneppscounter are physically reaonsable.
  
  dseconds = (double)inseconds;
  innanoseconds = clockticks * 24;
  //if(error < 2)
  //seconds += (double)nanoseconds * 1.0E-9;
  
  return error;
}


void qnetevent::Clear(){
  hittag = 0;
  triggercount = 0;
  for(int i = 0; i < 4; i++)
    {
      rise[i] = -1;
      fall[i] = -1;
      numrise[i] = 0;
      numfall[i] = 0;
    }
  oneppscounter = 0;
  utc = 0.0;
  date = 0;
  satellitequality = '0';
  numsatellites = 0;
  gpserror = 0;
  oneppserror = 0;
  nstrings = 0;
  //dseconds = -1.0;
  seconds = -1;
  nanoseconds = -1;
  errorflags = 0;
  nogps = 0;
  return;
}

inline int qnetevent::ReadLine(char *mystring, int frequency, int delay){
  // This method takes a string as an input,
  // breaks it out into components
  // and fills all the data elements from it.
  // It returns an error if the input string was NOT added to the event.


  //TODO I might prefer to notice gps valid or not, and fill all but gps.
  //     then return one kind of error saying gps not valid.
  //     and let the calling program decide what to reject or not.

  int error = 0;
  int stringlength = 0;
  int first_string_flag = 0;
  
  // The strtok function messes with string pointers.  Make a safe copy.
  char tempstring[80];

  // This tests whether mystring is a valid data string.
  error = QnetEventLineNotValid(mystring);
  if(error) return error;


  // If the string was valid except that it started with a '>' parse it.
  if(mystring[0] == '>'){
    strcpy(tempstring,&mystring[1]);
    //strcpy(mystring,tempstring);
  }
  else strcpy(tempstring,mystring);

  // ToDo  real error detection will require comparison with the previous
  // ToDo      string in the data file!

  // the first data word always has a 1 in a particular location.
  first_string_flag = QnetEventFirstStringFlag(tempstring);

  if(!nstrings && first_string_flag){
    // always clear data when I try to fill for first time
    // strictly speaking, its redundent because it has to be done externally!
    Clear();
  }
  // If I passed a string without this flag while nstrings=0, it is an error.
  else if(!nstrings && !first_string_flag){
    if(0){
      // For some reason this is very common.
      cerr << "qnetevent::ReadLine: "
	   << "First string does not have first_string_flag." << endl;
    }
    error = 4;
  }
  else if(nstrings && first_string_flag){
    cerr << "qnetevent::ReadLine: "
	 << "first_string_flag passed when not first string." << endl;
    error = 5;
  }
  // else all is good.
  // If the string was valid but with no gps, recognize this.
  if(strlen(mystring)==58 || strlen(mystring)==59)nogps = 1;
  else nogps = 0;


  // if error = 4, parse the line but return the error code.
  // WARNING I think this behavior causes no conflict with normal use,
  // and it allows the user to unpack a string regardless of the event
  // it belongs to.  The user should carefully clear the data afterwards.
  if(error && error != 4)return error;
  if(error == 4)first_string_flag=1;
  
  // 
  // Now I know the string is good.  Unpack the data in it.
  //

  
  // See a c++ book for how strtok (tokenize string) 
  // and strtol or strtoul (string to unsigned long) work.
  // the prototype for strtoul(*in, **out, radixbase)
  // so either define char *dummy and char tempstring[256]
  // and use strtol(tempstring,&dummy,16) or substitute NULL for dummy.


  int temp_int = 0;
  double temp_double = 0.0;
  unsigned int temp_unsignedint = 0;
  unsigned int this_triggercount = 0;

  temp_unsignedint = (unsigned int) strtoul(strtok(tempstring," "),NULL,16);
  // remember this value so I can calculate the timing offsets.
  this_triggercount = temp_unsignedint;
  // save the triggercount only for the first line in the event.
  if(first_string_flag)triggercount = temp_unsignedint;

  // if there are multiple strings, I need to remember what the cpld time
  // for the first one is, so that I can add 32 ticks for later strings.
  int triggerdifference = 0;
  if(triggercount <= this_triggercount) 
    triggerdifference = (int) (this_triggercount - triggercount);
  else triggerdifference = (int) (0xffffffff - this_triggercount + triggercount);
    
  // need to trap some errors due to nonsense triggerdifferences?
  // or the array is being overwritten?  some glitch is being passed...
  if(triggerdifference > 2048){
    error = 7;
    return error;
  }

  // I have already tested the string length above, so this is a safe copy.
  //strcpy(rawstring[nstrings],tempstring);
  nstrings++;

  for(int i=0; i<4; i++)
    {   
      int temp_rise = (int) strtol(strtok(NULL," "),NULL,16);
      int temp_fall = (int) strtol(strtok(NULL," "),NULL,16);
      
      // these values have the following structure:
      // [notused][notused][edgetag][time][time][time][time][time]

      // for simple use, increment hittag on rise and/or falling edge.
      // this is conveniently the way the old format worked,
      // but might not be what we really, really want going forward.
      if(temp_rise & 32)hittag = hittag | (1 << i) ;
      if(temp_fall & 32)hittag = hittag | (1 << i) ;

      // only fill these fields if hittag was on.  Save only the first value.
      // right now this is insufficient, still there are ambiguities.
      // this should be rethought to utilize the multi-hit in the data.
      if(temp_rise & 32){
	lastrise[i] = (temp_rise & 31) + 32 * triggerdifference;
	if(rise[i] < 0)rise[i] = lastrise[i];
      }
      if(temp_fall & 32){
	lastfall[i] = (temp_fall & 31) + 32 * triggerdifference;
	if(fall[i] < 0)fall[i] = lastfall[i];
      }
     
    }


  if(!nogps){   //the following make no sense if there is no gps.

  // read in the onepps counter, but only save the first one.
  temp_unsignedint = (unsigned int) strtoul(strtok(NULL," "),NULL,16);
  if(first_string_flag)oneppscounter = temp_unsignedint;

  temp_double = strtod(strtok(NULL," "),NULL);
  if(first_string_flag)utc = temp_double;
  temp_int = strtol(strtok(NULL," "),NULL,10);
  if(first_string_flag){//date = QnetFlipDate(temp_int);
    if(temp_int==0)date = 0;
    else{
      int day=temp_int/10000;
      int month=(temp_int - day*10000)/100;
      int year=(temp_int - day*10000 - month*100 + 2000);
      date = year*10000+month*100+day;
    }
  }

  char *temp = strtok(NULL," ");
  satellitequality = temp[0];

  temp_int = (int)strtol(strtok(NULL," "),NULL,10);
  if(first_string_flag)numsatellites = temp_int;

  // For now this is not protected by first_string_flag!
  gpserror = (int)strtol(strtok(NULL," "),NULL,16);

  temp_int = (int)strtol(strtok(NULL," "),NULL,10);
  if(first_string_flag)oneppserror = temp_int;

  // Now that I am at this point, if this is the first string,
  // I can calculate the approximate absolute time.
  if(first_string_flag){
    // swallow this error here for now.  How will the user know of problem?
    GPStime(seconds, nanoseconds, frequency, delay);
    //dseconds = (double)seconds + (double)nanoseconds * 1.0E-9;
  }
  }

  return error;
}


inline
int qnetevent::Nhits(void){
  // Analyzes hittag to extract the number of channels with hits.

  int somehits = 0;
  if(hittag & 1)somehits++;
  if(hittag & 2)somehits++;
  if(hittag & 4)somehits++;
  if(hittag & 8)somehits++;
  return somehits;
}

inline
int qnetevent::Hit(int channel){
  // Returns 1 if channel was flagged as hit, returns 0 if it wasn't.
  if(hittag & (1 << channel))return 1;
  return 0;
}


void qnetevent::WriteSpreadsheetHeader(ostream &stream){
  stream << "hits pattern hittag nstrings r0 f0 r1 f1 r2 f2 r3 f3 trig sec nsec date";
}

void qnetevent::WriteSpreadsheet(ostream &stream){
  // call this with just qnetevent.WriteSpreadsheet(cout); cout << endl;
  stream << Nhits() << " ";
  for(int i=0; i<4; i++)stream << Hit(i);
  stream << " " << hittag << " ";
  stream << nstrings << " ";

  for(int i=0; i<4; i++){
    stream << rise[i] << " ";
    stream << fall[i] << " ";
  }

  cout << triggercount;
  cout << " " << seconds << " " << nanoseconds;
 
  int year = date/10000;
  int month = (date - year*10000)/100;
  int day = (date - year*10000 - month*100);

  //int day=date/10000;
  //int month=(date - day*10000)/100;
  //int year=(date - day*10000 - month*100 + 2000);


  cout << " " << utc <<  " " 
       << day << "-" << month << "-" << year;
  
  return;    

}

ostream &operator<<(ostream &stream, qnetevent mydata){
  // This is my first guess at the fundamental, useful, human readable
  // text output for the raw data.  Some other folks might be able to read
  // the raw text files in hex, but it makes me crosseyed.

  stream << "hits " << mydata.Nhits() << " ";
  for(int i=0; i<4; i++)stream << mydata.Hit(i);
  //stream << " hittag ";
  //stream.width(2);
  //stream << mydata.hittag << " ";

  for(int i=0; i<4; i++){
    stream << "  c" << i << " " ;
    stream.width(4);
    stream << mydata.rise[i];
    stream << " ";
    stream.width(4);
    stream << mydata.fall[i];
  }

  stream << "  trig ";
  stream.width(10);
  stream << mydata.triggercount;
  stream << "  gps ";
    stream.width(5);
  stream << mydata.seconds << " ";
    stream.width(9);
  stream << mydata.nanoseconds << " " ;
  // reorder the date string to yyyymmdd so it can be sorted.
  stream << " date " << mydata.date;
  //stream << ((2000 + mydata.date % 100)*10000 +
  //     ((int)((mydata.date % 10000)/100))*100 +
  //     (int)(mydata.date / 10000));


  //stream << " date " << mydata.date;
  return stream;    
}


int QnetEventFirstStringFlag(char *mystring)
{
  // useful utility function.  Test to see if the string contains
  // the first_string_flag meaning that it is first string in a sequence
  // for a single walta daq event.

  // Be careful, this has not test for a valid string!
  // if that is important, do that before calling this routine.

  // the flag is encoded as the highest order bit in the first hex digit
  // in the first tmc word (2nd word overall).  Character 9.

  int first_string_flag = 0;
  char test_this_hexdigit = 0;
  if(mystring[0] == '>')test_this_hexdigit = mystring[10];
  else test_this_hexdigit = mystring[9];

  // digits 0-9 are ascii 48-57, letters A-F are ascii 65-70.
  if(test_this_hexdigit == '8' || test_this_hexdigit == '9'
     || (test_this_hexdigit >= 'A' && test_this_hexdigit <= 'F')
     || (test_this_hexdigit >= 'a' && test_this_hexdigit <= 'f'))
    first_string_flag = 1;

  return first_string_flag;
}

int QnetEventLineNotValid(char *mystring){
  // This section detects badly formed strings and rejects them.
  int stringlength = 0;
  int testlength = 71;
  int error = 0;
  int nogps = 0;

  // Simple test, is the string the correct length?
  // old version was 73 + garbling.  New version is 71 + garbled.
  stringlength = strlen(mystring);
  if(stringlength == 58 || stringlength == 59)
    {
      nogps = 1;
      testlength = 57;
    }
  else if(stringlength < 71 || stringlength > 79)
    {
      error = 1;
      return error;
    }

  // Does the string contain nothing but hex digits, 'V' '+' '-' '.' or space 
  // If there is something extra, then things got garbled.
  for(int i=0; i<testlength; i++)
    {
      if(!isxdigit(mystring[i]))
	{
	  if( mystring[i] != 'V' && mystring[i] != '+'
	      && mystring[i] != '-' && mystring[i] != ' '
	      && mystring[i] != '.' && mystring[i] != '>')error = 2;
	  if(error)return error;
	}
    }

  // Test to see if the pattern of spaces is exactly correct.
  /* A perfectly formed string.

  old version
6 0534258 35 41 DA F1 D2 DB 3B 3E 003DA199 224401.221 210103 A 06 8 -0420
  int spaces[16] = {1,9,12,15,18,21,24,27,30,33,42,53,60,62,65,67};

  new version
3E1691A5 01 2D 01 2C 00 01 00 01 5419E1FE 175935.133 040603 V 00 2 -0183
  int spaces[15] = {8,11,14,17,20,23,26,29,32,41,52,59,61,64,66};

  nogps version
0330B2A8 80 01 2C 36 00 01 00 01 00000000 0 0 0 0 8 +0000
  int spaces[15] = {8,11,14,17,20,23,26,29,32,41,43,45,47,49,51};

  */
  if(nogps){
    int spaces[15] = {8,11,14,17,20,23,26,29,32,41,43,45,47,49,51};
    for(int i=0; i<15; i++){
      if(mystring[spaces[i]] != ' ')error = 3;
    }
  }
  else {
    int spaces[15] = {8,11,14,17,20,23,26,29,32,41,52,59,61,64,66};
    for(int i=0; i<15; i++){
      if(mystring[spaces[i]] != ' ')error = 3;
    }
    // trap one thing that I hope will go away.
    // The line might start with a '>' but still be valid!
    if(error == 3 && mystring[0] == '>'){
      for(int i=0; i<15; i++){
	if(mystring[(spaces[i] + 1)] != ' ')error = 4;
      }
      if(error != 4)error = 0;
      else error = 3;
    }
  }

  return error;
}

int QnetDaySince2001(qnetevent &a);
int QnetFlipDate(const int date);
double QnetEventTimeDifference(qnetevent &a, qnetevent &b);
double QnetEventTimeDifference(qnetevent &a, qnetevent &b){
  // compute the time difference between pairs of events.
  // computes b - a  and does not test for errors!
  int datedifference;
  double timedifference;
  int oneday = 86400;

  datedifference = QnetDaySince2001(b) - QnetDaySince2001(a);
    //b.date - a.date;
  
  timedifference = (double)(b.seconds - a.seconds);
  timedifference += (double)(b.nanoseconds - a.nanoseconds)*(1.0E-9);
  if(datedifference)timedifference += (double)(datedifference * oneday);
  
  return timedifference;
}

int QnetDaySince2001(qnetevent &a){
  // convert the internal date format ddmmyyyy to days since January 2001.
  // probably better to get a julian date routine.
  // needed for correct decimal date comparisons.

  int dayof[13] = {0,31,59,90,120,151,181,212,243,273,304,334,365};
  int dayofyear = 0;
  
  int year=a.date/10000;
  int month=(a.date - year*10000)/100;
  int day=(a.date - year*10000 - month*100);
  
  int leapyearnow=0;
  int leapyearpast=0;
  
  if(!(year%4) && (month >= 3))leapyearnow = 1;

  if(month <= 0){cout << "invalid month " << a.date << endl; return -1;}

  dayofyear = dayof[month - 1] + day + leapyearnow;
  
  //2004 gives 0, 2005 gives 1, 2008 gives 1, 2009 gives 2.
  leapyearpast = (int)(year-2001)/4;
  
  int daysince2001 = (year - 2001)*365 + dayofyear + leapyearpast;

  return daysince2001;
}
  
int QnetFlipDate(const int date){
  // DAQ card date is ddmmyy, turn it into yyyymmdd (alphabetical).
  if(date==0)return 0;
  int day=date/10000;
  int month=(date - day*10000)/100;
  int year=(date - day*10000 - month*100 + 2000);
  return year*10000+month*100+day;
}
#endif

/* Documentation


  Notes from Hans about the microcode.
  See particularly how to use the +0nnn value to correct the 1pps pulse.
  Look for the word ROUND
Date: Mon, 4 Nov 2002 18:23:57 -0800 (PST)
From: Hans-Gerd Berns <berns@phys.washington.edu>
To: Terry Kiper <kiper@fnal.gov>, Steve Becker <sbecker@cse.unl.edu>,
     Graham Wheel <gmwheel@u.washington.edu>
Cc: Dan Claes <dclaes@unlhep.unl.edu>,
     Vicky Mariupolskaya <mariupolskaya@yahoo.com>,
     Greg Snow <gsnow@unlhep.unl.edu>, Thomas Jordan <jordant@fnal.gov>,
     Sten Hansen <hansen@fnal.gov>, Jeff Wilkes <wilkes@phys.washington.edu>
Subject: MSP430 code
Hi Terry, Steve, Graham, and those who are interested.

I played a little with the MSP430 code, and made the following changes
(summary) below.  I hope I didn't get too carried away.
The files are at
http://www.phys.washington.edu/~berns/WALTA/Qnet2/MSP430/
or in a compressed folder
http://www.phys.washington.edu/~berns/WALTA/Qnet2/MSP430/Qnet2_HGB_20021104.zip

Summary:
 - Changed interrupt edge select for P1.1 to rising edge
 - Changed the order for P1.1 and P1.2 interrupt processing
    (1PPS before trigger now)
 - Startup with NA=1 (GPS date/time/status enabled) as default
 - Modified 1PPS and GPS data readout
 - Added 'DG' (Display GPS data) command
 - Fixed 'CE' command and trigger interrupt hold while UART0 sends data
    (but I'm puzzled why the original code didn't work)
 - Changed 'GP' from RMC=5sec to RMC=1sec
 - Added 17th output number: 1PPS vs GPS data msec delay count
 - Modified/Added flags to 16th output number (4-bit hex):
   - Bit0 = 1PPS interrupt (p1.1) pending
   - Bit1 = Trigger interrupt (p1.2) pending
   - Bit2 = GPS data could be corrupted (write in progress while readout)
   - Bit3 = current or last 1PPS rate not within 41666666 +/-50 clock ticks

The main changes are the last 2 items.  Example of a data line:
9 B57E9F3 E0 FF 00 00 00 00 31 4E 5ABF4F8E 014455.032 051102 A 05 0 +0810

The 16th column is now a hex number (0...F), where the 4 bits have a
separate meaning.  Here, 0 = no warnings, data ok.
A warning flag example:
8 = Bit3 is set = 1PPS glitch detected, current 1PPS count (column 11) is
    not within the predicted value based on the last 2 1PPS numbers

The 17th column is a rough measurement (milliseconds) of the time between
the last GPS serial data interrupt start and the last 1PPS pulse rising
edge.  [I used the 0.512msec Watchdog counter as a stop watch for the
delay measurement).  In the example above, +0810 means, the 1PPS pulse
(with CPLD time 0x5ABF4F8E) is approx. 810 msec ahead of the last GPS
serial data (UART1 RX) with date/time 11/05/2002 01:44:55.032 (UTC).
With this number I hope to solve the asynchronisation problem:
Add the delay time to the hhmmss.mmm UTC number, round it to the nearest
integer (should be within ~150-200 msec) and you'll get the actual UTC
time referring to the 1PPS CPLD number.  In this example:
ROUND(01:44:55.032 + 0.810) = 01:44:56

I was hoping to develop an algorithm to automatically detect and correct
1PPS / GPS data glitches (the ones mentioned in my report from last year
http://www.phys.washington.edu/~berns/WALTA/GPS/), but I'm not advanced
enough with assembly code to attempt digging into floating point
programming.  Also, the MSP430 has its limits (RAM, processing speed),
too, so I think it's better to do this part on a PC (offline).

As mentioned in the summary above, I introduced command 'DG' (Display GPS
data).  Here's an example:
 Date+Time: 05/11/02 02:09:03.950
 Status:    A (valid)
 PosFix#:   1
 Latitude:   47:39.2247 N
 Longitude: 122:18.6514 W
 Altitude:  39.4m
 Sats used: 07
 PPS delay: -0145 msec  [91EC-9308]
 CPLD time: 69604DDE    [last 2: 66E48585,6468BD2C]
 CPLD freq: 41666649 Hz [2-sec:  41666649 Hz]

There are still some stability problems with the code that I haven't been
able to figure out yet:
- The interrupt disable/reenable for port 1 (e.g. trigger P1.2) doesn't
  seem to work the way it's supposed to according to the MSP430 User's
  Guide.  That was one of the causes for marbled data lines when triggers
  were very close together.  I kinda bypassed this by checking for
  Interrupt Enable bits (&P1IE) and the Interrupt mode (IntrMode) in
  the PORT1_VECT section.
- Occasionally (~1/day at my test bench here in Seattle) both UART RX's
  seem to freeze up, and then neither the GPS data is updated nor can the
  user execute any commands.  Trigger interrupts continue fine, but
  with frozen GPS date/time/status.  Only hardware reset helps.
  I'm not sure if that problem was happening before my changes or if I
  wasn't carefully enough about the Stack, RAM, or interrupt order usage.
  Maybe it's related to the port 1 interrupt item above?

Have fun playing with the code.
Any suggestions, help and comments welcome.
Cheers.

*/
