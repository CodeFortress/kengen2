local ASTNode = require("ASTNode")
local GrammarRuleItem = require("GrammarRuleItem")
local StringUtil = require("StringUtil")
local Util = require("Util")

local GrammarRule = {}
GrammarRule.__index = GrammarRule

function GrammarRule.New(grammar, items)
    assert(Util.IsTable(grammar))
    assert(Util.IsString(items))

    local self = setmetatable({}, GrammarRule)
    self.Grammar = grammar
    self.RawText = items
    self.Items = {}
    local split = StringUtil.Split(items)
    for _, item in ipairs(split) do
        self.Items[#self.Items + 1] = GrammarRuleItem.New(self, item)
    end
    return self
end

function GrammarRule:MatchTo(tokenizedFile, startPos, targetEndPos)
    local node = ASTNode.New(self, startPos, targetEndPos)

    local curLine = startPos
    for item in Items do
        local nodeMatch = item:MatchTo(tokenizedFile, curLine, targetEndPos)
        if nodeMatch == nil then
            return nil
        else
            node:Add(nodeMatch, item)
            curLine = nodeMatch.EndPos + 1
        end
    end

    if curLine == targetEndPos then
        return node
    end

    return nil
end

return GrammarRule