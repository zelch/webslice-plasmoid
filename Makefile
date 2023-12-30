SHELL := /bin/bash
 
 
test: ## Run Plasmaviewer to test the plasmoid
	plasmoidviewer -a ./com.aehallh.webslice/

locales: ## Run the Messages.sh to compile languages
	./com.aehallh.webslice/contents/locale/Messages.sh
	
dl-locales-de: ## Download de strings
	transifex_token=`cat transifex.token`; curl -L --user api:$$transifex_token -X GET "https://www.transifex.com/api/2/project/webslice/resource/cqcbplasmawebslicepot/translation/de/?file" -o com.aehallh.webslice/contents/locale/de/LC_MESSAGES/plasma_applet_com.aehallh.webslice.po

dl-locales-es: ## Download es strings
	transifex_token=`cat transifex.token`; curl -L --user api:$$transifex_token -X GET "https://www.transifex.com/api/2/project/webslice/resource/cqcbplasmawebslicepot/translation/es/?file" -o com.aehallh.webslice/contents/locale/es/LC_MESSAGES/plasma_applet_com.aehallh.webslice.po

dl-locales-nl: ## Download nl strings
	transifex_token=`cat transifex.token`; curl -L --user api:$$transifex_token -X GET "https://www.transifex.com/api/2/project/webslice/resource/cqcbplasmawebslicepot/translation/nl/?file" -o com.aehallh.webslice/contents/locale/nl/LC_MESSAGES/plasma_applet_com.aehallh.webslice.po

dl-locales-ru: ## Download ru strings
	transifex_token=`cat transifex.token`; curl -L --user api:$$transifex_token -X GET "https://www.transifex.com/api/2/project/webslice/resource/cqcbplasmawebslicepot/translation/ru/?file" -o com.aehallh.webslice/contents/locale/ru/LC_MESSAGES/plasma_applet_com.aehallh.webslice.po

dl-locales-all: dl-locales-de dl-locales-es dl-locales-nl dl-locales-ru ## Download from transifex all the locales

upload-pot: ## Upload the source strings to Transifex
	transifex_token=`cat transifex.token`; curl -i -L --user api:$$transifex_token -F file=@com.aehallh.webslice/contents/locale/plasma_applet_com.aehallh.webslice.pot -X PUT "https://www.transifex.com/api/2/project/webslice/resource/cqcbplasmawebslicepot/content/" 

upload-locale-fr: ## Upload fr locale to Transifex
	transifex_token=`cat transifex.token`; curl -i -L --user api:$$transifex_token -F file=@com.aehallh.webslice/contents/locale/fr/LC_MESSAGES/plasma_applet_com.aehallh.webslice.po -X PUT "https://www.transifex.com/api/2/project/webslice/resource/cqcbplasmawebslicepot/translation/fr/"

plasmoid: ## Make the .plasmoid file
	rm -f com.aehallh.webslice.plasmoid
	cd ./com.aehallh.webslice/; \
	zip -9 -r com.aehallh.webslice.plasmoid.zip contents/ metadata.desktop
	mv ./com.aehallh.webslice/com.aehallh.webslice.plasmoid.zip ./com.aehallh.webslice.plasmoid

update: ## Update the installed package
	plasmapkg2 -u com.aehallh.webslice.plasmoid

install: ## Install the package if it's not already there
	plasmapkg2 -i com.aehallh.webslice.plasmoid

help: ## Help target
	@ag '^[a-zA-Z_-]+:.*?## .*$$' --nofilename $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN{FS=": ## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.DEFAULT_GOAL := help
