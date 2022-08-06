local LU = require('kengen2.ThirdParty.luaunit.luaunit')
local MemoryOutputStream = require("kengen2.Execution.MemoryOutputStream")

Test_MemoryOutputStream = {}

function Test_MemoryOutputStream:Test_Class()
	local Stream = MemoryOutputStream:New()
	Stream:WriteLine("Hello, World")
	Stream:WriteLine("Welcome to Kengen!")
	Stream:Close()
		
	LU.assertEquals(Stream.FinalizedData, "Hello, World\nWelcome to Kengen!\n")
end

return Test_MemoryOutputStream