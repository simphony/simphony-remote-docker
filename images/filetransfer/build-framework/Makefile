.PHONY: clean base browsepy

base:
	apt-get update -qq
	apt-get install -y build-essential wget software-properties-common
	add-apt-repository ppa:git-core/ppa -y
	apt-get install git nodejs npm nodejs-legacy php5-fpm -y
	
app:
	npm install -g bower
	cd /webapp && bower install --allow-root --save angular-filemanager
