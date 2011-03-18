prefix = /usr/local
# etcdir must be either /etc or
etcdir = $(prefix)/etc
bootprefix = $(patsubst %/usr,%/,$(prefix:%/=%))
mandir = $(prefix)/share/man

# One font per fontset
fonts-mini = Arabic-VGA16 Armenian-Fixed16 CyrAsia-Fixed16		\
CyrKoi-TerminusBold16 CyrSlav-TerminusBold16 Ethiopian-Goha16		\
Georgian-Fixed16 Greek-VGA16 Hebrew-VGA16 Lao-Fixed16			\
Lat15-TerminusBold16 Lat2-TerminusBold16 Lat38-VGA16			\
Lat7-TerminusBold16 Thai-Fixed16 Uni1-VGA16 Uni2-VGA16 Uni3-Fixed16	\
Vietnamese-Fixed16

fonts-mini-linux = $(addprefix Fonts/, $(addsuffix .psf.gz, $(fonts-mini)))
fonts-mini-freebsd = $(addprefix Fonts/, $(addsuffix .fnt, $(fonts-mini)))

SHELL = /bin/sh

all: build-all

acmfiles = $(wildcard acm/*.acm)

gziped_acmfiles = $(addsuffix .gz, $(acmfiles))

gziped_acmfiles : $(gziped_acmfiles)

%.gz : %
	gzip -9 <$< >$@

build-any: gziped_acmfiles
	cd Keyboard && $(MAKE) build

build-linux: build-any
	cd Fonts && $(MAKE) build-linux

build-freebsd: build-any
	cd Fonts && $(MAKE) build-freebsd

build-mini-linux: build-linux build-any
	cd Keyboard && $(MAKE) build-mini-linux

build-mini-freebsd: build-freebsd build-any

build-all: build-linux build-freebsd build-mini-linux build-mini-freebsd

.PHONY: install-any
install-any: build-any
	install -d  $(bootprefix)/bin/
	install setupcon $(bootprefix)/bin/
	install -d $(etcdir)/default
	install -m 644 config/keyboard $(etcdir)/default/
	install -m 644 config/console-setup $(etcdir)/default/
	install -d $(mandir)/man1/
	install -m 644 man/setupcon.1 $(mandir)/man1/
	install -m 644 man/ckbcomp.1 $(mandir)/man1/
	install -d $(mandir)/man5/
	install -m 644 man/keyboard.5 $(mandir)/man5/
	install -m 644 man/console-setup.5 $(mandir)/man5/

.PHONY: install-linux
install-linux: build-linux install-any
	install -d $(prefix)/share/consolefonts/
	install -m 644 Fonts/*.psf.gz $(prefix)/share/consolefonts/
	install -d $(prefix)/share/consoletrans
	install -m 644 acm/*.acm.gz $(prefix)/share/consoletrans/
	install -d $(prefix)/bin/
	install Keyboard/ckbcomp $(prefix)/bin/
	if [ -z "$(xkbdir)" ]; then \
		mkdir -p $(etcdir)/console-setup \
		&& cp -r Keyboard/ckb/ $(etcdir)/console-setup/ckb; \
	fi
	install -d $(etcdir)/console-setup
	install -m 644 Keyboard/compose.*.inc $(etcdir)/console-setup/
	install -m 644 Keyboard/remap.inc $(etcdir)/console-setup/

.PHONY: install-freebsd
install-freebsd: build-freebsd install-any
	install -d $(prefix)/share/syscons/fonts/
	install -m 644 Fonts/*.fnt $(prefix)/share/syscons/fonts/
	install -d $(prefix)/share/syscons/scrnmaps/
	install -m 644 Fonts/*.scm $(prefix)/share/syscons/scrnmaps/
	install -d $(prefix)/share/consoletrans
	install -m 644 acm/*.acm $(prefix)/share/consoletrans/
	install -d $(prefix)/bin/
	install Keyboard/ckbcomp $(prefix)/bin/
	install -d $(etcdir)/console-setup
	install -m 644 Fonts/terminfo $(etcdir)/console-setup/
	install -m 644 Fonts/termcap $(etcdir)/console-setup/
	install -m 644 Keyboard/dkey.*.inc $(etcdir)/console-setup/
	install -m 644 Keyboard/remap.inc $(etcdir)/console-setup/
	if [ -z "$(xkbdir)" ]; then \
		mkdir -p $(etcdir)/console-setup \
		&& cp -r Keyboard/ckb/ $(etcdir)/console-setup/ckb; \
	fi

.PHONY : install-mini-linux
install-mini-linux: build-mini-linux install-any
	install -d $(prefix)/share/console-setup-mini/
	install -m 644 Keyboard/*.ekmap.gz $(prefix)/share/console-setup-mini
	install -d $(prefix)/share/consolefonts/
	install -m 644 $(fonts-mini-linux) $(prefix)/share/consolefonts/
	install -d $(prefix)/bin/
	install -m 644 Keyboard/ckbcomp-mini $(prefix)/bin/
	ln -s ckbcomp-mini $(prefix)/bin/ckbcomp

common-uninstall:
	-for font in Fonts/*.psf.gz; do \
		rm $(prefix)/share/consolefonts/$${font##*/}; \
	done
	-for acm in acm/*.acm.gz acm/*.acm; do \
		rm $(prefix)/share/consoletrans/$${acm##*/}; \
	done
	-for ekmap in Keyboard/*.ekmap.gz; do \
		rm $(prefix)/share/console-setup-mini/$${ekmap##*/}; \
	done
	-for font in Fonts/*.fnt; do \
		rm $(prefix)/share/syscons/fonts/$${font##*/}; \
	done
	-for scm in Fonts/*.scm; do \
		rm $(prefix)/share/syscons/scrnmaps/$${scm##*/}; \
	done
	-rm $(prefix)/share/man/man1/ckbcomp.1
	-rm $(prefix)/share/man/man1/setupcon.1
	-rm $(prefix)/share/man/man5/keyboard.5
	-rm $(prefix)/share/man/man5/console-setup.5
	-rm -r $(etcdir)/console-setup/
	-rm $(etcdir)/default/keyboard
	-rm $(etcdir)/default/console-setup
	-rm $(prefix)/bin/ckbcomp
	-rm $(bootprefix)/bin/setupcon

.PHONY: uninstall-linux
uninstall-linux: build-linux
	$(MAKE) common-uninstall

.PHONY: uninstall-mini-linux
uninstall-mini-linux: build-mini-linux
	$(MAKE) common-uninstall

.PHONY: uninstall-freebsd
uninstall-freebsd: build-freebsd
	$(MAKE) common-uninstall

.PHONY: clean
clean:
	cd Fonts && $(MAKE) clean
	cd Keyboard && $(MAKE) clean
	-rm -f acm/*.acm.gz
	-rm -f *~
	-rm -f build

.PHONY: maintainer-clean
maintainer-clean: clean
	cd Fonts && $(MAKE) maintainer-clean
	cd Keyboard && $(MAKE) maintainer-clean
