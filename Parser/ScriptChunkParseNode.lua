local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local Util = require("kengen2.Util")

local ScriptChunkParseNode = Util.ClassUtil.CreateClass("ScriptChunkParseNode", AbstractParseNode)

function ScriptChunkParseNode:Preprocess(preprocessParams)
	-- TODO: Actually perform work...
end

return ScriptChunkParseNode
