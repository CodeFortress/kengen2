local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local Util = require("kengen2.Util")

local TemplateChunkParseNode = Util.ClassUtil.CreateClass("TemplateChunkParseNode", AbstractParseNode)

return TemplateChunkParseNode
