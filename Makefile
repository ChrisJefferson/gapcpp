# sample makefile
CC=cc
GAPARCH=x86_64-apple-darwin14.1.0-gcc-default64
GAC=/Users/caj/work/source/gap/gap/bin/$(GAPARCH)/gac
CHECK=0

DEBUGFLAGS=

ifdef TIMING
timingflag = -DENABLE_TIMING
else
timingflag =
endif

ifneq ($(CHECK),0)
checkflag = $(DEBUGFLAGS) -DDEBUG_LEVEL=$(CHECK)
else
checkflag = -DDEBUG_LEVEL=0
endif

ifndef OPT
OPT = -O3
endif

ifdef PRINT
printflag = -DDEBUG_PRINT_LEVEL=$(PRINT)
else
printflag =
endif

MYCFLAGS=-Wall -Wextra -g -IYAPB++/source

BUILDSTUFF=-L "-lstdc++" -o bin/$(GAPARCH)/hellod.so -d src/hellod.cc src/cppmapper.cc

library : # Let's always rebuild src/hellod.c src/cppmapper.cc
	mkdir -p bin/$(GAPARCH)
	$(GAC)  -p "$(MYCFLAGS) $(timingflag) $(checkflag) $(OPT) $(printflag)"  $(BUILDSTUFF)

# By default, only build library, as symmetry_detect requires C++11
all: @BUILDLIST@

symmetry_detect : .FORCE
	$(CXX) $(MYCFLAGS) -std=gnu++0x YAPB++/simple_graph/symmetry_detect.cc YAPB++/simple_graph/symmetry_parse.cc  YAPB++/simple_graph/gason/gason.cpp  YAPB++/simple_graph/simple_graph.cc YAPB++/simple_graph/simple_parser.cc $(timingflag) $(checkflag) $(OPT) $(printflag) -I YAPB++/source -o symmetry_detect

clean:
	rm -rf bin

distclean: clean
	rm -rf Makefile

doc:
	gap -A -q -T < makedoc.g

.PHONY: all default clean distclean doc

.FORCE: