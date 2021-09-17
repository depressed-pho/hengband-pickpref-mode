EMACS ?= emacs

all:
	${EMACS} --no-init-file --no-site-file -batch \
		-f batch-byte-compile *.el

clean:
	rm -f *.elc
