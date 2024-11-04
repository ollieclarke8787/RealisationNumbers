
-- results from computations expected in folder:
-- ./Data/
--
-- all lines in all files must be of the form:
-- (a, b, c, d, e)
--
-- a, b : some data about the graph [not used here]
-- c	: number of realisations
-- d	: mixed vol bound
-- e	: nbc bases bound

folder = "./Data/"
fileList = findFiles folder

print "-- collecting data from files"
fileContents = for fileName in fileList list (
    try (
	file := openIn fileName;
	contents := get file;
	)
    then (
	contents
	)
    else (
	continue
	)
    );

print "-- formatting data"

results = flatten for contents in fileContents list (
    lineList := lines contents;
    for line in lineList list (
	val := value line;
	-- only list lines that are sequences of length 5
	if class val === Sequence and length val == 5 then val else continue
	)
    );


print "-- parsing data"
-- output formatting

-- how often is nbc bases a better bound than mixed vol
print ""
print "------------------------------------------------------"
print "-- How often is NBC bound better than mixed volume? --"
print "------------------------------------------------------"
print "--  1 : NBC is better"
print "--  0 : NBC equals mixed volume"
print "-- -1 : mixed volume is better"
print ""
NBCvMVol = for r in results list (
    rNum := r_2;
    mVol := r_3;
    nbcs := r_4;
    if nbcs < mVol then 1 else if nbcs == mVol then 0 else -1
    )
print tally NBCvMVol 
print ""
print ""

-- how far away are nbc bases from the realisation number
print "-------------------------------------------------------"
print "-- How far away is NBC bound from num. realisations? --"
print "-------------------------------------------------------"
NBCvRNum = for r in results list (
    rNum := r_2;
    mVol := r_3;
    nbcs := r_4;
    nbcs - rNum
    )
mean = sum NBCvRNum / #NBCvRNum
var = sum apply(NBCvRNum, x -> (x - mean)^2) / (#NBCvRNum - 1)
print ("-- Mean difference: " | toString (mean)_RR)
print ("-- Variance: " | toString (var)_RR | "  (SD: " | toString (sqrt var)_RR | ")")
print ""

-- normalised distances
NBCvRNumNormed = for r in results list (
    rNum := r_2;
    mVol := r_3;
    nbcs := r_4;
    (nbcs - rNum)/rNum
    )
mean = sum NBCvRNumNormed / #NBCvRNumNormed
var = sum apply(NBCvRNumNormed, x -> (x - mean)^2) / (#NBCvRNumNormed - 1)
print ("-- Mean difference [normalised]: " | toString (mean)_RR)
print ("-- Variance [normalised]: " | toString (var)_RR | "  (SD: " | toString (sqrt var)_RR | ")")
print ""
print ""



-- how far away are nbc bases from the realisation number
print "--------------------------------------------------------"
print "-- How far away is MVol bound from num. realisations? --"
print "--------------------------------------------------------"
mVolvRNum = for r in results list (
    rNum := r_2;
    mVol := r_3;
    nbcs := r_4;
    mVol - rNum
    );
mean = sum mVolvRNum / #mVolvRNum
var = sum apply(mVolvRNum, x -> (x - mean)^2) / (#mVolvRNum - 1)
print ("-- Mean difference: " | toString (mean)_RR)
print ("-- Variance: " | toString (var)_RR | "  (SD: " | toString (sqrt var)_RR | ")")
print ""

-- normalised distances
mVolvRNumNormed = for r in results list (
    rNum := r_2;
    mVol := r_3;
    nbcs := r_4;
    (mVol - rNum)/rNum
    )
mean = sum mVolvRNumNormed / #mVolvRNumNormed
var = sum apply(mVolvRNumNormed, x -> (x - mean)^2) / (#mVolvRNumNormed - 1)
print ("-- Mean difference [normalised]: " | toString (mean)_RR)
print ("-- Variance [normalised]: " | toString (var)_RR | "  (SD: " | toString (sqrt var)_RR | ")")
print ""
print ""


-- Display the raw data
-*
print "------------"
print "-- Tallys --"
print "------------"
print "-- distance nbc to realisation number:"
print tally NBCvRNum
print ""
print "-- distance mixed vol. to realisation number:"
print tally mVolvRNum
print ""
print ""
*-



end --
load "collectResults.m2"
