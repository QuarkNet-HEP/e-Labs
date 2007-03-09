/*
  This code contains several classes to manage and detect common critical
  daq card failure modes, and alert the user to this problem.

  Right now, all the code is included in the .h file, which is probably
  not the way I really want to do it.

  The list of modes covered by the classes below.

  Problem:  No GPS signal.
  Cause:  GPS unit is bad, cable is bad, or a glitch in the line.
  Detection:      A changes to V  
              OR  GPS timestamp doesn't change  
                  GPS timestamp is absent or garbled.
  What to know:  The data and the internal timing is fine.
                 But no sensible rate information.
                 If I have "V", the data might be fine, but less accurate?


  Problem:   Unusually high rate (singles or coincidence.  
  Cause:     Due to noise or some other problem.
  Detection: Set a sensible upper threshhold,
             something that corresponds to the serial port limit
  What to know:  Near the serial port transmission limit, data is garbled
                 Could fill up the disk
                 Should execute a hard-stop.

*/

#ifndef WALTA_ERRORTRAPS_H
#define WALTA_ERRORTRAPS_H

#include "waltadataclass.h"

class gps_error_detection
{
 public:
  gps_error_detection(void);
  char *message;
  int error;                     // is 1 if num > max, 10 if this repeats.
                                 // allows me to log repeats differently.

 private:
  int max_same;                  // maximum allowed same utc times
  int num_same;                  // current number of same utc times
  double previous_utc;           // need to save the most recent utc
  

  char gps_sameerr_message[64];
  char null_message[16];

 public:
  int test(const waltadata &mydata);
  void reset(void);

};

inline 
gps_error_detection::gps_error_detection(void)
{
  max_same = 40;
  strcpy(gps_sameerr_message,"ERROR: The GPS time stamp is not changing!");
  strcpy(null_message,"no gps problems");
  reset();
}

inline
void gps_error_detection::reset(void)
{
  error = 0;
  num_same = 0;
  previous_utc = -999.0;
  message = null_message;
  return;
}

inline
int gps_error_detection::test(const waltadata &mydata)
{

  // First bit of code, a garbled gps stamp is probably failed by 
  // the waltadataclass.h, not by this routine.

  // Second bit of code, test to see if the utc time fails to change.
  // Set max_same to 40, because the serial port limit is 30 events per second.
  //printf("%f %f\n",previous_utc, mydata.utc);
  if(previous_utc == mydata.utc)
    {
      num_same++;
      // did I already have an error?
      if(error)
	{
	  error = 10;
	  return error;
	}

      // test to see if I have an error yet.
      if(num_same > max_same)
	{
	  message = gps_sameerr_message;
	  //printf("%s\n",message);
	  error = 1;
	  return error;
	}
    }
  else
    {
      // the utc has changed.  No error, reset the counter.
      reset();
      previous_utc = mydata.utc;
    }

  return error;
}

/*
class highrate_error_detection
{
 public:
  highrate_error_detection(void);
  char *message;
  int error;

 private:
  int max_rate;
  int num_same;
  double previous_utc;
  char highrate_message[64];
  char null_message[16];

 public:
  int test(const waltadata &mydata);
  void reset(void);

};
*/


#endif
