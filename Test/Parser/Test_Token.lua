local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local Token = require("kengen2.Parser.Token")
local TokenTypes = require("kengen2.Parser.TokenTypes")

Test_Token = {}

function Test_Token:Test_Unit_New()
	
	local Token = Token:New(TokenTypes.STARTSCRIPT, 1, 2)
	LU.assertEquals(Token.Type, TokenTypes.STARTSCRIPT)
	LU.assertEquals(Token.StartPos, 1)
	LU.assertEquals(Token.EndPos, 2)
	
	LU.assertError(function()
		Token = Token:New("BLAH", 1, 2)
	end)
	LU.assertError(function()
		Token = Token:New(1, 1, 2)
	end)
	LU.assertError(function()
		Token = Token:New(TokenTypes.STARTSCRIPT, 3, 2)
	end)
	LU.assertError(function()
		Token = Token:New(TokenTypes.STARTSCRIPT, "blah", 2)
	end)
	LU.assertError(function()
		Token = Token:New(TokenTypes.STARTSCRIPT, 1, "blah")
	end)
end

return Test_Token