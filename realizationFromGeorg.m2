-- This file gives fuctions for loading laman graphs and their realisations
-- computed by Georg et al.
--
-- This file handles graphs up to 10 vertices (up to 17 edges)
--
-- This file requires the folders:
-- > ./Realization3-10
-- > ./LamanGraphs3-10
-- see: https://zenodo.org/records/1245517
--

needsPackage "Graphs"

-- as we load the Laman graph values, keep them stored in the current session
LamanGraphValues = new MutableHashTable from {};
LamanGraphRealizations = new MutableHashTable from {};

-- return the list of Laman graph realizations from file 
getLamanGraphRealizationList = method()
getLamanGraphRealizationList ZZ := numberVertices -> (
    global LamanGraphRealizations;
    if numberVertices < 3 or numberVertices > 10 then (
	error("expected numberVertices between 3 and 10");
	);
    if not LamanGraphRealizations#?numberVertices then (
	fileName := "./Realizations3-10/Realizations" | toString numberVertices | ".txt";
	fileContents := get fileName;
	LamanGraphRealizations#numberVertices = value fileContents;
	);
    LamanGraphRealizations#numberVertices
    )

-- get the number of realizations of a Laman graph
getRealizations = method()
getRealizations(ZZ, ZZ) := (numberVertices, graphIndex) -> (
    if graphIndex >= numberOfLamanGraphs numberVertices then (
	error("expected graphIndex between 0 and " | toString (numberOfLamanGraphs numberVertices - 1));
	);
    (getLamanGraphRealizationList numberVertices)_graphIndex
    )

-- return the list of Laman graph values from file 
getLamanGraphValueList = method()
getLamanGraphValueList ZZ := numberVertices -> (
    global LamanGraphValues;
    if numberVertices < 3 or numberVertices > 10 then (
	error("expected numberVertices between 3 and 10");
	);
    if not LamanGraphValues#?numberVertices then (
	fileName := "./LamanGraphs3-10/LamanGraphs" | toString numberVertices | ".txt";
	fileContents := get fileName;
	LamanGraphValues#numberVertices = value fileContents;
	);
    LamanGraphValues#numberVertices
    )

-- get the number of Laman graphs with a given number of vertices
numberOfLamanGraphs = method()
numberOfLamanGraphs ZZ := numberVertices -> (
    length getLamanGraphValueList numberVertices
    )

-- return the Laman graph value from file 
getLamanGraphValue = method()
getLamanGraphValue(ZZ, ZZ) := (numberVertices, graphIndex) -> (
    if graphIndex >= numberOfLamanGraphs numberVertices then (
	error("expected graphIndex between 0 and " | toString (numberOfLamanGraphs numberVertices - 1));
	);
    (getLamanGraphValueList numberVertices)_graphIndex
    )

-- produce a graph from a graph value
getGraphFromValue = method()
getGraphFromValue(ZZ, ZZ) := (numberVertices, graphValue) -> (
    totalEdges := binomial(numberVertices, 2);
    binaryGraphValue := changeBase(graphValue, 2);
    upperTriangleOfAdjMatrix := concatenate (totalEdges - length binaryGraphValue : "0") | binaryGraphValue;
    edgesInLexOrder := sort subsets(numberVertices, 2);
    graph(toList(0 .. numberVertices - 1), for i from 0 to totalEdges - 1 list (
	    if upperTriangleOfAdjMatrix_i == "1" then (
		edgesInLexOrder_i
		)
	    else (
		continue
		)
	    )
	)
    )

-- produce a Laman graph 
getLamanGraph = method()
getLamanGraph(ZZ, ZZ) := (numberVertices, graphIndex) -> (
    graphValue := getLamanGraphValue(numberVertices, graphIndex);
    getGraphFromValue(numberVertices, graphValue)
    )

end --

load "realizationFromGeorg.m2"

numberOfLamanGraphs 10
v = getLamanGraphValue(10, 1)
G = getGraphFromValue(10, v)

changeBase(v, 2)
adjacencyMatrix G

getRealizations(10, 1)
