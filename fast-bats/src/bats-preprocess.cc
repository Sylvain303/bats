#include <string>
#include <iostream>
#include <cctype>
#include <cstdio>
#include <vector>
#include <regex>
#include <sstream>

using namespace std;

enum type_param {
  in_string,
  none
};

struct param_func {
  type_param type_p;
  void *p;
};

string encode_name(const param_func &p) {
  string result("test_");

  const char *c = ((string *)p.p)->c_str();
  char buf[5];

  while (*c) {
    if(*c == ' ' or *c == '_') {
      result += "_";
    } else if(ispunct(*c)) {
      sprintf(buf, "-%02x", *c);
      result += buf;
    } else {
      result += *c;
    }

    ++c;
  }

  return result;
}

string encode_name(const string &s) {
  return encode_name(param_func({in_string, (void *) &s}));
}

// fake bash eval behavior, we simply remove quote (we suppose quoted string)
string bash_eval(const string &bash_string) {
  // copy all but first and last char
  string result(bash_string, 1, bash_string.size() -2);

  return result;
}

string preprocess(const param_func &p) {
  vector<string> tests;
  int index(0);

  regex pattern("^ *@test  *([^ ].*)  *\\{ *(.*)$");
  smatch m;

  string line, quoted_name, name, encoded_name, body;
  stringstream output;


  while(getline(cin, line)) {
    ++index;

    if(regex_match(line, m, pattern)) {
      quoted_name = m[1];
      body = m[2];
      name = bash_eval(quoted_name);
      encoded_name = encode_name(name);

      tests.push_back(encoded_name);

      output <<
        encoded_name << "() { bats_test_begin " <<
        quoted_name << " " << index << "; " << body
        ;
    } else {
      output << line;
    }

    output << "\n";
  }

  for(auto test_name : tests) {
    output << "bats_test_function " << test_name << "\n";
  }

  return output.str();
}

// Callable_func is a wrapper object to allow our function to
// be called from command line with a string. We also allow to
// control the print of an extra new_line.
typedef string (*ptr_param_func)(const param_func&);
class Callable_func {
public:
  string func_name;
  ptr_param_func func_ptr;
  bool new_line;

  Callable_func(const string&, ptr_param_func, bool);
};

Callable_func::Callable_func(
    const string &func_name,
    ptr_param_func func_ptr,
    bool new_line = true)
{
  this->func_name = func_name;
  this->func_ptr = func_ptr;
  this->new_line = new_line;
}

// our table of function
vector<Callable_func> callable;

// fill our list of function
void init_callable()
{
  callable.push_back(Callable_func("encode_name", encode_name));
  callable.push_back(Callable_func("preprocess", preprocess, false));
}

class Parsed_command
{
public:
  vector<string> parsed;
  Callable_func *func;

  Parsed_command();
  bool eof();
};

Parsed_command::Parsed_command()
{
  this->func = nullptr;
}

bool Parsed_command::eof() {
  return this->parsed.size() == 0;
}


// from http://stackoverflow.com/questions/236129/split-a-string-in-c#236803
template < class ContainerT >
void tokenize(const std::string& str, ContainerT& tokens,
              const std::string& delimiters = " ", bool trimEmpty = false)
{
   std::string::size_type pos, lastPos = 0, length = str.length();

   using value_type = typename ContainerT::value_type;
   using size_type  = typename ContainerT::size_type;

   while(lastPos < length + 1)
   {
      pos = str.find_first_of(delimiters, lastPos);
      if(pos == std::string::npos)
      {
         pos = length;
      }

      if(pos != lastPos || !trimEmpty)
         tokens.push_back(value_type(str.data()+lastPos,
               (size_type)pos-lastPos ));

      lastPos = pos + 1;
   }
}

Callable_func *find_func(const string &token)
{
  Callable_func *fp(nullptr);
  // for taking a pointer we need to use ref
  for(auto &f : callable)
  {
    if(f.func_name == token) {
      fp = &f;
      break;
    }
  }
  return fp;
}

void read_command(Parsed_command &command)
{
  string line;
  getline(cin, line);
  command.parsed.clear();
  tokenize(line, command.parsed, " ", true);
}

void eval(Parsed_command &command)
{
  for(auto t : command.parsed)
  {
    cout << "'" << t << "'";
  }
  cout << endl;

  if(command.parsed.size() > 0) {
    Callable_func *f = find_func(command.parsed[0]);

    if(f) {
      string param;

      if(command.parsed.size() > 1) {
        // to do join or keep or manage splited
        param = command.parsed[1];
      }

      cout << f->func_ptr(param_func({in_string, (void*) &param}));
      // by default we put a new_line here, for better function call display
      if(f->new_line)
        cout << endl;
    }
  }
}

void eval_loop() {
  bool finished(false);
  Parsed_command command;
  while(not finished)
  {
    read_command(command);
    if(command.eof())
    {
      finished = true;
      break;
    }
    eval(command);
    //cout << command;
  }
}

int main(int argc, char **argv)
{
  init_callable();
  if(argc > 1)
  {
    string param;

    if(argc > 2) {
      param = argv[2];
    }

    Callable_func *f(find_func(argv[1]));
    if(f)
    {
      cout << f->func_ptr(param_func({in_string, (void*) &param}));
      // by default we put a new_line here, for better function call display
      if(f->new_line)
        cout << endl;
    }
    else
    {
      cout << "unknown func: " << argv[1] << endl;
    }
  }
  else
  {
    // read from stdin
    eval_loop();
  }
  return 0;
}
