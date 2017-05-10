.PHONY: publish watch

build: iut-php.html iut-extended.html

build-pdf: iut-php.pdf

watch:
	watchmedo shell-command --patterns="*.md" --recursive --command='make build'

iut-php.html: src/me.md src/agenda/iut-php.md src/common/*.md src/iut/*.md
	landslide iut-php.cfg

iut-php.pdf: iut-php.html
	prince iut-php.html -o iut-php.pdf

iut-extended.html: src/me.md src/agenda/iut-extended.md src/common/*.md src/extended/*.md
	landslide iut-extended.cfg

clean:
	rm *.html

publish: build
	./scripts/publish
