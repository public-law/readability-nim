import std/[sets, strutils, unicode]
import errors, private/html

const easyWordList = staticRead("private/easy_words.txt")
let easyWords = easyWordList.strip.splitLines.toHashSet

proc isPythonSpace(r: Rune): bool =
  r.isWhiteSpace or r.int in 0x1C .. 0x1F

proc pythonSplit(text: string): seq[string] =
  var word = ""
  for r in text.runes:
    if r.isPythonSpace:
      if word.len > 0: result.add word
      word = ""
    else:
      word.add r
  if word.len > 0: result.add word

proc pythonStrip(text: string): seq[Rune] =
  result = text.toRunes
  while result.len > 0 and result[^1].isPythonSpace: result.setLen(result.len - 1)
  var start = 0
  while start < result.len and result[start].isPythonSpace: inc start
  result = result[start .. ^1]

proc words(text: string): seq[string] =
  for word in pythonSplit(visibleText(text)):
    result.add unicode.toLower(word).strip(chars = {'.', '(', ')', ',', '"'})

proc isUnfamiliar(word: string): bool =
  let isNumber = word.len > 0 and word.allCharsInSet(Digits)
  not isNumber and word notin easyWords

proc isWordChar(r: Rune): bool =
  r.isAlpha or (r.int < 128 and char(r.int) in {'0'..'9', '_'})

proc countSentences(text: string): int =
  let runes = pythonStrip(text.replace('\n', ' '))
  const terminators = [Rune('.'), Rune('!'), Rune('?')]
  proc boundary(i: int): bool =
    let before = i > 0 and runes[i - 1].isWordChar
    let after = i < runes.len and runes[i].isWordChar
    before != after
  var i = 0
  while i < runes.len:
    if boundary(i) and runes[i] notin terminators:
      while i < runes.len and runes[i] notin terminators: inc i
      while i < runes.len and runes[i] in terminators: inc i
      inc result
    else:
      inc i

proc pctUnfamiliarWords*(text: string): float =
  let words = words(text)
  if words.len == 0:
    fail NoWords
  var unfamiliar = 0
  for word in words:
    if isUnfamiliar(word.replace("'s", "").replace("s'", "")):
      inc unfamiliar
  unfamiliar / words.len

proc avgSentenceLength*(text: string): float =
  let sentences = countSentences(text)
  if sentences == 0:
    fail NoSentences
  words(text).len / sentences
