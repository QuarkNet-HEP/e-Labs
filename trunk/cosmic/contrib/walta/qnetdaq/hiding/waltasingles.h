/*
 * waltasingles class
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

#ifndef WALTASINGLES_H
#define WALTASINGLES_H

#include <cstring>
#include <cstdlib>
#include "waltadataclass.h"

using namespace std;

class waltasingles{
 public:
  waltasingles(void);
  ~waltasingles(void) {};

  unsigned long counts[5];

  int FillData(char *mystring);
  int FillTime(waltadata &mywaltadata);

  void Print(void);

  void Clear(void);

  int daysince2001;
  int seconds;
  int nanoseconds;


};

int waltasinglesrate(waltasingles &thefirst, waltasingles &thelast, double rate[5]);


waltasingles::waltasingles(void){
  Clear();
  return;
}

void waltasingles::Clear(void){
  for(int i=0; i<5; i++)counts[i] = 0;
  seconds = -1;
  daysince2001 = -1;
  nanoseconds = -1;
  return;
}  

int waltasingles::FillData(char *mystring){
  int channel;
  int error;

  //cout << "mystring " << strlen(mystring) <<  " " << mystring << endl;

  if(mystring[0] != '@')return 1;
  if(strlen(mystring) != 13)return 1;

  channel = atoi(&mystring[1]);

  if(channel > 6 && channel < 0)return 2;

  counts[channel] = strtoul(&mystring[4],NULL,16);

  //Print();

  return 0;
}

int waltasingles::FillTime(waltadata &mywaltadata){
  // the user must call this with a filled waltadata class.
  // it will extract the seconds and nanoseconds and save it.
  
  if(mywaltadata.seconds == -1)return seconds;

  daysince2001 = WaltaDaySince2001(mywaltadata);
  seconds = mywaltadata.seconds;
  nanoseconds = mywaltadata.nanoseconds;
  return seconds;
}

void waltasingles::Print(void){
  cout << "counts ";
  for(int i=0; i<5; i++){
    cout << counts[i] << " ";
  }
  cout << " time " << daysince2001 << " "  << seconds << " " << nanoseconds;
  cout << endl;


  return;
}

// an external useful function that will calculate the singles rate
// if you give the beginning and ending values.

int waltasinglesrate(waltasingles &thefirst, waltasingles &thelast, double rate[5], double &time){

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
