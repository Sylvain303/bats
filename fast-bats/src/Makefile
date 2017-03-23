CXXFLAGS=-Wall -std=c++11 -g
CXX=g++

%.o: %.cpp
	@echo "Compiling: $< -> $@"
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

#%: %.o
#	$(CXX) $< -o $@

clean:
	rm -f *.o
	find . -maxdepth 1 -type f -executable -a ! -name \*.sh -delete
