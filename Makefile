PACKAGE = mandriva-kde4-config
NAME = mandriva-kde4-config
VERSION = 2012

clean:
	find . -type d -name '.xvpics' -o -name '*~' |xargs rm -rf

# rules to build a distributable rpm

dist: changelog
	rm -rf $(NAME)-$(VERSION)*.tar* $(NAME)-$(VERSION)
	@if [ -e ".svn" ]; then \
		$(MAKE) dist-svn; \
	elif [ -e ".git" ]; then \
		$(MAKE) dist-git; \
	else \
		echo "Unknown SCM (not SVN nor GIT)";\
		exit 1; \
	fi;
	$(info $(NAME)-$(VERSION).tar.xz is ready)

dist-git: 
	@git archive --prefix=$(NAME)-$(VERSION)/ HEAD | xz -c > $(NAME)-$(VERSION).tar.xz;

dist-svn: 
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
