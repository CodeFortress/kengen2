-- Custom iterator to enable kengen functionality
-- This file was used in CoGS for CA, but was part of kengen first
-- Changes have been made for kengen2

local Util = require("kengen2.Util")

local Iterator = Util.ClassUtil.CreateClass("Iterator", nil)

-- data is the actual table being iterated over
-- whereFunc is a function which takes a single value as input and returns a bool
-- byFunc is a function used to sort the order of the iteration
function Iterator:New(data, whereFunc, byFunc)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Iterator))

    local instance = self:Create()
	instance.Data = data
	instance.WhereFunc = whereFunc
	instance.ByFunc = byFunc
    return instance
end

function Iterator.Count(value)
	return #value.__kengen_iter
end
function Iterator.Index(value)
	return value.__kengen_iter.__index()
end
function Iterator.OriginalIndex(value)
	return value.__kengen_iter.__origIndices[_value]
end
function Iterator.IsFirst(value)
	return Iterator.index(value) == 1
end
function Iterator.IsLast(value)
	return Iterator.index(value) == Iterator.Count(value)
end

function Iterator:Make_Iterator()
	
	if self.Data == nil then
		return function() return nil end
	end
	
	local itOut = {};
	itOut.__origIndices = {}
	
	-- each item iterated over will have a reference back to its iterator
	
	-- TODO: is it possible to optimize this for common use case when _where and _by are both null?
	
	-- iterate over the data (the irony!) to construct the filtered iterator
	-- also create the lookup table for original indices
	local origIndex = 1
	for _,v in pairs(self.Data) do
		if self.WhereFunc == nil or self.WhereFunc(v) then
			table.insert(itOut, v)
			itOut.__origIndices[v] = origIndex
			
			-- assign iterator and helper functions to each object
			-- there's a very slim chance this could clobber valid data in a field name "__kengen_iter" :P
			v.__kengen_iter = itOut
		end
		origIndex = origIndex + 1
	end
	
	if self.ByFunc ~= nil then
		table.sort(itOut, self.ByFunc)
	end
	
	itOut.Count = #itOut
	
	local i = 0
	itOut.__index = function() return i end
	return function()
		i = i + 1
		return itOut[i]
	end
end

return Iterator