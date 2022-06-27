local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local Util = require("kengen2.Util")

local ScriptChunkParseNode = Util.ClassUtil.CreateClass("ScriptChunkParseNode", AbstractParseNode)

return ScriptChunkParseNode
