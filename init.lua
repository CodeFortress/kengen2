-- Public API for Kengen2
-- 'require' this to get access to the functionality you need!

local Kengen2 = {
	Framework = require("kengen2.Framework"),
	Parser = require("kengen2.Parser"),
	Test = require("kengen2.Test"),
	ThirdParty = require("kengen2.ThirdParty"),
	Util = require("kengen2.Util")
}

return Kengen2
