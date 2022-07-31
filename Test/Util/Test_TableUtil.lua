local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local TableUtil = require("kengen2.Util.TableUtil")

Test_TableUtil = {}

function Test_TableUtil:Test_Unit_Invert()
	LU.assertEquals(TableUtil.Invert({}), {})
	LU.assertEquals(TableUtil.Invert({"foo"}), { foo = 1 })
	LU.assertEquals(TableUtil.Invert({"foo", "bar"}), { foo = 1, bar = 2 })
	
	LU.assertEquals(TableUtil.Invert({foo = "a"}), { a = "foo" })
	LU.assertEquals(TableUtil.Invert({foo = "a", bar = "b"}), { a = "foo", b = "bar" })
	
	LU.assertEquals(TableUtil.Invert({"foo", "bar", other = "baz"}), { foo = 1, bar = 2, baz = "other" })
	
	LU.assertError(function()
		TableUtil.Invert(nil)
	end)
	LU.assertError(function()
		TableUtil.Invert("foo")
	end)
	LU.assertError(function()
		TableUtil.Invert(1)
	end)
	LU.assertError(function()
		TableUtil.Invert(true)
	end)
end

function Test_TableUtil:Test_Unit_CalcLength()
	LU.assertEquals(TableUtil.CalcLength({}), 0)
	LU.assertEquals(TableUtil.CalcLength({"foo"}), 1)
	LU.assertEquals(TableUtil.CalcLength({"foo", "bar"}), 2)
	
	LU.assertEquals(TableUtil.CalcLength({foo = "a"}), 1)
	LU.assertEquals(TableUtil.CalcLength({foo = "a", bar = "b"}), 2)
	
	LU.assertEquals(TableUtil.CalcLength({"foo", "bar", other = "baz"}), 3)
	
	local skipOneTable = {}
	skipOneTable[2] = "foo"
	skipOneTable[3] = "bar"
	LU.assertEquals(TableUtil.CalcLength(skipOneTable), 2)
	
	LU.assertError(function()
		TableUtil.CalcLength(nil)
	end)
	LU.assertError(function()
		TableUtil.CalcLength("foo")
	end)
	LU.assertError(function()
		TableUtil.CalcLength(1)
	end)
	LU.assertError(function()
		TableUtil.CalcLength(true)
	end)
end

return Test_TableUtil