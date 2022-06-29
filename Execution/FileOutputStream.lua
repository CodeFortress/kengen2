-- Contains settings which kengen2 needs when executing generated lua files
local IOutputStream = require("kengen2.Execution.IOutputStream")
local Util = require("kengen2.Util")

local FileOutputStream = Util.ClassUtil.CreateClass("FileOutputStream", IOutputStream)

function FileOutputStream:New(filepath)
    assert(Util.TestUtil.IsTable(self) and self:IsA(FileOutputStream))
	assert(Util.TestUtil.IsString(filepath))

    local instance = FileOutputStream.SuperClass().New(self)
	local err
	instance.WriteHandle, err = io.open(filepath, "w")
	assert(instance.WriteHandle ~= nil,
		"FileOutputStream :: Failed to open output file: " .. tostring(filepath) .. " err: " .. tostring(err))
	return instance
end

function FileOutputStream:WriteLine(line)
	assert(Util.TestUtil.IsTable(self) and self:IsA(FileOutputStream))
	
	self.WriteHandle:write(line)
	self.WriteHandle:write("\n")
end

return FileOutputStream
