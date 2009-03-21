/* This class manages the file openings and closings.
   I think it has all the checks it needs to run safely, but just in case,
   do not operate on the file pointer out side of this class.

   2003 Jan 21  Rik   First mostly working version.
   2003 Jan 24  Rik   Added fflush to the close method, and took out at
                      wrong fclose.

*/
#ifndef WALTA_DAQFILE_H
#define WALTA_DAQFILE_H

#define NAMESIZE 256

class daqfile{
 public:
  daqfile(char *indir, char *inbegin, char *intag, int innum = -1);
  ~daqfile(){};

  char filename[NAMESIZE];

  char mydir[NAMESIZE];
  char mybegin[NAMESIZE];
  char mytag[NAMESIZE];
  int mynum;

  int tested_for_file_existence;
  int file_is_open;
  int file_exists_error;

  FILE *fp;

  int make_filename(void);
  FILE * open(void);
  void close(void);

};

daqfile::daqfile(char *indir, char *inbegin, char *intag, int innum)
{
  strcpy(mydir,indir);
  strcpy(mybegin,inbegin);
  strcpy(mytag,intag);
  mynum = innum;
  if(innum < 0)mynum = 0;
  tested_for_file_existence = 0;
  file_is_open = 0;
  file_exists_error = 0;
  fp = NULL;
}

int daqfile::make_filename(void)
{
  int error = 0;
  char tempdigits[8];

  strcpy(filename,mydir);
  strcat(filename,mybegin);
  sprintf(tempdigits,"%03d",mynum);
  strcat(filename,"_");
  strcat(filename,tempdigits);
  strcat(filename,mytag);

  printf("%s\n",filename);

  return 0;

}

FILE * daqfile::open(void)
{
  int error = 0;
  
  // This might be called with the previous file open.
  // the daqfile::close tests for this case.
  close();

  if(!tested_for_file_existence)
    {
      make_filename();
      FILE *fptemp;
      if( (fptemp = fopen(filename,"rb")) == NULL)
	{
	  //printf("could not open file %s.  good!",filename);
	  error = 0;
	}
      else
	{
	  printf("file exists! %s\n", filename);
	  fprintf(stderr,"file exists! %s\n", filename);
	  fclose(fptemp);
	  file_exists_error = 1;
	  error = 1;
	}

      tested_for_file_existence = 1;
      // but don't increment mynum with a mynum++;
      // and don't make a filename, I already made it above.

      if(error)return NULL;
    }
  else
    {
      mynum++;
      make_filename();
    }

  if( (fp = fopen(filename,"w")) == NULL)
    {
      printf("could not open file %s for writing\n",filename);
      return NULL;
    }
  else
    {
      file_is_open = 1;
    }

  return fp;
}

void daqfile::close(void)
{
  if(file_is_open && fp != NULL)
    {
      fflush(fp);
      fclose(fp);
    }
  file_is_open = 0;
}


#endif

//#define STORED_FILE_NUMBER_FILE "lastfilenumber.txt"
//int use_number_from_file(char *whichfile);


/*

int make_filename(char *myfilename, char *mydir, char *mybegin, 
		 int mynum, char *mytag, int tested_filename)
{
  // if tested_filename is 0 (I have not tested the filename yet)
  // then ths program will test the newly created filename to make sure
  // that I don't overwrite a previous file.
  // I might only want to do this once, at the beginning of running
  // the program, if the computer's filesystem is ornery.
  // This program will return an error of 1 if there is danger.

  int error = 0;
  char tempdigits[8];
  // Generate a new filename.
  // The pattern is blah_0001.data

  strcpy(myfilename,mydir);
  strcat(myfilename,mybegin);
  sprintf(tempdigits,"%04d",mynum);
  strcat(myfilename,"_");
  strcat(myfilename,tempdigits);
  strcat(myfilename,mytag);

  printf("%s\n",myfilename);

  // Test for a filename conflict only at the beginning of the program.
  if(!tested_filename)
    {
      // treat the default filename as untested, and make sure I look
      // to see if there is already a file with this name.
      FILE *fptemp;
      if( (fptemp = fopen(myfilename,"rb")) == NULL)
	{
	  printf("could not open file %s.  good!",myfilename);
          //fclose(fptemp);
	  error = 0;
	}
      else
	{
	  printf("file exists! %s",myfilename);
	  fclose(fptemp);
	  error = 1;
	}
    }
  else
    {
      // do nothing

    }

  return error;
}
*/
