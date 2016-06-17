SimPhoNy Remote Docker CHANGELOG
================================

Release 0.1.1
-------------

Fixes
~~~~~

- Simplify image names: simphony-framework-* -> simphonic-*
- Rename ubuntu-*-base to ubuntu-*-remote
- Fix simphony-openfoam import for the simphonic-mayavi image
- Added README for every image


Release 0.1.0
-------------

Features
~~~~~~~~

- Added ubuntu-12.04-base and ubuntu-14.04-base as base ubuntu images with remote access support
- Added simphony-framework-mayavi and simphony-framework-paraview images with remote access support
- Added build scripts for development and for creating the Docker context for DockerHub auto build
