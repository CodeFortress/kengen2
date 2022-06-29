-- Contains settings which kengen2 needs when executing generated lua files
local IOutputStream = require("kengen2.Execution.IOutputStream")
local Util = require("kengen2.Util")

local MemoryOutputStream = Util.ClassUtil.CreateClass("MemoryOutputStream", IOutputStream)

function MemoryOutputStream:New()
    assert(Util.TestUtil.IsTable(self) and self:IsA(MemoryOutputStream))

    local instance = MemoryOutputStream.SuperClass().New(self)
	instance.BufferData = {""}
	instance.FinalizedData = "<Unfinalized!>"
	return instance
end

function MemoryOutputStream:WriteLine(line)
	assert(Util.TestUtil.IsTable(self) and self:IsA(MemoryOutputStream))
	
	self.BufferData[#self.BufferData + 1] = line
	self.BufferData[#self.BufferData + 1] = "\n"
end

function MemoryOutputStream:Close()
	assert(Util.TestUtil.IsTable(self) and self:IsA(MemoryOutputStream))
	
	self.FinalizedData = table.concat(self.BufferData, "")
end

return MemoryOutputStream
