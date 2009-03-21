/*
 * qnetsingles class
 *
 * to read in, unpack, and transform the scalar counts.
 *
 * it is assumed that you want a singles "rate", so it can save the time
 * but the code that calls methods in this class must give that time.
 *
 * Basically, the user needs to know what the structure of the data file
 * is before this will be useful.
 *
 */

#ifndef QNETSINGLES_H
#define QNETSINGLES_H

#include <cstring>
#include <cstdlib>
#include <ctime>
#include "qnetevent.h"

using namespace std;

class qnetsingles{
 public:
  qnetsingles(void);
  ~qnetsingles(void) {};

  unsigned long counts[6];

  int FillData(char *mystring);
  int FillTime(qnetevent &myqnetdata);
  int FillTime(int day, int sec, int nsec=0);
  int FillTime(time_t in_rawtime);

  void Print(void);

  void Clear(void);

  int daysince2001;
  int seconds;
  int nanoseconds;

};

int qnetsinglesrate(qnetsingles &thefirst, qnetsingles &thelast, double rate[5]);


qnetsingles::qnetsingles(void){
  Clear();
  return;
}

void qnetsingles::Clear(void){
  for(int i=0; i<6; i++)counts[i] = 0;
  seconds = -1;
  daysince2001 = -1;
  nanoseconds = -1;
  return;
}  

int qnetsingles::FillData(char *mystring){
  // Returns -1 if it is an invalid line.
  // Otherwise returns the register it read.  
  // Look for a return value of "5" to indicate a complete read.

  int channel;
  int error;  //Special case.  Return -1 if there is an error.
  int format = 0;  //20 = version 2.0 firmware.  25 = version 2.5 firmware

  //cout << "mystring " << strlen(mystring) <<  " " << mystring << endl;

  // Support two formats.  Multi-line, 13 characters starting with @
  // or single line starting with DS S0=
  //DS
  //@00 000001B6
  //@01 0000017A
  //@02 000001A8
  //@03 000000E1
  //@04 00000001
  //@05 0B0D7767
  //
  // Version 2.5 format
  //DS S0=0029898A S1=0002F31F S2=00000000 S3=00000000 S4=00003C59 S5=D74D0CFE

  //cout << "in qnetsingles ReadLine " << strlen(mystring) << endl;

  if(mystring[0] == '@' && (strlen(mystring) == 13 || strlen(mystring)==14))format = 20;
  else if(mystring[0] == 'D' && mystring[1] == 'S' && mystring[3] == 'S' &&
	  (strlen(mystring) >= 74 || strlen(mystring) <= 77))format=25;

  if(format==20){
    // unpack one line of version 2 format.
    channel = atoi(&mystring[1]);
    if(channel > 6 && channel < 0)return 2;
    counts[channel] = strtoul(&mystring[4],NULL,16);
    return channel;
  }
  else if(format==25){
    // unpack all four version 2.5 format lines all at once.
    counts[0] = strtoul(&mystring[6],NULL,16);
    counts[1] = strtoul(&mystring[18],NULL,16);
    counts[2] = strtoul(&mystring[30],NULL,16);
    counts[3] = strtoul(&mystring[42],NULL,16);
    counts[4] = strtoul(&mystring[54],NULL,16);
    counts[5] = strtoul(&mystring[66],NULL,16);
    return 5;
  }

  return -1;
}

// To do.  Overload FillTime to also accept a valid "ST" line.
/*
int qnetsingles::FillTime(char *mystring){
  // Send in a "ST" line and parse out the time from that.
  // Only accurate to one second right now.
ST 0002 0264 0160 2680 212300 300604 A 06 027BC872 25 0152 002F4B00 0096711F
  if(mystring[0]=='S' && mystring[1]=='T' && strlen(mystring)==77){
    int hhmmss = atoi(mystring[23]);
    int ddmmyy = atoi(mystring[30]);

  }
 return -1;
}
*/

int qnetsingles::FillTime(qnetevent &myqnetdata){
  // the user must call this with a filled qnetdata class.
  // it will extract the seconds and nanoseconds and save it.
  
  if(myqnetdata.seconds == -1)return seconds;

  daysince2001 = QnetDaySince2001(myqnetdata);
  seconds = myqnetdata.seconds;
  nanoseconds = myqnetdata.nanoseconds;
  return seconds;
}

int qnetsingles::FillTime(int day, int sec, int nsec){
  daysince2001 = day;
  seconds = sec;
  nanoseconds = nsec;
  return seconds;
}

int qnetsingles::FillTime(time_t in_rawtime){
  // use the system time to fill in day,sec,nanosec
  tm *ptimestruct;
  tm timestruct;
  ptimestruct = gmtime(&in_rawtime);
  timestruct = *ptimestruct;
  int year = timestruct.tm_year;
  // simple assumptions about what a year might be.
  if(year > 50 && year < 1900) year+=1900;  //year since 1900.
  else if(year <= 50)year += 2000; 

  daysince2001 = ((year - 2001)*365);
  daysince2001 += timestruct.tm_yday;
  if(year > 2004){
    int nleaps = (year - 2001)/4;
    daysince2001 += nleaps;
  }
  seconds = ((timestruct.tm_hour * 60 + timestruct.tm_min)* 60) + timestruct.tm_sec;
  nanoseconds = 0;
  //cout << "year " << year << " " << timestruct.tm_yday << " " 
  //     << daysince2001 << " " << seconds << endl;
  return 0;
}

void qnetsingles::Print(void){
  cout << "counts ";
  for(int i=0; i<6; i++){
    cout << counts[i] << " ";
  }
  cout << " time " << daysince2001 << " "  << seconds << " " << nanoseconds;
  cout << endl;


  return;
}

// an external useful function that will calculate the singles rate
// if you give the beginning and ending values.

int qnetsinglesrate(qnetsingles &thefirst, qnetsingles &thelast, double rate[5], double &time){

  int daydifference = thelast.daysince2001-thefirst.daysince2001;
  time = (double)daydifference * 86400.0 + 
	(double)(thelast.seconds - thefirst.seconds);
  time += (1.0E-9)*(double)(thelast.nanoseconds - thefirst.nanoseconds);
  //time = thelast.seconds - thefirst.seconds;
  //if(time <= 0)time += 3600. * 24.;
  //cout << "rate ";
  for(int i=0; i<5; i++){
    rate[i] = (double)(thelast.counts[i] - thefirst.counts[i]) / time;
    //cout << rate[i] << " ";
  }
  //cout << endl;
  return 0;
}

#endif
