local StringUtil = require("StringUtil")
local GrammarRule = require("GrammarRule")
local ASTNode = require("ASTNode")

local Grammar = {}
Grammar.__index = Grammar

-- Grammar rules:
-- terminals are just words, other rules are surrounded with <>
-- * = 0 or more
-- + = 1 or more
-- ? = 0 or 1
-- | to separate multiple alternative matches for a rule
-- must have a "program" rule
KenGenGrammar = {}
KenGenGrammar.program = "<block>*"
KenGenGrammar.block = "<func_block> | <exec_block>"
KenGenGrammar.func_block = "FUNCTION <exec_chain> ENDFUNCTION"
KenGenGrammar.exec_block = "<if_block> | <foreach_block> | <script_block> | <template_block> | CALLFUNC | ScriptLine+ | TemplateLine+"
KenGenGrammar.exec_chain = "<exec_block>*"
KenGenGrammar.if_block = "IF <exec_chain> <elseif_block>* <else_block>? ENDIF"
KenGenGrammar.elseif_block = "ELSEIF <exec_chain>"
KenGenGrammar.else_block = "ELSE <exec_chain>"
KenGenGrammar.foreach_block = "FOREACH <exec_chain> ENDFOREACH"
KenGenGrammar.script_block = "STARTSCRIPT <exec_chain> ENDSCRIPT"
KenGenGrammar.template_block = "STARTTEMPLATE <exec_chain> ENDTEMPLATE"

function Grammar.New(definition)
    local self = setmetatable({}, Grammar)

    self.Rules = {}
    for key, val in pairs(definition) do
        -- Separate alternate definitions of the same token
        self.Rules[key] = {}
        local curRuleList = self.Rules[key]
        local split = StringUtil.Split(val, "|")
        for _, alternative in ipairs(split) do
            curRuleList[#curRuleList + 1] = GrammarRule.New(self, alternative)
        end
    end
end

function Grammar:Parse(tokenizedFile)
    for _, alternative in self.Rules["program"] do
        if Grammar:Matches(alternative, tokenizedFile, tokenizedFile.StartPos, tokenizedFile.EndPos) then
            local root = ASTNode.New(alternative, tokenizedFile.StartPos, tokenizedFile.EndPos)
            return root
        end
    end

    return nil
end

function Grammar:Matches(rule, tokenizedFile, startPos, endPos)
    return rule:Matches(tokenizedFile, startPos, endPos)
end

return Grammar