import std/[json, math, unittest]
import readability

template raisesKind(expected: ErrorKind, body: untyped) =
  try:
    discard body
    check false
  except ReadabilityError as e:
    check e.kind == expected

suite "formulas":
  test "cloze score of simple inputs":
    check computeClozeScore(0.2, 10.0) == 38.1
  test "cloze score of book sample":
    check computeClozeScore(0.11, 100 / 27) == 50.99
  test "reading level inside a band":
    check readingLevelFromCloze(39.01) == "5-6"
  test "reading level on a band edge":
    check readingLevelFromCloze(44.0) == "5-6"
  test "reading level of a low score":
    check readingLevelFromCloze(11.2) == "16+"
  test "reading level of the highest score":
    check readingLevelFromCloze(64.0) == "1"
  test "reading level of the lowest band":
    check readingLevelFromCloze(15.0) == "16+"
  test "scores outside the table":
    check readingLevelFromCloze(99.0) == "1"
    check readingLevelFromCloze(-99.0) == "16+"
  test "compute reading level of simple inputs":
    check computeReadingLevel(0.2, 10.0) == "7-8"
  test "compute reading level of book sample":
    check computeReadingLevel(0.11, 100 / 27) == "3"
  test "rejects invalid inputs":
    raisesKind RatioOutOfRange, computeClozeScore(1.5, 10.0)
    raisesKind NotFinite, computeClozeScore(NaN, 10.0)
    raisesKind NonPositiveSentenceLength, computeReadingLevel(0.2, 0.0)
    raisesKind NotFinite, readingLevelFromCloze(Inf)

  test "golden formula cases":
    let cases = parseFile("../readability-rs/tests/golden/formulas.json")["cases"]
    var mismatches = 0
    for c in cases:
      let matches =
        if c.hasKey("cloze_input"):
          readingLevelFromCloze(c["cloze_input"].getFloat) == c["reading_level"].getStr
        else:
          let ratio = c["unfamiliar_word_ratio"].getFloat
          let length = c["average_sentence_length"].getFloat
          computeClozeScore(ratio, length) == c["cloze_score"].getFloat and
            computeReadingLevel(ratio, length) == c["reading_level"].getStr
      if not matches:
        inc mismatches
    echo "  formula golden cases: ", cases.len - mismatches, "/", cases.len
    check mismatches == 0
