-- LessAnimeTabbing. Keep track of your anime without tabbing!
-- Copyright (C) 2014  Linus Sörensen

-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


--- Used to define classes that inherit other classes.
-- This needs to be set up this way since we can't
-- explicitly init inheritance outside of a function/method.
-- @return nil
function oo()
    if classes and #classes > 0 then
        for i = 1, #classes do
            local init_func = "define_" .. classes[i]
            vlc.msg.dbg(string.format("%s Loaded class %s", os.date("%H:%M:%S"), classes[i]))
            _G[init_func]()
        end
    end
end

--- Defines inheritance between classes.
-- Used to allow one class to inherit another class. Also sets
-- up basic OO methods like new, class, super and instanceof.
-- @param base Parent class to inherit. Optional.
-- @return Basic class structure.
function inherits(base)
    local class = {}
    local class_mt = {__index = class}

    --- Class constructor.
    -- Create a new instance of class.
    -- @param obj Class arguments.
    -- @return New instance of class.
    function class:new(obj)
        local instance = obj or {}
        setmetatable(instance, class_mt)
        return instance
    end

    if base ~= nil then
        setmetatable(class, {__index = base})
    end

    --- Get class of class.
    -- Gets the class of the class, like Java's Object.class.
    -- @return Class of class.
    function class:class()
        return class
    end

    --- Get superclass of class.
    -- Gets the parent or "superclass" of the class.
    -- @return Superclass of class.
    function class:super()
        return base
    end

    --- Check class equality.
    -- Checks if class is a instance of some other class.
    -- @param other_class Class to test against.
    -- @return Comparison outcome.
    function class:instanceof(other_class)
        local result = false
        local current_class = class

        while current_class ~= nil and result == false do
            if current_class == other_class then
                result = true
            else
                current_class = current_class:super()
            end
        end

        return result
    end

    return class
end
