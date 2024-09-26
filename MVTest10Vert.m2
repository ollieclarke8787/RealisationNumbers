
load "testViaMixedVolume.m2"

numVertices = 10

inputIndex = value if #scriptCommandLine >= 1 then scriptCommandLine#1 else "0"

startIndex = inputIndex
endIndex = inputIndex

testGraphs(numVertices,
    ShowTimings => false,
    MixedVol2 => false,
    MinimalMV => false,
    Verbose => false,
    StartVal => startIndex,
    EndVal => endIndex,
    AutoGenerateOutputFile => true)
