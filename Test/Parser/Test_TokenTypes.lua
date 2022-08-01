local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local TokenTypes = require("kengen2.Parser.TokenTypes")

Test_TokenTypes = {}

function Test_TokenTypes:Test_Unit_IsToken()
	LU.assertTrue(TokenTypes.IsToken(TokenTypes.STARTSCRIPT))
	LU.assertTrue(TokenTypes.IsToken(TokenTypes.ENDSCRIPT))
	LU.assertTrue(TokenTypes.IsToken(TokenTypes.STARTFUNCTION))
	LU.assertTrue(TokenTypes.IsToken(TokenTypes.ENDFUNCTION))
	
	LU.assertFalse(TokenTypes.IsToken("blah"))
	LU.assertFalse(TokenTypes.IsToken(TokenTypes.Invalid))
	LU.assertFalse(TokenTypes.IsToken(2))
	LU.assertFalse(TokenTypes.IsToken(TokenTypes.IsToken))
end

return TokenTypes