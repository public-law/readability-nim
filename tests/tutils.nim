import std/unittest
import readability

template raisesKind(expected: ErrorKind, body: untyped) =
  try:
    discard body
    check false
  except ReadabilityError as e:
    check e.kind == expected

const
  highlightsForChildren = """
Once upon a time a very small witch was walking in the woods. The cold
wind was blowing the dry leaves all around her. The little witch was
frantically searching for a house for the winter. She could not find one.
Suddenly a piece of orange paper, blown by the wind, landed at her feet.
She picked it up.

The little witch looked closely at the paper and then she said,
"I shall make myself a little house from this piece of orange paper."

She folded the paper in half. Then she took her scissors (she always
carried a pair
"""
  psychologyToday = """
Until the 1940's, there were no specific psychiatric drugs. Bromides,
barbituates, and opiates were known to sedate disturbed patients but
did not reverse the symptoms of severe mental illnesses such as the
schizophrenias or manic-depressive psychoses. They did ameliorate anxiety,
but only at the cost of fogging the minds of the recipients, who had to
decide between being unhappy and being intoxicated. In the 1950's, the
first specific drug appeared: chlorpromazine (trade name Thorazine). It
was synthesized when an antihiatamine chemical relative was found to
sedate surgical patients. However, clinical observations showed that this
drug did much more than simply
"""
  harvardEdRev = "\nFurther support for the view that educational expansion would reduce\n" &
    "inequalities was derived from the dualistic nature of developing\n" &
    "societies. The economic structures of developing societies were said to \n" &
    "consist of two sectors: a traditional sector that uses little capital,\n" &
    "is relatively unproductive, does not require an educated labor force,\n" &
    "and places a great emphasis on subsistence farming, small workshops and\n" &
    "small commercial enterprises: and a modern sector that uses advanced\n" &
    "technology and capital, is far more productive, and requires a labor\n" &
    "force with at least some schooling. Expanding the educational system \n" &
    "would qualify more workers for jobs where demands\n"

suite "utils":
  test "all familiar words":
    check pctUnfamiliarWords("Dog cat play house.") == 0.0
  test "half unfamiliar words":
    check pctUnfamiliarWords("Dog respondent dog respondent dog respondent.") == 0.5
  test "different unfamiliar words":
    check pctUnfamiliarWords("Dog raconteur dog respondent dog respondent.") == 0.5
  test "only unfamiliar words":
    check pctUnfamiliarWords("Deponent deponent deponent.") == 1.0
  test "singular possessives are familiar":
    check pctUnfamiliarWords("Dog's dog's dog's.") == 0.0
  test "plural possessives are familiar":
    check pctUnfamiliarWords("Dogs' dog's dogs'.") == 0.0
  test "html is ignored":
    check pctUnfamiliarWords("Dog <em>dog</em> dog.") == 0.0
  test "years are familiar":
    check pctUnfamiliarWords("A dog born in 2020.") == 0.0
  test "numbers are familiar":
    check pctUnfamiliarWords("A boy or girl aged 14, 15 or 16.") == 0.0
  test "readme example":
    let text = "Latin for \"friend of the court.\" It is advice formally offered " &
      "to the court in a brief filed by an entity interested in, but not " &
      "a party to, the case."
    check readingLevel(text) == "7-8"
    check clozeScore(text) == 36.91
  test "text without words is an error":
    raisesKind NoWords, clozeScore("")
    raisesKind NoWords, readingLevel("<b></b>")
    raisesKind NoWords, pctUnfamiliarWords("")
  test "text without sentences is an error":
    raisesKind NoSentences, clozeScore("...")
    raisesKind NoSentences, avgSentenceLength("")
  test "average sentence length":
    check avgSentenceLength("The dog ran. It was late.") == 3.0
    check avgSentenceLength("<b></b>") == 0.0

suite "integration":
  test "highlights for children":
    check abs(clozeScore(highlightsForChildren) - 53.0) <= 0.01
    check readingLevel(highlightsForChildren) == "3"
  test "psychology today":
    check abs(clozeScore(psychologyToday) - 17.0) <= 0.01
    check readingLevel(psychologyToday) == "13-15"
  test "harvard ed rev":
    check abs(clozeScore(harvardEdRev) - -6.0) <= 0.01
    check readingLevel(harvardEdRev) == "16+"
