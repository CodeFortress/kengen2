local ASTNode = require("kengen2.ASTNode")
local StringUtil = require("kengen2.Util.StringUtil")
require("kengen2.Util")

local GrammarRuleItem = {}
GrammarRuleItem.__index = GrammarRuleItem

function GrammarRuleItem.New(grammarRule, symbol)
    local self = setmetatable({}, GrammarRuleItem)
    self.RawText = symbol

    assert(Util.TestUtil.IsTable(grammarRule))
    assert(Util.TestUtil.IsString(symbol))
    symbol = StringUtil.Trim(symbol)
    assert(symbol:len() > 0)

    self.Rule = grammarRule

    if StringUtil.EndsWith(symbol, "*") then
        self.RepeatType = "*"
    elseif StringUtil.EndsWith(symbol, "+") then
        self.RepeatType = "+"
    elseif StringUtil.EndsWith(symbol, "?") then
        self.RepeatType = "?"
    else
        self.RepeatType = nil
    end
    assert(self.RepeatType == nil or self.RepeatType == "*" or self.RepeatType == "+" or self.RepeatType == "?")

    if self.RepeatType ~= nil then
        symbol = symbol:sub(1, -2)
    end

    if StringUtil.StartsWith(symbol, "<") and StringUtil.EndsWith(symbol, ">") then
        self.IsTerminal = false
        symbol = symbol:sub(2, -2)
    else
        self.IsTerminal = true
    end

    self.Name = symbol
    return self
end

function GrammarRuleItem:MatchTo(tokenizedFile, startPos, endPos)
    if ((not self:IsOptional()) and (startPos > endPos)) then
        return nil
    end
    if self.IsTerminal then
        if tokenizedFile.TokensByLine[startPos] == symbol then
            if self:IsRepeatable() then
                local curPos = startPos
                local lastMatchPos = startPos
                while tokenizedFile.TokensByLine[curPos] == symbol do
                    lastMatchPos = curPos
                    curPos = curPos + 1
                end
                return ASTNode.New(self, startPos, lastMatchPos)
            else
                return ASTNode.New(self, startPos, startPos) -- Consumes only one token
            end
        end
    else
        local rule = self.Grammar.Rules[symbol]
        assert(rule ~= nil, "Non-terminal in grammar did not have a definition: "..tostring(symbol))
        local match = rule:MatchTo(tokenizedFile, startPos, endPos)
    end
end

function GrammarRuleItem:IsRepeatable()
    return self.RepeatType = "*" or self.RepeatType = "+"
end

function GrammarRuleItem:IsOptional()
    return self.RepeatType = "*" or self.RepeatType = "?"
end

return GrammarRuleItem