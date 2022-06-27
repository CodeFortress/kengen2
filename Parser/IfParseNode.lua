local ListParseNode = require("kengen2.Parser.ListParseNode")
local Util = require("kengen2.Util")

local IfParseNode = Util.ClassUtil.CreateClass("IfParseNode", ListParseNode)

return IfParseNode
