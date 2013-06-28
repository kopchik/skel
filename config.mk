GIT_LS_COMMAND= git ls-files | grep -v -e Makefile
GIT_FILES=      $(shell $(GIT_LS_COMMAND))   # GNU Make compatible
GIT_FILES!=     $(GIT_LS_COMMAND)            # BSD Make compatible

FILES?=         $(GIT_FILES)
CURDIR?=        $(.CURDIR)                   # BSD Make compatibility

COMMAND?=       ln -sf
DEST?=          $(HOME)

.PHONY: all
all:
	@echo Usage:
	@echo make install - Run default command set in the Makefile \(default is to symlink\)

.PHONY: install $(FILES)
install: $(FILES)

$(FILES):
	@echo $(DEST)/$@
	@if test ! -d `dirname "$(DEST)/$@"`; then \
	  mkdir -p `dirname "$(DEST)/$@"`; \
	fi
	@if test -e "$(DEST)/$@"; then \
	  rm "$(DEST)/$@"; \
	fi
	@$(COMMAND) "$(CURDIR)/$@" "$(DEST)/$@"

