import std/[json, strutils, unittest]
import readability

proc outcome(text: string): string =
  try:
    $clozeScore(text) & " " & readingLevel(text)
  except ReadabilityError as e:
    $e.kind

suite "golden passages":
  test "parity report":
    let cases = parseFile("tests/golden/passages.json")["cases"]
    var plain, plainOk, markup, markupOk: int
    for c in cases:
      let text = c["text"].getStr
      let expected =
        if c.hasKey("error"): c["error"].getStr
        else: $c["cloze_score"].getFloat & " " & c["reading_level"].getStr
      let isMarkup = '<' in text or '&' in text
      let ok = outcome(text) == expected
      if not ok and not isMarkup and text.allCharsInSet({char(0)..char(127)}):
        echo "  ascii miss: ", text.escape, " ", outcome(text), " vs ", expected
      if isMarkup:
        inc markup
        if ok: inc markupOk
      else:
        inc plain
        if ok: inc plainOk
    echo "  plain text: ", plainOk, "/", plain, "  with markup: ", markupOk, "/", markup
