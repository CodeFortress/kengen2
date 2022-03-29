local Lexer = require("Lexer")

local tokenizedFile = Tokenize("test.kengen")
tokenizedFile:PrintDebug()
