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
	    This code accompanies the paper {\em A tropical approach to rigidity:
	    counting realisations of frameworks}.
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
	    The number of realizations of all Laman graphs with at most 12 vertices")@

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
    Subnodes
	edgeEquations
	modifiedEquations
	realizationsFromMixedVolume
	minimalMixedVolume
	RandomVal
    SeeAlso
	edgeEquations
	modifiedEquations
        script1
	RandomVal
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
	"packageDirectory"
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
	(edgeList, Graph)
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
	[testGraphs, RandomVal]
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
	    to give fine control over which families of equations are used.
	    Some of the options for @TT "testGraphs"@ are passed on to
	    the function @TO "rigidityEquations"@ when writing down the rigidity
	    equations. The other options are for controlling the computation
	    and its output. For instance,
	    one can use the {\em edge equations} for the mixed volume
	    bound by setting the option @TT "EdgeEqns"@ to @TT "true"@. One can
	    also add the computation of the mixed volume bound given by the
	    {\em modified equations} with the option @TT "MixedVol2"@, which is
	    set to true by default. However this bound tends to be very high
	    so it recommended to avoid using it. For more details on the modified
	    equations see the functions @TO "modifiedEquations"@ and
	    @TO "edgeEquations"@.
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

doc ///
    Key
	edgeEquations
       (edgeEquations, Graph)
       [edgeEquations, RemoveAnEdge]
       [edgeEquations, UseCorrectCoefficients]
        RemoveAnEdge
	UseCorrectCoefficients
    Headline
	list the edge equations of a graph
    Usage
	F = edgeEquations G
    Inputs
	G: Graph
	    graph with m edges
	RemoveAnEdge => Boolean
	    (not implemented) remove the variables corresponding to the pinning
	    equations and adjust the ambient ring
	UseCorrectCoefficients => Boolean
	    (not implemented) use generic values for the coefficients $\lambda_{ij}$
	    and the correct coefficients for the cycle equations
    Outputs
	F: List
	    list of edge equations and vertex-pinning equations
    Description
        Text
	    Consider the following graph given by $K_4$ on vertices
	    $\{0,1,2,3\}$ minus the edge $13$.
	Example
	    G = graph {{0,1}, {1,2}, {2,3}, {0,3}, {0,2}} -- K4 minus an edge
        Text
	    {\bf Background.}
	    The {\em edge equations} lie in the ring with variables $x_{ij}, y_{ij}$
	    for each edge $ij$ of $G$. We call these, the edge variables.
	    So, in this example, the edge equations
	    belong to a polynomial ring with $10$ edge variables.

	    Consider the rigidity equations,
	    @TO "rigidityEquations"@, which are given by 
	    $(x_i - x_j)(y_i - y_j) - \lambda_{ij}$ for each edge $ij$ of $G$.
	    Intuitively, the edge equations are obtained by setting
	    $x_{ij} = (x_i - x_j)$ and $y_{ij} = (y_i - y_j)$. If the variables
	    $x_i$ and $y_i$ satisfy the rigidity equations, then clearly
	    the edge variables satisfy $x_{ij} y_{ij} - \lambda_{ij} = 0$ for
	    all edges $ij$. However, there are some more equations that the edge
	    variables satisfy.

	    Suppose we orient our graph. Given a (not necessarily oriented) cycle
	    $C$, we obtain two equations for the edge variabes. Suppose that by
	    traversing $C$ in one direction we see the edges $e_1, e_2, \dots, e_k$.
	    For each $i \in [k]$, write $s_i = 1$ if $e_1$ is oriented concurrent
	    to traversal direction, otherwise write $s_i = -1$ if the edge is oriented
	    against the direction of travel. The equations we obtain are
	    $s_1x_{e_1} + s_2x_{e_2} + \dots + s_kx_{e_k}$ and
	    $s_1y_{e_1} + s_2y_{e_2} + \dots + s_ky_{e_k}$. We call these equations
	    the {\em cycle equations}.

	    The set of edge equations is the union of the equations
	    $x_e y_e - \lambda_e$ for edges $e$ and the cycle equations.
	    The ideal generated by these equations is minimally generated by
	    a subset of $x_e y_e - \lambda_e$ together with only those cycle
	    equations that form a cycle basis.

	    So, for a Laman graph with $n$ vertices and $2n-3$ edges, the
	    ideal of edge equations lies in a ring with $2(2n-3)$ variables.
	    There are $2n-3$ equations of the form $x_e y_e - \lambda_e$.
	    The number of cycle equations is equal to the number of loops in the
	    graphic matroid if we contract a spanning tree. In this case, a
	    spanning tree has $n-1$ edges. So contracting it leaves $n-2$ loops.
	    So a cycle basis has size $n-2$. Therefore, there are $2(n-2)$ cycle
	    equations, which gives a total of $4n-7$ edge equations. For generic
	    choices of $\lambda_e$, the edge equations carve out a one-dimensional
	    affine variety. So we define a pinning equation $x_e - 1$ for some
	    edge $e$.

	    {\bf Code.} The function @TT "edgeEquations"@ lists the
	    edge equations of the graph. The options @TT "RemoveAnEdge"@ and
	    @TT "CorrectCoefficients"@ are currently not implemented. So
	    all the generic scalar values, and circuit equation coefficients are
	    $1$. In particular, they are not generic or correct. These equations
	    can be used for applying a mixed volume bound, as the mixed volume
	    only cares about the case with generic coefficients.
	Example
	    F = edgeEquations G;
	    netList F
	    gfanMixedVolume F
	Text
	    For the developer. Note that the mixed volume returned by gfan is
	    of class @TO "String"@, and not an integer.
    SeeAlso
	rigidityEquations
	testGraphs
///

doc ///
    Key
	modifiedEquations
       (modifiedEquations, Graph)
       [modifiedEquations, RandomVal]
    Headline
	modified rigidity equations
    Usage
	F = modifiedEquations G
    Inputs
	G: Graph
	RandomVal => Boolean
	    use random coefficients for the rigidity equations 
    Outputs
	F: List
	    modified rigidity equations
    Description
        Text
	    The modified rigidity equations are a hybrid of the
	    rigidity equations and the edge equations. See
	    @TO "rigidityEquations"@ and @TO  "edgeEquations"@.
	Example
	    G = graph {{0, 1}, {0, 2}, {0, 3}, {1, 2}, {2, 3}}
	    F = modifiedEquations G;
	    netList F
	Text
	    The ambient ring of the modified equations includes the vertex
	    varaibles, denoted $x_{0,i}$ and $x_{1,i}$ for each vertex $i$
	    of $G$, and the edge variables $y_{e,0}$ and $y_{e,1}$ for each
	    edge $e$ of $G$.

	    The options @TT "RandomVal"@ may be set to @TT "false"@ if the
	    coefficients of the equations are not important. For instance,
	    if one is performing a mixed volume bound computation, then
	    you may set the option to @TT "false"@.
	Example
	    F' = modifiedEquations(G, RandomVal => false);
	    netList F'
	    gfanMixedVolume F
	    gfanMixedVolume F'
    SeeAlso
	rigidityEquations
	edgeEquations
	testGraphs
	RandomVal
///

doc ///
    Key
	RandomVal
    Headline
	give random coefficients
    Description
        Text
	    This option applies to the functions @TO "rigidityEquations"@
	    and @TO "modifiedEquations"@. By default, it is set to
	    @TT "true"@ and gives the rigidity equations random coefficients
	    $\lambda_{ij}$ and random values for the pinning equations.
	Example
	    G = graph {{0, 1}, {0, 2}, {0, 3}, {1, 2}, {2, 3}}
	    netList rigidityEquations G
	    netList rigidityEquations(G, RandomVal => false)
	Text
	    If the option is set to @TT "false"@ then the coefficients
	    are set to one.
    SeeAlso
	rigidityEquations
	modifiedEquations
///


doc ///
    Key
	minimalMixedVolume
       (minimalMixedVolume, Graph)
       [minimalMixedVolume, CheckNeighbors]
       [minimalMixedVolume, Verbose]
       [minimalMixedVolume, ChangeOfVars]
        CheckNeighbors
    Headline
	minimal mixed volume with different pinning equations
    Usage
	v = minimalMixedVolume G
    Inputs
	G: Graph
	    A Laman graph with n vertices
	CheckNeighbors => Boolean
	    pin only those vertices that are adjacent to vertex 0
	Verbose => Boolean
	    print the mixed volumes for all checked pinned vertices
	ChangeOfVars => Boolean
	    use the equations $(x_i - x_j)(y_i - y_j) - \lambda_{ij}$
	    instead of $(x_i - y_i)^2 + (x_j - y_j)^2 - \lambda_{ij}$
    Outputs
	v: ZZ
	    minimal mixed volume bound ranging over different pinning equations
    Description
        Text
	    The rigidity equations produced by the function
	    @TO "rigidityEquations"@ include pinning equations given by
	    $x_0 - a, y_0 - b, x_1 - c$ where $a,b,c$ are some generic
	    values. This function modifies the last equation $x_1 - c$
	    and computes the mixed volume bound when this equation is
	    replaced with $x_i - c$ for some different $i$.

	    If the option @TT "CheckNeighbors"@ is @TT "true"@ then $i$ above
	    is taken so that $0i$ is an edge of $G$. Otherwise $i$ ranges over
	    all vertices of $G$ with $i \neq 0$. 
	Example
	    G = graph {{0, 1}, {0, 3}, {1, 2}, {1,3}, {2, 3}}
	    minimalMixedVolume(G, CheckNeighbors => false)
	    minimalMixedVolume(G, CheckNeighbors => true)
    SeeAlso
	rigidityEquations
///

doc ///
    Key
	realizationsFromMixedVolume
       (realizationsFromMixedVolume, Graph)
       [realizationsFromMixedVolume, PolynomialSource]
       [realizationsFromMixedVolume, RandomVal]
        PolynomialSource
    Headline
        compute mixed volume bound of realization number
    Usage
	r = realizationsFromMixedVolume G
    Inputs
	G: Graph
	    A Laman graph
	PolynomialSource => String
	    one of "rm-new", "rm-old", "mod", "edge"
	RandomVal => Boolean
	    use random coefficients for the equations
    Outputs
	r: ZZ
	    mixed volume bound for realization number
    Description
        Text
	    The function computes the mixed volume bound for the rigidity equations
	    of a graph $G$.
	Example
	    G = graph {{0, 1}, {0, 3}, {1, 2}, {1,3}, {2, 3}}
	    realizationsFromMixedVolume G
	Text
	    By default the option @TT "PolynomialSource"@ is set to "rm-new", which
	    means that the rigidity equations are of the form
	    $(x_i - x_j)(y_i - y_j) - \lambda_{ij}$. The other values for this
	    option are: "rm-old", which will use equations
	    $(x_i - y_i)^2 + (x_j - y_j)^2 - \lambda_{ij}$;
	    "mod", which will use the modified equations, see
	    @TO "modifiedEquations"@; and "edge", which uses the
	    edge equations, see @TO "edgeEquations"@.
	Example
	    realizationsFromMixedVolume(G, PolynomialSource => "edge")
	    realizationsFromMixedVolume(G, PolynomialSource => "rm-old")
    SeeAlso
	rigidityEquations
	modifiedEquations
	edgeEquations
	RandomVal
///


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

