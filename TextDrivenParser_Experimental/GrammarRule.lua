local ASTNode = require("kengen2.ASTNode")
local GrammarRuleItem = require("kengen2.GrammarRuleItem")
local StringUtil = require("kengen2.Util.StringUtil")
require("kengen2.Util")

local GrammarRule = {}
GrammarRule.__index = GrammarRule

function GrammarRule.New(grammar, items)
    assert(Util.TestUtil.IsTable(grammar))
    assert(Util.TestUtil.IsString(items))

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