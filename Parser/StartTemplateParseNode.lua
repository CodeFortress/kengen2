local ListParseNode = require("kengen2.Parser.ListParseNode")
local Util = require("kengen2.Util")

local StartTemplateParseNode = Util.ClassUtil.CreateClass("StartTemplateParseNode", ListParseNode)

return StartTemplateParseNode
