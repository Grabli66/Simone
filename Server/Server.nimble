# Package

version       = "0.1.0"
author        = "Grabli66"
description   = "Simone Server"
license       = "MIT"
srcDir        = "src"
bin           = @["Server"]
binDir        = "out"

# Dependencies

requires "nim >= 2.2.2"
requires "db_connector"
requires "mummy"