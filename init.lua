-- Public API for Kengen2
-- 'require' this to get access to the functionality you need!

local Kengen = {
	Framework = require("kengen2.Framework"),
	Parser = require("kengen2.Parser"),
	Util = require("kengen2.Util")
}

function Kengen.LoadXmlFile(path, settings)
	return Kengen.Framework.Xml.loadXmlFile(path, settings)
end

return Kengen
