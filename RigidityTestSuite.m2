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
    -- nbc and realization bases
    "nbcBases",
    "realisationBases",
    --"permuteGraphVertices",
    "edgeList",
    -- scripts
    "script1",
    "script2",
    "script3",
    "script4",
    -- other --
    "packageDirectory"
    }

packageDirectory = applicationDirectory() | "local/share/Macaulay2/RigidityTestSuite/"

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
	    This code accompanies the paper {\em TODO: ADD TITLE OF PAPER}.
	    The package includes the data from
	    @HREF{"https://zenodo.org/records/1245517"}@
	    of all minimally rigid graphs on up to
	    10 vertices and their realisation numbers.
	Example
	    G = getLamanGraph(6, 3) -- 3-prism
	    F = rigidityEquations G;
	    netList F -- equations include some random (generic) coefficients
	    I = ideal F;
	    dim I
	    degree I -- number of complex realisations
	    getRealizations(6, 3) -- precomputed result
	Text
	    In the above example, we define $G$ to be the Laman graph with index $3$
	    in the list from above-mentioned data, which happens to be the 3-prism.
	    See @TO "working with Laman graphs"@.
	    The function @TO "rigidityEquations"@ takes the graph and produces a list
	    of equations $(x_i - x_j)(y_i - y_j) - \lambda_{ij}$ for each edge $ij$
	    of $G$ and where $\lambda_{ij}$ is a (generic) random value.
	    The final three equations in $F$ are the {\em pinning equations}.
	    Minimally $2$-rigid graphs (Laman graphs) are graphs $G$ such that these
	    equations result is a $0$-dimensional system.
	    The {\em realization number} of Laman graph $G$ is the number of solutions
	    to this system.
	    
	    The package has methods to compute nbcBases and realisationBases.
	    See the help page @TO "nbc and realization bases"@
	Example
	    M = matroid(G, {0, 1, 2, 4, 5, 6, 7, 8, 3}) -- see help (matroid, Graph, List)
	    (s -> toList s) \ M.cache.groundSet -- ground set of M indexed from 0 to 8 
	    nbcBases M -- sets of edge-indices of nbcBases
	    countNBCBases M -- via Tutte polynomial
	    realisationBases M -- realisationBases
	    #realisationBases M
	Text
	    In the above example $M$ is defined as the matroid of $G$ and the
	    edges of $G$ are ordered from $03$ (with index $0$) up to $52$
	    (with index $8$). We can use the function @TO "nbcBases"@ to
	    compute the list of NBC bases of $M$ with respect to the given
	    ordering. The function @TO "countNBCBases"@ counts the number
	    of NBC bases by evaluating the Tutte polynomial at $(1,0)$. The
	    function 
    References
	@HREF("https://zenodo.org/records/1245517",
	    "Capco, Gallet, Grassegger, Koutschan, Lubbes, Schicho,
	    The number of realiztions of all Laman graphs with at most 12 vertices")@

	@arXiv("1701:05500",
	    "Capco, Gallet, Grassegger, Koutschan, Lubbes, Schicho,
	    The number of realizations of a Laman graph")@
    	
    Subnodes
	rigidityEquations
	"working with Laman graphs"
	"nbc and realization bases"
	"scripts"
	
///

doc ///
    Key
	 rigidityEquations
	(rigidityEquations, Graph)
	[rigidityEquations, ChangeOfVars]
	[rigidityEquations, PinWithEdge]
	[rigidityEquations, RandomVal]
	 ChangeOfVars
	 PinWithEdge
	 RandomVal
    Headline
	rigidity equations of a graph
    Usage
	F = rigidityEquations G
    Inputs
	G: Graph
	ChangeOfVars => Boolean
	    use the equations $(x_i - x_j)(y_i - y_j) - \lambda_{ij}$
	    instead of $(x_i - y_i)^2 + (x_j - y_j)^2 - \lambda_{ij}$
	PinWithEdge => Boolean
	    use an edge to construct the pinning equations
        RandomVal => Boolean
	    use random values for $\lambda_{ij}$ in the rigidity equations
    Outputs
	F: List
	    rigidity equations and pinning equations
    Description
        Text
	    The rigidity equations are typically defined as
	    $(x_i - y_i)^2 + (x_j - y_j)^2 - \lambda_{ij}$, however,
	    under a complex change of coordinates, they may be written as
	    $(x_i - x_j)(y_i - y_j) - \lambda_{ij}$, where $ij$ ranges
	    over all edges of $G$.
	Example
	    G = graph {{0,1}, {1,2}, {2,3}, {1,3}, {0,2}}
	    netList rigidityEquations G
	    netList rigidityEquations(G, ChangeOfVars => true) -- original rigidityEquations
	    netList rigidityEquations(G, RandomVal => false) -- non generic values
	Text
	    To compute the realization number, the value $\lambda_{ij}$ must be
	    generic. If they are not generic, as in final output above, the ideal
	    generated by these equations may not be zero dimensional.
	Example
	    I = ideal rigidityEquations(G, RandomVal => false);
	    member(1, I) -- 1 belongs to I <=> V(I) is empty
    SeeAlso
	script1
///


doc ///
    Key
	"working with Laman graphs"
	 getLamanGraph
	(getLamanGraph, ZZ, ZZ)
	 numberOfLamanGraphs
	(numberOfLamanGraphs, ZZ)
	 getLamanGraphRealizationList
	(getLamanGraphRealizationList, ZZ)
	 getRealizations
	(getRealizations, ZZ, ZZ)
	 packageDirectory
    Headline
        fetch, count, get realization numbers of Laman graphs
    Usage
	N = numberOfLamanGraphs n
	R = getLamanGraphRealizationList n
        G = getLamanGraph(n, i)
	r = getRealizations(n, i)
	s = packageDirectory
    Inputs
	n: ZZ
	    number of vertices of the Laman graph between 3 and 10 inclusive
	i: ZZ
	    index of the Laman graph between 0 and N
    Outputs
	N: ZZ
	    number of Laman graphs with n vertices
	R: List
	    list of 2-dim. realization numbers for all graphs with n vertices
	G: Graph
	    the i-th Laman graph with n vertices
	r: ZZ
	    the 2-dim. realization number of G; the number of complex
	    realizations of G in the plane with generic edge lengths
	s: String
	    the location of the source files for Laman graphs and the number
	    of their realizations 
    Description
        Text
	    The function @TT "numberOfLamanGraphs"@ takes a value $n$ between
	    $3$ and $10$, loads all Laman graphs on $n$ vertices into memory,
	    and returns the number of Laman graphs loaded. The other functions
	    listed above will also load the Laman graphs with $n$ vertices
	    into memory, if it has not already been done.
	    For large $n$, like $9$ and $10$, this may take a little time but
	    only needs to be done once.
	Example
	    numberOfLamanGraphs 5
	    lamanGraphList = for i from 0 to 2 list getLamanGraph(5, i);
	    netList lamanGraphList
	    getLamanGraphRealizationList 5
	    G = getLamanGraph(6, 3) -- 3-prism
	    getRealizations(6, 3) 
	Text
	    The Laman graphs are listed up to isomorphism. The specification
	    of these isomorphism-class representatives is defined here:
	    @HREF("https://zenodo.org/records/1245517")@. The 2-dim. realization
	    numbers have been copied from this source.

	    For the developer. The source files for the graphs and realization
	    numbers are located here:
	Example
	    packageDirectory	    
    SeeAlso
	"scripts"
///


doc ///
    Key
	"nbc and realization bases"
	 nbcBases
	(nbcBases, Graph)
	(nbcBases, Matroid)
	 countNBCBases
	(countNBCBases, Graph)
	(countNBCBases, Matroid)
	 realisationBases
	(realisationBases, Matroid)
	 edgeList
	(matroid, Graph, List)
    Headline
        working with nbc and realization bases
    Usage
	E = edgeList G
	M = matroid(G, P)
	B = nbcBases {M, G}
	b = countNBCBases {M, G}
	B' = realisationBases M
    Inputs
	G: Graph
	    a graph with m edges
	P: List
	    a permutation of {0 .. m-1}
	M: Matroid
	    graphic matroid of G
    Outputs
	E: List
	    edges of the graph, which are totally ordered
	    from smallest (index 0) to largest (index m-1) 
	M: Matroid
	    graphic matroid of G with edges permuted by P
	B: List
	    list of nbc bases of M or the matroid of G
	b: ZZ
	    the number of nbc bases of M or the matroid of G
	B': List
	    list of realization bases of M
    Description
        Text
	    Let $M$ be a matroid on ground set $E = \{0, \dots, m-1\}$.
	    For each circuit $C$ of $M$, we define a broken circuit
	    $C \setminus \{\min(C)\}$. The non-broken circuit bases
	    (nbc bases) of $M$ are the set of bases $B$ that do not
	    contain a broken circuit as a subset. An nbc basis B
	    is called a realization basis if $E - B + \{0\}$ is also an
	    nbc basis.

	    The functions @TT "nbcBases"@ and @TT "realizationBases"@
	    find the nbc bases and realization bases of a matroid. They
	    do this following the definition.
	Example
	    G = getLamanGraph(6, 3)
	    edgeList G -- ordered from 0 to 8
	    M = matroid G
	    #bases M
	    nbcBases M
	    realisationBases M
	Text
	    Note that the edgeList of $G$ gives an implicit ordering
	    of the edges. In the above example $03$ is edge $0$, $40$
	    is edge $1$, and so on.
	
	    This package implements a new constructor for matroids.
	    Given a graph $G$ and a permutation $P$ of the values
	    $0, \dots, |E(G)|-1$, the function
	    @TT "(matroid, Graph, List)"@ produces the graphic matroid
	    of $G$ such that the underlying ground set is a permutation
	    of the edgeList of $G$, see above.
	Example
	    P = {1,2,0, 3,4,5,6,7,8}
	    edgeList G
	    M' = matroid(G, P)
	    (s -> toList s) \ M'.cache.groundSet
	    realisationBases M'
	Text
	    In the above example, the edges of $G$ have been permuted by $P$
	    before constructing the matroid. So we have $03$, which is
	    edge $0$ of $G$, is mapped to $1$ under $P$ and appears at index
	    $1$ in the ground set of $M'$. The choice of permutation $P$ does not
	    affect the number nbc bases, as this is a matroid invariant. However
	    it does affect the number of realization bases.
	Example
	    #realisationBases M
	    #realisationBases M'	    
    SeeAlso
	script2
	rigidityEquations
///


doc ///
    Key
	"scripts"
	 script1
	(script1, ZZ)
	 script2
	(script2, ZZ)
	 script3
	 script4
	 testGraphs
	(testGraphs, ZZ)
	[testGraphs, ShowTimings]
	[testGraphs, MixedVol2]
	[testGraphs, MinimalMV]
	[testGraphs, Verbose]
	[testGraphs, StartVal]
	[testGraphs, EndVal]
	[testGraphs, EdgeEqns]
	[testGraphs, OutputFile]
	[testGraphs, AutoGenerateOutputFile]
	 ShowTimings
	 MixedVol2
	 MinimalMV
	 OutputFile
	 StartVal
	 EndVal
	 EdgeEqns
	 AutoGenerateOutputFile
    Headline
        scripts for routine computations
    Usage
	script1 n
	script2 n
	script3()
	script4()
	testGraphs n
    Inputs
	n: ZZ
	    number of vertices for the Laman graphs
    Description
        Text
	    The function @TT "script1"@ computes, for each Laman graph $G$
	    on $n$ vertices, the mixed volume bound for the realization
	    number and the number of nbcBases, which is a different upper bound.
	Example
	    script1 5
	Text
	    The script runs the function @TT "testGraphs"@, which has more options
	    to give fine control over which families of equations are used. For
	    instance, one can use the {\em edge equations} for the mixed volume
	    bound by setting the option @TT "EdgeEqns"@ to @TT "true"@. One can
	    also add the computation of the mixed volume bound given by the
	    {\em modified equations} with the option @TT "MixedVol2"@, which is
	    set to true by default. However this bound tends to be very high
	    so it recommended to avoid using it.
	Example
	    testGraphs(5, MixedVol2 => false, EdgeEqns => true)
	Text
	    The functions @TT "script2"@, @TT "script3"@, @TT "script4"@ are for
	    computing realisation bases. The function @TT "script2"@ goes through
	    the list of laman graphs on $n$ vertices, and for each graph goes through
	    every permutation of its edges. Whenever a permutation produces an ordering
	    of the edges such that the number of realisation bases is equal to the
	    number of complex realisations of the graph, then it prints a line. The
	    output is $(P, r, E, R)$ where $P$ is the permutation of the edges, $r$
	    is the number of realisation bases, $E$ is the edge set of the graph
	    ordered by $P$, and $R$ is the list of realisation bases.
	Example
	    script2 4
	Text
	    Note, this script runs over all $(2n-3)!$ permutations, so for $n > 6$,
	    it is not recommended to run this computation. For $n = 6$, the results
	    are written down in the source files.

	    The functions @TT "script3"@ and @TT "script4"@ perform a similar
	    computation to @TT "script2"@. One difference is that
	    @TT "script3"@ only checks the graph $K_{3,3}$ and @TT "script4"@
	    only checks the 3-prism. The other difference is in its output.
	    Whenever a permutation gives strictly more realisation bases than
	    any previously seen permutation, it prints a line of the form
	    $(P, r, E, R)$, with the notation above.

	    Again, these scripts run over all $9!$ orderings of the edges so
	    they take some time to run. The outputs have already been computed
	    and are written down in the source code in the
	    file "/RigidityTestSuite/scripts.m2".
    SeeAlso
	rigidityEquations
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

