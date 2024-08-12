-- scirpt for testing mixed volume and nbc bases upper bounds for
-- Laman graphs

load "testViaMixedVolume.m2"

outputFile = "mixVolTestOutput.txt"
numVertices = 9
startIndex = 4000
endIndex = 4999
testGraphs(numVertices,
    ShowTimings => false,
    MixedVol2 => false,
    MinimalMV => false,
    Verbose => false,
    StartVal => startIndex,
    EndVal => endIndex,
    OutputFile => outputFile)
