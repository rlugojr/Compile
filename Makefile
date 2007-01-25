
VERSION=
PROGRAM=Compile
SCRIPTS_DIR=/Programs/$(PROGRAM)/Current
PACKAGE_DIR=$(HOME)
PACKAGE_ROOT=$(PACKAGE_DIR)/$(PROGRAM)
PACKAGE_BASE=$(PACKAGE_ROOT)/$(VERSION)
PACKAGE_FILE=$(PACKAGE_DIR)/$(PROGRAM)--$(VERSION)--$(shell uname -m).tar.bz2
CVSTAG=`echo $(PROGRAM)_$(VERSION) | tr "[:lower:]" "[:upper:]" | sed  's,\.,_,g'`

default:

version_check:
	@[ "$(VERSION)" = "" ] && { echo -e "Error: run make with VERSION=<version-number>.\n"; exit 1 ;} || exit 0

cleanup:
	rm -rf Resources/FileHash*
	find * -path "*~" -or -path "*/.\#*" -or -path "*.bak" | xargs rm -f

verify:
	! { cvs up -dP 2>&1 | grep "^[\?]" | grep -v "Resources/SettingsBackup" ;}

dist: version_check cleanup verify
	rm -rf $(PACKAGE_ROOT)
	mkdir -p $(PACKAGE_BASE)
	SignProgram $(PROGRAM)
	cat Resources/FileHash
	ListProgramFiles $(PROGRAM) | cpio -p $(PACKAGE_BASE)
	cd $(PACKAGE_DIR); tar cvp $(PROGRAM) | bzip2 > $(PACKAGE_FILE)
	rm -rf $(PACKAGE_ROOT)
	@echo; echo "Package at $(PACKAGE_FILE)"
	@echo; echo "Now run 'cvs tag $(CVSTAG)'"; echo
	! { cvs up -dP 2>&1 | grep "^M" ;}

manuals:
	mkdir -p man/man1
	for i in `cd bin && grep -l Parse_Options *`; do bn=`basename $$i`; help2man --name=" " --source="GoboLinux" --no-info $$bn > man/man1/$$bn.1; done
