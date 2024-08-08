needsPackage "Matroids"
needsPackage "Polyhedra"


-- realisation(G) = matrix whose column matroid is the
--  graphic matroid of G
--  if G has a cone-ing vertex then it should be 0 
--  and the last row of the matrix will be deleted 
--  (see the matrix A and ker(A) from workshop)
realisation = method(
    Options => {
	ConeVertex => true
	}
    )

realisation(Graph) := opts -> G -> (
    if opts.ConeVertex and not member(0, vertices G) then error("expected cone vertex 0");
    matrix for row in vertices G list if row == 0 then continue else for col in edges G list (
        L := toList col;
	i := min L;
	j := max L;
	if row == j then 1 else if row == i then -1 else 0 
	)
    )


-- genericPoint(G) = vector with generic coordinates
-- the vector is (\alpha, \alpha^2, \dots, \alpha^k)
genericPoint = method(
    Options => {
	Alpha => 1/10,
	Random => false
	}
    )

genericPoint(Graph) := opts -> G -> (
    coords := for i from 1 to #edges G list opts.Alpha^i;
    if opts.Random then coords = random coords;
    transpose matrix {coords} 
    )



bergmanCone = method(
    Options => {
	RaysOnly => false
	}
    )

-- bergmanCone(F, m) = the polyhedral cone associated to the chain of flats F
-- the cone lives in \RR^#E(G) === \RR^m
bergmanCone(List, ZZ) := opts -> (F, m) -> (
    local rayMatrix;
    rayMatrix = transpose matrix for f in F list for i from 0 to m-1 list if member(i, f) then 1 else 0;
    if opts.RaysOnly then (
	rayMatrix
	) else (
	coneFromVData(
	    (rayMatrix) | (transpose matrix {toList(m : -1)})  
	    )
	)
    )


-- Given a graph G, find all the pairs of flats in the 
-- graphic matroid of G that are 'compatible' i.e. 
-- complementary
compatibleFlats = method(
    Options => {
	AllPairs => false,
	Verbose => false
	}
    )
compatibleFlats(Graph) := opts -> G -> (
    if opts.Verbose then (
	print "-- computing lattice of flats";
	);
    m := #edges G;
    R := realisation(G, ConeVertex => false);
    M := matroid G;
    L := latticeOfFlats M;
    B := maximalChains L;
    numPairs := binomial(#B, 2);
    if opts.Verbose then (
	print("-- there are " | toString(#B) | " maximal chains of flats");
	print("-- there are " | toString(numPairs) | " pairs of chains");
	);
    lastUpdateTime := currentTime();
    numberOfConesDone := 0;
    Cones := B / (F -> bergmanCone(F, m));
    for conePair in subsets(Cones, 2) list (
	if opts.Verbose and currentTime - lastUpdateTime > 5 then (
	    print("-- " | toString numberOfConeDone | " / " | toString numPairs);
	    );
	numberOfConesDone = numberOfConesDone + 1;
	C0 := conePair_0;
	C1 := conePair_1;
	if opts.AllPairs then conePair else (
	    -- the lineality space of a cone is exactly (1..1) 
	    if rank(rays C0 | rays C1 | linealitySpace C0 | -linealitySpace C0) == m then (
	    	conePair
	    	) else (
	    	continue
	    	)
	    )
	)
    )

-- the list of Minkowski sums C1+C2 of compatible flats 
-- We want to find all pairs of compatible flats such that
-- the generic point \alpha is contained in the Minkowski sum
--
-- returns a list of (C1, C2, C1+C2)
doubleCones = method(
    Options => {
	AllPairs => false,
	Verbose => false
	}
    )
doubleCones(Graph) := opts -> G -> (
    CF := compatibleFlats(G, AllPairs => opts.AllPairs, Verbose => opts.Verbose);
    CF / (x -> (x_0, x_1, x_0+x_1))
    )

--------------------
-- List of graphs --
--------------------


--  1---2
--  |\  |
--  | \ |
--  |  \|
--  3---4

G1 = graph {{1,2},{1,3},{1,4},{2,4},{3,4}}
-*
m = #edges G1
R = realisation(G1, ConeVertex => false)
M = matroid G1
L = latticeOfFlats M
B = maximalChains L
C = B / (F -> bergmanCone(F, m))
rays C_0 | rays C_1
rays C_0 | rays C_3

rank(rays C_0 | rays C_1)
rank(rays C_0 | rays C_3)
*-

-- 1--2--3
-- | /| /
-- |/ |/
-- 4--5
--
G2 = graph {{1,2},{1,4},{2,3},{2,4},{2,5},{3,5},{4,5}}

-- small test with a triangle
G3 = graph {{1,2}, {1,3}, {2,3}}


--  1------2
--  |\    /|
--  | 3--4 |
--  |/    \|
--  5------6
G4 = graph {{1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,5},{4,6},{5,6}}



-- we can implement a fast compatible pairs method based on generic \alpha very small
fasterRealisationNumbers = method(
    Options => {
	Verbose => false
	}
    )

fasterRealisationNumbers(Graph) := opts -> G -> (
    if opts.Verbose then (
	print("-- setting up matroid")
	);
    m := #edges G;
    R := realisation(G, ConeVertex => false);
    M := matroid G;
    L := latticeOfFlats M;
    if opts.Verbose then (
	print("-- computing maximal chains of flats")
	);
    B := maximalChains L;
    -- form compatible pairs and compute determinants...
    )


end
-------------------------
-- Start of test cases --
-------------------------
restart
load "tests.m2"

---------------------------
-- G1
G = G1
edges G
-- edge order: 12, 13, 14, 24, 34 === 1, 2, 3, 4, 5
--  x-1-x
--  |\  |
--  2 3 4
--  |  \|
--  x-5-x

D = doubleCones(G, AllPairs => false); #D
p = genericPoint(G, Random => false)
S = select(D, x -> inInterior(p, x_2));
netList for d in S list {rays d_0, rays d_1}
-- Chain pairs:
-- 2 < 235 + 1 < 134
-- 3 < 134 + 1 < 12
tally for d in D list inInterior(p, d_2)
-- compatible pairs: 44
-- number containing p: 2

-- This is the correct number of realisations because we're
-- NOT SWAPPING THEM - so we get half the count
-- which is actually what we want!!

---------------------------
-- G2
G = G2
edges G
-- edge order: 12, 14, 24, 23, 25, 45, 35 === 1,2,3,4,5,6,7
--  x-1-x-4-x
--  |  /|  /
--  2 3 5 7
--  |/  |/
--  x-6-x

D = doubleCones(G, AllPairs => false); #D
p = genericPoint(G, Random => false)
S = select(D, x -> inInterior(p, x_2));
netList for d in S list {rays d_0, rays d_1}
-- Chain pairs:
-- 2 < 123 < 1234   +  1 < 15  < 12356
-- 2 < 123 < 12356  +  1 < 14  < 1457
-- 2 < 25  < 12356  +  1 < 123 < 1234 
-- 2 < 24  < 2457   +  1 < 123 < 12356
tally for d in D list inInterior(p, d_2)
-- compatible pairs: 1172
-- number containing p: 4
-- Correct count!

---------------------------
-- G3
G = G3
edges G
-- edge order: 12, 13, 23 === 1,2,3
--  x-1-x
--  |  /
--  2 3
--  |/
--  x

D = doubleCones(G, AllPairs => false); #D
p = genericPoint(G, Random => false)
S = select(D, x -> inInterior(p, x_2));
netList for d in S list {rays d_0, rays d_1}
-- Chain pairs:
-- 2  +  1
tally for d in D list inInterior(p, d_2)
-- compatible pairs: 3
-- number containing p: 1


---------------------------
-- G4
G = G4
--  1------2
--  |\    /|
--  | 3--4 |
--  |/    \|
--  5------6

edges G
-- edge order: 12, 13, 15, 24, 26, 35, 34, 56, 46
--  o-----1-----o
--  |\         /|
--  | 2       4 |
--  |  \     /  |
--  3   o-7-o   5
--  |  /     \  |
--  | 6       9 |
--  |/         \|
--  o-----8-----o

D = time doubleCones(G, AllPairs => false); #D
-- took around 933 seconds on Oliver's laptop
-- total: 73512 compatiblePairs

p = genericPoint(G, Random => false)

S = (i := 0; for d in D list (
	i = i+1;
	if i % 1000 == 0 then print(i);
	if inInterior(p, d_2) then d else continue
	) 
    )
-- S = select(D, x -> inInterior(p, x_2));
#S
netList for d in S list {rays d_0, rays d_1}
-- Chain pairs:
-- 1)  2 < 24  < 2346 < 234569  +  1 < 13 < 137  < 13578
-- 2)  2 < 25  < 258  < 24589   +  1 < 13 < 1236 < 123467
-- 3)  2 < 24  < 1247 < 124579  +  1 < 13 < 1236 < 123568
-- 4)  2 < 25  < 2356 < 123568  +  1 < 13 < 134  < 123467
-- 5)  2 < 236 < 2367 < 123467  +  1 < 15 < 1358 < 134589
-- 6)  2 < 236 < 2367 < 23567   +  1 < 14 < 148  < 134589
-- 7)  3 < 35  < 2356 < 234569  +  1 < 12 < 1247 < 12478
-- 8)  3 < 35  < 1358 < 134589  +  1 < 12 < 1236 < 123467
-- 9)  3 < 236 < 2368 < 23468   +  1 < 15 < 157  < 124579
-- 10) 3 < 236 < 2368 < 123568  +  1 < 14 < 1247 < 124579
-- 11) 3 < 34  < 2346 < 123467  +  1 < 12 < 125  < 123568
-- 12) 3 < 34  < 347  < 34579   +  1 < 12 < 1236 < 123568

-- tally for d in D list inInterior(p, d_2)
-- compatible pairs: 73512
-- number containing p: 12
-- Correct!


---------------------------
-- G1: send Alpha --> 0 
G = G1
edges G
-- edge order: 12, 13, 14, 24, 34 === 1, 2, 3, 4, 5
--  x-1-x
--  |\  |
--  2 3 4
--  |  \|
--  x-5-x

D = doubleCones(G, AllPairs => false); #D
p = genericPoint(G, Random => false, Alpha => 1/1000)
S = select(D, x -> inInterior(p, x_2));
netList for d in S list {rays d_0, rays d_1}
-- Chain pairs: (Alpha => 1/10)
-- 2 < 235 + 1 < 134
-- 3 < 134 + 1 < 12
-- Chain pairs: (Alpha => 1/100)
-- 2 < 235 + 1 < 134
-- 3 < 134 + 1 < 12
-- Chain pairs: (Alpha => 1/1000)
-- 2 < 235 + 1 < 134
-- 3 < 134 + 1 < 12

-- Seems to be pretty stable

-- why doesn't 4 < 134 + 1 < 12 work?
A = matrix {
    {0,1,1,1,1},
    {0,0,0,1,1},
    {0,1,0,0,1},
    {1,1,0,0,1},
    {0,0,0,0,1}
    }
inverse A
-- it doesn't work because in the first row of inverse(A)
-- there is a -1 that appears before 1
B = matrix {
    {0, 0, -1, 1, 0},
    {0, 0,  1, 0, 0},
    {1, 0,  0, 0, 0},
    {0, 1,  0, 0, 0},
    {0, 0,  0, 0, 1}
    }
inverse B

-- But (3 < 134 + 1 < 12) does work
A = matrix {
    {0,1,1,1,1},
    {0,0,0,1,1},
    {1,1,0,0,1},
    {0,1,0,0,1},
    {0,0,0,0,1}
    }
inverse A

B = matrix {
    {0, 0, 1, 0, 0},
    {0, 0, 0, 1, 0},
    {1, 0, 0, 0, 0},
    {0, 1, 0, 0, 0},
    {0, 0, 0, 0, 1}
    }
inverse B -- just keeping the first non-zero entry in each row
-- this has the same contour as the A, i.e. just by taking the
-- "reduced" chains of flats


-- there is also a working pair: 
-- 2 < 235 + 1 < 134 
A = matrix {
    {1, 1, 0, 0, 1},
    {0, 0, 1, 1, 1},
    {0, 1, 0, 1, 1},
    {0, 1, 0, 0, 1},
    {0 ,0, 0, 1, 1}
    }
inverse A

C = matrix {
    {1, 0, 0, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 1, 0, 1, 1},
    {0, 1, 0, 0, 1},
    {0, 0, 0, 1, 1}
    }
inverse C

B = matrix {
    {1, 0, 0, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 1, 0, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 0,-1, 1, 1}
    }
inverse B 


---------------------------
-- G2
G = G2
edges G
-- edge order: 12, 14, 24, 23, 25, 45, 35 === 1,2,3,4,5,6,7
--  x-1-x-4-x
--  |  /|  /
--  2 3 5 7
--  |/  |/
--  x-6-x

D = doubleCones(G, AllPairs => false); #D
p = genericPoint(G, Random => false, Alpha => 1/1000)
S = select(D, x -> inInterior(p, x_2));
netList for d in S list {rays d_0, rays d_1}
-- Chain pairs (Alpha => 1/10, 1/100):
-- 2 < 123 < 1234   +  1 < 15  < 12356
-- 2 < 123 < 12356  +  1 < 14  < 1457
-- 2 < 25  < 12356  +  1 < 123 < 1234 
-- 2 < 24  < 2457   +  1 < 123 < 12356
tally for d in D list inInterior(p, d_2)
-- compatible pairs: 1172
-- number containing p: 4
-- Correct count!


--------------
G = graph {{1,2}, {1,3}, {1,4}, {2,3}, {3,4}}
edges G
-- edge order: 12, 13, 14, 24, 34 === 1, 2, 3, 4, 5
--  x-1-x
--  |\  |
--  3 2 4
--  |  \|
--  x-5-x

D = doubleCones(G, AllPairs => false); #D
p = genericPoint(G, Random => false)
S = select(D, x -> inInterior(p, x_2));
netList for d in S list {rays d_0, rays d_1}
-- Chain pairs:
-- 3 < 235 + 1 < 124
-- 2 < 124 + 1 < 13
tally for d in D list inInterior(p, d_2)
-- compatible pairs: 44
-- number containing p: 2



------------------------------
--  1------2
--  |\    /|
--  | 3--4 |
--  |/    \|
--  5------6
G = graph {{1,5},{1,3},{3,5},{1,2},{2,4},{3,4},{5,6},{4,6},{2,6}}
-- edges order:
-- {{5, 1}, {1, 3}, {1, 2}, {5, 3}, {5, 6}, {4, 3}, {4, 2}, {6, 2}, {4, 6}}


D = time doubleCones(G, AllPairs => false); #D
-- 
p = genericPoint(G, Random => false)

S = (i := 0; for d in D list (
	i = i+1;
	if i % 1000 == 0 then print(i);
	if inInterior(p, d_2) then d else continue
	) 
    )
-- S = select(D, x -> inInterior(p, x_2));
#S
netList for d in S list {rays d_0, rays d_1}

-- output:
-*
      +---------------+---------------+
o28 = || 0 0 0 0 |    || 0  0  0  0  ||
      || 0 0 0 1 |    || 0  0  0  -1 ||
      || 1 1 1 1 |    || -1 -1 -1 -1 ||
      || 0 0 0 0 |    || 0  0  0  -1 ||
      || 0 0 0 0 |    || 0  0  -1 -1 ||
      || 0 1 1 1 |    || -1 -1 -1 -1 ||
      || 0 0 0 1 |    || 0  -1 -1 -1 ||
      || 0 0 1 1 |    || -1 -1 -1 -1 ||
      || 0 0 0 1 |    || -1 -1 -1 -1 ||
      +---------------+---------------+
      || 0 0 0 0 |    || 0  0  0  0  ||
      || 0 0 1 1 |    || 0  0  0  -1 ||
      || 1 1 1 1 |    || 0  -1 -1 -1 ||
      || 0 0 0 0 |    || 0  0  0  -1 ||
      || 0 0 0 0 |    || 0  0  -1 -1 ||
      || 0 1 1 1 |    || -1 -1 -1 -1 ||
      || 0 0 1 1 |    || -1 -1 -1 -1 ||
      || 0 0 0 1 |    || 0  -1 -1 -1 ||
      || 0 0 0 1 |    || -1 -1 -1 -1 ||
      +---------------+---------------+
      || 0  0  0  0  ||| 0 0 0 0 |    |
      || 0  0  -1 -1 ||| 1 1 1 1 |    |
      || 0  0  0  -1 ||| 0 0 0 1 |    |
      || 0  0  -1 -1 ||| 0 0 0 0 |    |
      || 0  -1 -1 -1 ||| 0 1 1 1 |    |
      || -1 -1 -1 -1 ||| 0 0 1 1 |    |
      || -1 -1 -1 -1 ||| 0 0 0 1 |    |
      || 0  -1 -1 -1 ||| 0 0 0 0 |    |
      || -1 -1 -1 -1 ||| 0 0 0 0 |    |
      +---------------+---------------+
      || 0  0  0  0  ||| 0 0 0 0 |    |
      || 0  0  -1 -1 ||| 1 1 1 1 |    |
      || 0  0  0  -1 ||| 0 0 0 0 |    |
      || 0  0  -1 -1 ||| 0 0 0 0 |    |
      || -1 -1 -1 -1 ||| 0 1 1 1 |    |
      || 0  -1 -1 -1 ||| 0 0 1 1 |    |
      || 0  -1 -1 -1 ||| 0 0 0 0 |    |
      || -1 -1 -1 -1 ||| 0 0 0 1 |    |
      || -1 -1 -1 -1 ||| 0 0 0 0 |    |
      +---------------+---------------+
      || 0  0  0  0  ||| 0 0 0  0  |  |
      || -1 -1 -1 -1 ||| 1 1 0  0  |  |
      || 0  -1 -1 -1 ||| 0 1 0  0  |  |
      || -1 -1 -1 -1 ||| 0 0 0  0  |  |
      || 0  0  0  -1 ||| 0 0 -1 -1 |  |
      || 0  0  -1 -1 ||| 0 0 0  -1 |  |
      || -1 -1 -1 -1 ||| 0 0 0  -1 |  |
      || 0  -1 -1 -1 ||| 0 0 -1 -1 |  |
      || -1 -1 -1 -1 ||| 0 0 -1 -1 |  |
      +---------------+---------------+
      || 0  0  0  0  ||| 0 0 0  0  |  |
      || -1 -1 -1 -1 ||| 1 1 0  0  |  |
      || -1 -1 -1 -1 ||| 0 1 0  0  |  |
      || -1 -1 -1 -1 ||| 0 0 0  0  |  |
      || 0  0  0  -1 ||| 0 0 0  -1 |  |
      || 0  0  -1 -1 ||| 0 0 -1 -1 |  |
      || 0  -1 -1 -1 ||| 0 0 -1 -1 |  |
      || -1 -1 -1 -1 ||| 0 0 0  -1 |  |
      || -1 -1 -1 -1 ||| 0 0 -1 -1 |  |
      +---------------+---------------+
      || 0  0  0  0  ||| 0 0 0 0 |    |
      || 0  0  0  -1 ||| 1 1 1 1 |    |
      || -1 -1 -1 -1 ||| 0 1 1 1 |    |
      || 0  0  0  -1 ||| 0 0 0 0 |    |
      || -1 -1 -1 -1 ||| 0 0 1 1 |    |
      || 0  0  -1 -1 ||| 0 0 0 1 |    |
      || -1 -1 -1 -1 ||| 0 0 0 1 |    |
      || 0  -1 -1 -1 ||| 0 0 0 0 |    |
      || -1 -1 -1 -1 ||| 0 0 0 0 |    |
      +---------------+---------------+
      || 0  0  0  0  ||| 0 0 0 0  |   |
      || 0  0  0  -1 ||| 1 1 1 0  |   |
      || 0  -1 -1 -1 ||| 0 1 1 0  |   |
      || 0  0  0  -1 ||| 0 0 0 0  |   |
      || -1 -1 -1 -1 ||| 0 0 1 0  |   |
      || 0  0  -1 -1 ||| 0 0 0 -1 |   |
      || 0  -1 -1 -1 ||| 0 0 0 -1 |   |
      || -1 -1 -1 -1 ||| 0 0 0 0  |   |
      || -1 -1 -1 -1 ||| 0 0 0 -1 |   |
      +---------------+---------------+
      || 0 0 0  0  |  || 0 0  0  0  | |
      || 0 0 -1 -1 |  || 1 0  0  0  | |
      || 1 1 0  0  |  || 0 0  -1 -1 | |
      || 0 0 -1 -1 |  || 0 0  0  0  | |
      || 0 1 0  0  |  || 0 -1 -1 -1 | |
      || 0 0 -1 -1 |  || 0 0  0  -1 | |
      || 0 0 0  -1 |  || 0 0  -1 -1 | |
      || 0 0 0  0  |  || 0 -1 -1 -1 | |
      || 0 0 0  -1 |  || 0 -1 -1 -1 | |
      +---------------+---------------+
      || 0 0 0  0 |   || 0 0  0  0  | |
      || 0 0 -1 0 |   || 1 0  0  0  | |
      || 1 1 0  1 |   || 0 -1 -1 -1 | |
      || 0 0 -1 0 |   || 0 0  0  0  | |
      || 0 1 0  1 |   || 0 -1 -1 -1 | |
      || 0 0 -1 0 |   || 0 0  0  -1 | |
      || 0 0 0  1 |   || 0 -1 -1 -1 | |
      || 0 0 0  0 |   || 0 0  -1 -1 | |
      || 0 0 0  0 |   || 0 -1 -1 -1 | |
      +---------------+---------------+
      || 0  0  0  0  ||| 0 0  0  0  | |
      || -1 -1 -1 -1 ||| 1 0  0  0  | |
      || 0  0  0  -1 ||| 0 -1 -1 -1 | |
      || -1 -1 -1 -1 ||| 0 0  0  0  | |
      || 0  -1 -1 -1 ||| 0 0  0  -1 | |
      || 0  0  -1 -1 ||| 0 -1 -1 -1 | |
      || -1 -1 -1 -1 ||| 0 0  -1 -1 | |
      || 0  -1 -1 -1 ||| 0 -1 -1 -1 | |
      || -1 -1 -1 -1 ||| 0 -1 -1 -1 | |
      +---------------+---------------+
      || 0  0  0  0  ||| 0 0  0  0  | |
      || 0  -1 -1 -1 ||| 1 0  0  0  | |
      || 0  0  0  -1 ||| 0 0  -1 -1 | |
      || 0  -1 -1 -1 ||| 0 0  0  0  | |
      || -1 -1 -1 -1 ||| 0 0  0  -1 | |
      || 0  0  -1 -1 ||| 0 -1 -1 -1 | |
      || 0  -1 -1 -1 ||| 0 -1 -1 -1 | |
      || -1 -1 -1 -1 ||| 0 0  -1 -1 | |
      || -1 -1 -1 -1 ||| 0 -1 -1 -1 | |
      +---------------+---------------+
*-
-- 3 < 36 < 368 < 236789   +  





-- GOAL: Combinatorialise this!

-- Guess, the flats that appear can be ordered with increasing intervals



---------------------------
------------------------------
-- K_(3,3)
--  1 --- 4
--    \ /
--     x
--    / \
--  2 --- 5
--    \ /
--     x 
--    / \
--  3 --- 6
load "tests.m2"
G = graph {{1,4},{1,5},{1,6},{2,4},{2,5},{2,6},{3,4},{3,5},{3,6}}
-- edges order:
-- 14, 15, 16, 24, 34, 25, 35, 26, 36

D = time doubleCones(G, AllPairs => false); #D
-- used 963.422 seconds
-- o4 = 74592
 
p = genericPoint(G, Random => false);

S = (i := 0; for d in D list (
	i = i+1;
	if i % 1000 == 0 then print(i);
	if inInterior(p, d_2) then d else continue
	) 
    )
-- S = select(D, x -> inInterior(p, x_2));
#S
netList for d in S list {rays d_0, rays d_1}

-*
     +---------------+-------------+
o8 = || 0  0  0  0  ||| 0 0 0  0  ||
     || 0  0  -1 -1 ||| 1 1 0  0  ||
     || 0  -1 -1 -1 ||| 0 0 0  -1 ||
     || 0  0  0  -1 ||| 0 0 -1 -1 ||
     || -1 -1 -1 -1 ||| 0 1 0  0  ||
     || 0  0  -1 -1 ||| 0 0 -1 -1 ||
     || -1 -1 -1 -1 ||| 0 0 0  0  ||
     || 0  -1 -1 -1 ||| 0 0 -1 -1 ||
     || -1 -1 -1 -1 ||| 0 0 0  -1 ||
     +---------------+-------------+
     || 0  0  0  0  ||| 0 0 0 0  | |
     || 0  -1 -1 -1 ||| 1 1 1 0  | |
     || 0  0  0  -1 ||| 0 0 0 -1 | |
     || 0  -1 -1 -1 ||| 0 1 1 0  | |
     || -1 -1 -1 -1 ||| 0 0 1 0  | |
     || 0  0  -1 -1 ||| 0 0 0 0  | |
     || -1 -1 -1 -1 ||| 0 0 0 0  | |
     || 0  -1 -1 -1 ||| 0 0 0 -1 | |
     || -1 -1 -1 -1 ||| 0 0 0 -1 | |
     +---------------+-------------+
     || 0  0  0  0  ||| 0 0 0  0  ||
     || -1 -1 -1 -1 ||| 1 1 0  0  ||
     || 0  0  0  -1 ||| 0 0 -1 -1 ||
     || 0  0  -1 -1 ||| 0 1 0  0  ||
     || 0  -1 -1 -1 ||| 0 0 0  -1 ||
     || -1 -1 -1 -1 ||| 0 0 0  0  ||
     || -1 -1 -1 -1 ||| 0 0 0  -1 ||
     || 0  0  -1 -1 ||| 0 0 -1 -1 ||
     || 0  -1 -1 -1 ||| 0 0 -1 -1 ||
     +---------------+-------------+
     || 0  0  0  0  ||| 0 0 0  0  ||
     || 0  0  -1 -1 ||| 1 1 0  0  ||
     || 0  -1 -1 -1 ||| 0 0 0  -1 ||
     || -1 -1 -1 -1 ||| 0 1 0  0  ||
     || 0  0  0  -1 ||| 0 0 -1 -1 ||
     || -1 -1 -1 -1 ||| 0 0 0  0  ||
     || 0  0  -1 -1 ||| 0 0 -1 -1 ||
     || -1 -1 -1 -1 ||| 0 0 0  -1 ||
     || 0  -1 -1 -1 ||| 0 0 -1 -1 ||
     +---------------+-------------+
     || 0  0  0  0  ||| 0 0 0 0 |  |
     || 0  0  -1 -1 ||| 1 1 1 1 |  |
     || -1 -1 -1 -1 ||| 0 1 1 1 |  |
     || 0  0  0  -1 ||| 0 0 0 0 |  |
     || 0  -1 -1 -1 ||| 0 0 1 1 |  |
     || 0  0  -1 -1 ||| 0 0 0 1 |  |
     || 0  -1 -1 -1 ||| 0 0 0 0 |  |
     || -1 -1 -1 -1 ||| 0 0 0 1 |  |
     || -1 -1 -1 -1 ||| 0 0 0 0 |  |
     +---------------+-------------+
     || 0  0  0  0  ||| 0 0 0 0  | |
     || 0  -1 -1 -1 ||| 1 1 1 0  | |
     || -1 -1 -1 -1 ||| 0 1 1 0  | |
     || 0  -1 -1 -1 ||| 0 0 1 0  | |
     || 0  0  0  -1 ||| 0 0 0 -1 | |
     || 0  0  -1 -1 ||| 0 0 0 0  | |
     || 0  -1 -1 -1 ||| 0 0 0 -1 | |
     || -1 -1 -1 -1 ||| 0 0 0 0  | |
     || -1 -1 -1 -1 ||| 0 0 0 -1 | |
     +---------------+-------------+
     || 0  0  0  0  ||| 0 0 0 0 |  |
     || 0  0  0  -1 ||| 0 0 0 0 |  |
     || 0  -1 -1 -1 ||| 1 1 1 1 |  |
     || 0  0  -1 -1 ||| 0 1 1 1 |  |
     || -1 -1 -1 -1 ||| 0 0 1 1 |  |
     || 0  0  -1 -1 ||| 0 0 0 1 |  |
     || -1 -1 -1 -1 ||| 0 0 0 1 |  |
     || 0  -1 -1 -1 ||| 0 0 0 0 |  |
     || -1 -1 -1 -1 ||| 0 0 0 0 |  |
     +---------------+-------------+
     || 0  0  0  0  ||| 0 0 0  0  ||
     || 0  0  0  -1 ||| 0 0 -1 -1 ||
     || -1 -1 -1 -1 ||| 1 1 0  0  ||
     || 0  0  -1 -1 ||| 0 1 0  0  ||
     || 0  -1 -1 -1 ||| 0 0 0  -1 ||
     || 0  0  -1 -1 ||| 0 0 -1 -1 ||
     || 0  -1 -1 -1 ||| 0 0 -1 -1 ||
     || -1 -1 -1 -1 ||| 0 0 0  0  ||
     || -1 -1 -1 -1 ||| 0 0 0  -1 ||
     +---------------+-------------+
*-



------------------------------
-- Wheel minus an edge
--
--     3 
--    /|\
--   / | \
--  2--1--4
--  |   \ | 
--  |    \|
--  6-----5
--


load "tests.m2"
G = graph {{1,2}, {1,3}, {1,4}, {1,5}, {2,3}, {2,6}, {3,4}, {4,5}, {5,6}}
-- edges order:
-- 12, 13, 14, 15, 23, 26, 34, 45, 56
edges G

D = time doubleCones(G, AllPairs => false); #D
-- used 1209.09 seconds
-- o5 = 54168

p = genericPoint(G, Random => false);

S = (i := 0; for d in D list (
	i = i+1;
	if i % 1000 == 0 then print(i);
	if inInterior(p, d_2) then d else continue
	) 
    )
-- S = select(D, x -> inInterior(p, x_2));
#S
netList for d in S list {rays d_0, rays d_1}

-*
     +--------------+---------------+
o9 = || 0 0  0  0  ||| 0  0  0  0  ||
     || 1 0  0  0  ||| -1 -1 -1 -1 ||
     || 0 0  0  -1 ||| 0  -1 -1 -1 ||
     || 0 0  -1 -1 ||| 0  0  -1 -1 ||
     || 0 0  0  0  ||| -1 -1 -1 -1 ||
     || 0 -1 -1 -1 ||| 0  0  0  -1 ||
     || 0 0  0  -1 ||| -1 -1 -1 -1 ||
     || 0 0  -1 -1 ||| 0  -1 -1 -1 ||
     || 0 -1 -1 -1 ||| 0  0  -1 -1 ||
     +--------------+---------------+
     || 0 0  0  0  ||| 0  0  0  0  ||
     || 1 0  0  0  ||| -1 -1 -1 -1 ||
     || 0 0  0  -1 ||| 0  0  -1 -1 ||
     || 0 -1 -1 -1 ||| 0  0  0  -1 ||
     || 0 0  0  0  ||| -1 -1 -1 -1 ||
     || 0 0  -1 -1 ||| 0  -1 -1 -1 ||
     || 0 0  0  -1 ||| -1 -1 -1 -1 ||
     || 0 -1 -1 -1 ||| 0  0  -1 -1 ||
     || 0 -1 -1 -1 ||| 0  -1 -1 -1 ||
     +--------------+---------------+
     || 0 0 0  0  | || 0  0  0  0  ||
     || 1 1 0  0  | || 0  -1 -1 -1 ||
     || 0 0 0  -1 | || 0  0  0  -1 ||
     || 0 1 0  0  | || -1 -1 -1 -1 ||
     || 0 0 0  0  | || 0  -1 -1 -1 ||
     || 0 0 -1 -1 | || 0  0  -1 -1 ||
     || 0 0 0  -1 | || 0  -1 -1 -1 ||
     || 0 0 0  -1 | || -1 -1 -1 -1 ||
     || 0 0 -1 -1 | || -1 -1 -1 -1 ||
     +--------------+---------------+
     || 0 0 0 0  |  || 0  0  0  0  ||
     || 1 1 1 0  |  || 0  0  -1 -1 ||
     || 0 0 0 -1 |  || 0  0  0  -1 ||
     || 0 1 1 0  |  || 0  -1 -1 -1 ||
     || 0 0 0 0  |  || 0  0  -1 -1 ||
     || 0 0 1 0  |  || -1 -1 -1 -1 ||
     || 0 0 0 -1 |  || 0  0  -1 -1 ||
     || 0 0 0 -1 |  || 0  -1 -1 -1 ||
     || 0 0 0 0  |  || -1 -1 -1 -1 ||
     +--------------+---------------+
     || 0 0 0 0 |   || 0  0  0  0  ||
     || 0 0 0 1 |   || 0  0  0  -1 ||
     || 0 1 1 1 |   || 0  -1 -1 -1 ||
     || 1 1 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 0 0 |   || 0  0  0  -1 ||
     || 0 0 0 0 |   || 0  0  -1 -1 ||
     || 0 0 0 1 |   || 0  -1 -1 -1 ||
     || 0 1 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 1 1 |   || -1 -1 -1 -1 ||
     +--------------+---------------+
     || 0 0 0 0 |   || 0  0  0  0  ||
     || 0 1 1 1 |   || 0  0  0  -1 ||
     || 1 1 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 1 1 |   || 0  -1 -1 -1 ||
     || 0 0 0 0 |   || 0  0  0  -1 ||
     || 0 0 0 0 |   || 0  0  -1 -1 ||
     || 0 1 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 0 1 |   || 0  -1 -1 -1 ||
     +--------------+---------------+
     || 0 0 0 0 |   || 0  0  0  0  ||
     || 0 0 0 1 |   || 0  0  0  -1 ||
     || 0 0 1 1 |   || 0  -1 -1 -1 ||
     || 1 1 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 0 0 |   || 0  0  0  -1 ||
     || 0 1 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 0 1 |   || 0  -1 -1 -1 ||
     || 0 0 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 0 0 |   || 0  0  -1 -1 ||
     +--------------+---------------+
     || 0 0 0 0 |   || 0  0  0  0  ||
     || 0 1 1 1 |   || 0  0  0  -1 ||
     || 1 1 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 1 1 |   || 0  -1 -1 -1 ||
     || 0 0 0 0 |   || 0  0  0  -1 ||
     || 0 0 0 1 |   || 0  -1 -1 -1 ||
     || 0 1 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 1 1 |   || -1 -1 -1 -1 ||
     || 0 0 0 0 |   || 0  0  -1 -1 ||
     +--------------+---------------+
*-

------------------------------
-- 7-vertex example (answer is 28)

load "tests.m2"
G = graph {{1,2}, {1,5}, {1,6}, {2,3}, {2,4}, {3,6}, {3,7}, {4,5}, {4,7}, {5,7}, {6,7}}
-- edges order:
-- 12, 15, 16, 23, 24, 45, 57, 36, 67, 37, 47
edges G

D = time doubleCones(G, AllPairs => false, Verbose => true); #D
-- 

p = genericPoint(G, Random => false);

S = (i := 0; for d in D list (
	i = i+1;
	if i % 1000 == 0 then print(i);
	if inInterior(p, d_2) then d else continue
	) 
    )
-- S = select(D, x -> inInterior(p, x_2));
#S
netList for d in S list {rays d_0, rays d_1}
-- Too many heap sections: Increase MAXHINCR or MAX_HEAP_SECTS
-- Aborted (core dumped)
