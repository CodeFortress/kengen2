local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local Util = require("kengen2.Util")

local TemplateChunkParseNode = Util.ClassUtil.CreateClass("TemplateChunkParseNode", AbstractParseNode)

function TemplateChunkParseNode:Preprocess(preprocessParams)
	-- TODO: Actually perform work...
end

return TemplateChunkParseNode
