local ListParseNode = require("kengen2.Parser.ListParseNode")
local Util = require("kengen2.Util")

local FuncParseNode = Util.ClassUtil.CreateClass("FuncParseNode", ListParseNode)

return FuncParseNode
