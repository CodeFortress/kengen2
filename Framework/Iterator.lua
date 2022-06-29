-- Custom iterator to enable kengen functionality
-- This file was used in CoGS for CA, but was part of kengen first
-- Changes have been made for kengen2

local Iterator = {}

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

-- _data is a table with the values we're iterating
-- _where is a function which takes a single value as input and returns a bool
-- _by is a function used to sort the order of the iteration
function Iterator.iterate(_data, _where, _by)
	
	if _data == nil then
		return function() return nil end
	end
	
	local itOut = {};
	itOut.__origIndices = {}
	
	-- each item iterated over will have a reference back to its iterator
	
	-- TODO: is it possible to optimize this for common use case when _where and _by are both null?
	
	-- iterate over the data (the irony!) to construct the filtered iterator
	-- also create the lookup table for original indices
	local origIndex = 1
	for _,v in pairs(_data) do
		if _where == nil or _where(v) then
			table.insert(itOut, v)
			itOut.__origIndices[v] = origIndex
			
			-- assign iterator and helper functions to each object
			-- there's a very slim chance this could clobber valid data in a field name "__kengen_iter" :P
			v.__kengen_iter = itOut
		end
		origIndex = origIndex + 1
	end
	
	if _by ~= nil then
		table.sort(itOut, _by)
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