import std/[math, strutils]
import errors

const
  arbitraryMax = 64.0
  arbitraryMin = 10.0
  levels = [
    (58.0, "1"), (54.0, "2"), (50.0, "3"), (45.0, "4"), (40.0, "5-6"),
    (34.0, "7-8"), (28.0, "9-10"), (22.0, "11-12"), (16.0, "13-15"),
  ]

proc roundTo2*(x: float): float =
  parseFloat(formatFloat(x, ffDecimal, 2))

proc requireFinite(x: float) =
  if classify(x) in {fcNan, fcInf, fcNegInf}:
    fail NotFinite

proc computeClozeScore*(pctUnfamiliarWords, avgSentenceLength: float): float =
  requireFinite pctUnfamiliarWords
  requireFinite avgSentenceLength
  if pctUnfamiliarWords notin 0.0 .. 1.0:
    fail RatioOutOfRange
  if avgSentenceLength <= 0.0:
    fail NonPositiveSentenceLength
  roundTo2(64 - 95 * pctUnfamiliarWords - 0.69 * avgSentenceLength)

proc readingLevelFromCloze*(clozeScore: float): string =
  requireFinite clozeScore
  let bounded = ceil(clamp(clozeScore, arbitraryMin, arbitraryMax))
  for (floor, level) in levels:
    if bounded >= floor:
      return level
  "16+"

proc computeReadingLevel*(pctUnfamiliarWords, avgSentenceLength: float): string =
  readingLevelFromCloze computeClozeScore(pctUnfamiliarWords, avgSentenceLength)
