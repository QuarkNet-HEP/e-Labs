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


//using namespace std;
//#include "rik__histogram.h"

rik_histogram::rik_histogram(int size)
{
  nbins = size;

  try { phistogram = new long [nbins]; }
  catch (bad_alloc xa)
  { cerr << "Allocation Failure hist\n";};

  //phistogram = new(nothrow) long[nbins];

  clearall();

}

rik_histogram::rik_histogram(const rik_histogram &inhist)
{
  int i,j;
  nbins = inhist.nbins;

  try  { phistogram = new long [nbins]; }
  catch (bad_alloc xa)
  { cerr << "Allocation Failure hist\n";};

  clearall();
  for(i=0;i<nbins;i++)phistogram[i] = inhist.phistogram[i];
  nentries = inhist.nentries;
  nevents = inhist.nevents;
  sum = inhist.sum;
  for(i=0;i<NTITLES;i++)title_is_set[i] = inhist.title_is_set[i];
  for(i=0;i<NTITLES;i++)for(j=0;j<256;j++)title[i][j] = inhist.title[i][j];

  //strcpy(title[i],inhist.title[i]);
  shorttitle_is_set = inhist.shorttitle_is_set;
  for(i=0;i<64;i++)shorttitle[i] = inhist.shorttitle[i];
  idnumber_is_set = inhist.idnumber_is_set;
  idnumber = inhist.idnumber;
  writeswitch_few = inhist.writeswitch_few;
  writeswitch_nosummary = inhist.writeswitch_nosummary;
  writeswitch_sparse = inhist.writeswitch_sparse;
  writeswitch_id = inhist.writeswitch_id;
  num_miscstrings = inhist.num_miscstrings;
  for(i=0;i<32;i++)
    for(j=0;j<256;j++)
      miscstring[i][j] = inhist.miscstring[i][j];
  return;
}



rik_histogram::~rik_histogram(void)
{
  delete [] phistogram;
}



void rik_histogram::increment(int value)
{
  if(value >= nbins)phistogram[nbins-1]++;
  else if(value < 0)phistogram[0]++;
  else phistogram[value]++;
  nentries++;
  sum += (double)value;
  return;
}

void rik_histogram::increment(float value)
{
  int temp;
  temp = (int)value;
  if(temp >= nbins)phistogram[nbins-1]++;
  else if(temp < 0)phistogram[0]++;
  else phistogram[temp]++;
  nentries++;
  sum += (double)value;
  return;
}

void rik_histogram::increment(double value)
{
  int temp;
  temp = (int)value;
  if(temp >= nbins)phistogram[nbins-1]++;
  else if(temp < 0)phistogram[0]++;
  else phistogram[temp]++;
  nentries++;
  sum += value;
  return;
}

void rik_histogram::increment(int bin, int many)
{
  if(bin >= nbins)phistogram[nbins-1]+=many;
  else if(bin < 0)phistogram[0]+=many;
  else phistogram[bin]+=many;
  nentries+=many;
  sum += many * bin;
  return;
}

double rik_histogram::getAverage(void)
{
  double average;
  if(nentries == 0)average = 0.0;
  else  average = sum / (double)nentries;
  return average;
}

int rik_histogram::getMedian(void)
{
  //note, this can only tell me the median bin!
  int i,halfnentries;
  int count = 0;
  halfnentries = nentries / 2;
  for(i=0;i<nbins;i++)
    {
      count += phistogram[i];
      if(count >= halfnentries)break;
    }
  return i;
}

/* obsolete
void rik_histogram::print(int few)
{
  int i, howmany;

  if(few <= 0)howmany=nbins;
  else if(few >= nbins)howmany=nbins;
  else howmany=few;

  for(i=0;i<howmany;i++)
    {
      cout << "bin " << i << " " <<  phistogram[i] << endl;
    }
  return;
}
*/

void rik_histogram::setSubtitle(char *mystring, int whichtitle)
{
  int i;

  if(whichtitle < 0)
    {
      //search for a blank title
      for(i=1;i<NTITLES;i++)
        {
          if(!title_is_set[i])break;
        }
      //put this title in the next unused one.
      if(i < NTITLES)whichtitle = i;
      else return;  //simply ignore if too many titles are present.
    }

    {
      strcpy(title[whichtitle],mystring);
      title_is_set[whichtitle] = 1;
    }
  return;
}

/* obsolete
int rik_histogram::write(FILE *fp, int few)
{
  int i, howmany, error = 0;

  if(few <= 0)howmany=nbins;
  else if(few >= nbins)howmany=nbins;
  else howmany=few;

  for(i=0;i<howmany;i++)
    {
      error = fprintf(fp,"bin %d %ld\n",i,phistogram[i]);
      if(error<0)break;
    }
  if(error<0)
    {
      cout << "rik_histogram: could not write to file." << endl;
      return 1;
    }
  return 0;
}
*/

/*
 * Printing control strings and the simple printing options.
 *
 * Want to enter a control string like this:
 *  "few=18, sparse, nosummary"
 */

int rik_histogram::parsecontrolstring(char *controlstring)
{
  //Parses a control string.  Uses only first 4 characters.  Valid examples:
  //"few = 18 sparse nosummary"
  //"few=18, sparse nosummary"
  //"few = 18, spar nosu"
  int ncols,i,j;
  char word[7][16];
  ncols = sscanf(controlstring, "%s %s %s %s %s %s %s",
         word[0],word[1],word[2],word[3],word[4],word[5],word[6]);
  //cout << "parse control string " << ncols << " " << controlstring << endl;
  for(i=0;i<ncols;i++)
    {
      char thisword[5];
      for(j=0;j<5;j++)thisword[j]=word[i][j];
      thisword[4] = 0;

      if(!strcmp(thisword,"few"))writeswitch_few = atoi(word[i+2]);
      if(!strcmp(thisword,"few="))
        {
          char intword[16];
          for(j=0;j<12;j++)intword[j]=word[i][j+4];
          writeswitch_few = atoi(intword);
        }
      if(!strcmp(thisword,"id"))writeswitch_id = atoi(word[i+2]);
      if(thisword[0] == 'i' && thisword[1] == 'd' && thisword[2] == '=')
        {
          writeswitch_id = atoi(&word[i][3]);
    //cout << "writeswitch_id is " << writeswitch_id << " " << word[i] << endl;
        }
      if(!strcmp(thisword,"spar"))writeswitch_sparse = 1;
      if(!strcmp(thisword,"nosu"))writeswitch_nosummary = 1;
      if(!strcmp(thisword,"summ"))writeswitch_nosummary = 0;
    }

  return 1;
}



int rik_histogram::write(FILE *fp, char *controlstring)
{
  int i, howmany, error=0;
  if(controlstring != NULL)parsecontrolstring(controlstring);

  if(writeswitch_few <= 0)howmany=nbins;
  else if(writeswitch_few >= nbins)howmany=nbins;
  else howmany=writeswitch_few;

  fprintf(fp,"<histogram>\n");
  for(i=0;i<NTITLES;i++)if(title_is_set[i])
    {
      error = fprintf(fp,"<title> %s </title>\n",title[i]);
    }
  if(shorttitle_is_set)
    {
      error = fprintf(fp,"<shorttitle> %s </shorttitle>\n",shorttitle);
    }
  if(idnumber_is_set)
    {
      error = fprintf(fp,"<idnumber> %d </idnumber>\n",idnumber);
    }
  if(error < 0)
    {
      cout << "rik_histogram: could not write to file." << endl;
      return 1;
    }
  if(!writeswitch_nosummary)
    //I should test to see what this string is, but for today it defaluts to verbose.
    {
      fprintf(fp,"<summary>\n");
      fprintf(fp,"<average> %f </average>\n",getAverage());
      fprintf(fp,"<median> %d </median>\n",getMedian());
      fprintf(fp,"<Nbins> %d </Nbins>\n",nbins);
      fprintf(fp,"<Nprinted> %d </Nprinted>\n",howmany);
      fprintf(fp,"<Nentries> %ld </Nentries>\n",nentries);
      fprintf(fp,"<Nevents> %ld </Nevents>\n",nevents);
      for(i=0;i<num_miscstrings;i++)fprintf(fp,miscstring[num_miscstrings]);
      fprintf(fp,"</summary>\n");
    }
  fprintf(fp,"<data>\n");
  for(i=0;i<howmany;i++)
    {
      if(writeswitch_sparse)
        {
          if(phistogram[i])
            {
              error = fprintf(fp,"bin %d %ld\n",i,phistogram[i]);
              if(error<0)break;
            }
        }
      else
        {
          error = fprintf(fp,"bin %d %ld\n",i,phistogram[i]);
          if(error<0)break;
        }
    }
  if(error<0)
    {
      cout << "rik_histogram: could not write to file." << endl;
      return 1;
    }
  fprintf(fp,"</data>\n");
  fprintf(fp,"</histogram>\n");
  return 0;
}

int rik_histogram::read(FILE *fp, char *controlstring)
{
  //This will go through the file looking for the next histogram.
  //first version, simply go through parsing for "bin"
  char mystring[256],word[8][64];
  long tempentry, tempbin;
  int found_correct_histogram = 0;
  int found_data = 0;
  writeswitch_id = -1;
  num_miscstrings = 0;
  //clear();
  if(controlstring != NULL)parsecontrolstring(controlstring);
  if(writeswitch_id < 0)found_correct_histogram = 1;
  //cout << "writeswitch " << writeswitch_id << endl;
  //sift through to find <histogram>
  while(!feof(fp))
    {
      fgets(mystring, 256, fp);
      sscanf(mystring,"%s %s %s",word[0], word[1], word[2]);
      if(!strcmp(word[0],"<histogram>"))
        {
          //some problem here with cint causes the first line to be missed.
          if(0)cout << "Found histogram" << endl;
          break;
        }
    }

  if(feof(fp))
    {
      printf("No histogram found\n");
      return 1;
    }
  double tempaverage=0;
  long tempnentries=0;
  clearall();
  while(!feof(fp))
    {
      int ncols;
      fgets(mystring, 256, fp);
      ncols = sscanf(mystring,"%s %s %s",word[0],word[1],word[2]);
      if(ncols <= 0)continue;
      //printf(mystring);
      if(!strcmp(word[0],"<histogram>")){ clearall(); continue; }
      if(!strcmp(word[0],"</histogram>"))
        {
          if(found_correct_histogram)break;
          else clearall();
          continue;
        }
      if(!strcmp(word[0],"<title>") || !strcmp(word[0],"<Title>"))
        {
          //undo the formatting.
          char temptitle[256];
          int length;
          strcpy(temptitle,&mystring[8]);
          length = strlen(temptitle);
          temptitle[length - 9] = 0;
          if(!title_is_set[0])setTitle(temptitle);
          else setSubtitle(temptitle);
          continue;
        }
      if(!strcmp(word[0],"<idnumber>"))
        {
          idnumber = atoi(word[1]);
          idnumber_is_set = 1;
          if(writeswitch_id >= 0 && writeswitch_id == idnumber)
            {
              found_correct_histogram = 1;
            }
          else if(writeswitch_id >= 0 && writeswitch_id != idnumber)
            {
              //not the correct one.  clear any titles that have been set.
              clearall();
              //int i;
              //for(i=0;i<NTITLES;i++)title_is_set[i] = 0;
            }
          else
            {
              //if I haven't specified an idnumber,
              //force this to be correct.
              found_correct_histogram = 1;
            }
          continue;
        }
      if(writeswitch_id >= 0 && !found_correct_histogram)continue;

      if(!strcmp(word[0],"<Nevents>"))
        {
          nevents = atoi(word[1]);
        }
      else if(!strcmp(word[0],"<Nentries>"))
        {
          tempnentries = atoi(word[1]);
        }
      else if(!strcmp(word[0],"<Nbins>"))
        {
          int tempnbins = atoi(word[1]);

          // force a reallocation of nbins
          if(tempnbins != nbins)
            {
              delete [] phistogram;
              nbins = tempnbins;
              //phistogram = new(nothrow) long[nbins];
              try  { phistogram = new long [nbins]; }
              catch (bad_alloc xa)
                { cerr << "Allocation Failure hist\n";};

              clear();
            }
        }
      else if(!strcmp(word[0],"<average>"))
        {
          tempaverage = atof(word[1]);
        }
      else if(!strcmp(word[0],"<data>"))
        {
          found_data = 1;
        }
      else if(!strcmp(word[0],"</data>"))
        {
          found_data = 0;
        }
      //else if(!strcmp(word[0],"<median>")){continue;}
      //else if(!strcmp(word[0],"<summary>")){continue;}
      //else if(!strcmp(word[0],"</summary>")){continue;}
      //else if(!strcmp(word[0],"<Nprinted>")){continue;}
      else if(!strcmp(word[0],"bin") || !strcmp(word[0],"Bin") || found_data)
        {
          if(ncols == 2)
            {
              tempbin = atoi(word[0]);
              tempentry = atoi(word[1]);
            }
          else
            {
              tempbin = atoi(word[1]);
              tempentry = atoi(word[2]);
            }
          //sscanf(mystring,"%s %d %d\n",word[0], &tempbin, &tempentry);
          increment(tempbin,tempentry);
        }
      else
        {
          if(num_miscstrings >= 32)continue;
          strcpy(miscstring[num_miscstrings], mystring);
          num_miscstrings++;
        }
    }

  //  now the original average should imply a particular sum,
  //  because of the overflow bin, this sum could be wrong,
  //  so update that.
  if(nentries != tempnentries)
    {
      printf("nentries don't match. file %ld compute %ld\n",
             tempnentries, nentries);
    }

  //updateSum(tempaverage);

  //  redefine sum, and nentries if I know the data I am reading is valid.
  //  if these are zero or less, then they were probably unfilled to start.
  //  in the latter case, keep sum and nentries as figured by increment.
  if(tempnentries > 0 && tempaverage > 0)
    {
      sum = tempaverage * (double)tempnentries;
      nentries = tempnentries;
    }


  return 0;
}

rik_histogram rik_histogram::operator=(const rik_histogram &inhist)
{
  //much of this is identical to the copy constructor.

  int i,j;

  //nbins = inhist.nbins;
  if(inhist.nbins != nbins)
    {
      delete [] phistogram;
      nbins = inhist.nbins;
      try  { phistogram = new long [nbins]; }
      catch (bad_alloc xa)
        { cerr << "Allocation Failure hist\n";};
    }

  clear();
  for(i=0;i<nbins;i++)phistogram[i] = inhist.phistogram[i];
  nentries = inhist.nentries;
  nevents = inhist.nevents;
  sum = inhist.sum;
  for(i=0;i<NTITLES;i++)title_is_set[i] = inhist.title_is_set[i];
  for(i=0;i<NTITLES;i++)for(j=0;j<256;j++)title[i][j] = inhist.title[i][j];

  //strcpy(title[i],inhist.title[i]);
  shorttitle_is_set = inhist.shorttitle_is_set;
  for(i=0;i<64;i++)shorttitle[i] = inhist.shorttitle[i];
  idnumber_is_set = inhist.idnumber_is_set;
  idnumber = inhist.idnumber;
  writeswitch_few = inhist.writeswitch_few;
  writeswitch_nosummary = inhist.writeswitch_nosummary;
  writeswitch_sparse = inhist.writeswitch_sparse;
  writeswitch_id = inhist.writeswitch_id;
  num_miscstrings = inhist.num_miscstrings;
  for(i=0;i<32;i++)
    for(j=0;j<256;j++)
      miscstring[i][j] = inhist.miscstring[i][j];

  return *this;
}

rik_histogram rik_histogram::operator*(float fraction)
{
  //double originalsum = sum;
  long newnentries = 0;
  for(int i = 0; i < nbins; i++)
    {
      //beware of Roundoff Error!!!
      //cout << "Old hist is " << phistogram[i] << " ";
      phistogram[i] = (int)((float)phistogram[i] * fraction);
      //cout << " new is " << phistogram[i] << " fraction is " << fraction << endl;
      newnentries += phistogram[i];
    }
  //nevents stays the same.
  //sum is decreased by fraction, with some roundoff error.
  //but the roundoff error is smaller than what I get if I lose the overflowbin.
  sum = sum * fraction;
  //total nentries is now decreased by fraction, but to be on the safe side,
  //resum the histogram.
  nentries = newnentries;

  //average is based on the new sum.
  return *this;
}

rik_histogram rik_histogram::operator+=(const rik_histogram &inhist)
{
  int i;
  double originalsum = sum;
  for(i=0;i<inhist.nbins;i++)
    {
      increment(i,inhist.phistogram[i]);
    }
  nevents += inhist.nevents;

  //  because of the overflow bin, the average will be wrong,
  //  get it right.
  if(inhist.sum > 0)
    {
      sum = originalsum + inhist.sum;
    }

  return *this;
}



int rik_histogram::addHistogram(rik_histogram *phist)
{
  //deprecated.  use the += operator instead.
  //add to the histogram.
  int i;
  for(i=0;i<phist->getNbins();i++)
    {
      increment(i,phist->getBin(i));
    }
  return 0;
}

//rik_histogram rik_histogram::operator+=(rik_histogram hist)
//{
//  int i;
//  for(i=0;i<hist.getNbins();i++)
//    {
//      cout << hist.getBin(i);
//      increment(i,hist.getBin(i));
//    }
//  return *this;
//}

int rik_histogram::scaleHistogram(float scale)
{
  float *pnewhist,*poldhist;
  poldhist = new float[nbins];
  pnewhist = new float[nbins];
  int i;
  for(i=0;i<nbins;i++)
    {
      poldhist[i] = (float)phistogram[i];
      pnewhist[i] = 0.0;
    }

  stretch_histogram(nbins,poldhist,nbins,pnewhist,scale);

  if(scale < 1.0)setSubtitle("scaleHistogram: Beware of overflow bin, histogram was shrunk.");
  else setSubtitle("scaleHistogram: Overflow bin should be good.");

  clear();
  for(i=0;i<nbins;i++)
    {
      //danger, I am integerizing the value of bin i
      //obviously this is because my histogram function only knows integers.
      increment(i,(int)pnewhist[i]);
    }

  delete [] poldhist;
  delete [] pnewhist;

  return 0;
}


//rik_histogram rik_histgram::scaleHistogram(float scale)
//{


int stretch_histogram(int oldsize, rik_float *inputhistogram, int newsize, rik_float *outputhistogram, rik_float newscale)
{
  //Like most C programs, this code really does no bounds checking.  You need to get size and array correct.
  //This is designed so that newscale describes where a feature has moved to.  New location = newscale * old location.
  //Example newscale = 2.0:  A feature (peak) at bin 10 will appear in the new histogram around bin 20.

  int i, numberofbins, whatsnext;
  rik_float newarea;
  //struct hist_bin oldhist[oldsize], newhist[newsize];
  struct hist_bin *poldhist, *pnewhist;
  struct hist_bin *poldhistend, *pnewhistend;
  int nextoutputbin = 1, nextinputbin = 2;


  poldhist = new hist_bin[oldsize];
  pnewhist = new hist_bin[newsize];

  poldhistend = poldhist + oldsize;
  pnewhistend = pnewhist + newsize;
  //poldhist = oldhist;
  //pnewhist = newhist;

  //Fill the array of structures with the proper data.

  for(i=0;i<oldsize;i++)
  {
    poldhist->xbegin = (rik_float) i;
    poldhist->xend = (rik_float) i+1;  //Assume that the input histogram has binwidth of 1.0
    poldhist->xmiddle = ((rik_float) i) + 0.5;
    poldhist->binsize = 1.0;
    poldhist->yvalue = inputhistogram[i];//histogram[i];
    if(i != oldsize - 1)
    {
      poldhist->slopetonext = (rik_float)(inputhistogram[i+1] - inputhistogram[i]) / poldhist->binsize;
      poldhist->areatonext = poldhist->binsize * (rik_float)(inputhistogram[i+1] + inputhistogram[i]) / 2.0;
    }
    else
    {
      poldhist->slopetonext = ((rik_float) inputhistogram[i]) / poldhist->binsize;
      poldhist->areatonext = poldhist->binsize * (rik_float)(inputhistogram[i]) / 2.0;
    }
    poldhist++;
  }

  //use newscale to compute what newsize could be.
  //newscale is defined as so:  newhistogram bin = newscale * oldhistogram bin.
  numberofbins = (int)(oldsize * newscale);
  //If the old histogram has a value in the overflow bin, it could appear as a lump in the middle.
  if(numberofbins < newsize)printf("beware of the location of overflowbin \n");
  //Otherwise the old overflow bin and all bins pushed out of range will be in the overflow.
  if(numberofbins >= newsize)printf("overflowbin should properly be the last bin \n");

  for(i=0;i<newsize;i++)
  {
    pnewhist->xbegin = (rik_float)(i) / newscale;
    pnewhist->xend = (rik_float)(i+1) / newscale;
    pnewhist->xmiddle = ((rik_float)(i) + 0.5) / newscale;
    pnewhist->binsize = 1.0 / newscale;
    pnewhist->yvalue = 0.0;  //set yvalues to zero.
    //slopes and areas are unknown now.
    pnewhist++;
  }

  //poldhist = oldhist;
  //pnewhist = newhist;

  //they both start at zero, but there is no -1 bin.  So treat bin zero in a special way.
  if(poldhist->xmiddle < pnewhist->xend)
  {
    pnewhist->yvalue += poldhist->yvalue / 2.0;
    //poldhist++;  //No! don't increment this.  compute segment area takes over from here.
  }
  else
  {
    while(poldhist->xmiddle >= pnewhist->xend)
    {
      pnewhist->yvalue += poldhist->yvalue * pnewhist->binsize / poldhist->binsize;
      pnewhist++;
    }
    pnewhist->yvalue += poldhist->yvalue * (poldhist->xmiddle - pnewhist->xbegin) / poldhist->binsize;
  }

  //Now that the first half of bin zero has been handeled, all the middle bins work the same way.
  while(poldhist < poldhistend && pnewhist < pnewhistend)
  {

    whatsnext = compute_segment_area(*poldhist, *pnewhist, &newarea);
    pnewhist->yvalue += newarea;
    //printf("%d %f %f %f %f %d %d\n",whatsnext,pnewhist->xbegin, pnewhist->xend, pnewhist->yvalue, newarea,
    //        poldhistend - poldhist, pnewhistend - pnewhist);

    //Increment one or the other bin.
    if(whatsnext == nextoutputbin)pnewhist++;
    else if(whatsnext == nextinputbin)poldhist++;
    else exit(1);
  }
  //printf("\n\n");
  //  Check to see what to do about the overflow bin.  This is incorrect right now.

  if(pnewhist == pnewhistend && poldhist < poldhistend)
  {
    pnewhist--;  //if the above loop ran out of newhist, then it incremented one too far.
    pnewhist->yvalue += poldhist->yvalue / 2.0;
    poldhist++;
  }
  while(poldhist < poldhistend)   //why does this have to be less than and not less than or equal to?
  {
    pnewhist->yvalue += poldhist->yvalue;

    //printf("%d %f %f %f %f %d %d\n",whatsnext,pnewhist->xbegin, pnewhist->xend, pnewhist->yvalue, newarea,
    //        poldhistend - poldhist, pnewhistend - pnewhist);

    poldhist++;

  }
  //printf("\n\n");
  for(i=0;i<newsize;i++)
  {
    outputhistogram[i] = pnewhist[i].yvalue;
    //printf("%d %f %f %f %f\n",i,newhist[i].xbegin, newhist[i].xend, newhist[i].yvalue, oldhist[i].yvalue);
  }

  delete [] poldhist;
  delete [] pnewhist;

  return 0;
}


inline int compute_segment_area(struct hist_bin inputbin, struct hist_bin outputbin, rik_float *newarea)
{
  //The calling routine has to figure out properly which two bins should be passed.
  //This really means it needs to work out which segment needs to be done next.
  //And, the calling routine needs to take into account the zeroth bin by itself.

//struct hist_bin
//{
//  rik_float xbegin;
//  rik_float xmiddle;
//  rik_float xend;
//  rik_float binsize;
//  rik_float yvalue;
//  rik_float slopetonext;
//  rik_float areatonext;
//}


  //Four choices about what might need to be done.
  //Choice one:  work out new begin to new end
  //Choice two:  work new begin to oldnextmidpoint
  //Choice three:  work out oldcurrentmidpoint to oldnextmidpoint
  //Choice four:  work out oldcurrentmidpoint to new end

  rik_float newxprime, newyprime;
  int nextoutputbin = 1, nextinputbin = 2, waserror = 0;

  if(outputbin.xbegin > inputbin.xmiddle && outputbin.xend < (inputbin.xmiddle + inputbin.binsize))
  {
    //Choice one:  work out new begin to new end
    //This x is the midpoint of the segment whose area is being computed
    newxprime = (outputbin.xend + outputbin.xbegin) / 2.0;
    //This is the value of y at newxprime computed using the slope of the input line.
    newyprime = inputbin.slopetonext * (newxprime - inputbin.xmiddle) + inputbin.yvalue;
    //The are of this segment is the correct fraction of the total hits.
    *newarea = newyprime * (outputbin.xend - outputbin.xbegin);
    //Increment the new histogram appropriately.
    return nextoutputbin;  //outputbin.yvalue += newy;
  }
  else if(outputbin.xbegin > inputbin.xmiddle && outputbin.xend >= (inputbin.xmiddle + inputbin.binsize))
  {
    //Choice two:  work new begin to oldnextmidpoint
    //This x is the midpoint of the segment whose area is being computed
    newxprime = (inputbin.xmiddle + inputbin.binsize + outputbin.xbegin) / 2.0;
    //This is the value of y at newxprime computed using the slope of the input line.
    newyprime = inputbin.slopetonext * (newxprime - inputbin.xmiddle) + inputbin.yvalue;
    //The are of this segment is the correct fraction of the total hits.
    *newarea = newyprime * (inputbin.xmiddle + inputbin.binsize - outputbin.xbegin);
    //Increment the new histogram appropriately.
    return nextinputbin;//outputbin.yvalue += newy;
  }
  else if(outputbin.xbegin <= inputbin.xmiddle && outputbin.xend >= (inputbin.xmiddle + inputbin.binsize))
  {
    //Choice three:  work out oldcurrentmidpoint to oldnextmidpoint
    //This x is the midpoint of the segment whose area is being computed
    newxprime = (inputbin.xmiddle + inputbin.binsize + inputbin.xmiddle) / 2.0;
    //This is the value of y at newxprime computed using the slope of the input line.
    newyprime = inputbin.slopetonext * (newxprime - inputbin.xmiddle) + inputbin.yvalue;
    //The are of this segment is the correct fraction of the total hits.
    *newarea = newyprime * (inputbin.xmiddle + inputbin.binsize - inputbin.xmiddle);
    //Increment the new histogram appropriately.
    return nextinputbin;//outputbin.yvalue += newy;
  }
  else if(outputbin.xbegin <= inputbin.xmiddle && outputbin.xend < (inputbin.xmiddle + inputbin.binsize))
  {
    //Choice four:  work out oldcurrentmidpoint to new end
    //This x is the midpoint of the segment whose area is being computed
    newxprime = (outputbin.xend + inputbin.xmiddle) / 2.0;
    //This is the value of y at newxprime computed using the slope of the input line.
    newyprime = inputbin.slopetonext * (newxprime - inputbin.xmiddle) + inputbin.yvalue;
    //The are of this segment is the correct fraction of the total hits.
    *newarea = newyprime * (outputbin.xend - inputbin.xmiddle);
    //Increment the new histogram appropriately.
    return nextoutputbin; //outputbin.yvalue += newy;
  }
  else
  {
    //probably the two bins that are passed do not overlap.
    printf("Error.  No valid combination was found in Area computation.\n");
    return waserror;
  }
}




//#endif

/*
 *
 * In this code, I pass a mystring to setTitle, and then assign the pointer in the class
 * to this mystring.  So the pointer points to something outside the class, it isn't
 * "safe" I suppose.  I should copy that mystring into storage within the class which has
 * limited access.
 */

#endif

