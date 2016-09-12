# Makefile for browsepy

.PHONY: clean base browsepy

base:
	apt-get update -qq
	apt-get install -y build-essential subversion wget software-properties-common
	add-apt-repository ppa:git-core/ppa -y
	apt-get install git -y

fix-pip:
	wget https://bootstrap.pypa.io/get-pip.py
	python get-pip.py
	rm get-pip.py
	pip install --upgrade setuptools
	pip install --upgrade virtualenv
	pip install --upgrade pip
	@echo
	pip --version
	@echo "Latest pip installed"

jupyter:
	pip install jupyter
