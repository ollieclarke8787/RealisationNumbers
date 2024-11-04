-- output moved to Data/smallGraphs
load "testViaMixedVolume.m2"
for n from 3 to 8 do (
    testGraphs(n,
	ShowTimings => false,
	MixedVol2 => false,
	MinimalMV => false,
	Verbose => false,
	StartVal => 0,
	EndVal => null,
	AutoGenerateOutputFile => true)
    )
