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

	const char *c_str = ((string *)p.p)->c_str();
  char buf[5];

	while (*c_str) {
    if(*c_str == ' ') {
      result += "_";
    } else if(ispunct(*c_str)) {
      sprintf(buf, "-%02x", *c_str);
      result += buf;
    } else {
      result += *c_str;
    }

		++c_str;
  }

  return result;
}

string encode_name(const string &s) {
  return encode_name(param_func({in_string, (void *) &s}));
}

string bash_eval(const string &bash_string) {
  return bash_string;
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
      quoted_name = m[0];
      body = m[1];
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

struct Callable_func {
  string func_name;
  string (*func_ptr)(const param_func&);
};

vector<Callable_func> callable;

void init_callable()
{
  Callable_func f;

  f.func_name = "encode_name";
  f.func_ptr = encode_name;
  callable.push_back(f);

  f.func_name = "preprocess";
  f.func_ptr = preprocess;
  callable.push_back(f);
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
        cout << f.func_ptr(param_func({in_string, (void*) &param})) << endl;
        found = true;
        break;
      }
    }

    if(not found)
      cout << "unknown func: " << argv[1] << endl;
  }
  return 0;
}
