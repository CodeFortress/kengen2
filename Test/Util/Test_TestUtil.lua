local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local TestUtil = require("kengen2.Util.TestUtil")

Test_TestUtil = {}

function Test_TestUtil:Test_Unit_IsTable()
	LU.assertFalse(TestUtil.IsTable(nil))
	LU.assertTrue(TestUtil.IsTable({}))
	LU.assertTrue(TestUtil.IsTable({Test_TestUtil}))
	LU.assertTrue(TestUtil.IsTable({1}))
	LU.assertFalse(TestUtil.IsTable(""))
	LU.assertFalse(TestUtil.IsTable("foo"))
	LU.assertFalse(TestUtil.IsTable(0))
	LU.assertFalse(TestUtil.IsTable(1))
	LU.assertFalse(TestUtil.IsTable(-1))
	LU.assertFalse(TestUtil.IsTable(false))
	LU.assertFalse(TestUtil.IsTable(true))
end

function Test_TestUtil:Test_Unit_IsString()
	LU.assertFalse(TestUtil.IsString(nil))
	LU.assertFalse(TestUtil.IsString({}))
	LU.assertFalse(TestUtil.IsString({Test_TestUtil}))
	LU.assertFalse(TestUtil.IsString({1}))
	LU.assertTrue(TestUtil.IsString(""))
	LU.assertTrue(TestUtil.IsString("foo"))
	LU.assertFalse(TestUtil.IsString(0))
	LU.assertFalse(TestUtil.IsString(1))
	LU.assertFalse(TestUtil.IsString(-1))
	LU.assertFalse(TestUtil.IsString(false))
	LU.assertFalse(TestUtil.IsString(true))
end

function Test_TestUtil:Test_Unit_IsBool()
	LU.assertFalse(TestUtil.IsBool(nil))
	LU.assertFalse(TestUtil.IsBool({}))
	LU.assertFalse(TestUtil.IsBool({Test_TestUtil}))
	LU.assertFalse(TestUtil.IsBool({1}))
	LU.assertFalse(TestUtil.IsBool(""))
	LU.assertFalse(TestUtil.IsBool("foo"))
	LU.assertFalse(TestUtil.IsBool(0))
	LU.assertFalse(TestUtil.IsBool(1))
	LU.assertFalse(TestUtil.IsBool(-1))
	LU.assertTrue(TestUtil.IsBool(false))
	LU.assertTrue(TestUtil.IsBool(true))
end

function Test_TestUtil:Test_Unit_IsNumber()
	LU.assertFalse(TestUtil.IsNumber(nil))
	LU.assertFalse(TestUtil.IsNumber({}))
	LU.assertFalse(TestUtil.IsNumber({Test_TestUtil}))
	LU.assertFalse(TestUtil.IsNumber({1}))
	LU.assertFalse(TestUtil.IsNumber(""))
	LU.assertFalse(TestUtil.IsNumber("foo"))
	LU.assertTrue(TestUtil.IsNumber(0))
	LU.assertTrue(TestUtil.IsNumber(1))
	LU.assertTrue(TestUtil.IsNumber(-1))
	LU.assertFalse(TestUtil.IsNumber(false))
	LU.assertFalse(TestUtil.IsNumber(true))
end

return Test_TestUtil