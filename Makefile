SRC_DIR = ptl
DOCS_DIR = docs
VERSION=$(shell python setup.py --version)
FULLNAME=$(shell python setup.py --fullname)
FORMATS=--formats=bztar

.PHONY: all init devinit build docs pot mo mo-all test requirements help \
	publish publish-pypi test-publish-pypi publish-sourceforge

all: help

help:
	@echo "Help"
	@echo "----"
	@echo
	@echo "  init - install recommended dependencies in virtualenv"
	@echo "  devinit - install full dependencies in virtualenv"
	@echo "  mininit - install min versions of dependencies in virtualenv"
	@echo "  test - run tests"
	@echo "  build - create sdist with required prep"
	@echo "  pot - update the POT translations templates"
	@echo "  mo - build MO files for languages listed in locale/LINGUAS"
	@echo "  mo-all - build MO files for all languages (only for testing)"
	@echo "  requirements - (re)generate pinned and minimum requirements"
	@echo "  publish-pypi - publish on PyPI"
	@echo "  test-publish-pypi - publish on PyPI testing platform"
	@echo "  publish-sourceforge - publish on sourceforge"
	@echo "  publish - publish on PyPI and sourceforge"
	@echo "  clean - remove generated files"

init:
	@[ -n "$$VIRTUAL_ENV" ] || { echo "No virtualenv!"; exit 1; }
	@echo "Installing recommended dependencies"
	pip install --use-mirrors -r requirements/recommended.txt

devinit:
	@[ -n "$$VIRTUAL_ENV" ] || { echo "No virtualenv!"; exit 1; }
	@echo "Installing full dependencies for development and testing"
	pip install --use-mirrors -r requirements/development.txt

mininit: min-required.txt
	@[ -n "$$VIRTUAL_ENV" ] || { echo "No virtualenv!"; exit 1; }
	@echo "Installing minimum versions of dependencies"
	pip install --use-mirrors -r min-required.txt

COVERAGE=coverage run --source=ptl

test:
	PTL_TESTING=ALL PYTHONPATH=. ${COVERAGE} `which steadymark` README.md
	#${COVERAGE} py.test --pep8

build: requirements.txt docs mo
	python setup.py sdist ${FORMATS} ${TAIL}

docs:
	# Make sure the submodule with docs theme is pulled and up-to-date.
	git submodule update --init
	# The following creates the HTML docs.
	make -C docs html ${TAIL}

pot:
	@${SRC_DIR}/tools/createptlpot

mo:
	python setup.py build_mo ${TAIL}

mo-all:
	python setup.py build_mo --all

clean:
	@if git clean -ndX | grep .; then				\
	   printf 'Remove these files? (y/N) '; read ANS;		\
	   case $$ANS in [yY]*) git clean -fdX;; *) exit 1;; esac	\
	 fi

publish-pypi:
	python setup.py sdist ${FORMATS} upload

test-publish-pypi:
	python setup.py sdist ${FORMATS} upload \
		-r https://testpypi.python.org/pypi

#scp -p dist/ptl-client-0.9.tar.bz2 \
#jsmith@frs.sourceforge.net:/home/frs/project/translate/ptl client/0.9/

publish-sourceforge:
	@echo -n "We don't trust automation that much."
	@echo "The following is the command you need to run"
	@echo 'scp -p dist/${FULLNAME}.tar.bz2' \
		jsmith@frs.sourceforge.net:"/home/frs/project/translate/ptl-client/${VERSION}/"'
	@echo 'scp -p release/RELEASE-NOTES-${VERSION}.rst \
	jsmith@frs.sourceforge.net:"/home/frs/project/translate/Pootle/${VERSION}/README.rst"

publish: publish-pypi publish-sourceforge

# Perform forced build using -W for the (.PHONY) requirements target
requirements:
	$(MAKE) -W $(REQFILE) min-required.txt requirements.txt

REQS=.reqs
REQFILE=requirements/recommended.txt

requirements.txt: $(REQFILE) requirements/required.txt # by inclusion
	@set -e;							\
	 case `pip --version` in					\
	   "pip 0"*|"pip 1.[012]"*)					\
	     virtualenv --no-site-packages --clear $(REQS);		\
	     source $(REQS)/bin/activate;				\
	     echo starting clean install of requirements from PyPI;	\
	     pip install --use-mirrors -r $(REQFILE);			\
	     : trap removes partial/empty target on failure;		\
	     trap 'if [ "$$?" != 0 ]; then rm -f $@; fi' 0;		\
	     pip freeze | grep -v '^wsgiref==' | sort > $@ ;;		\
	   *)								\
	     : only pip 1.3.1+ processes --download recursively;	\
	     rm -rf $(REQS); mkdir $(REQS);				\
	     echo starting download of requirements from PyPI;		\
	     pip install --download $(REQS) -r $(REQFILE);		\
	     : trap removes partial/empty target on failure;		\
	     trap 'if [ "$$?" != 0 ]; then rm -f $@; fi' 0;		\
	     (cd $(REQS) && ls *.tar* |					\
	      sed -e 's/-\([0-9]\)/==\1/' -e 's/\.tar.*$$//') > $@;	\
	 esac; 

min-required.txt: requirements/*.txt
	@if grep -q '>[0-9]' $^; then				\
	   echo "Use '>=' not '>' for requirements"; exit 1;	\
	 fi
	@echo "creating $@"
	@# uses `ls -r` to alphabetically reverse req files for better ordering
	@cat `ls -r $^` | sed -n '/=/{s/>=/==/;s/<.*//;p;}' > $@
