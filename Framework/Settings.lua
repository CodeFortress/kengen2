-- Contains settings which kengen2 needs when executing generated lua files
-- This file was used in CoGS for CA, but was part of kengen first
-- Changes have been made for kengen2
local Util = require("kengen2.Util")

local Settings = Util.ClassUtil.CreateClass("Settings", nil)

function Settings:New()
    assert(Util.TestUtil.IsTable(self) and self:IsA(Settings))

    local instance = self:Create()
	instance.DIRECTORY_RECURSION = true
	instance.EASY_DIRECTIVES = true
    instance.XML_FLATTEN_ELEMENT_TEXT = true
    instance.XML_ELEMENT_TEXT_KEY = "InnerText"
    return instance
end

return Settings
