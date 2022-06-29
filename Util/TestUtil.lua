local TestUtil = {}

function TestUtil.IsTable(var)
    return type(var) == "table"
end

function TestUtil.IsString(var)
    return type(var) == "string"
end

function TestUtil.IsBool(var)
    return type(var) == "boolean"
end

TestUtil.IsBoolean = TestUtil.IsBool

function TestUtil.IsNumber(var)
    return type(var) == "number"
end

return TestUtil