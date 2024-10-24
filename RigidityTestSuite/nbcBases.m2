-- compute and return the non-broken circuit bases of a matroid

needsPackage "Matroids"
needsPackage "Graphs"

brokenCircuits = method()
brokenCircuits Matroid := M -> (
    for c in circuits M list c - {min keys c}
    )

nbcBases = method()
nbcBases Matroid := M -> (
    brokenCircuitList := brokenCircuits M;
    for B in bases M list (
        containsBrokenCircuit := false;
	for c in brokenCircuitList do (
	    if isSubset(c, B) then (
		containsBrokenCircuit = true;
		break
		)
	    else continue
	    );
	if containsBrokenCircuit then continue else B
	)
    )

nbcBases Graph := G -> nbcBases matroid G

end ---
load "nbcBases.m2"
G = graph {{1,2}, {1,5}, {1,6}, {2,3}, {2,4}, {3,6}, {3,7}, {4,5}, {4,7}, {5,7}, {6,7}}
G = graph {{1,4},{1,5},{1,6},{2,4},{2,5},{2,6},{3,4},{3,5},{3,6}}
G = graph {{1,5},{1,3},{3,5},{1,2},{2,4},{3,4},{5,6},{4,6},{2,6}}
G = graph {{1,2}, {1,3}, {2,6}, {3,6}, {2,4}, {3,4}, {1,5}, {4,5}, {5,6}}

M = matroid G
B = brokenCircuits M
#B
time # nbcBases M
#bases M
#circuits M
nbcBases M
time # realisationBases M
-- bases 81

B = (nbcBases M)_3
E = groundSet M
B' = E - B + set {0}
member(B', nbcBases M)
