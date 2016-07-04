# Makefile for Simphony Framework

# We customised this for a docker image such that the
# framework is no longer installed in a virtual environment
PREFIX ?= /usr/local

PYTHONPATH ?= $(PREFIX)/lib/python2.7/site-packages/

# Envrionment templates for all users
BASHRC_PATH ?= /etc/skel/.bashrc

# Path for MPI in HDF5 suport
MPI_INCLUDE_PATH ?= /usr/include/mpi

SIMPHONYVERSION  ?= 0.3.0
SIMPHONY_JYU_LB_VERSION ?= 0.2.0
SIMPHONY_LAMMPS_VERSION ?= 0.1.5
SIMPHONY_NUMERRIN_VERSION ?= 0.1.1
SIMPHONY_OPENFOAM_VERSION ?= 0.2.1
SIMPHONY_KRATOS_VERSION ?= 0.2.0
SIMPHONY_AVIZ_VERSION ?= 0.1.0
SIMPHONY_MAYAVI_VERSION ?= 0.4.0
SIMPHONY_PARAVIEW_VERSION ?= 0.2.0
JYU_LB_VERSION ?= 0.1.2
AVIZ_VERSION ?= v6.5.0

# Use Paraview OpenFoam? (if no, Paraview from Ubuntu is installed)
USE_OPENFOAM_PARAVIEW ?= no

.PHONY: clean base apt-aviz-deps apt-openfoam-deps apt-simphony-deps apt-lammps-deps apt-mayavi-deps apt-paraview-deps fix-pip fix-python-path aviz lammps jyu-lb kratos numerrin simphony simphony-aviz simphony-lammps simphony-mayavi simphony-openfoam simphony-kratos simphony-jyu-lb simphony-numerrin

clean:
	rm -Rf src/aviz
	rm -Rf src/kratos
	rm -Rf src/lammps
	rm -Rf src/JYU-LB
	rm -Rf src/simphony-openfoam
	rm -Rf src/simphony-numerrin
	@echo
	@echo "Removed temporary folders"

base:
	apt-get update -qq
	apt-get install -y build-essential subversion wget software-properties-common python-software-properties
	add-apt-repository ppa:git-core/ppa -y
	apt-get update -qq
	apt-get install -y git

apt-aviz-deps:
	apt-get update -qq
	apt-get install -y python-qt4 python-qt4-gl qt4-qmake qt4-dev-tools libpng-dev
	@echo
	@echo "Build dependencies for Aviz"

apt-openfoam-deps:
	echo deb http://www.openfoam.org/download/ubuntu precise main > /etc/apt/sources.list.d/openfoam.list
	apt-get update -qq
	apt-get install -y --force-yes openfoam222
	echo 'source /opt/openfoam222/etc/bashrc' >> $(BASHRC_PATH)
	@echo
	@echo "Openfoam installed"

apt-simphony-deps:
	apt-get update -qq
	apt-get install -y python-dev cython libhdf5-serial-dev libatlas-dev libatlas3gf-base
	@echo
	@echo "Build dependencies for simphony installed"

apt-lammps-deps:
	apt-get update -qq
	apt-get install -y mpi-default-bin mpi-default-dev
	@echo
	@echo "Build dependencies for lammps installed"

apt-mayavi-deps:
	apt-get update -qq
	apt-get install -y python-vtk python-qt4 python-qt4-dev python-sip python-qt4-gl libqt4-scripttools python-imaging
	@echo
	@echo "Build dependencies for mayavi installed"

apt-paraview-deps:
	apt-get update -qq
ifeq ($(USE_OPENFOAM_PARAVIEW),yes)
	echo deb http://www.openfoam.org/download/ubuntu precise main > /etc/apt/sources.list.d/openfoam.list
	apt-get update -qq
	apt-get install -y --force-yes paraviewopenfoam410 libhdf5-openmpi-dev
	echo "LD_LIBRARY_PATH=$(PREFIX)/lib:/opt/paraviewopenfoam410/lib/paraview-4.1:\$$LD_LIBRARY_PATH\n" >> $(BASHRC_PATH)
	echo "export LD_LIBRARY_PATH" >> $(BASHRC_PATH)
	echo "PYTHONPATH=/opt/paraviewopenfoam410/lib/paraview-4.1/site-packages/:/opt/paraviewopenfoam410/lib/paraview-4.1/site-packages/vtk:\$$PYTHONPATH" >> $(BASHRC_PATH)
	echo "export PYTHONPATH" >> $(BASHRC_PATH)
	@echo
	@echo "Paraview (openfoam) installed"
else
	apt-get install -y --force-yes paraview libhdf5-openmpi-dev
	echo "LD_LIBRARY_PATH=$(PREFIX)/lib:\$$LD_LIBRARY_PATH" >> $(BASHRC_PATH)
	echo "export LD_LIBRARY_PATH" >> $(BASHRC_PATH)
	@echo
	@echo "Paraview (ubuntu) installed"
endif

apt-kratos-deps:
	apt-get update -qq
	apt-get install -y subversion
	@echo
	@echo "Build dependencies for kratos installed"

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

fix-python-path:
	echo "PYTHONPATH=$(PYTHONPATH):\$$PYTHONPATH" >> $(BASHRC_PATH)
	echo "export PYTHONPATH" >> $(BASHRC_PATH)
	@echo "$(PYTHONPATH) is added to PYTHONPATH"

aviz:
	rm -Rf src/aviz
	git clone --branch $(AVIZ_VERSION) https://github.com/simphony/AViz src/aviz
	(cd src/aviz/src; qmake aviz.pro; make; cp aviz $(PREFIX)/bin/)
	@echo
	@echo "Aviz installed"

lammps:
	rm -Rf src/lammps
        # bulding and installing executable
	git clone --branch r12824 --depth 1 git://git.lammps.org/lammps-ro.git src/lammps
	$(MAKE) -C src/lammps/src ubuntu_simple -j 3
	cp src/lammps/src/lmp_ubuntu_simple $(PREFIX)/bin/lammps
        # bulding and installing python module
	$(MAKE) -C src/lammps/src makeshlib -j 2
	$(MAKE) -C src/lammps/src ubuntu_simple -f Makefile.shlib -j 2
	(cd src/lammps/python; python install.py $(PREFIX)/lib $(PYTHONPATH))
	rm -Rf src/lammps
        # build liggghts
	@echo "Building LIGGGHTS"
	git clone --branch 3.3.0 --depth 1 git://github.com/CFDEMproject/LIGGGHTS-PUBLIC.git src/lammps/myliggghts
	$(MAKE) -C src/lammps/myliggghts/src fedora -j 1
	cp src/lammps/myliggghts/src/lmp_fedora $(PREFIX)/bin/liggghts
	@echo
	@echo "Lammps/LIGGGHTS solver installed"

jyu-lb:
	rm -Rf src/JYU-LB
	git clone --branch $(JYU_LB_VERSION) https://github.com/simphony/JYU-LB.git src/JYU-LB
	$(MAKE) -C src/JYU-LB -j 2
	cp src/JYU-LB/bin/jyu_lb_isothermal.exe $(PREFIX)/bin/jyu_lb_isothermal.exe
	rm -Rf src/JYU-LB
	@echo
	@echo "jyu-lb solver installed"


kratos:
	rm -Rf src/kratos
	mkdir -p src/kratos
	wget https://web.cimne.upc.edu/users/croig/data/kratos-simphony.tgz -O src/kratos/kratos.tgz
	(tar -xzf src/kratos/kratos.tgz -C src/kratos; rm -Rf src/kratos/kratos.tgz)
	rm -rf $(SIMPHONYENV)/lib/python2.7/site-packages/KratosMultiphysics
	(ln -s $(PWD)/src/kratos/KratosMultiphysics $(SIMPHONYENV)/lib/python2.7/site-packages/KratosMultiphysics)
	cp -rf src/kratos/libs/*Kratos*.so $(SIMPHONYENV)/lib/.
	cp -rf src/kratos/libs/libboost_python.so.1.55.0 $(SIMPHONYENV)/lib/.
	@echo
	@echo "Kratos solver installed"

numerrin:
	rm -Rf src/simphony-numerrin
	git clone --branch $(SIMPHONY_NUMERRIN_VERSION) https://github.com/simphony/simphony-numerrin.git src/simphony-numerrin
	(cp src/simphony-numerrin/numerrin-interface/libnumerrin4.so $(PREFIX)/lib/.)
	rm -Rf src/simphony-numerrin
	@echo
	@echo "Numerrin installed"
	@echo "(Ensure that environment variable PYNUMERRIN_LICENSE points to license file)"

simphony:
	pip install --prefix=$(PREFIX) numpy
	pip install --prefix=$(PREFIX) "numexpr>=2.0.0"
	C_INCLUDE_PATH=$(MPI_INCLUDE_PATH) pip install --prefix=$(PREFIX) tables
	pip install --prefix=$(PREFIX) -r requirements.txt
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-common.git@$(SIMPHONYVERSION)#egg=simphony
	@echo
	@echo "Simphony library installed"

simphony-aviz:
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-aviz.git@$(SIMPHONY_AVIZ_VERSION)
	@echo
	@echo "Simphony AViz plugin installed"

simphony-mayavi:
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-mayavi.git@$(SIMPHONY_MAYAVI_VERSION)#egg=simphony_mayavi
	@echo
	@echo "Simphony Mayavi plugin installed"

simphony-numerrin:
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-numerrin.git@$(SIMPHONY_NUMERRIN_VERSION)
	@echo
	@echo "Simphony Numerrin plugin installed"

simphony-openfoam:
	rm -Rf src/simphony-openfoam
	(mkdir -p src/simphony-openfoam/pyfoam; wget https://openfoamwiki.net/images/3/3b/PyFoam-0.6.4.tar.gz -O src/simphony-openfoam/pyfoam/pyfoam.tgz --no-check-certificate)
	tar -xzf src/simphony-openfoam/pyfoam/pyfoam.tgz -C src/simphony-openfoam/pyfoam
	(pip install --prefix=$(PREFIX) --upgrade src/simphony-openfoam/pyfoam/PyFoam-0.6.4; rm -Rf src/simphony-openfoam/pyfoam)
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-openfoam.git@$(SIMPHONY_OPENFOAM_VERSION)
	@echo
	@echo "Simphony OpenFoam plugin installed"

simphony-kratos:
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-kratos.git@$(SIMPHONY_KRATOS_VERSION)
	@echo
	@echo "Simphony Kratos plugin installed"

simphony-jyu-lb:
	pip install --prefix=$(PREFIX) --upgrade cython
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-jyulb.git@$(SIMPHONY_JYU_LB_VERSION)
	@echo
	@echo "Simphony jyu-lb plugin installed"

simphony-lammps:
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-lammps-md.git@$(SIMPHONY_LAMMPS_VERSION)#egg=simlammps
	@echo
	@echo "Simphony lammps plugin installed"

simphony-paraview:
	pip install --prefix=$(PREFIX) --upgrade git+https://github.com/simphony/simphony-paraview.git@$(SIMPHONY_PARAVIEW_VERSION)#egg=simphony_paraview
	@echo
	@echo "Simphony Paraview plugin installed"

simphony-plugins: simphony-kratos simphony-numerrin simphony-mayavi simphony-openfoam simphony-jyu-lb simphony-lammps simphony-aviz
	@echo
	@echo "Simphony plugins installed"

simphony-framework:
	@echo
	@echo "Simphony framework installed"
