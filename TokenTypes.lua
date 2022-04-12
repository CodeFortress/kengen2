local TableUtil = require("TableUtil")

local TokenTypes = {
    Invalid = 0,
    STARTSCRIPT = 1,
    ENDSCRIPT = 2,
    STARTTEMPLATE = 3,
    ENDTEMPLATE = 4,
    FOREACH = 5,
    ENDFOREACH = 6,
    IF = 7,
    ENDIF = 8,
    ELSEIF = 9,
    ELSE = 10,
    ScriptLine = 11,
    TemplateLine = 12,
    STARTFUNCTION = 13,
    ENDFUNCTION = 14,
}

-- Having this mess up iteration is ugly, but we can make a custom iterator if we need to iterate
--  over the token types
local inversion = TableUtil.Invert(TokenTypes)
TokenTypes.ToString = inversion

return TokenTypes