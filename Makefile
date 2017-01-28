.PHONY: publish watch

build: iut-php.html iut-extended.html isima-php.html

watch:
	watchmedo shell-command --patterns="*.md" --recursive --command='make build'

iut-php.html: src/me.md src/agenda/iut-php.md src/common/*.md src/iut/*.md
	landslide iut-php.cfg

iut-extended.html: src/me.md src/agenda/iut-extended.md src/common/*.md src/extended/*.md
	landslide iut-extended.cfg

isima-php.html: src/me.md src/agenda/isima-php.md src/common/*.md src/isima/*.md
	landslide isima-php.cfg

clean:
	rm *.html

publish: build
	./scripts/publish
