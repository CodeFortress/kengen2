local ListParseNode = require("kengen2.Parser.ListParseNode")
local Util = require("kengen2.Util")

local StartScriptParseNode = Util.ClassUtil.CreateClass("StartScriptParseNode", ListParseNode)

return StartScriptParseNode
