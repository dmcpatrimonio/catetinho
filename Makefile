# Global variables {{{1
# ================
# Where make should look for things
VPATH = _lib
vpath %.bib bibliography
vpath %.csl _csl
vpath %.yaml .:_spec
vpath default.% _lib
vpath reference.% _lib

# Branch-specific targets and recipes {{{1
# ===================================

ANYTHING = $(filter_out _site,$(wildcard *))
TEXT     = $(shell cat layout.md)

PANDOC/CROSSREF := docker run --rm -v "`pwd`:/data" \
	--user "`id -u`:`id -g`" pandoc/crossref:2.12

PANDOC/LATEX := docker run --rm -v "`pwd`:/data" \
	--user "`id -u`:`id -g`" pandoc/latex:2.12

artigo.docx : $(TEXT) metadata.yaml docx.yaml reference.docx biblio.bib | _csl
	$(PANDOC/CROSSREF) -o $@ -d _spec/docx.yaml $(TEXT) metadata.yaml

.jekyll-cache : $(ANYTHING) _site/Gemfile.lock | _csl
	@bundle exec jekyll build

serve : Gemfile.lock
	@bundle exec jekyll serve --incremental

# Genérico, restringir conforme aplicável
_book/%.docx : %.md docx.yaml default.markdown reference.docx \
	biblio.bib figures | _csl
	$(PANDOC/CROSSREF) -o $@ -d _spec/docx.yaml $<

docs/%.md : %.md jekyll.yaml _data/biblio.yaml
	$(PANDOC/CROSSREF) -o $@ -d _spec/jekyll.yaml $<

figures/%.png : %.svg
	inkscape -f $< -e $@ -d 96

_csl :
	@gh repo clone citation-style-language/styles \
		$@ -- --depth=1

_site :
	@-gh repo clone dmcpatrimonio/catetinho _site -- \
		-b gh-pages --depth=1 --recurse-submodules

Gemfile.lock : Gemfile _config.yaml | _site
	@cd _site && git pull
	@bundle install

# vim: set foldmethod=marker tw=72 shiftwidth=2 tabstop=2 :
