PACKAGE = moondrake-kde4-config
NAME = moondrake-kde4-config
VERSION = 2013.0

clean:
	find . -type d -name '.xvpics' -o -name '*~' |xargs rm -rf

# rules to build a distributable rpm

dist: dist-git
	$(info $(NAME)-$(VERSION).tar.xz is ready)

dist-git: 
	git archive --prefix=$(NAME)-$(VERSION)/ HEAD | xz -c > $(NAME)-$(VERSION).tar.xz;

dist-svn:  changelog
	svn export -q -rBASE . $(NAME)-$(VERSION)
	tar cfJ $(NAME)-$(VERSION).tar.xz $(NAME)-$(VERSION)
	rm -rf $(NAME)-$(VERSION)


.PHONY: ChangeLog log changelog

log: ChangeLog

changelog: ChangeLog

#svn2cl is available in our contrib.
ChangeLog: ../common/username.xml
	@if test -d "$$PWD/.git"; then \
	  ../common/gitlog-to-changelog | sed -e '/\tgit-svn-id:.*/d' > $@.tmp \
	  && mv -f $@.tmp $@ \
	  && git commit ChangeLog -m 'generated changelog' \
	  && if [ -e ".git/svn" ]; then \
	    git svn dcommit ; \
	    fi \
	  || (rm -f  $@.tmp; \
	 echo Failed to generate ChangeLog, your ChangeLog may be outdated >&2; \
	 (test -f $@ || echo git-log is required to generate this file >> $@)); \
	else \
	 svn2cl --accum --authors ../common/username.xml; \
	 rm -f *.bak;  \
	fi;
