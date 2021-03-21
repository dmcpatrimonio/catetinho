# Global variables {{{1
# ================
# Where make should look for things
VPATH = lib
vpath %.csl _csl
vpath %.yaml .:_spec
vpath default.% _lib
vpath reference.% _lib
# Sets a base directory for project files that reside somewhere else,
# for example in a synced virtual drive.
SHARE = ~/dmcp/arqtrad/arqtrad

# Branch-specific targets and recipes {{{1
# ===================================

ANYTHING = $(filter_out _site,$(wildcard *))

PANDOC/CROSSREF := docker run --rm -v "`pwd`:/data" \
	--user "`id -u`:`id -g`" pandoc/crossref:2.12

PANDOC/LATEX := docker run --rm -v "`pwd`:/data" \
	--user "`id -u`:`id -g`" pandoc/latex:2.12

.jekyll-cache : $(ANYTHING) _site/Gemfile.lock | _csl
	@bundle exec jekyll build

serve : Gemfile.lock
	@bundle exec jekyll serve --incremental

# Genérico, restringir conforme aplicável
_book/%.docx : %.md article_docx.yaml _data/biblio.yaml
	$(PANDOC/CROSSREF) -o $@ -d _spec/article_docx.yaml $<

docs/%.md : %.md jekyll.yaml _data/biblio.yaml
	$(PANDOC/CROSSREF) -o $@ -d _spec/jekyll.yaml $<

figures/%.png : %.svg
	inkscape -f $< -e $@ -d 96

_csl :
	git clone https://github.com/citation-style-language/styles _csl

_site :
	@-gh repo clone catetinho _site -- \
		-b gh-pages --depth=1 --recurse-submodules

Gemfile.lock : Gemfile _config.yaml | _site
	@cd _site && git pull
	@bundle install

# vim: set foldmethod=marker tw=72 shiftwidth=2 tabstop=2 :
