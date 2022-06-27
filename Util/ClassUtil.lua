local ClassUtil = {}

-- Subclass creation utility, modified from http://lua-users.org/wiki/InheritanceTutorial
function ClassUtil.CreateClass( className, baseClass )

    local new_class = {}
    local class_mt = {
        __index = new_class,
        __tostring = function(currtable)
            return currtable:ToString()
        end
    }

    function new_class.Create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:Class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:SuperClass()
        return baseClass
    end

    function new_class:ClassName()
        return className
    end

    function new_class:ToString()
        return "ObjectOfType:"..className
    end

    -- Return true if the caller is an instance of theClass
    function new_class:IsA( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:SuperClass()
            end
        end

        return b_isa
    end

    return new_class
end

return ClassUtil