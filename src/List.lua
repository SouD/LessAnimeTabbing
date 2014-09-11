-- A My Anime List Bot VLC Extension. Because keeping track of anime is hard!
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


--- Defines the List class.
-- @return nil.
function define_List()

    --- List class.
    -- Represents an generic list structure.
    -- @class List
    -- @field _values List values.
    List = inherits(nil)
    List._values = {}

    --- Add element to list.
    -- Adds the @param element to the end of the list.
    -- @class List
    -- @param element The element to add.
    -- @return The new list size or nil if no argument.
    function List:add(element)
        if element ~= nil then
            table.insert(self._values, element)

            return #self._values
        end
    end

    --- Clears the list.
    -- Resets the list. All elements are removed.
    -- @class List
    -- @return nil.
    function List:clear()
        self._values = {}
    end

    --- Get an element in the list.
    -- Get the element at the given index.
    -- @class List
    -- @param index The index to get, must be a greater than 0 number.
    -- @return The element at the given index or nil on fail.
    function List:get(index)
        if #self._values > 0 and type(index) == "number" then
            return self._values[index]
        end
    end

    --- Pop an element from the list.
    -- Removes the last element from the list and returns it.
    -- @class List
    -- @return The popped element or nil if list is empty.
    function List:pop()
        if #self._values > 0 then
            local tail = self._values[#self._values]
            table.remove(self._values)

            return tail
        end
    end

    --- Remove an element.
    -- Removes the element at the given index.
    -- @class List
    -- @param index The index to remove, must a number within the size of the list.
    -- @return The removed element or nil if list is empty or fail.
    function List:remove(index)
        if #self._values > 0 and type(index) == "number" and index > 0 and index <= #self._values then
            local obj = self._values[index]
            table.remove(self._values, index)

            return obj
        end
    end

    --- Assign an element to an index.
    -- Set the given index to the given element.
    -- @class List
    -- @param index The index to set, must a number within the size of the list.
    -- @param element The element to set at the index.
    -- @return The previous element at index or nil if list is empty or fail.
    function List:set(index, element)
        if #self._values > 0 and type(index) == "number" and index > 0 and index <= #self._values then
            local obj = self._values[index]
            self._values[index] = element

            return obj
        end
    end

    --- Get the size of the list.
    -- Returns the size of the internal table.
    -- @class List
    -- @return A number representing the list size.
    function List:size()
        return #self._values
    end
end
