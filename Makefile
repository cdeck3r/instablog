.PHONY: clean lint requirements venv freeze doc init

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME = instablog
PROJECT_ENV = venv
PYTHON_INTERPRETER = python3

DOCS_DIR = docs
DOCS_SITE = docs_site
HUGO = hugo/hugo
HUGO_THEME_DIR = ${DOCS_SITE}/themes/onedly
HUGO_THEME_URL = https://github.com/cdeck3r/OneDly-Theme.git
PLANTUML_JAR = plantuml/plantuml.jar

################################################################################
# Check for tools
################################################################################

# Hugo static website generator
ifeq (,$(wildcard ${HUGO}))
$(warning WARNING: No hugo found!)
endif

ifeq (,$(wildcard ${HUGO_THEME_DIR}))
HAS_HUGO_THEME=False
$(warning WARNING: No hugo theme found!)
endif

# git version control
ifeq (,$(shell which git))
$(warning WARNING: No git found!)
endif

# java jre
ifeq (,$(shell which java))
HAS_JAVA=False
$(warning WARNING: No java found!)
else
HAS_JAVA=True
endif

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Install Python Dependencies
requirements: test_environment
	pip install --no-cache-dir -U pip setuptools wheel
	pip install --no-cache-dir -r requirements.txt

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 --select F src

## testing using pytest
test:
	pytest -v -ra -rf -x


## Set up python interpreter environment and install the requirements.txt
create_environment: test_environment requirements.txt
ifeq (True,$(HAS_CONDA))
		@echo ">>> Detected conda, creating conda environment."
ifeq (3,$(findstring 3,$(PYTHON_INTERPRETER)))
	conda create --name $(PROJECT_NAME) python=3
else
	conda create --name $(PROJECT_NAME) python=2.7
endif
		@echo ">>> New conda env created. Activate with:\nsource activate $(PROJECT_NAME)"
else
	@echo ">>> Create a new virtualenv for $(PROJECT_ENV)"
	test -d $(PROJECT_ENV) || virtualenv --always-copy -p $(PYTHON_INTERPRETER) $(PROJECT_ENV)
	$(PROJECT_ENV)/bin/pip --no-cache-dir install -Ur requirements.txt
	touch $(PROJECT_ENV)/bin/activate
	@echo ">>> New virtualenv created. Activate with:\nsource $(PROJECT_ENV)/bin/activate"
endif

## Test python environment is setup correctly
test_environment:
	$(PYTHON_INTERPRETER) test_environment.py

## freeze current python environment
freeze:
	. ${PROJECT_ENV}/bin/activate && ${PROJECT_ENV}/bin/pip --no-cache-dir freeze > requirements.txt

## remove the current python environment
clean_environment:
	rm -rf ${PROJECT_ENV}

## setup a completely new virtualenv venv, deletes an old one
venv: clean_environment create_environment

## generate complete doc 
doc: hugotheme plantuml
	${HUGO} -s "${DOCS_SITE}" -d "${DOCS_DIR}"

## hugo theme install 
hugotheme:
ifeq (False,$(HAS_HUGO_THEME))
	git submodule add ${HUGO_THEME_URL} "${HUGO_THEME_DIR}"
endif


## generate UML diagrams using plantuml; generate always all diagrams
UML_DIR = ${DOCS_SITE}/content/uml
UML_SRC       := $(foreach sdir,$(UML_DIR),$(wildcard $(sdir)/*.txt))
UML_PNG       := $(patsubst %.txt,%.png,$(UML_SRC))
plantuml: $(UML_PNG)
$(UML_DIR)/%.png: $(UML_DIR)/%.txt
	@echo ">>> run plantuml... "
ifeq (True,$(HAS_JAVA))
		-java -jar "${PLANTUML_JAR}" -tpng -v -o "${PROJECT_DIR}/${DOCS_SITE}/content/uml" $+
endif

## install supplemental tools
init: 
	./install_supplementals.sh

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
