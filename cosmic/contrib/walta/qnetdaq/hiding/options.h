/*
 * options.h
 *
 * this program will read in and store all command-line and steering file
 * options so that the main routine can easily query it for values.
 * 
 * It does not know anything about what it reads, it just encapsulates the
 * process of reading and parsing the options so that the main routine
 * can query the lists with a Get(key,value) which returns 0 upon success.
 *
 * It allows you to use the regular unix command-line structures and
 * also keyword-value pairs read in from a file.
 *
 * it recognizes exactly one special case:
 * --options=filename  in which it is supposed to read in a file full of
 *         options in "keyword value comment endline" format and apply them. 
 *
 * Then use the simple methods to search for an option and assign its value.
 * the method does not change the value if keyword is not found and returns 1.
 * option("keyword",keyvalue);
 * option("keyword",string);
 * 
 */

#include <string>
#include <iostream>
#include <fstream>
#include <map>
#include <list>
#include <cctype>

using namespace std;

class options{
 public:
  options(int argc, char *argv[]);
  ~options(void){};

  // public "get" options, return 1 if mykey is not found.
  // it is possible to call with "blah" and the conversion will work.
  int Get(string mykey, string &myvalue);
  int Get(string mykey, int &myvalue);
  int Get(string mykey, double &myvalue);
  int Get(string mykey, float &myvalue);

  list<string> &GetList(void){ return optionlist;};
  map<string,string> &GetMap(void){ return optionmap;};
  

  int listsize;

 private:
  // map contains keys and values from --key=value syntax.
  map<string,string> optionmap;
  // list contains all other arguments not preceeded by "--"
  list<string> optionlist;

  int GetOptionsFromFile(string filename);

};

options::options(int argc, char *argv[]){
  
  for(int i=1; i<argc; i++){
    string myinput = argv[i];
    if(!(argv[i][0] == '-' && argv[i][1] == '-')){
      optionlist.push_back(myinput);
      continue;
    }
    int equalsign = myinput.find('=',0);
    string mykey = myinput.substr(2,equalsign - 2);
    string myvalue = myinput.substr(equalsign+1,myinput.size()-equalsign);
    optionmap.insert(pair<string,string>(mykey,myvalue));

    // cout << myinput << " " << mykey << " " << myvalue << endl;
    // cout << "key " << mykey << " " << optionmap[mykey] << endl;

    if(mykey == "options")GetOptionsFromFile(myvalue);

  }

  cout << endl << "Test map" << endl;
  map<string,string>::iterator pmap;
  for(pmap = optionmap.begin(); pmap != optionmap.end(); pmap++){
    cout << pmap->first << " " << pmap->second << endl;
  }

  cout << endl << "Test list" << endl;
  list<string>::iterator plist;
  for(plist = optionlist.begin(); plist != optionlist.end(); plist++){
    cout << *plist << endl;
  }
  cout << endl;

  listsize = optionlist.size();

}



int options::GetOptionsFromFile(string filename){
  ifstream in(filename.c_str());

  if(!in){
    cerr << "options::GetOptionsFromFile can not open " << filename << endl;
    exit(1);
  }

  // parse the input file.
  while(!in.eof()){
    string instring, firstword, secondword;
    char line[1024];

    in.getline(line,1024);

    // if the line is empty, continue.
    if(!strlen(line))continue;

    // The most common "comment" entries that do not conflict either with
    // well-formed filenames nor with my standard options.
    if(line[0] == '#')continue;                    // bash style comment
    if(line[0] == '*')continue;                    // paw style comment
    if(line[0] == '/' && line[1] == '/')continue;  //c,c++ style comment
    if(line[0] == '!')continue;                    // fortran inline comment

    instring = line;

    //if(instring.size() == 0)continue;
    // test the first character for a comment.

    // parse out first word.
    int start = instring.find_first_not_of(' ',0);
    int end = instring.find_first_of(' ',start);
    if(end == string::npos)end = instring.size();

    if(start != string::npos && end != string::npos)
      firstword = instring.substr(start,end - start);

    start = instring.find_first_not_of(' ',end);
    end = instring.find_first_of(' ',start);
    if(end == string::npos)end = instring.size();

    if(start != string::npos && end != string::npos)
      secondword = instring.substr(start,end - start);

    if(secondword.size() == 0)secondword = "1";
    optionmap[firstword] = secondword;


  }

  in.clear();
  in.close();
  return 0;
}


int options::Get(string mykey, string &myvalue){
  string myresult;
  myresult = optionmap[mykey];

  if(myresult.size()){
    myvalue = myresult;
    return 0;
  }
  else return 1;
}

int options::Get(string mykey, int &myvalue){
  
  string tempvalue;
  int err = Get(mykey,tempvalue);
  //check tempvalue to see if it is really a number.

  if(!err)myvalue = atoi(tempvalue.c_str());

  return err;
}

int options::Get(string mykey, float &myvalue){

  string tempvalue;
  int err = Get(mykey,tempvalue);
  //check tempvalue to see if it is really a number.

  if(!err)myvalue = (float) atof(tempvalue.c_str());

  return err;
}

int options::Get(string mykey, double &myvalue){
  string tempvalue;
  int err = Get(mykey,tempvalue);
  //check tempvalue to see if it is really a number.

  if(!err)myvalue = atof(tempvalue.c_str());

  return err;
}


/*
#include <iostream>
#include "options.h"

using namespace std;

int main(int argc, char *argv[]){

  string returnstring;

  options myoptions(argc, argv);

  myoptions.Get("key",returnstring);
  cout << "key " << returnstring << endl;
 
  myoptions.Get("notkey",returnstring);

  int value;
  myoptions.Get("value",value);
  cout << "value " << value << endl;

  cout << "done " << endl;

  list<string> mylist;
  mylist = myoptions.GetList();

  cout << "look at list again" << endl;
  list<string>::iterator plist;
   for(plist = mylist.begin(); plist != mylist.end(); plist++){
    cout << *plist << endl;
  }
 


  return 0;
}
*/
