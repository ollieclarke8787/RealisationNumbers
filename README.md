# RealisationNumbers
Computing the complex realisation numbers in Macaulay2.

This code was used for computations that appear in the paper: _A tropical approach to rigidity: counting realisations of frameworks_


# Data

This package contains a copy of the data for all generically minimally 2-rigid graphs (Laman graphs) on up to and including 10
vertices, which was computed in _The number of realizations of all Laman graphs with at most 12 vertices_:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1245517.svg)](https://doi.org/10.5281/zenodo.1245517)

For each of these graphs, we have computed the upper bound on the number of realisations via mixed volumes and nbc-bases.
The script we used for this computation is contained in the files _10-[X].sh_, for each X from 0 to 7. Each of these scripts
executes code from the files _MVTest10Vert.m2_ and _testViaMixedVolume.m2_, which automatically appends new results to output
files. The different files, e.g. _10-0.sh_ and _10-1.sh_, produce append their results to different files so they may
be run in parallel.

These scripts are concerned with the graphs on 10 vertices as there are an order of magnitude more graphs on 10 vertices than 9
and below. For the computation of graphs with 9 and fewer vertices, we refer to the RigidityTestSuite package outlined below.

The results of these computations can be found summarised in our paper. An automatic summary can be generated with the script
_collectResults.m2_, which formats some of the data so that it may be put into a histogram.


# Macaulay2 Package: Rigidity Test Suite

The package RigidityTestSuite is a package written for the computer algebra software Macaulay2:

Grayson, D. R., & Stillman, M. E. Macaulay2, a software system for research in algebraic geometry [Computer software]. https://macaulay2.com/

See also https://github.com/Macaulay2/M2

## Installing the package

The package comes with full documentation, which can be viewed once the package is installed.

To install the package:

1. Launch a new Macaulay2 session from this directory. _RigidityTestSuite.m2_

2. install the package with "installPackage "RigidityTestSuite"

3. to get started, view the help with either "help RigitidytestSuite" (in-terminal help) or "viewHelp RigidityTestSuite" (in-browser help)

