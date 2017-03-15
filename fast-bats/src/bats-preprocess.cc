#include <string>
#include <iostream>
#include <cctype>
#include <cstdio>
#include <vector>

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

string encode_name(string name) {
  string result("test_");

	const char *c_str = name.c_str();
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

struct Callable_func {
  string func_name;
  string (*func_ptr)(string);
};

vector<Callable_func> callable;


void init_callable()
{
  Callable_func f;
  f.func_name = "encode_name";
  f.func_ptr = encode_name;

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
        cout << f.func_ptr(param) << endl;
        found = true;
        break;
      }
    }

    if(not found)
      cout << "unknown func: " << argv[1] << endl;
  }
  return 0;
}
