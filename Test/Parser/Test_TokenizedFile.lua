local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local Settings = require("kengen2.Framework.Settings")

local Token = require("kengen2.Parser.Token")
local TokenizedFile = require("kengen2.Parser.TokenizedFile")
local TokenTypes = require("kengen2.Parser.TokenTypes")

Test_TokenizedFile = {}

function Test_TokenizedFile:Test_Unit_New()
	
	local Token1 = Token:New(TokenTypes.STARTSCRIPT, 1, 1)
	local Token2 = Token:New(TokenTypes.ScriptLine, 2, 4)
	local Token3 = Token:New(TokenTypes.ENDSCRIPT, 5, 5)
	
	local Tokens = { Token1, Token2, Token3 }
	
	local DummyPath = "/dummy/path"
	local StringsByLine = { TokenTypes.STARTSCRIPT, ".foo = 1", ".bar = 2", ".baz = 3", TokenTypes.ENDSCRIPT }
	local CleanStringsByLine = { TokenTypes.STARTSCRIPT, "foo = 1", "bar = 2", "baz = 3", TokenTypes.ENDSCRIPT }
	local Settings = Settings:New()
	
	local TokenizedFile = TokenizedFile:New(DummyPath, StringsByLine, CleanStringsByLine, Tokens, Settings)
	LU.assertEquals(TokenizedFile.Length, 5)
	LU.assertEquals(TokenizedFile.Path, DummyPath)
	LU.assertEquals(TokenizedFile.StringsByLine, StringsByLine)
	LU.assertEquals(TokenizedFile.CleanStringsByLine, CleanStringsByLine)
	LU.assertEquals(TokenizedFile.Settings, Settings)
	LU.assertEquals(#TokenizedFile.TokensByLine, 5)
end

function Test_TokenizedFile:Test_Unit_MakeTokensByLine()
	
	local Token1 = Token:New(TokenTypes.STARTSCRIPT, 1, 1)
	local Token2 = Token:New(TokenTypes.ScriptLine, 2, 4)
	local Token3 = Token:New(TokenTypes.ENDSCRIPT, 5, 5)
	
	local Tokens = { Token1, Token2, Token3 }
	local TokensByLine = TokenizedFile.MakeTokensByLine(Tokens)
	
	LU.assertEquals(TokensByLine[1], Token1)
	LU.assertEquals(TokensByLine[2], Token2)
	LU.assertEquals(TokensByLine[3], Token2)
	LU.assertEquals(TokensByLine[4], Token2)
	LU.assertEquals(TokensByLine[5], Token3)
end

return Test_TokenizedFile