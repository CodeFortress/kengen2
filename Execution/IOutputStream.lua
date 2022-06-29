-- Contains settings which kengen2 needs when executing generated lua files
local Util = require("kengen2.Util")

local IOutputStream = Util.ClassUtil.CreateClass("IOutputStream", nil)

function IOutputStream:New()
    assert(Util.TestUtil.IsTable(self) and self:IsA(IOutputStream))

    return self:Create()
end

function IOutputStream:WriteLine(line)
	error(self:ClassName().." needs to override IOutputStream:WriteLine")
end

function IOutputStream:Close()
	error(self:ClassName().." needs to override IOutputStream:Close")
end

return IOutputStream
