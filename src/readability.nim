import readability/[errors, formulas, utils]
export errors, formulas, utils

const
  compensationUltraLow = 1.305
  compensationLower = 1.1725
  compensationHigher = 1.2315

proc clozeScore*(text: string): float =
  let raw = computeClozeScore(pctUnfamiliarWords(text), avgSentenceLength(text))
  let compensation =
    if raw >= 40: compensationHigher
    elif raw > 0: compensationLower
    else: compensationUltraLow
  roundTo2(raw * compensation)

proc readingLevel*(text: string): string =
  readingLevelFromCloze clozeScore(text)
