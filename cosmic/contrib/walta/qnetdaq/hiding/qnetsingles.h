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
#include "qnetevent.h"

using namespace std;

class qnetsingles{
 public:
  qnetsingles(void);
  ~qnetsingles(void) {};

  unsigned long counts[5];

  int ReadLine(char *mystring);
  double FillTime(qnetevent &myqnetevent);

  void Print(void);

  void Clear(void);

  double seconds;
};

int qnetsinglesrate(qnetsingles &thefirst, qnetsingles &thelast, double rate[5]);


qnetsingles::qnetsingles(void){
  Clear();
  return;
}

void qnetsingles::Clear(void){
  for(int i=0; i<5; i++)counts[i] = 0;
  seconds = -1.0;
  return;
}  

int qnetsingles::ReadLine(char *mystring){
  // unusual return value!  
  // It returns -1 if there is an error
  // It returns the channel that was filled otherwise.
  int channel;
  int error;
  int length;

  //cout << "mystring " << strlen(mystring) <<  " " << mystring << endl;

  if(mystring[0] != '@')return -1;
  length = strlen(mystring);
  if(length > 13 || length < 12)return -1;

  channel = atoi(&mystring[1]);

  if(channel > 6 && channel < 0)return -1;

  counts[channel] = strtoul(&mystring[4],NULL,16);

  //Print();

  return channel;
}

double qnetsingles::FillTime(qnetevent &myqnetevent){
  // the user must call this with a filled qnetevent class.
  // it will extract the seconds and nanoseconds and save it.
  seconds = (double)myqnetevent.seconds 
    + (double)((double)myqnetevent.nanoseconds * (double)1.0E-9);

  return seconds;
}

//double qnetsingles::FillTime(int seconds, int nanoseconds)
//double qnetsingles::FillTime(some other time format)

void qnetsingles::Print(void){
  cout << "counts ";
  for(int i=0; i<5; i++){
    cout << counts[i] << " ";
  }
  cout << " time " << seconds << endl;


  return;
}

// an external useful function that will calculate the singles rate
// if you give the beginning and ending values.

int qnetsinglesrate(qnetsingles &thefirst, qnetsingles &thelast, double rate[5], double &time){
  time = thelast.seconds - thefirst.seconds;
  if(time <= 0)time += 3600. * 24.;
  //cout << "rate ";
  for(int i=0; i<5; i++){
    rate[i] = (double)(thelast.counts[i] - thefirst.counts[i]) / time;
    //cout << rate[i] << " ";
  }
  //cout << endl;
  return 0;
}

#endif
