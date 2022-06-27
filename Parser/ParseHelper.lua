local Lexer = require("kengen2.Parser.Lexer")
local Parser = require("kengen2.Parser.Parser")

local ParseHelper = {}

function ParseHelper.ParseFile(path)
	local tokenizedFile = Lexer.Tokenize(path)
	tokenizedFile:PrintDebug()

	local parser = Parser:New(tokenizedFile)
	return parser:ParseProgram()
end

return ParseHelper