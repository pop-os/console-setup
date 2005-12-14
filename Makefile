SHELL = /bin/sh

all: build

build:
	cd Fonts; $(MAKE) build
	cd Keyboard; $(MAKE) build
	touch build

.PHONY: clean
clean:
	cd Fonts; $(MAKE) clean
	cd Keyboard; $(MAKE) clean
	-rm -f *~
	-rm -f build

