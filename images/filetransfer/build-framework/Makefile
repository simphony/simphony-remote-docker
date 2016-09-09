.PHONY: clean base

base:
	apt-get update -qq
	apt-get install -y build-essential wget software-properties-common
	add-apt-repository ppa:git-core/ppa -y
	apt-get install git nodejs npm nodejs-legacy php5-fpm -y
	update-rc.d php5-fpm defaults
	
app:
	npm install -g bower
	cd /webapp && bower install --allow-root --save angular-filemanager
	# Replace default index with one with appropriate configuration
	cp index.html /webapp/bower_components/angular-filemanager/
