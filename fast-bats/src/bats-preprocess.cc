#include <string>
#include <iostream>
#include <cctype>
#include <cstdio>
#include <vector>
#include <regex>
#include <sstream>

using namespace std;

bool is_utf8(const char * string)
{
    if (!string)
        return true;

    const unsigned char * bytes = (const unsigned char *)string;
    int num;

    while (*bytes != 0x00)
    {
        if ((*bytes & 0x80) == 0x00)
        {
            // U+0000 to U+007F
            num = 1;
        }
        else if ((*bytes & 0xE0) == 0xC0)
        {
            // U+0080 to U+07FF
            num = 2;
        }
        else if ((*bytes & 0xF0) == 0xE0)
        {
            // U+0800 to U+FFFF
            num = 3;
        }
        else if ((*bytes & 0xF8) == 0xF0)
        {
            // U+10000 to U+10FFFF
            num = 4;
        }
        else
            return false;

        bytes += 1;
        for (int i = 1; i < num; ++i)
        {
            if ((*bytes & 0xC0) != 0x80)
                return false;
            bytes += 1;
        }
    }

    return true;
}

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

Callable_func::Callable_func(const string &func_name,
    ptr_param_func func_ptr,
    bool new_line = true) {
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

int main(int argc, char **argv)
{
  init_callable();
  if(argc > 1)
  {
    bool found(false);
    string param;

    if(argc > 2) {
      param = argv[2];
    }

    for(auto f : callable) {
      if(f.func_name == argv[1]) {
        cout << f.func_ptr(param_func({in_string, (void*) &param}));
        // by default we put a new_line here, for better function call display
        if(f.new_line)
          cout << endl;
        found = true;
        break;
      }
    }

    if(not found)
      cout << "unknown func: " << argv[1] << endl;
  }
  return 0;
}
