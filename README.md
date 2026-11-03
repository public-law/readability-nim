# readability-nim

A Nim port of [new-dale-chall-readability](https://github.com/public-law/readability),
written to compare against the
[Rust port](https://github.com/public-law/readability-rs). It has the same
functions as the Python library.

## Usage

```nim
import readability

let text = "Latin for \"friend of the court.\" It is advice formally offered " &
  "to the court in a brief filed by an entity interested in, but not " &
  "a party to, the case."

echo readingLevel(text)  # 7-8
echo clozeScore(text)    # 36.91
```

The formulas and measurements are in the same modules as in Python:

```nim
import readability

echo computeClozeScore(0.2, 10.0)    # 38.1
echo computeReadingLevel(0.2, 10.0)  # 7-8
echo readingLevelFromCloze(44.0)     # 5-6

echo pctUnfamiliarWords("Dog respondent dog respondent.")  # 0.5
echo avgSentenceLength("The dog ran. It was late.")        # 3.0
```

Nim ignores case and underscores after the first letter, so
`reading_level` works too.

Text with no words or no sentences raises `ReadabilityError`, where Python
raises `ZeroDivisionError`. Its `kind` field is `NoWords`, `NoSentences`,
`NotFinite`, `RatioOutOfRange`, or `NonPositiveSentenceLength`.

```nim
try:
  echo clozeScore("")
except ReadabilityError as e:
  echo e.kind  # NoWords
```

## Differences from Python

The formulas match Python exactly. Text handling is close but not exact:

- HTML is removed by a simple tag stripper. It hides comments and the
  contents of script, style, template, rt, and rp, and decodes named and
  numeric entities. It does not reproduce html.parser and BeautifulSoup,
  so malformed or unusual markup can give different words than Python.
- Lowercasing and letter checks use Nim's `std/unicode`, not Python's
  tables. Only ASCII digits count as numbers, and lowercase mappings that
  produce more than one character are not handled.

## Tests

```
nimble test
```

This runs the Python library's tests, the formula golden cases, and a
parity report against the passage golden cases. The golden files were
generated from Python 3.13.5 and BeautifulSoup 4.15.0 for the Rust port.
On the current code all 5,403 formula cases match, 363 of 373 plain text
passages match, and 5,449 of 7,659 passages with markup match.

## License

MIT
