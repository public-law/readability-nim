import std/[strutils, tables, unicode]
import entities

const hiddenTags = ["script", "style", "template", "rt", "rp"]

proc decodeEntity(entity: string): string =
  try:
    let code =
      if entity.startsWith("#x") or entity.startsWith("#X"): parseHexInt(entity[2..^1])
      elif entity.startsWith("#"): parseInt(entity[1..^1])
      else: return namedEntities.getOrDefault(entity)
    if code in 1 .. 0x10FFFF: $Rune(code) else: ""
  except ValueError:
    ""

proc tagName(tag: string): string =
  var i = 0
  if i < tag.len and tag[i] == '/': inc i
  while i < tag.len and tag[i] notin Whitespace + {'/', '>'}:
    result.add toLowerAscii(tag[i])
    inc i

proc visibleText*(markup: string): string =
  var i = 0
  var hiddenUntil = ""
  while i < markup.len:
    if markup.continuesWith("<!--", i):
      let close = markup.find("-->", i + 4)
      i = if close < 0: markup.len else: close + 3
    elif markup[i] == '<' and i + 1 < markup.len and markup[i + 1] in Letters + {'/', '!', '?'}:
      let close = markup.find('>', i)
      if close < 0:
        result.add markup[i .. ^1]
        break
      let tag = markup[i + 1 ..< close]
      let name = tagName(tag)
      if hiddenUntil == "" and name in hiddenTags and not tag.startsWith('/'):
        hiddenUntil = name
      elif hiddenUntil == name and tag.startsWith('/'):
        hiddenUntil = ""
      i = close + 1
    elif hiddenUntil != "":
      inc i
    elif markup[i] == '&':
      let semi = markup.find(';', i)
      let decoded =
        if semi > i + 1 and semi - i <= 33: decodeEntity(markup[i + 1 ..< semi])
        else: ""
      if decoded.len > 0:
        result.add decoded
        i = semi + 1
      else:
        result.add '&'
        inc i
    else:
      result.add markup[i]
      inc i
