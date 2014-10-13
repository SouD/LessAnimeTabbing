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

-- col row width height

--- Defines the GUI class.
-- @return nil.
function define_GUI()

    --- GUI class.
    -- Contains methods to handle the VLC qt4 interface.
    -- @class GUI
    -- @field _dialog qt4 dialog userdata object.
    -- @field _input Dialog input table.
    -- @field _locale Contains an instance of @class Locale.
    -- @field _widgets Table containing active qt4 widgets.
    -- @field _publisher Optional instance of @class Publisher.
    GUI = inherits(nil)
    GUI._dialog = nil
    GUI._input = {}
    GUI._locale = nil
    GUI._widgets = {}
    GUI._publisher = nil

    GUI._new = GUI.new
    --- GUI constructor.
    -- Creates a new instance of @class GUI.
    -- @class GUI
    -- @param publisher Optional instance of @class Publisher.
    -- @param locale An instance of @class Locale.
    -- @return Instance of @class GUI.
    function GUI:new(publisher, locale)
        return self._new(self, {
            _locale = locale,
            _publisher = publisher
        })
    end

    --- Publish a message.
    -- Publishes a message using the injected publisher if there is one.
    -- This method is for internal use only.
    -- @class GUI
    -- @param msg Message to publish.
    -- @param ... Message args to send.
    -- @return nil.
    function GUI:_publish(msg, ...)
        if type(self._publisher) == "table" and type(self._publisher.publish) == "function" then
            self._publisher:publish(msg, ...)
        end
    end

    --- Clears input table.
    -- Clears all user input data from @field _input.
    -- @class GUI
    -- @return nil.
    function GUI:clear_input()
        for k, _ in pairs(self._input) do
            self._input[k] = nil
        end
    end

    --- Close the dialog.
    -- Closes and deletes the dialog if present.
    -- @class GUI
    -- @return nil.
    function GUI:close()
        if self._dialog ~= nil then
            self._dialog:hide()

            for k, _ in pairs(self._widgets) do
                self._widgets[k] = nil
            end

            -- self._dialog:delete()
            self._dialog = nil

            collectgarbage()
        end
    end

    --- Get user input data.
    -- Attempt to retreive the input data matching supplied key.
    -- @class GUI
    -- @param key Key to look for.
    -- @return Value matching key or nil.
    function GUI:get(key)
        return self._input[key]
    end

    --- Get publisher.
    -- Getter for @field _publisher.
    -- @class GUI
    -- @return Instance of @class Publisher or nil if not injected.
    function GUI:publisher()
        return self._publisher
    end
end
