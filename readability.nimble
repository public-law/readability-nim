version     = "0.1.0"
author      = "Robb Shecter"
description = "Sketch of the new Dale-Chall readability formula in Nim"
license     = "MIT"
srcDir      = "src"

requires "nim == 2.2.4"

task test, "Run the tests":
  for t in ["tformulas", "tutils", "tpassages"]:
    exec "nim c --hints:off -r --path:src tests/" & t & ".nim"
