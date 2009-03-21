/*
 *  Though I reinvented the wheel, this is a simple histogram class.
 *  It was actually a very early C++ programming exercise for me, and 
 *  has not been completely updated, so don't laugh too much at it.
 *
 *  It does perform the simplest bounds checking, 
 *  does not test the new allocation; it uses an untested nothrow.
 *  and dumps overflow values into bin zero and the highest bin.
 *  in this way it does not follow the convention of HBOOK and ROOT and others.
 *
 *  Basic things, 
 *  Instantiate a histogram by giving it the number of bins.
 *  Increment a bin using histogram.increment(number)
 *   the number can be any value, int, float, double.
 *  When you have filled it, print it out with the histogram.write(output)
 *  where output could be a file pointer, or stdout or stderr
 *
 *  Second version, 30 January 2003.
 *  First version, 17 February 2001.
 *
 *  Many improvements later
 *  20 July 2001 added scale function.
 *  29 July 2001 added copy constructor, = and += operators.
 *  
 *
 */

/*
 *  notes.
 *  the write function uses the C file routine printf 
 *  and only writes to text files.
 *  sum and average are tracked using the original entry values, a real sum.
 *  median just works out what bin the median occurs.
 *  in either case, the presence of crap data in the overflow bins is a mess.
 */

#ifndef RIK__HISTOGRAM_H
#define RIK__HISTOGRAM_H

//using namespace std;

#include <cstdio> 
#include <cstdlib>  //for atoi
#include <iostream>
#include <new>

#define NTITLES 10

class rik_histogram{
public:
  // constructor and copy constructor
  rik_histogram(int size); 
  rik_histogram(const rik_histogram &inhist);
  ~rik_histogram(void);

  // some manipulation operators to add, assign, and scale the histogram.
  rik_histogram operator+=(const rik_histogram &inhist);
  rik_histogram operator=(const rik_histogram &inhist);
  rik_histogram operator*(float fraction);

  // the basic increment functions.  To fill, use myhist.increment(bintofill);
  void increment(int value);
  void increment(float value);
  void increment(double value);
  void increment(int bin, int many);

  // methods to access the data, and set it too.
  inline int getBin(int bin) {return phistogram[bin];}
  inline void setBin(int bin, int value) {phistogram[bin] = value;};
  double      getAverage(void);
  int         getMedian(void);

  //Extra access functions to allow me to clear histograms
  //but keep an external running average.
  inline long getNentries(void) {return nentries;};
  inline int  getNbins(void) {return nbins;};
  inline int  getNevents(void) {return nevents;};
  inline void setNevents(int n) {nevents = n;};

  //  PRINTING FUNCTIONS
  // writes a faux-xml style text file.  read reads one from a file.
  // to print to the screen, use write(stdout);
  int  write(FILE *fp, char *controlstring = NULL);
  int  read(FILE *fp, char *controlstring = NULL);

  // set titles that will be printed and saved along with the histogram.
  // useful for leaving a description for yourself.
  void setTitle(char *mystring) {strcpy(title[0],mystring);title_is_set[0]=1;};
  void setSubtitle(char *mystring,int whichtitle = -1);
  void setShorttitle(char *mystring)
    {strcpy(shorttitle,mystring); shorttitle_is_set=1;};

  // It might be useful to number histograms if you put many into one file.
  void setIdnumber(int num){idnumber=num; idnumber_is_set=1;};
  int  getIdnumber(void) {return idnumber;};

  // These will undo any of the title and IDnumber things you want undone.
  void unsetTitle(void) {title_is_set[0]=0;};
  void unsetSubtitle(int whichtitle) {title_is_set[whichtitle]=0;};
  void unsetShorttitle(void) {shorttitle_is_set=0;};
  void unsetIdnumber(void) {idnumber_is_set=0;};
  // this is a dangerous get because it does no bounds checking.
  void getTitle(int num, char *mystring)
    {strcpy(mystring,title[num]); return;};


  inline int updateSum(float tempaverage) 
    {  
      if(nentries == 0)return 1; 
      sum = tempaverage * (double)nentries;
      return 0;
    };


  //  MATH MANIPULATION FUNCTIONS.  Obsolete.  use += and *= instead.
  int addHistogram(rik_histogram *phist);  //obsolete, use += instead.
  int scaleHistogram(float scale);


  //clear function allows reuse.  Clear is done automatically in constructor.
  inline void clear();
  inline void clearall();

private:
  char title[NTITLES][256];
  int title_is_set[NTITLES];
  char shorttitle[64];
  int shorttitle_is_set;
  int idnumber;
  int idnumber_is_set;
  double sum;    
  long *phistogram;
  long nentries;
  int nbins;
  long nevents;

  int writeswitch_id;
  int writeswitch_few;
  int writeswitch_nosummary;
  int writeswitch_sparse;

  char miscstring[32][256];
  int num_miscstrings;
  int  parsecontrolstring(char *controlstring);
};

inline void rik_histogram::clear(void)
{
  int i;
  for(i=0;i<nbins;i++)phistogram[i]=0;
  nentries=0;
  sum=0.0;
  return;
}

inline void rik_histogram::clearall(void)
{
  int i;
  clear();

  for(i=0;i<NTITLES;i++)title_is_set[i] = 0;
  shorttitle_is_set = 0;
  idnumber_is_set = 0;
  idnumber = -1;
  //writeswitch_few = -1;
  //writeswitch_nosummary = 0;
  //writeswitch_sparse = 0;
  //writeswitch_id = -1;
  num_miscstrings = 0;

  return;
}


// This is some extra stuff that is useful for scaling and manipulating 
// histograms, but they are dangerous.

typedef float rik_float;

struct hist_bin
{
  rik_float xbegin;
  rik_float xmiddle;
  rik_float xend;
  rik_float binsize;
  rik_float yvalue;
  rik_float slopetonext;
  rik_float areatonext;
};

int compute_segment_area(struct hist_bin inputbin, struct hist_bin outputbin, rik_float *returnarea);
int stretch_histogram(int oldsize, rik_float *oldhist, int newsize, rik_float *newhist, rik_float newscale);


#endif
