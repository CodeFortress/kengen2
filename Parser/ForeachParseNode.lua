local ListParseNode = require("kengen2.Parser.ListParseNode")
local Util = require("kengen2.Util")

local ForeachParseNode = Util.ClassUtil.CreateClass("ForeachParseNode", ListParseNode)

return ForeachParseNode
