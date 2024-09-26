-- Mixed volume method for bounding above the number of realisations
needsPackage "gfanInterface"
needsPackage "Graphs"
needsPackage "Matroids"
needsPackage "Tropical"
load "realizationFromGeorg.m2"

-- Equations from the rigidity map:
-- in 2d we use: (x_i - x_j)*(y_i - y_j) = 1
rigidityEquations = method(
    Options => {
	ChangeOfVars => true, -- if false use the standard equations: (x_i - x_j)^2 + (y_i - y_j)^2 = 1
	RandomVal => true, -- use random edge lengths in the equations
	PinWithEdge => true -- the pinning equations pin an edge
	}
    )
rigidityEquations Graph := opts ->  G -> (
    E := (x -> toSequence keys x) \ edges G;
    V := vertices G;
    A := adjacencyMatrix G;
    x := getSymbol "x";
    y := getSymbol "y";
    R := QQ(monoid[(for i in V list x_i) | (for i in V list y_i)]);
    X := transpose genericMatrix(R, #V, 2);
    rigidityEqns := flatten for i from 0 to #V - 2 list (
	for j from i+1 to #V - 1 list (
	    if A_(i,j) == 1 then (
		f := if opts.ChangeOfVars then (
		    (X_(0, i) - X_(0, j))*(X_(1,i) - X_(1,j))
		    )
		else (
		    (X_(0, i) - X_(0, j))^2 + (X_(1,i) - X_(1,j))^2
		    );
		if opts.RandomVal then (
		    f - random QQ
		    )
		else (
		    f - 1
		    )
		)
	    else (
		continue
		)
	    )
	);
    -- construct pinning equations
    pinningMonomials := if opts.PinWithEdge then (
	neighbor := first keys neighbors(G, 0);
	{X_(0,0), X_(1,0), X_(0,neighbor)}
	)
    else (
	{X_(0,0), X_(1,0), X_(0,1)}
	);
    pinningEqns := if opts.RandomVal then (
	pinningMonomials - {random QQ, random QQ, random QQ}
	)
    else (
        pinningMonomials - {1,1,1}
	);
    rigidityEqns | pinningEqns
    )

-- equations from the modified system
modifiedEquations = method(
    Options => {
	RandomVal => true
	})
modifiedEquations Graph := opts -> G -> (
    E := (x -> toSequence  toList x) \ edges G;
    V := vertices G;
    VIndices := new HashTable from for i from 0 to #V-1 list V_i => i;
    A := adjacencyMatrix G;
    x := getSymbol "x";
    y := getSymbol "y";
    R := QQ(monoid[(flatten for i from 0 to 1 list for j in V list x_(j, i)) | (flatten for i from 0 to 1 list for e in E list y_(e, i))]);
    X := transpose genericMatrix(R, #V, 2);
    Y := transpose genericMatrix(R, R_(2*#V), #E, 2);
    degTwoEqns := for edgeIndex from 0 to #E-1 list (
	Y_(0, edgeIndex)*Y_(1, edgeIndex) - if opts.RandomVal then (
	    random QQ
	    )
	else (
	    1
	    )
	);
    linearEqns := flatten for i from 0 to 1 list for j from 0 to #E-1 list (
	v1Index := VIndices#((E_j)_0);
	v2Index := VIndices#((E_j)_1);
	Y_(i, j) - X_(i, v1Index) + X_(i, v2Index)
	);
    pinningEqns := if opts.RandomVal then (
	{X_(0,0) - random QQ, X_(1,0) - random QQ, X_(0,1) - random QQ}
	)
    else (
	{X_(0,0) - 1, X_(1,0) - 1, X_(0,1) - 1}
	);
    degTwoEqns | linearEqns | pinningEqns 
    )



-- realization is 2^d * generic root count of the rigidity equations 
realizationsFromMixedVolume = method(
    Options => {
	PolynomialSource => "rm-new",
	-- PolynomialSource:
	-- > "rm-new" uses the rigidity map equations (x_i - x_j)*(y_i - y_j) = 1 plus pinning equations
	-- > "rm-old" uses the rigidity map equations (x_i - x_j)^2 + (y_i - y_j)^2 = 1 plus pinning equations
	-- > "mod" uses the modified system of equations
	-- > "edge" uses edge equations
	RandomVal => true
	})

realizationsFromMixedVolume Graph := opts -> G -> (
    eqns := if opts.PolynomialSource == "rm-new" then (
	rigidityEquations(G, ChangeOfVars => true, RandomVal => opts.RandomVal)
	)
    else if opts.PolynomialSource == "rm-old" then (
	rigidityEquations(G, ChangeOfVars => false, RandomVal => opts.RandomVal)
	)
    else if opts.PolynomialSource == "mod" then (
	modifiedEquations(G, RandomVal => opts.RandomVal)
	)
    else if opts.PolynomialSource == "edge" then (
	edgeEquations G
	)
    else (
	error("unknown option: PolynomialSource => " | toString opts.PolynomialSource)
	);
    mixedVol := value gfanMixedVolume eqns; --gfanMixedVolume returns a string (!?)
    mixedVol -- should we divide by 2?
    )

cone Graph := G -> (
    A := adjacencyMatrix G;
    graph(matrix {{0} | toList(#vertices G : 1)} || transpose matrix {toList(#vertices G : 1)} | A)
    )

beta = method ()
beta Matroid := M -> (
    X := characteristicPolynomial M;
    x := (ring X)_0;
    X' := diff(x, X);
    abs sub(X', x => 1)
    )

countNBCBases = method()
countNBCBases Matroid := M -> (
    tutteEvaluate(M, 1, 0)
    )

countNBCBases Graph := G -> (
    countNBCBases matroid G
    )

-- for each Laman graph with n vertices (for some 3 <= n <= 10)
-- we print out (i, v, r, m1, m2, n)
-- where
-- >> i : graph index
-- >> v : graph value
-- >> r : realization number
-- >> m1 : mixed volume bound (using rigidity equations)
-- >> m2 : mixed volume bound (using modified equations)
-- >> n : number of nbc bases
testGraphs = method(
    Options => {
	ShowTimings => false,
	MixedVol2 => true,
	RandomVal => true,
	MinimalMV => false,
	Verbose => false,
	StartVal => 0,
	EndVal => null,
	EdgeEqns => true,
	AutoGenerateOutputFile => false, 
	OutputFile => null -- output appended to contents of the file 
	})
testGraphs ZZ := opts -> numberVertices -> (
    local m1;
    local m2;
    local n;
    local file;
    --------------------
    -- Print description
    print("---------------------------------------------------------");
    print("-- testing Laman graphs with " | toString numberVertices | " vertices");
    if opts.MixedVol2 then (
	print("-- output format : (i, v, r, m1, m2, n)");
	)
    else (
	print("-- output format : (i, v, r, m1, n)");
	);
    print("-- i  : graph index");
    print("-- v  : graph representation value");
    print("-- r  : realization number");
    if opts.EdgeEqns then (
	print("-- m1 : mixed volume bound - edge equations");
	)
    else (
	print("-- m1 : mixed volume bound - vertex equations");
	);
    if opts.MixedVol2 then (
	print("-- m2 : mixed volume bound - modified equations");
	);
    print("-- n : number of nbc bases");
    print("---------------------------------------------------------");
    if opts.ShowTimings then (
	if opts.MixedVol2 then (
	    print("-- timings shown for computing: m1, m2, n");
	    )
	else (
	    print("-- timings shown for computing: m1, n");
	    );
	print("---------------------------------------------------------");
	);
    N := numberOfLamanGraphs numberVertices;
    print("-- There are " | toString N | " Laman graphs in total");
    if opts.StartVal > 0 then (
	print("Starting at graph index: " | toString opts.StartVal);
	);
    if not opts.EndVal === null and opts.EndVal < N-1 then (
	print("Ending at graph index: " | toString opts.EndVal);
	);
    --------------------
    if opts.AutoGenerateOutputFile then (
	fileName := "MVOutput_v_" | toString numberVertices | "_f_" | toString(opts.EndVal // 1000) | ".txt";
	file = openOutAppend fileName;
	)
    else if not opts.OutputFile === null then (
	file = openOutAppend opts.OutputFile;
	file << ("-- vertices: " | toString numberVertices) << endl;
	);
    endVal := if not opts.EndVal === null then min(opts.EndVal, N-1) else N-1;
    for i from opts.StartVal to endVal do (
	v := getLamanGraphValue(numberVertices, i);
	G := getLamanGraph(numberVertices, i);
	r := getRealizations(numberVertices, i);
	if opts.MinimalMV then ( -- minimal MV dominates the options
	    m1 = minimalMixedVolume(G, Verbose => opts.Verbose); -- minimal mixed volume over different choices of pinning eqns
	    n = countNBCBases G;
	    )
	else (
	    if opts.ShowTimings then (
		if opts.EdgeEqns then (
		    m1 = elapsedTime realizationsFromMixedVolume(G, PolynomialSource => "edge", RandomVal => opts.RandomVal);
		    )
		else (
		    m1 = elapsedTime realizationsFromMixedVolume(G, PolynomialSource => "rm-new", RandomVal => opts.RandomVal);
		    );
		if opts.MixedVol2 then (
		    m2 = elapsedTime realizationsFromMixedVolume(G, PolynomialSource => "mod", RandomVal => opts.RandomVal);
		    );
		n = elapsedTime countNBCBases G;
		)
	    else (
		if opts.EdgeEqns then (
		    m1 = realizationsFromMixedVolume(G, PolynomialSource => "edge", RandomVal => opts.RandomVal);
		    )
		else (
		    m1 = realizationsFromMixedVolume(G, PolynomialSource => "rm-new", RandomVal => opts.RandomVal);
		    );
		if opts.MixedVol2 then (
		    m2 = realizationsFromMixedVolume(G, PolynomialSource => "mod", RandomVal => opts.RandomVal);
		    );
		n = countNBCBases G;
		);
	    );
	output := if opts.MixedVol2 then (
	    (i, v, r, m1, m2, n)
	    )
	else (
	    (i, v, r, m1, n)
	    );
	if not opts.OutputFile === null then (
	    file << toString output << endl; 
	    );
	print output;
	);
    if not opts.OutputFile === null then (
	file << close;
	);
    )

-- compute the mixed volume using different pinning equations
-- return the minimum
minimalMixedVolume = method(
    Options => {
	CheckNeighbors => true,
	Verbose => true,
	ChangeOfVars => true
	}
    )
minimalMixedVolume Graph := opts -> G -> (
    local adjustedEquations;
    local mixedVol;
    E := rigidityEquations(G, ChangeOfVars => opts.ChangeOfVars);
    R := ring first E;
    varIndices := if opts.CheckNeighbors then (
	keys neighbors(G, 0)
	)
    else (
	toList(1 .. #vertices G -1)
	);
    minimumMixedVol := infinity;
    if opts.Verbose then (
	print("----------------------------------------------");
	print("-- Mixed vols with different pinning equations");
	print("----------------------------------------------")
	);
    for ind in varIndices do (
	adjustedEquations = E_{0 .. #E-2} | {R_ind - 1};
	mixedVol = value gfanMixedVolume adjustedEquations; -- returns a string with '\n' at end - NB '\n' is 1 character
	if opts.Verbose then (
	    print("-- vertex: " | toString ind | ", MV: " | toString mixedVol)
	    );
	if mixedVol < minimumMixedVol then (
	    minimumMixedVol = mixedVol;
	    );
	);
    if opts.Verbose then (
	print("----------------------------------------------");
	);
    minimumMixedVol
    )


-- given a connected graph, return a spanning tree 
-- graph is given as a list of edges (i,j) as a sequence
-- output the indices of edges that form a spanning tree
getSpanningTree = method()
getSpanningTree List := E -> (
    -- if E is all loops then we're done
    if select(E, e -> e_0 != e_1) == {} then (
	{}
	)
    else (
	p := position(E, e -> e_0 != e_1);
	(i,j) := E_p;
	E' := for e in E list (
	    if e_0 == i and e_1 == i then (j,j)
	    else if e_0 == i then (j, e_1)
	    else if e_1 == i then (e_0, j)
	    else e
	    );
	{p} | getSpanningTree E'
	)
    )

-- given a tree and a pair of vertices, find the path in the tree from one vertex to the other
-- input list of edges E, vertex v, vertex w (expect vertices to be integers)
-- output list of indices of edges to be traversed
getPath = method()
getPath(List, ZZ, ZZ) := (E, v, w) -> (
    G := graph E;
    edgeIndices := hashTable flatten for i from 0 to #E-1 list {E_i => i, ((E_i)_1, (E_i)_0) => i};
    Bv := breadthFirstSearch(G, v);
    Bw := breadthFirstSearch(G, w);
    d := position(Bv, b -> member(w, b));
    vertexList := for i from 0 to d list (
	sv := set Bv_i;
	sw := set Bw_(d-i);
	svw := intersect(sv, sw);
	first keys svw
	);
    edgeList := for i from 0 to #vertexList -2 list (vertexList_i, vertexList_(i+1));
    apply(edgeList, e -> edgeIndices#e)
    )


-- edge equations
edgeEquations = method(
    Options => {
	UseCorrectCoefficients => false, -- the correct coefficients are obtained by orienting the cycles 
	RemoveAnEdge => false -- there is one pinning equation which implies the values of the two variables of an edge 
	}
    )
edgeEquations Graph := opts -> G -> (
    if opts.UseCorrectCoefficients then (
	error("Sorry not implemented");
	);
    if opts.RemoveAnEdge then (
	error("Sorry not implemented");
	);
    if not opts.UseCorrectCoefficients and not opts.RemoveAnEdge then (
	E := (e -> toSequence keys e) \ edges G;
	x := getSymbol "x";
	y := getSymbol "y";
	R := QQ[(for e in E list x_e) | (for e in E list y_e)];
        X := for i from 0 to #E-1 list R_i;
	Y := for i from 0 to #E-1 list R_(#E + i);
	edgeEqn := for i from 0 to #E-1 list X_i * Y_i - 1;
	-- circuit basis for the graph
	T := getSpanningTree E; -- this set is ordered
	nT := ( -- edge indices not in the tree
	    Tind := 0;
	    for i from 0 to #E-1 list (
		if Tind < #T and i == T_Tind then (
		    Tind = Tind + 1;
		    continue
		    )
		else (
		    i
		    )
		)
	    );
        cycleEqn := flatten for eInd in nT list (
	    (v, w) := E_eInd;
	    pathInds := T_(getPath(E_T, v, w));
	    C := {eInd} | pathInds; -- circuit of the circuit basis
	    {
		sum X_C, -- wrong coefficients but sufficient for mixed volume bounds
		sum Y_C
		}
	    );
	pinningEqn := {X_0 - 1};
	edgeEqn | cycleEqn | pinningEqn
	)
    )

end --

restart
load "testViaMixedVolume.m2"
G = graph({0,1,2,3}, {{0,1}, {0,2}, {0,3}, {1,3}, {2,3}})

-- 3 prism example
G = graph({0,1,2,3,4,5}, {{0,1},{0,2},{1,2}, {3,4},{3,5},{4,5}, {0,3},{1,4},{2,5}})
netList rigidityEquations G

elapsedTime gfanMixedVolume rigidityEquations G

rigidityEquations(G, ChangeOfVars => false)
gfanMixedVolume rigidityEquations(G, ChangeOfVars => false)

modifiedEquations G
elapsedTime gfanMixedVolume modifiedEquations G

realizationsFromMixedVolume(G, PolynomialSource => "mod")

G = graph({0,1,2,3,4,5}, {{0,1},{0,2},{1,2}, {3,4},{3,5},{4,5}, {0,3},{1,4},{2,5}});
elapsedTime countNBCBases matroid G

beta matroid cone G 




testGraphs(8, ShowTimings => true, MixedVol2 => false)

getGraphFromValue(5, 223)
----------------------
restart
load "testViaMixedVolume.m2"
testGraphs(9, ShowTimings => true, MixedVol2 => false, MinimalMV => false, Verbose => false, StartVal => 0)

G = getLamanGraph(8, 0)
E = rigidityEquations(G, RandomVal => true)
netList E
E' = modifiedEquations G
gfanMixedVolume E
gfanMixedVolume E'
countNBCBases G
getRealizations(10, 0)
minimalMixedVolume(G, CheckNeighbors => false, Verbose => true)

use ring first E
R = ring first E
gfanMixedVolume (E_{0 .. 10} | {x_5 - 1})
netList(E_{0 .. 10} | {x_4 - 1})

S = sub(matrix {E_{0 .. 8}}, {x_0 => random QQ, y_0 => random QQ, x_1 => random QQ})
R' = QQ[x_2 .. x_5, y_1 .. y_5]
m = map(R', R, {0, 0} | (gens R')_{0 .. 3} | {0} | (gens R')_{4 .. 8})
S' = m S 
gfanMixedVolume first entries S'

F = E_{0 .. 8} | {sum gens R - 1, sum gens R -1, sum gens R -1}
netList F
gfanMixedVolume F

I = ideal(E_{0 .. 8})
degree I
dim I

M = matrix {E}
R = ring M

-- (0)(1,3)(2,4)(5)
L = map(R, R, {
	R_0, R_3, R_4, R_1, R_2, R_5,
	R_6, R_9, R_10, R_7, R_8, R_11})
E = first entries L M
gfanMixedVolume E

--------------------------------
restart
load "testViaMixedVolume.m2"

n = 4
G = getLamanGraph(n,0)
E = rigidityEquations(G, RandomVal => true)
R = ring E_0
I = ideal E_{0 .. 2*n-4}

T = tropicalVariety I
dim T
rays T
linealitySpace T
netList maxCones T
L = linealitySpace T

(rays T) + (L * matrix {
	{1, 1, 1, 1, -1, -1, -1, -1, 1}
	})
netList sort maxCones T

-- maxcone: {1,4}
w = {1,0,0,0, 1,0,0,0}

needsPackage "gfanInterface"
transpose mingens ideal gfanInitialForms(E_{0 .. 2*n-4}, -w)

R' = newRing(R, MonomialOrder => {Weights => -w}, Global => false)
describe R'
m = map(R', R, gens R')
transpose mingens ideal leadTerm(1, m I)

J = ideal leadTerm(1, m I)
isPrime J
--------------
load "testViaMixedVolume.m2"
