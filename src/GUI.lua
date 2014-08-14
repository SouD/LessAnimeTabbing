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


--- Defines the GUI class.
-- @return nil.
function define_GUI()

    --- Globally available messages
    MSG_GUI_DIALOG_CLOSE_AFTER = "MSG_GUI_DIALOG_CLOSE_AFTER"
    MSG_GUI_DIALOG_CLOSE_BEFORE = "MSG_GUI_DIALOG_CLOSE_BEFORE"
    MSG_GUI_DIALOG_SHOW = "MSG_GUI_DIALOG_SHOW"
    MSG_GUI_INPUT_AUTH = "MSG_GUI_INPUT_AUTH"

    --- GUI class.
    -- Contains methods to handle the VLC qt4 interface.
    -- @class GUI
    -- @field _dialog qt4 dialog userdata object.
    -- @field _input Dialog input table.
    -- @field _widgets Table containing active qt4 widgets.
    -- @field _publisher Optional instance of @class Publisher.
    GUI = inherits(nil)
    GUI._dialog = nil
    GUI._input = {}
    GUI._widgets = {}
    GUI._publisher = nil

    GUI._new = GUI.new
    --- GUI constructor.
    -- Creates a new instance of @class GUI.
    -- @class GUI
    -- @param publisher Optional instance of @class Publisher.
    -- @return Instance of @class GUI.
    function GUI:new(publisher)
        return self._new(self, {
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
            self:_publish(MSG_GUI_DIALOG_CLOSE_BEFORE)

            self._dialog:hide()

            for k, _ in pairs(self._widgets) do
                self._widgets[k] = nil
            end

            -- self._dialog:delete()
            self._dialog = nil

            collectgarbage()

            self:_publish(MSG_GUI_DIALOG_CLOSE_AFTER)
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

    --- Show the login dialog.
    -- Setup and show the login dialog.
    -- @class GUI
    -- @return nil.
    function GUI:login()
        self:close()

        local title = "Login"
        local function auth_button_on_click()
            local username = self._widgets["username"]:get_text()
            local password = self._widgets["password"]:get_text()
            local save_credentials = self._widgets["save_credentials"]:get_checked()

            if username ~= "" and password ~= "" then
                self._input["username"] = username
                self._input["password"] = password
                self._input["save_credentials"] = save_credentials

                self:close()

                -- Tell subs that user input auth data
                self:_publish(MSG_GUI_INPUT_AUTH)
            end
        end

        self._dialog = vlc.dialog(title)

        self._dialog:add_label("MALBot requires your MAL login credentials to continue.", 1, 1, 6, 1)

        self._dialog:add_label("Username:", 1, 2, 2, 1)
        self._widgets["username"] = self._dialog:add_text_input("", 3, 2, 4, 1)

        self._dialog:add_label("Password:", 1, 3, 2, 1)
        self._widgets["password"] = self._dialog:add_password("", 3, 3, 4, 1)

        self._widgets["save_credentials"] = self._dialog:add_check_box("Remember me", false, 3, 4, 4, 1)

        self._dialog:add_button("Authorize", auth_button_on_click, 3, 5, 2, 1)
        self._dialog:add_button("Cancel", vlc.deactivate, 5, 5, 2, 1)

        -- Tell our sweet subs that something is showing! =(^_^)=
        self:_publish(MSG_GUI_DIALOG_SHOW, title)
    end

    --- Get publisher.
    -- Getter for @field _publisher.
    -- @class GUI
    -- @return Instance of @class Publisher or nil if not injected.
    function GUI:publisher()
        return self._publisher
    end
end
