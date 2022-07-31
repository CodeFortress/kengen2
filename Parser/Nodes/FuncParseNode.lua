local ListParseNode = require("kengen2.Parser.Nodes.ListParseNode")
local Util = require("kengen2.Util")

local FuncParseNode = Util.ClassUtil.CreateClass("FuncParseNode", ListParseNode)

return FuncParseNode
