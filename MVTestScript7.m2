-- scirpt for testing mixed volume and nbc bases upper bounds for
-- Laman graphs

load "testViaMixedVolume.m2"

outputFile = "mixVolTestOutput7.txt"
numVertices = 9
startIndex = 6000
endIndex = 6999
testGraphs(numVertices,
    ShowTimings => false,
    MixedVol2 => false,
    MinimalMV => false,
    Verbose => false,
    StartVal => startIndex,
    EndVal => endIndex,
    OutputFile => outputFile)
