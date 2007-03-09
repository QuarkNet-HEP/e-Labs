/* 
   Version 2.31  Thu 27 Jan 2005

   Functionality:
     Allows user to input the most basic settings.
     Takes data, saving a faithful transcript of what the card sends.
     Optionally calculates singles rates and writes it to a log file,
       which is useful for checking the status online.
     v 2.1 supports firmware 29 and above, and implements a read timeout.
     v 2.2 supports DAQ with disconnected gps and firmware 29.
     v 2.3 supports text output for efficiency, singles, and nooutput

*/

#include <string.h>
#include <fcntl.h>    // needed to open serial port
#include <termios.h>  // needed for serial port access
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>  //needed for write, read, and maybe usleep
#include <time.h>
#include <sys/time.h>
#define DEBUG 0  // 1 prints regular stuff to stdout, 2 prints real debug stuff.

#include "qnetevent.h"
#include "daqfile.h"
#include "qnetsingles.h"
//#include "errortraps.h"

/* change this definition for the correct port */
#define MODEMDEVICE "/dev/ttyS0"
#define _POSIX_SOURCE 1 /* POSIX compliant source */

#define FALSE 0
#define TRUE 1


//#define SAVETIMESTAMP

#define MAXFILES 9999

#define BUFSIZE 512

volatile int MY_STOP_LOOP=FALSE; 

//for a careful look, shows \r and \d
//void showallstring(char *mystring, int inputlength = -1);

int setup_terminal(int fd, int baudrate);
void restore_terminal(int fd);

int utc_difference(double a, double b);
char makehex(int myint);

/* global variables for subroutines */
struct termios oldtio, newtio;


int main(int argc, char *argv[])
{
  time_t rawtime;
  time_t begin_file_time;
  time_t prev_singles_time;
  time_t current_singles_time;
  FILE *fpdataout;
  FILE *fplogout;
  int files;
  int fd = 0, res;
  // the Timeout is used so I can go in and trigger DS even for low rates.
  // If there is no serial activity within Timeout, do tests, then reloop.
  int maxfd;  // for Timeout
  fd_set readfs;  // for Timeout
  struct timeval BaseTimeout; // for Timeout
  struct timeval Timeout; // for Timeout
  BaseTimeout.tv_usec = 200000;  // wait 0.2 seconds = 200000 usec
  BaseTimeout.tv_sec = 0;

  char buf[BUFSIZE];
  char tempbuf[BUFSIZE];
  int nstrings = 0;
  int numwrite = 0;
  int error = 0;
  int events_since_firstdata = 0;
  int numreads_since_firstdata = 0;
  int prev_singles_events = 0;

  int hittag_histogram[16];
  int coincidence_histogram[5];

  char writestring[24][32];
  char writenumchars[24];
  for(int i=0;i<32;i++){
    for(int j=0; j<24; j++){
      writestring[j][0] = 0;
      writenumchars[j] = 0;
    }
  }


  //  gps_error_detection mygpserror;

  // TODO
  // Need to add some kind of lock, so that I don't accidentally run
  // this program on two machines at once.

  if(argc < 2)
    {
      printf("usage: %s --name=filename --num=filenumber\n",argv[0]);
      return 1;
    }

  // user _must_ give filename and start number.
  // command line options that override default behavior.
  // --coincidence=2  changes coincidence level (1 to 4)
  // --events=5000    one data file will have nevents in it.
  // --seconds=20000  one data file will run for 20000 seconds (not nevents)
  // --singles_events=blah
  // --singles_seconds=blah
  // --files=9999     program will make this many files (0 = infinite)

  int coincidence = 2;
  int timeout_nevents = 5000;
  int timeout_nseconds = 20000;
  int readsingles_nevents = 0;
  int readsingles_nseconds = 60;
  int maxfiles = 999;
  int input_file_number = 0;
  int baudrate = 38400;
  int gatewidth = 10;
  int tmcdelay = 6;
  int loglevel = 0;
  int outlevel = 1;
  int nogps = 0;
  int firmware = 32;
  int setuponly = 0;
  int efficiency = 0;
  int printrate = 0;
  int safeds = 0;
  char filename[256];
  for(int i=0; i<256;i++)filename[i]=0;
  
  for(int i=1; i<argc; i++){
    if(argv[i][0] == '-' && argv[i][1] == '-'){
      if(!strncmp(&argv[i][2],"coincidence",11))
	coincidence = atoi(&argv[i][14]);
      if(!strncmp(&argv[i][2],"events",6))
	timeout_nevents = atoi(&argv[i][9]);
      if(!strncmp(&argv[i][2],"seconds",7))
	timeout_nseconds = atoi(&argv[i][10]);
      if(!strncmp(&argv[i][2],"singles_events",14)){
	readsingles_nevents = atoi(&argv[i][17]);
	readsingles_nseconds = 0;  // if user requests, disable nseconds.
      }
      if(!strncmp(&argv[i][2],"singles_seconds",15))
	readsingles_nseconds = atoi(&argv[i][18]);
      if(!strncmp(&argv[i][2],"files",5))
	maxfiles = atoi(&argv[i][8]);
      if(!strncmp(&argv[i][2],"name",4))
	strcpy(filename,&argv[i][7]);
      if(!strncmp(&argv[i][2],"num",3))
	input_file_number = atoi(&argv[i][6]);
      if(!strncmp(&argv[i][2],"baudrate",8))
	baudrate = atoi(&argv[i][11]);
      if(!strncmp(&argv[i][2],"gatewidth",9))
	gatewidth = atoi(&argv[i][12]);
      if(!strncmp(&argv[i][2],"tmcdelay",8))
	tmcdelay = atoi(&argv[i][11]);
      if(!strncmp(&argv[i][2],"loglevel",8))
	loglevel = atoi(&argv[i][11]);
      if(!strncmp(&argv[i][2],"nogps",5))
	nogps = 1;
      if(!strncmp(&argv[i][2],"firmware",8)){
        firmware = atoi(&argv[i][11]);
	if(firmware <= 23)safeds = 1;
      }
      if(!strncmp(&argv[i][2],"setuponly",9))
        setuponly = 1;
      if(!strncmp(&argv[i][2],"efficiency",10))
        efficiency = 1;
      if(!strncmp(&argv[i][2],"printrate",9))
        printrate = 1;
      if(!strncmp(&argv[i][2],"safeds",6))
        safeds = 1;
      if(!strncmp(&argv[i][2],"nooutput",8))
        outlevel = 0;
    }
    else {
      fprintf(stderr,"usage: %s --name=filename --num=filenum\n",argv[0]);
      fprintf(stderr,"options: --coincidence=%d --events=%d --seconds=%d --files=%d\n",coincidence,timeout_nevents,timeout_nseconds,maxfiles);
      return 1;
    }
  }
	
  // test for unreasonable input values.
  if(coincidence < 0 || coincidence > 4){
    fprintf(stderr,"%s: unreasonable coincidence level %d\n",coincidence);
    return 1;
  }
	
  if(input_file_number < 0){
    fprintf(stderr,"usage: %s --name=filename --num=filenum\n",argv[0]);
    return 1;
  }  
 
  if(!strlen(filename)){
    fprintf(stderr,"usage: %s --name=filename --num=filenum\n",argv[0]);
    return 1;
  }   

  //printf("input_file_number %d\n",input_file_number);
  daqfile datafile("data/",filename,".txt",input_file_number);
  daqfile logfile("log/",filename,".log",input_file_number);

  for(int i=0;i<BUFSIZE;i++){
    buf[i]=0; tempbuf[i]=0;
  }
  
  qnetevent myevent;

  // Use this one to store the current event.
  qnetevent currentevent;
  qnetsingles currentsingles;

  // save the first real event in each file so that I can count
  // how many events have been read
  qnetevent firstevent;
  qnetsingles firstsingles;

  // I also want to periodically read out the singles rate information
  // And I think I want to do this more frequently than every event.
  qnetevent timemarkevent;
  qnetsingles timemarksingles;

  fd = setup_terminal(fd,baudrate);
  maxfd = fd + 1;  //for Timeout
  fflush(stdout);
  
  for(files = 0; files < maxfiles; files++){
    int bad_event_error = 0;
    int timedifference = 0;
    int markdifference = 0;

    firstevent.Clear();	
    timemarkevent.Clear();
    firstsingles.Clear();
    
      
    //-----------------------------------------------------
    // Beginning of File things
    
    // the daqfile class manages the opening and incrementing of filenumbers
    // it makes sure I increment the number in the filename and opens and
    // closes the old files.
    if(outlevel){
      if( (fpdataout = datafile.open()) == NULL){
        printf("error, could not open %s",datafile.filename);
        return 1;
      }
    }
    if(loglevel){
      if( (fplogout = logfile.open()) == NULL){
	printf("error, could not open %s",logfile.filename);
	return 1;
      }
    }

    for(int i=0; i<16; i++)hittag_histogram[i] = 0;
    for(int i=0; i<5; i++)coincidence_histogram[i] = 0;
   

    //---------------------------------------------------------------------
    // Initialize and reset DAQ card commands
    // These commands are stored in "writestring" and pushed to the card
    // during the main read/write loop.

    nstrings = 0;
    // Command CD disables the TMC while I do the setup (dead time!)
    writenumchars[nstrings] = sprintf(writestring[nstrings],"CD\r");
    nstrings++;

    writenumchars[nstrings] = sprintf(writestring[nstrings],"WC 06 00\r");
    nstrings++;

    // Command DG reports the GPS status
    if(!nogps){
      writenumchars[nstrings] = sprintf(writestring[nstrings],"DG\r");
      nstrings++;
    }
    // 
    // Command WC 00 nF changes the coincidence reqirement 
    // 0F is one-fold, 1F is two-fold, 2F is three-fold, 3F is four-fold 
    if(coincidence==1)
      writenumchars[nstrings] = sprintf(writestring[nstrings],"WC 00 0F\r");
    if(coincidence==2)
      writenumchars[nstrings] = sprintf(writestring[nstrings],"WC 00 1F\r");
    if(coincidence==3)
      writenumchars[nstrings] = sprintf(writestring[nstrings],"WC 00 2F\r");
    if(coincidence==4)
      writenumchars[nstrings] = sprintf(writestring[nstrings],"WC 00 3F\r");
    nstrings++;
    /* Command WC 02 nn and WC 03 nn changes the width of the gate */
    /* There are eleven bits total, so the width can be tuned to
       2048 * 24ns = 49.152 microseconds
       but as a practical matter, I don't think it actually can be
       this long because of the depth of the tmc buffer.  */
    int maxgatewidth = 2048;
    if(gatewidth > maxgatewidth){
      cerr << "Invalid gate width " << gatewidth << " > "
	   << maxgatewidth << ", quitting program." << endl;
      return 1;
    }
    
    int lowerbits = 0, middlebits = 0, upperbits = 0;
    
    lowerbits = gatewidth & 0xf;
    middlebits = (gatewidth >> 4) & 0xf;
    upperbits = (gatewidth >> 8) & 0xf;
    writenumchars[nstrings] = sprintf(writestring[nstrings],"WC 02 00\r");
    writestring[nstrings][6] = makehex(middlebits);
    writestring[nstrings][7] = makehex(lowerbits);
    nstrings++;
    writenumchars[nstrings] = sprintf(writestring[nstrings],"WC 03 00\r");
    writestring[nstrings][6] = makehex(upperbits);
    writestring[nstrings][7] = makehex(0);
    nstrings++;

    // The default is WC 01 07, which mess up things at the edge of the gate
    writenumchars[nstrings] = sprintf(writestring[nstrings],"WC 01 00\r");
    nstrings++;
     
    // For some reason, sending in two WT commands in a row is unreliable.

    writenumchars[nstrings] = sprintf(writestring[nstrings],"WT 01 00\r");
    nstrings++;

    // WT 02 00 sets the tmc delay
    lowerbits = tmcdelay & 0xf;
    middlebits = (tmcdelay >> 4) & 0xf;
    writenumchars[nstrings] = sprintf(writestring[nstrings],"WT 02 32\r");
    writestring[nstrings][6] = makehex(middlebits);
    writestring[nstrings][7] = makehex(lowerbits);
    nstrings++;

    // Command BA reports the Barometer reading
    writenumchars[nstrings] = sprintf(writestring[nstrings],"BA\r");
    nstrings++;

    // Command TH reports the Thermometer reading
    writenumchars[nstrings] = sprintf(writestring[nstrings],"TH\r");
    nstrings++;


    /* Command WC 06 FF resets the scalars and the fifo */
    /* Old version, this was WC 04 FF */
    /* TODO! I have to take dead time if I do this here! */

    // Command DS reports the Singles counts
    writenumchars[nstrings] = sprintf(writestring[nstrings],"DS\r");
    nstrings++;

    // Get Status line
    //writenumchars[nstrings] = sprintf(writestring[nstrings],"ST\r");
    //nstrings++;

    if(firmware <= 23 && !nogps){
    // Turn on/off automatic 5 minute status line
      if(nogps){
	writenumchars[nstrings] = sprintf(writestring[nstrings],"ST 1\r");
	nstrings++;
      }
      else{
	writenumchars[nstrings] = sprintf(writestring[nstrings],"ST 1\r");
	nstrings++;
      }
    }
    else{
    // Turn on/off automatic 5 minute status line
      //if(nogps){
    writenumchars[nstrings] = sprintf(writestring[nstrings],"ST 0\r");
    nstrings++;
    //}

      

    // Command DF reports something
    writenumchars[nstrings] = sprintf(writestring[nstrings],"DF\r");
    nstrings++;

    // Command DT reports the TMC registers
    writenumchars[nstrings] = sprintf(writestring[nstrings],"DT\r");
    nstrings++;

    // Command DC reports the counter registers
    writenumchars[nstrings] = sprintf(writestring[nstrings],"DC\r");
    nstrings++;
    }
      


    // Command CE enables the TMC and counters
    writenumchars[nstrings] = sprintf(writestring[nstrings],"CE\r");
    nstrings++;

    // Now I have nstrings that I want to send, one-by-one into the card.
    // They are stored and will be sent in during the read/write loop.
    // --------------------------------------------------------------------

    events_since_firstdata = 0;
    numreads_since_firstdata = 0;
    prev_singles_events = 0;
    currentevent.Clear();
    firstevent.Clear();
    MY_STOP_LOOP = FALSE;

 
    if(loglevel >= 1)fflush(fplogout);    
    //if(outlevel >= 1)fflush(fpdataout);

    // End of Beginning of File stuff
    //-----------------------------------------------------------------------
    
    //-------------------------------------------------------------------    
    // This is the primary data reading loop
    time(&begin_file_time);
    prev_singles_time = begin_file_time;
    int cd_is_set = 0;
    int strings = 0;
    while (MY_STOP_LOOP == FALSE) {

      //----------------------------------------------------
      // send the beginning of the file commands to the card.
      //for(int i=0; i<nstrings; i++){
      while(strings < nstrings){
	int i=strings;
	if(cd_is_set && safeds)break;
	res = (int) write(fd,writestring[i],writenumchars[i]);
	strings++;
	//printf("sent %d %d string %s\n",i,writenumchars[i],writestring[i]);
	//fflush(stdout);
	//if(loglevel >= 2){
	//  fprintf(fplogout,"numsent %d %d writestring %s\n\n",
	//	  i,res,writestring[i]);
	//}	  

        // Need to pause between entering commands.
        // Most commands are fine with 10 ms, but DG needs extra time.
	// Might also need more time for older, slower computers.
	if(safeds && writestring[i][0]=='C' && writestring[i][1]=='D')
          cd_is_set = 1;
	//if(writestring[i][0]=='C' && writestring[i][1]=='D')usleep(30000);

        if(writestring[i][0]=='D' && writestring[i][1]=='G')usleep(100000);
        else usleep(40000);  // pause (40000=40ms) to avoid input problems.
      }


      if(strings==nstrings){
	nstrings = 0; strings=0;
          if(setuponly==1){
            MY_STOP_LOOP = TRUE;
            printf("Setup only.  Exiting now.\n"); 
          }  
      }
      bad_event_error = 0;
      timedifference = 0;
      markdifference = 0;
      
      FD_SET(fd, &readfs);
      // wait one millisecond = 1000 usec.  Set this every time.
      Timeout = BaseTimeout;
      //Timeout.tv_usec = 1000;
      //Timeout.tv_sec = 1;
      if(select(maxfd,&readfs,NULL,NULL,&Timeout) != 0){


      //-----------------------------------------------------
      // Read the line from the card, write it to the file, and make a copy.

      if(DEBUG >= 2)printf("%d:about to read\n",events_since_firstdata);
      
      numreads_since_firstdata++;
      res = read(fd,buf,BUFSIZE-1); 
      buf[res]=0;             /* set end of string, so we can printf */

#ifdef SAVETIMESTAMP
      // immediately get timestamp from the PC.  
      time(&rawtime);
      if(loglevel >= 2)
	fprintf(fplogout,"pctime %s",ctime(&rawtime));
      
      // Also insert this into the DAQ card data stream ! 
      
#endif

      // write the serial port string to the data file.
      if(outlevel){      
        fwrite(buf,1,res,fpdataout);
        fflush(fpdataout);
      }

      // make a safe copy of that string to analyze.
      memcpy(tempbuf,buf,res+1);

      numreads_since_firstdata++;

      //--------------------------------------
      // Look at the line I just read and update internal things.

      if(!QnetEventLineNotValid(tempbuf)){
	// Line is a valid data line.

	// If this is the first string of a new event, previous one is complete
	if(QnetEventFirstStringFlag(tempbuf)){
	  // reject zeroth event, it might not be complete.
	  if(events_since_firstdata==1){
	    firstevent = currentevent;
	  }
	  // if "firstdata" has not been set yet, set it to this event.
	  if(firstevent.date == 0 && !firstevent.nogps){
	    firstevent = currentevent;
	  }
	  // do analysis things here.
	  // update histograms.
	  if(currentevent.hittag >=0 && currentevent.hittag < 16){
	    hittag_histogram[currentevent.hittag]++;
	  }
	  int nhits = currentevent.Nhits();
	  if(nhits >=0 && nhits < 5)coincidence_histogram[nhits]++;
	  
	  //increment event counter.
	  events_since_firstdata++;
	  //save or clear the complete event.
	  //cout << currentevent << endl;
	  currentevent.Clear();
	}
	
	// Add the most recent string to the current event.
	bad_event_error = currentevent.ReadLine(tempbuf);

      }
      else{    // Not a valid data line.  Could be DS, ST or crap.
	if((tempbuf[0]=='D' && tempbuf[1] == 'S') ||
	   (tempbuf[0]=='@' && tempbuf[1] == '0')){
	  int returncode = -1;
	  returncode = currentsingles.FillData(tempbuf);
	  //printf("DS is found returncode %d\n",returncode);
	  if(returncode == 5){
	    // I have a complete set of singles information.
	    // But I might not know what time it is now ?!
            // One alternative is to use the system time.
            time(&current_singles_time);
            currentsingles.FillTime(current_singles_time);
            // use the timestamp from the immediately previous event
     	    //currentsingles.FillTime(currentevent);
	    if(timemarksingles.daysince2001 > 0 && loglevel >= 1){
	      double rate[5];
	      double time;
	      qnetsinglesrate(timemarksingles,currentsingles,rate,time);
	      fprintf(fplogout,"channel 0 hits %d rate %f time %f\n",
		      currentsingles.counts[0],rate[0],time);
	      fprintf(fplogout,"channel 1 hits %d rate %f time %f\n",
		      currentsingles.counts[1],rate[1],time);
	      fprintf(fplogout,"channel 2 hits %d rate %f time %f\n",
		      currentsingles.counts[2],rate[2],time);
	      fprintf(fplogout,"channel 3 hits %d rate %f time %f\n",
		      currentsingles.counts[3],rate[3],time);
	      fprintf(fplogout,"channel 4 trigs %d rate %f time %f\n",
		      currentsingles.counts[4],rate[4],time);
	      fflush(fplogout);
	    }
	    timemarksingles=currentsingles;
	    // Also check if this should also be saved as firstsingles.
	    if(firstsingles.daysince2001 < 0)firstsingles=currentsingles;
	  }
	}
	//else if test for ST
      } //end if(!QnetEventLineNotValid(tempbuf))

      //----------------------------------------
      // Make decisions about whether to start new file,
      // or request DS or spit out some kind of error.

      // Three primary tests for starting a new file:
      // system time exceeds limit, nevents exceeds limit, or major error

      if(timeout_nevents > 0 && events_since_firstdata >= timeout_nevents){
	// do what is needed to begin a new file now.
	//printf("Exceeded timeout_nevents\n");
	MY_STOP_LOOP = TRUE;
      }
      // Add code that evaluates for a major error here.

      // Test if it is time to take another singles reading.
      if(readsingles_nevents > 0 &&
	 prev_singles_events - events_since_firstdata >= readsingles_nevents){
	prev_singles_events = events_since_firstdata;
	//printf("Exceeded readsingles_nevents\n");
	// Command DS reports the Singles counts
	if(safeds){
	  writenumchars[nstrings] = sprintf(writestring[nstrings],"CD\r");
	  nstrings++;
        }
	if(firmware>=26 && !nogps){
	  writenumchars[nstrings] = sprintf(writestring[nstrings],"ST\r");
	  nstrings++;
	} 
	writenumchars[nstrings] = sprintf(writestring[nstrings],"DS\r");
	nstrings++;
	//writenumchars[nstrings] = sprintf(writestring[nstrings],"DF\r");
	//nstrings++;
	//writenumchars[nstrings] = sprintf(writestring[nstrings],"DT\r");
	//nstrings++;
	//writenumchars[nstrings] = sprintf(writestring[nstrings],"DC\r");
	//nstrings++;
	if(safeds){
          writenumchars[nstrings] = sprintf(writestring[nstrings],"CE\r");
	  nstrings++;
        }
      }
      
      if(loglevel>=1)fflush(fplogout);
      } // end if(select(...Timeout))
      else {
        //printf("Timed out after s %d  us %d \n",
	//       (int)BaseTimeout.tv_sec, (int)BaseTimeout.tv_usec);
	if(safeds && cd_is_set){
	  //printf("CD was set, but now is not anymore.\n");
	  cd_is_set = 0;
	}
        // This is where I might to put a data independent timer
        // which decides to request the DS and ST every n seconds.
      }

      //----------------------------------------
      // Make decisions about whether to start new file,
      // or request DS or spit out some kind of error.

      // Three primary tests for starting a new file:
      // system time exceeds limit, nevents exceeds limit, or major error

      // get systemtime.
      time(&rawtime);

      //printf("time %d %d %d %d %d\n",rawtime,
      //     begin_file_time, rawtime - begin_file_time,
      //     prev_singles_time,rawtime - prev_singles_time);

      if(timeout_nseconds > 0 && rawtime-begin_file_time >= timeout_nseconds){
	// do what is needed to begin a new file now.
	//printf("Exceeded timeout_nseconds\n");
	MY_STOP_LOOP = TRUE;
      }
      // Add code that evaluates for a major error here.

      // Test if it is time to take another singles reading.

      if(readsingles_nseconds > 0 &&
	      rawtime - prev_singles_time >= readsingles_nseconds){
	prev_singles_time = rawtime;
	//printf("Exceeded readsingles_nseconds\n");
	// Command DS reports the Singles counts
	if(safeds){
	  writenumchars[nstrings] = sprintf(writestring[nstrings],"CD\r");
	  nstrings++;
        }
	if(firmware>=26 && !nogps){
	  writenumchars[nstrings] = sprintf(writestring[nstrings],"ST\r");
	  nstrings++;  
	}    
	writenumchars[nstrings] = sprintf(writestring[nstrings],"DS\r");
	nstrings++;
	//writenumchars[nstrings] = sprintf(writestring[nstrings],"DF\r");
	//nstrings++;
	//writenumchars[nstrings] = sprintf(writestring[nstrings],"DT\r");
	//nstrings++;
	//writenumchars[nstrings] = sprintf(writestring[nstrings],"DC\r");
	//nstrings++;
	if(safeds){
	  writenumchars[nstrings] = sprintf(writestring[nstrings],"CE\r");
	  nstrings++;
        }
      }


    } // end  while (MY_STOP_LOOP == FALSE) {
    
    //----------------------------------------------------------------------
    // do any thing to close out the end of the file.

    if(efficiency==1){
      int threehits = hittag_histogram[15] + hittag_histogram[7];
      int fourhits = hittag_histogram[15];
  
      cout << "ch0123 " << fourhits << " ch123 " << threehits
           << " efficiency " << (float)fourhits / (float)threehits 
           << endl;
    }

    if(printrate==1){
      double rate[5];
      double time;
      qnetsinglesrate(firstsingles,currentsingles,rate,time);
      cout << "singles " << rate[0] << " " << rate[1] << " " << rate[2]
           << " " << rate[3] << " " << rate[4] << " time " << time 
           << endl;
    }


    if(loglevel >= 1){
      fprintf(fplogout,"<summary>\n");
      fprintf(fplogout,"time start %d %d\n",
	      firstevent.date,firstevent.seconds);
      fprintf(fplogout,"time end %d %d\n",
	      currentevent.date,currentevent.seconds);
      if(firstsingles.daysince2001 > 0){
	double rate[5];
	double time;
	qnetsinglesrate(firstsingles,currentsingles,rate,time);
	fprintf(fplogout,"channel 0 hits %d rate %f time %f\n",
		currentsingles.counts[0],rate[0],time);
	fprintf(fplogout,"channel 1 hits %d rate %f time %f\n",
		currentsingles.counts[1],rate[1],time);
	fprintf(fplogout,"channel 2 hits %d rate %f time %f\n",
		currentsingles.counts[2],rate[2],time);
	fprintf(fplogout,"channel 3 hits %d rate %f time %f\n",
		currentsingles.counts[3],rate[3],time);
	fprintf(fplogout,"channel 4 trigs %d rate %f time %f\n",
		currentsingles.counts[4],rate[4],time);	 
      }
      fprintf(fplogout,"</summary>\n");
    }
    // done with end of file things.
    //----------------------------------------------------------------------
   
  } //end for(files = 0; files < maxfiles; files++){
  
/* restore the old port settings */
tcsetattr(fd,TCSANOW,&oldtio);
//fclose(fpdataout);
if(outlevel >= 1)datafile.close();
if(loglevel >= 1)logfile.close();
return 0;
}

/* ------------------------------ subroutines ------------------------------ */

int setup_terminal(int fd, int baudrate)
{
  /* see below for avilable baud rates */


    fd = open(MODEMDEVICE, O_RDWR | O_NOCTTY );
    //    fd = open(MODEMDEVICE, O_RDWR | O_NOCTTY | O_NONBLOCK );
    if (fd <0) { perror(MODEMDEVICE); exit(-1); }

    if (DEBUG) fprintf(stderr,"   %s open\n", MODEMDEVICE);

    tcgetattr(fd,&oldtio);         /* save current serial port settings */
    bzero(&newtio, sizeof(newtio)); /* clear struct for new port settings */

    /* BAUDRATE: Set bps rate. You could also use cfsetispeed and
                 cfsetospeed.
       CRTSCTS : output hardware flow control (only used if the cable has
                 all necessary lines. See sect. 7 of Serial-HOWTO)
                 [not used here = no flow control]
       CS8     : 8n1 (8bit,no parity,1 stopbit)
       CLOCAL  : local connection, no modem contol
       CREAD   : enable receiving characters
    */

/*  newtio.c_cflag = BAUDRATE | CRTSCTS | CS8 | CLOCAL | CREAD;  */

/* baudrate settings are defined in <asm/termbits.h>, which is
   included by <termios.h> */

/*      there is some room for "forgetfulness" in what baudrates are allowed */
/*      newtio.c_cflag = BAUDRATE_19200 | CS8 | CLOCAL | CREAD; */
    if(baudrate == 19200)
      newtio.c_cflag = B19200 | CS8 | CLOCAL | CREAD; 
    else if(baudrate >= 38000 && baudrate < 39000)
      newtio.c_cflag = B38400 | CS8 | CLOCAL | CREAD; 
    else if(baudrate >= 56000 && baudrate < 58000)
      newtio.c_cflag = B57600 | CS8 | CLOCAL | CREAD; 
    else if(baudrate >= 115000 && baudrate < 116000)
      newtio.c_cflag = B115200 | CS8 | CLOCAL | CREAD; 


      /* no flow control */

    /* IGNPAR  : ignore bytes with parity errors
       ICRNL   : map CR to NL (otherwise a CR input on the other computer
                 will not terminate input)
       otherwise make device raw (no other input processing)
    */

    newtio.c_iflag = IGNPAR;

    /* Raw output. */

    newtio.c_oflag = 0;

    /*  ICANON  : enable canonical input
        disable all echo functionality, and don't send signals to calling
        program
    */

    newtio.c_lflag = ICANON;

    /* initialize all control characters
       default values can be found in /usr/include/termios.h, and are
       given in the comments, but we don't need them here
    */

    newtio.c_cc[VINTR]    = 0;   /* Ctrl-c */
    newtio.c_cc[VQUIT]    = 0;   /* Ctrl-\ */
    newtio.c_cc[VERASE]   = 0;   /* del */
    newtio.c_cc[VKILL]    = 0;   /* @ */
    newtio.c_cc[VEOF]     = 0;   /* Ctrl-d */
    newtio.c_cc[VTIME]    = 0;   /* inter-character timer unused */
    newtio.c_cc[VMIN]     = 0;   /* blocking read until 1 character arrives */
    newtio.c_cc[VSWTC]    = 0;   /* '\0' */
    newtio.c_cc[VSTART]   = 0;   /* Ctrl-q */
    newtio.c_cc[VSTOP]    = 0;   /* Ctrl-s */
    newtio.c_cc[VSUSP]    = 0;   /* Ctrl-z */
    //if (mode==1)
    //{
    //  newtio.c_cc[VEOL]   = 0xb3;  /* EOL character for SiRF mode = 0xb3 */
    //}
    //else
    //{
      newtio.c_cc[VEOL]   = 0;   /* 0='\0' */
      //}
    newtio.c_cc[VREPRINT] = 0;   /* Ctrl-r */
    newtio.c_cc[VDISCARD] = 0;   /* Ctrl-u */
    newtio.c_cc[VWERASE]  = 0;   /* Ctrl-w */
    newtio.c_cc[VLNEXT]   = 0;   /* Ctrl-v */
    newtio.c_cc[VEOL2]    = 0;   /* '\0' */

    /* now clean the modem line and activate the settings for the port */

    if (DEBUG) fprintf(stderr,"   %s new terminal settings loaded\n",MODEMDEVICE);

    tcflush(fd, TCIFLUSH);
    tcsetattr(fd,TCSANOW,&newtio);

    /* terminal settings done, now handle input
       In this example, inputting a 'z' at the beginning of a line will
       exit the program.
    */

    if (DEBUG) fprintf(stderr,"   %s activated ...\n",MODEMDEVICE);
    return(fd);
}

void restore_terminal(int fd)
{
    /* restore the old port settings */

    tcsetattr(fd,TCSANOW,&oldtio);
}


/*
void showallstring(char *mystring, int inputlength)
{
  // Completely replaces the incoming mystring with a new one.
  // Does no bounds checking!  Very dangerous!
  // You'll get a segfault or worse if the string buffer is too small.
  
  char tempstring[BUFSIZE]; 
  int i, len;
  for(i=0; i<BUFSIZE; i++)tempstring[i] = 0;

  if(inputlength < 0)len = strlen(mystring);
  else len = inputlength;

  for(i=0; i<len; i++)
    {
      if(!isprint(mystring[i]))
	{
	  char littlestring[8];
	  char thischar = mystring[i];
	  sprintf(littlestring,"<0x%02x>",thischar);
	  if(mystring[i] > 0 && mystring[i] < 255){
	    //printf("i %d %d %s\n",i,mystring[i],littlestring);
	    //fflush(stdout);
	    strcat(tempstring,littlestring);
	  }
	  else{
	    fprintf(stderr,"wierd error I don't understand in the output string i %d %d %s\n",i,mystring[i],littlestring);
	    fflush(stderr);
	  }
	      
	}
      else
	{
	  char littlestring[2];
	  sprintf(littlestring,"%c",mystring[i]);
	  //printf("i %d %c %s\n",i,mystring[i],littlestring);
	  //fflush(stdout);
	  strcat(tempstring,littlestring);
	}
    }
  strcat(tempstring,"\n");
  strcpy(mystring,tempstring);
}
*/

int utc_difference(double a, double b)
{
  // This one returns seconds, and some rounding and truncation will occur.

  //assume utc time format hhmmss.mmm, and return the difference in seconds.
  int bhours = ((int) b) / 10000;
  int bmins = ((int) b - bhours * 10000) / 100;
  int bsecs = ((int) b - bhours * 10000 - bmins * 100);
  bsecs += bmins * 60 + bhours * 3600;

  int ahours = ((int) a) / 10000;
  int amins = ((int) a - ahours * 10000) / 100;
  int asecs = ((int) a - ahours * 10000 - amins * 100);
  asecs += amins * 60 + ahours * 3600;

  int difference = bsecs - asecs;


  //if it is negative, that is because the hours have rolled over.  
  if(difference < 0)difference += 60 * 60 * 24;

  return difference;
}

char makehex(int myint){
  // This makes a single hex character from four bytes, or returns ?
  char mychar;
  if(myint < 10) mychar = '0' + myint;
  else if(myint < 16) mychar = 'A' + myint - 10;
  else mychar = '?';
  return mychar;
}




/* Some old version information


   I think this will not work with optimization -O3
   But does work with -O1

   2003 Jan 21  Rik   First working version
   2003 Jan 24  Rik   Added gps error detection mechanism, see errortraps.h
                      Fixed problem that TIMEOUT message was not written.
   2003 Jan 27  Rik   Changed the file output and showallstring to be more
                      careful about binary data in what is usually character
                      strings.  For example, if the GPS data is missing,
                      the DAQ card spits out some zeros, which are 
                      interpreted as end of strings.

   2003 Feb 13  Rik   Added system timestamp to the log file.
                      Need to be able to turn it off and recompile.
                      And test it to see if it bogs the system down.

   2004 Jul 01  Rik   Version 1.95 significant update.
                      Code name changes and updates
                      Setup commands are sent in differently.
                      Use system time to determine when to read singles
                      Use system time to determine when to start new file
                      Reads firmware version 2.0 and 2.5+
                      Still to do before major 2.0 release:
                        implement logfile, rate display, and summary.
                        remove cruft from code
                        check system timestamp capability
                        check debug capability
                        try to implement serial read timeout
                        merge code with analysis utilities

   2004 Oct 22  Rik   Put in real timeouts, and added a safety feature
                      into the DS read portion.
                      Also a new parameter to switch between old and 
                      new firmware (turns on new features).

       A note about pauses and timeouts.  
       A typical event is 2 x 76 bytes which takes 32 ms to read out
       running at 38400.  I am not sure how much time it takes for the
       MCU to prepare the event.    So, pauses and timeouts should 
       probably be about this big.

*/
