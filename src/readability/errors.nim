type
  ErrorKind* = enum
    NoWords, NoSentences, NotFinite, RatioOutOfRange, NonPositiveSentenceLength

  ReadabilityError* = object of ValueError
    kind*: ErrorKind

proc fail*(kind: ErrorKind) {.noreturn.} =
  const messages: array[ErrorKind, string] = [
    "the text has no words",
    "the text has no sentences",
    "the value is not a finite number",
    "the ratio is not between 0 and 1",
    "the average sentence length is not positive",
  ]
  var e = newException(ReadabilityError, messages[kind])
  e.kind = kind
  raise e
