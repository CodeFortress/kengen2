local LU = require('kengen2.ThirdParty.luaunit.luaunit')
local Settings = require("kengen2.Framework.Settings")

Test_ClassUtil = {}

function Test_ClassUtil:Test_Unit_IsAFailsOnNil()
	local function funcToFail()
		local settings = Settings:New()
		settings:IsA(nil)
	end
	LU.assertErrorMsgContains("Passed a nil class to an IsA check", funcToFail)
end

return Test_ClassUtil