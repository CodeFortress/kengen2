local StringUtil = require("kengen2.Util.StringUtil")
local TableUtil = require("kengen2.Util.TableUtil")
local Token = require("kengen2.Parser.Token")
local TokenizedFile = require("kengen2.Parser.TokenizedFile")
local TokenTypes = require("kengen2.Parser.TokenTypes")

local Lexer = {}

function Lexer.IsMergeableType(tokenType)
    return tokenType == TokenTypes.ScriptLine or tokenType == TokenTypes.TemplateLine
end

-- Takes a kengen filepath and returns a TokenizedFile
function Lexer.Tokenize(filepath)
    local content = StringUtil.FileToString(filepath)
    local stringsByLine = StringUtil.Split(content, "\n")
    local tokens = {}
    local isTemplateModeStack = {}
    function isTemplateMode()
        if #isTemplateModeStack == 0 then
            return true
        else
            return isTemplateModeStack[#isTemplateModeStack]
        end
    end

    for index, string in ipairs(stringsByLine) do
        local trimmed = StringUtil.Trim(stringsByLine[index])
        local tokenType = TokenTypes[trimmed]
        if TokenTypes[trimmed] ~= nil then
            -- tokenType is already correct, but do extra logic
            -- in an ideal world this would be the parser's job but it saves us so much headache to just identify
            --  what lines here are script vs template
            if tokenType == TokenTypes.STARTSCRIPT then
                isTemplateModeStack[#isTemplateModeStack + 1] = false
            elseif tokenType == TokenTypes.STARTTEMPLATE then
                isTemplateModeStack[#isTemplateModeStack + 1] = true
            elseif tokenType == TokenTypes.ENDSCRIPT then
                assert(not isTemplateMode(), "File "..filepath.." had an ENDSCRIPT when not in script mode at line "..index)
                assert(#isTemplateModeStack > 0, "File "..filepath.." had an ENDSCRIPT without matching start on line "..index)
                isTemplateModeStack[#isTemplateModeStack] = nil
            elseif tokenType == TokenTypes.ENDTEMPLATE then
                assert(isTemplateMode(), "File "..filepath.." had an ENDTEMPLATE when not in template mode at line "..index)
                assert(#isTemplateModeStack > 0, "File "..filepath.." had an ENDTEMPLATE without matching start on line "..index)
                isTemplateModeStack[#isTemplateModeStack] = nil
            end
        elseif StringUtil.StartsWith(trimmed, ">") then
            tokenType = TokenTypes.TemplateLine
        elseif StringUtil.StartsWith(trimmed, ".") then
            tokenType = TokenTypes.ScriptLine
        else
            tokenType = (isTemplateMode() and TokenTypes.TemplateLine) or TokenTypes.ScriptLine
        end

        -- determine whether this line is a part of the same token
        -- or whether to create a new token
        if Lexer.IsMergeableType(tokenType) and tokens[#tokens].TokenType == tokenType then
            tokens[#tokens].EndLine = tokens[#tokens].EndLine + 1
        else
            tokens[#tokens + 1] = Token:New(tokenType, index, index)
        end
    end
    return TokenizedFile:New(filepath,stringsByLine,tokens)
end

return Lexer