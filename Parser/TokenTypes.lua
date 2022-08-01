local TableUtil = require("kengen2.Util.TableUtil")

local TokenTypes = {
    Invalid = "Invalid",
    STARTSCRIPT = "STARTSCRIPT",
    ENDSCRIPT = "ENDSCRIPT",
    STARTTEMPLATE = "STARTTEMPLATE",
    ENDTEMPLATE = "ENDTEMPLATE",
    FOREACH = "FOREACH",
    ENDFOREACH = "ENDFOREACH",
    IF = "IF",
    ENDIF = "ENDIF",
    ELSEIF = "ELSEIF",
    ELSE = "ELSE",
    ScriptLine = "ScriptLine",
    TemplateLine = "TemplateLine",
    STARTFUNCTION = "STARTFUNCTION",
    ENDFUNCTION = "ENDFUNCTION",
}

-- Having this mess up iteration is ugly, but we can make a custom iterator if we need to iterate
--  over the token types
TokenTypes.IsToken = function (maybeToken)
	return maybeToken ~= "IsToken" and TokenTypes[maybeToken] ~= nil
end

return TokenTypes