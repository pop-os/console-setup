SHELL = /bin/sh

build : compose_files gziped_acmfiles KeyboardNames.pl

%.gz : %
	gzip -9 <$< >$@

acmfiles = $(wildcard acm/*.acm)

gziped_acmfiles = $(addsuffix .gz, $(acmfiles))

gziped_acmfiles : $(gziped_acmfiles)

charmaps = $(basename $(notdir $(acmfiles)))

compose_files = $(addprefix compose.,$(addsuffix .inc, $(charmaps)))

$(compose_files): charmap = $(patsubst compose.%.inc,%, $@)

VISCII-XCOMPOSE = locale/vi_VN.viscii/Compose
ISO-8859-1-XCOMPOSE = locale/iso8859-1/Compose
ISO-8859-2-XCOMPOSE = locale/iso8859-2/Compose
ISO-8859-3-XCOMPOSE = locale/iso8859-3/Compose
ISO-8859-4-XCOMPOSE = locale/iso8859-4/Compose
ISO-8859-7-XCOMPOSE = locale/iso8859-7/Compose
ISO-8859-9-XCOMPOSE = locale/iso8859-9/Compose
ISO-8859-13-XCOMPOSE = locale/iso8859-13/Compose
ISO-8859-14-XCOMPOSE = locale/iso8859-14/Compose
ISO-8859-15-XCOMPOSE = locale/iso8859-15/Compose


$(compose_files) :
	echo '# Compose sequences for $(charmap)' >$@
	$(if $($(charmap)-XCOMPOSE), \
		./compose_translator --acm acm/$(charmap).acm \
				     $($(charmap)-XCOMPOSE) >>$@)

compose_files : $(compose_files)


KeyboardNames.pl : xmlreader ckb/rules/xfree86.xml
	./xmlreader >$@


.PHONY: clean
clean:
	-rm -f *~
	-rm -f acm/*.acm.gz
	-rm -rf compose $(compose_files)
	-rm -f KeyboardNames.pl
	-rm -rf keymaps
	-rm -f keymaps.dir names.list

