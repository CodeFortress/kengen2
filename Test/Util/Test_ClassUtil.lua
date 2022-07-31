local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local ClassUtil = require("kengen2.Util.ClassUtil")
local TestUtil = require("kengen2.Util.TestUtil")

Test_ClassUtil = {}

function Test_ClassUtil:Test_Unit_1_CreateClass()
	local DummyClass = ClassUtil.CreateClass("DummyClass", nil)
	LU.assertTrue(DummyClass ~= nil)
end

function Test_ClassUtil:Test_Unit_2_CreateSubclass()
	local DummyClass = ClassUtil.CreateClass("DummyClass", nil)
	local DummySubclass = ClassUtil.CreateClass("DummySubclass", DummyClass)
	LU.assertTrue(DummySubclass ~= nil)
end

function Test_ClassUtil:Test_Unit_3_CreateInstance()
	local DummyClass = ClassUtil.CreateClass("DummyClass", nil)
	LU.assertTrue(DummyClass ~= nil)
	
	local DummyObject = DummyClass:Create()
	LU.assertEquals(DummyClass, DummyObject:Class())
	LU.assertEquals(nil, DummyObject:SuperClass())
	LU.assertEquals(tostring(DummyObject), "ObjectOfType:DummyClass")
end

function Test_ClassUtil:Test_Unit_4_CreateSubclassInstance()
	local DummyClass = ClassUtil.CreateClass("DummyClass", nil)
	LU.assertTrue(DummyClass ~= nil)
	
	local DummySubclass = ClassUtil.CreateClass("DummySubclass", DummyClass)
	LU.assertTrue(DummySubclass ~= nil)
	
	local DummyObject = DummySubclass:Create()
	LU.assertEquals(DummySubclass, DummyObject:Class())
	LU.assertEquals(DummyClass, DummyObject:SuperClass())
	LU.assertEquals(tostring(DummyObject), "ObjectOfType:DummySubclass")
end

function Test_ClassUtil:Test_Unit_5_IsA()
	local DummyClass = ClassUtil.CreateClass("DummyClass", nil)
	LU.assertTrue(DummyClass ~= nil)
	
	local DummySubclass = ClassUtil.CreateClass("DummySubclass", DummyClass)
	LU.assertTrue(DummySubclass ~= nil)
	
	local OtherClass = ClassUtil.CreateClass("OtherClass", nil)
	LU.assertTrue(OtherClass ~= nil)
	
	local DummyClassObject = DummyClass:Create()
	LU.assertTrue(DummyClassObject:IsA(DummyClass))
	LU.assertFalse(DummyClassObject:IsA(DummySubclass))
	LU.assertFalse(DummyClassObject:IsA(OtherClass))
	
	local DummySubclassObject = DummySubclass:Create()
	LU.assertTrue(DummySubclassObject:IsA(DummyClass))
	LU.assertTrue(DummySubclassObject:IsA(DummySubclass))
	LU.assertFalse(DummySubclassObject:IsA(OtherClass))
	
	local function funcToFail()
		DummyClassObject:IsA(nil)
	end
	LU.assertErrorMsgContains("Passed a nil class to an IsA check", funcToFail)
end

return Test_ClassUtil