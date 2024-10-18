newPackage(
    "RigidityTestSuite",
    Version => "0.1",
    Date => "October 18, 2024",
    Headline => "Tropical approach to rigidity examples",
    Authors => {
	{Name => "Oliver Clarke", Email => "oliver.clarke.crgs@gmail.com", HomePage => "oliverclarkemath.com"}},
    AuxiliaryFiles => true,
    DebuggingMode => false,
    PackageExports => {"Tropical", "gfanInterface", "Graphs", "Matroids"}
    )
    
export {
    -- >> Option names << --
    "AutoGenerateOutputFile",
    "MinimalMV",
    "OutputFile",
    "ShowTimings",
    "MixedVol2",
    "RemoveAnEdge",
    "PinWithEdge",
    "RandomVal",
    "CheckNeighbors",
    "UseCorrectCoefficients",
    "StartVal",
    "EdgeEqns",
    "PolynomialSource",
    "EndVal",
    "ChangeOfVars",
    -- >> Methods / Functions << --
    -- get Laman graphs
    "getLamanGraphRealizationList",
    "getRealizations",
    "numberOfLamanGraphs",
    "getLamanGraph",
    -- rigidity equations
    "rigidityEquations",
    "modifiedEquations",
    "realizationsFromMixedVolume",
    "countNBCBases",
    "testGraphs",
    "minimalMixedVolume",
    "edgeEquations",
    -- nbc bases
    "nbcBases",
    -- realization bases
    "realisationBases",
    "permuteGraphVertices",
    "edgeList",
    -- scripts
    "script1",
    "script2",
    "script3",
    "script4"
    }

needs "./RigidityTestSuite/realizationsFromGeorg.m2"
needs "./RigidityTestSuite/rigidityEquations.m2"
needs "./RigidityTestSuite/nbcBases.m2"
needs "./RigidityTestSuite/realizationBases.m2"
needs "./RigidityTestSuite/scripts.m2"

beginDocumentation()
    
doc ///
    Key
        RigidityTestSuite
    Headline
        Tropical examples in Rigidity Theory
    Description
        Text
	    A package for computing examples that come from rigidity theory.
	    This code accompanies the paper
	    {\em TODO: ADD TITLE OF PAPER}.
	    The package includes the data of all minimally rigid graphs on up to
	    10 vertices and their realisation numbers.
    Acknowledgement
    Contributors
    References
    Caveat
    SeeAlso
    Subnodes
///

-*
doc ///
    Key
    Headline
    Usage
    Inputs
    Outputs
    Consequences
        Item
    Description
        Text
	Example
	CannedExample
	Code
	Pre
    ExampleFiles
    Contributors
    References
    Caveat
    SeeAlso
///
*-

-* Test section *-
TEST /// -* [insert short title for this test] *-
-- test code and assertions here
-- may have as many TEST sections as needed
///
    
end--
    
-* Development section *-
restart
debug needsPackage "RigidityTestSuite"
check "RigidityTestSuite"
    
uninstallPackage "RigidityTestSuite"
restart
installPackage "RigidityTestSuite"
viewHelp "RigidityTestSuite"

