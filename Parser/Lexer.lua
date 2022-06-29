local StringUtil = require("kengen2.Util.StringUtil")
local TableUtil = require("kengen2.Util.TableUtil")
local TestUtil = require("kengen2.Util.TestUtil")
local Token = require("kengen2.Parser.Token")
local TokenizedFile = require("kengen2.Parser.TokenizedFile")
local TokenTypes = require("kengen2.Parser.TokenTypes")

local Lexer = {}

function Lexer.IsMergeableType(tokenType)
    return tokenType == TokenTypes.ScriptLine or tokenType == TokenTypes.TemplateLine
end

-- Takes a kengen filepath and returns a TokenizedFile
function Lexer.Tokenize(filepath)
	assert(TestUtil.IsString(filepath))
	
	local content = StringUtil.FileToString(filepath)
	local stringsByLine, tokens = Lexer.TokenizeImpl(filepath, content)
	return TokenizedFile:New(filepath, stringsByLine, tokens)
end

-- Takes a kengen string and returns the tokens
function Lexer.TokenizeString(string)
	assert(TestUtil.IsString(string))
	
	local stringsByLine, tokens = Lexer.TokenizeImpl("<RawString>", string)
	return tokens
end

-- returns a token type for the provided line
-- "easyDirectives" indicates whether you can skip the "." in front of ALL directives, even when in template mode
function Lexer.ExtractTokenFromLine(line, isTemplateMode, easyDirectives)
	local token, contents = Lexer.ExtractTokenAndContentFromLine(line, isTemplateMode, easyDirectives)
	return token
end

-- returns a token type for the provided line
-- "easyDirectives" indicates whether you can skip the "." in front of ALL directives, even when in template mode
function Lexer.ExtractContentFromLine(line, isTemplateMode, easyDirectives)
	local token, contents = Lexer.ExtractTokenAndContentFromLine(line, isTemplateMode, easyDirectives)
	return contents
end

function Lexer.ExtractTokenAndContentFromLine(line, isTemplateMode, easyDirectives)
	local firstChar = line:sub(1,1)
	local isTemplateLine = (firstChar ~= ".") and isTemplateMode
	if not isTemplateLine and (firstChar == ">" or firstChar == ".") then
		line = line:sub(2) -- Remove preceding > or .
	end
	
	local trimmed = StringUtil.Trim(line)
	local firstCharPostWhitespace = trimmed:sub(1,1)
	if not isTemplateLine and (firstCharPostWhitespace == ">" or firstCharPostWhitespace == ".") then
		trimmed = trimmed:sub(2) -- Remove preceding > or .
	end
	
	local firstSpace = trimmed:find(" ")
	local firstWord = (firstSpace and trimmed:sub(1, firstSpace-1)) or trimmed
	
	local tokenType = TokenTypes[firstWord]
	if isTemplateLine and not easyDirectives then
		tokenType = TokenTypes.TemplateLine
	elseif tokenType ~= nil then
		-- no action, it's already been set correctly
	elseif firstChar == ">" or firstCharPostWhitespace == ">" then
		tokenType = TokenTypes.TemplateLine
	elseif firstChar == "." or firstCharPostWhitespace == "." then
		tokenType = TokenTypes.ScriptLine
	else
		tokenType = (isTemplateMode and TokenTypes.TemplateLine) or TokenTypes.ScriptLine
	end
	
	return tokenType, trimmed
end

-- returns a pair of <stringsByLine, tokens>
function Lexer.TokenizeImpl(debugName, stringContents)
	assert(TestUtil.IsString(debugName))
	assert(TestUtil.IsString(stringContents))
	
    local stringsByLine = StringUtil.Split(stringContents, "\n")
    local tokens = {}
    local isTemplateModeStack = {}
    function isTemplateMode()
        if #isTemplateModeStack == 0 then
            return true
        else
            return isTemplateModeStack[#isTemplateModeStack]
        end
    end

    for index, current in ipairs(stringsByLine) do
		
		local tokenType = Lexer.ExtractTokenFromLine(current, isTemplateMode(), false)
		
		-- in an ideal world this would be the parser's job but it saves us so much headache to just identify
		--  what lines here are script vs template
		if tokenType == TokenTypes.STARTSCRIPT then
			isTemplateModeStack[#isTemplateModeStack + 1] = false
		elseif tokenType == TokenTypes.STARTTEMPLATE then
			isTemplateModeStack[#isTemplateModeStack + 1] = true
		elseif tokenType == TokenTypes.ENDSCRIPT then
			assert(not isTemplateMode(), "File "..debugName.." had an ENDSCRIPT when not in script mode at line "..index)
			assert(#isTemplateModeStack > 0, "File "..debugName.." had an ENDSCRIPT without matching start on line "..index)
			isTemplateModeStack[#isTemplateModeStack] = nil
		elseif tokenType == TokenTypes.ENDTEMPLATE then
			assert(isTemplateMode(), "File "..debugName.." had an ENDTEMPLATE when not in template mode at line "..index)
			assert(#isTemplateModeStack > 0, "File "..debugName.." had an ENDTEMPLATE without matching start on line "..index)
			isTemplateModeStack[#isTemplateModeStack] = nil
		end

        -- determine whether this line is a part of the same token
        -- or whether to create a new token
        if Lexer.IsMergeableType(tokenType) and #tokens > 0 and tokens[#tokens].Type == tokenType then
            tokens[#tokens].EndPos = tokens[#tokens].EndPos + 1
        else
            tokens[#tokens + 1] = Token:New(tokenType, index, index)
        end
    end
    return stringsByLine, tokens
end

return Lexer