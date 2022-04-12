local Lexer = require("Lexer")
local Parser = require("Parser")
--local Grammar = require("Grammar")

local tokenizedFile = Tokenize("test.kengen")
tokenizedFile:PrintDebug()

print(tokenizedFile)

local parser = Parser:New(tokenizedFile)
local nodes = parser:ParseProgram()

--local g = Grammar.New(KenGenGrammar)
