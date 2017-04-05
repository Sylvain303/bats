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
  return cin.eof();
  //this->parsed.size() == 0;
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
