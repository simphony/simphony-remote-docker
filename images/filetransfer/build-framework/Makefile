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

browsepy:
	# Install a specific PR on top of 0.4.0 that fixes and encoding problem.
	# See https://github.com/ergoithz/browsepy/pull/2
	pip install git+https://github.com/stefanoborini/browsepy.git@3487ab3b4c3d3b264d83334db3148c45cfeb60a6
