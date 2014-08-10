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




-- ~~DISCLAIMER~~
-- I am not in any way associated with myanimelist.net (henceforth known
-- as MAL) or the creators/maintainers of MAL. I am simply a MAL user.
-- This extension is not an official extension created by MAL. I will not
-- be held accountible for any loss, material or otherwise, due to usage
-- of this extension. Passwords and usernames are stored in plaintext due
-- to technical limitations so please keep this in mind. MAL's API does
-- currently not support HTTPS request or SSL connections so also bear in
-- mind that your username and password will be transmitted in plaintext
-- across the internet with each request made by MALBot.

-- Use at your own discretion~~




-- ~~NEWS~~
-- Now with weird object-oriented classes and inheritance!!!!!!!!
-- New working title:
-- How to annoy people by obscuring parent classes and alienating children.
-- Written to the tune of: Highschool of the Dead - Kishida Kyōdan ft. Akeboshi Rocket.




--- Classes which implement inheritance.
-- An array of all classes which need to be defined within
-- its own function to init inheritance.
local classes = {
    "Event",
    "IO",
    "Config",
    "GUI"
}


--- Used to define classes that inherit other classes.
-- This needs to be set up this way since we can't
-- explicitly init inheritance outside of a function/method.
-- @return nil
function oo()
    if #classes > 0 then
        for i = 1, #classes do
            local init_func = "define_" .. classes[i]
            vlc.msg.dbg(string.format("%s [%s %s]: Invoking %s", os.date("%H:%M:%S"),
                MALBot.info.title, MALBot.info.version, init_func))
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

--- Trim a string.
-- Strips a string from trailing whitespace.
-- @param str String to strip.
-- @return The stripped string.
function string_trim(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--- Split a string.
-- Splits a string using a delimiter. Set limit to
-- limit the amount of parts returned.
-- @param str String to split.
-- @param delim Delimiter to use.
-- @param limit Amount of results to return.
-- @return Varying amount of parts depending on delimiter and limit.
function string_split(str, delim, limit)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if limit == nil or limit < 1 then
        limit = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local last_pos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        last_pos = pos
        if nb == limit then break end
    end
    -- Handle the last field
    if nb ~= limit then
        result[nb + 1] = string.sub(str, last_pos)
    end
    return result
end

--- Copy a table.
-- Copys a table and its values to a new table and returns it.
-- Called shallow copy because it will not deeply copy values
-- which are tables. I.e. no recursion!
-- @param t Table to copy.
-- @return A shallow copy of t.
function table_shallow_copy(t)
    local t2 = {}

    for k, v in pairs(t) do
        t2[k] = v
    end

    return t2
end




------------
-- MALBot --
------------

--- My Anime List Bot class.
-- The main class of the extension. Not defined within a define_ OO function
-- since we need instant access to information.
-- @class MALBot
-- @field info Contains extension information.
-- @field info.title Extension title.
-- @field info.version Extension version.
-- @field info.author Extension author.
-- @field info.url Extension url.
-- @field info.shortdesc Short extension description.
-- @field info.description Extension description.
-- @field info.capabilities Extension capabilities like menu, input and meta.
MALBot = {
    info = {
        title = "MALBot",
        version = "0.0.2a",
        author = "Linus Sörensen",
        url = 'http://soud.se',
        shortdesc = "Map to MAL", -- Text shown in context menu
        description = "TODO: Write description here.",
        capabilities = {}
    }
}

--- Activate MALBot.
-- Called when the extension is activated.
-- @class MALBot
-- @return nil.
function MALBot:activate()

    -- Init config
    if not Config:instance():load() then
        Config:instance():error("Failed to load config")

        if not Config:instance():loaded() then
            Config:instance():reset() -- Load defaults into memory
        end
    end
end

--- Deactivate MALBot.
-- Called when the extension is deactivated.
-- @class MALBot
-- @return nil.
function MALBot:deactivate()
    self.config:save()
end




------------------
-- MALBot Event --
------------------

--- Defines the Event class.
-- @return nil.
function define_Event()

    --- Event class.
    -- Represents an event. Fireable from shiet.
    -- @class Event
    -- @field _name Name of event.
    Event = inherits(nil)
    Event._name = nil

    --- Getter/Setter for @field _name.
    -- Returns the name of this event. If @param name is present and
    -- is a non-empty string it will set it as the new name.
    -- @class Event
    -- @param name Name to set.
    -- @return String with this events name.
    function Event:name(name)
        if type(name) == "string" and string_trim(name) ~= "" then
            self._name = name
        end

        return self._name
    end
end




---------------
-- MALBot IO --
---------------

--- Defines the IO class.
-- @return nil.
function define_IO()

    --- Input/Output class.
    -- Contains methods to handle IO and the file system.
    -- @class IO
    -- @field OS Operating System abbreviation constant.
    -- @field DIRECTORY_SEPARATOR Operating System directory separator.
    -- @field _format Print format string. Default is "%s %s%s".
    -- @field _out Default output function.
    -- @field _prefix Prefix to prepend to all print output.
    IO = inherits(nil)
    -- Match conf dir against drive letter pattern to see if windows or posix
    if string.match(vlc.config.datadir(), "^(%w:\\).+$") then
        IO.OS = "nt"
        IO.DIRECTORY_SEPARATOR = "\\"
    else
        IO.OS = "posix"
        IO.DIRECTORY_SEPARATOR = "/"
    end
    IO._format = "%s %s%s"
    IO._out = vlc.msg.dbg
    IO._prefix = nil


    --- Create directory.
    -- Attempt to create a directory on supplied path.
    -- @class IO
    -- @param path Relative or absolute path where directory will be created.
    -- @return Status (-1 on fail and 0 on success???) of mkdir command
    function IO:create_dir(path)
        if type(path) ~= "string" then
            return -1
        end

        local status = os.execute('mkdir "' .. path ..'"')
        self:debug("Executed OS cmd mkdir with status: " .. status)

        return status
    end

    --- Create a file.
    -- Attempt to create a file on supplied path.
    -- @class IO
    -- @param path Relative or absolute path where file will be created.
    -- @return True if file was created or false on error.
    -- @return Error number on error.
    function IO:create_file(path)
        if type(path) ~= "string" then
            return false
        end

        local file, _, errno = io.open(path, "w")

        if file ~= nil then -- Yatta! We created the file!
            file:close()

            return true
        else -- Kuso! No file for you...
            return false, errno
        end
    end

    --- Print to debug.
    -- Prints object to vlc debug output. Will attempt to cast object
    -- to string if other type.
    -- @class IO
    -- @param obj Object to debug.
    -- @return Object as string on success or false on fail.
    function IO:debug(obj)
        if type(obj) ~= "string" then
            obj = tostring(obj)

            if not obj then
                return false
            end
        end

        if self._prefix then
            obj = string.format(self._format, os.date("%H:%M:%S"), self._prefix, obj)
        else
            obj = string.format(self._format, os.date("%H:%M:%S"), "", obj)
        end

        vlc.msg.dbg(obj)

        return obj
    end

    --- Print error.
    -- Prints error to vlc error output. Will attempt to cast error
    -- to string if other type.
    -- @class IO
    -- @param obj Error to print.
    -- @return Error as string on success or false on fail.
    function IO:error(obj)
        if type(obj) ~= "string" then
            obj = tostring(obj)

            if not obj then
                return false
            end
        end

        if self._prefix then
            obj = string.format(self._format, os.date("%H:%M:%S"), self._prefix, obj)
        else
            obj = string.format(self._format, os.date("%H:%M:%S"), "", obj)
        end

        vlc.msg.err(obj)

        return obj
    end

    --- Check if given directory exists.
    -- Will check if directory found on path actually exists.
    -- @class IO
    -- @param path Relative or absolute path to test.
    -- @return True if directory exists or false if it doesn't or on error.
    -- @return Error number on error.
    function IO:dir_exists(path)
        if type(path) ~= "string" then
            return false
        end

        -- Remove anything anything after last slash (slash included)
        path = string.gsub(path, "^(.-)[\\/]?$", "%1")
        local file, _, errno = io.open(path, "rb") -- Why do we need errno from this?

        if file then
            _, _, errno = file:read("*a")
            file:close()

            if errno == 21 then -- EISDIR: "Is a directory"
                return true
            end
        elseif errno == 13 then -- EACCES: "Permission denied"
            return true
        end

        return false, errno
    end

    --- Check if given file exists.
    -- Will check if file found on path actually exists.
    -- @class IO
    -- @param path Relative or absolute path to test.
    -- @return True if file exists or false if it doesn't or on error.
    -- @return Error number on error.
    function IO:file_exists(path)
        if type(path) ~= "string" then
            return false
        end

        -- Test by attempting to open file in read mode
        local file, _, errno = io.open(path, "r")

        if file ~= nil then
            file:close()

            return true
        else -- We failed, return something useful
            return false, errno
        end
    end

    --- Getter/Setter for @field _prefix.
    -- Returns the current prefix. If @param prefix is present and
    -- is a non-empty string it will set it as the new prefix.
    -- @class IO
    -- @param name Prefix to set.
    -- @return String with the current prefix.
    function IO:prefix(prefix)
        if type(prefix) == "string" and string_trim(prefix) ~= "" then
            self._prefix = prefix
        end

        return self._prefix
    end

    --- Print argument.
    -- Prints argument to default output. Will attempt to cast argument
    -- to string if other type.
    -- @class IO
    -- @param obj Object to print.
    -- @return Argument as string on success or false on fail.
    function IO:print(obj)
        if type(obj) ~= "string" then
            obj = tostring(obj)

            if not obj then
                return false
            end
        end

        if self._prefix then
            obj = string.format(self._format, os.date("%H:%M:%S"), self._prefix, obj)
        else
            obj = string.format(self._format, os.date("%H:%M:%S"), "", obj)
        end

        (self._out or vlc.msg.dbg or print)(obj)

        return obj
    end

    --- Recursive print (dump).
    -- Will build a formatted string with all data related
    -- to the input argument. Works like PHP's print_r.
    -- @class IO
    -- @param obj Object to print.
    -- @return Argument as string on success or false on fail.
    function IO:print_r(obj)
            -- Cache of tables already printed, to avoid infinite recursive loops
        local tablecache = {}
        local buffer = ""
        local padder = "    "

        local function _dumpvar(d, depth)
            local t = type(d)
            local str = tostring(d)

            if (t == "table") then
                if (tablecache[str]) then
                    -- Table already dumped before, so we dont
                    -- dump it again, just mention it
                    buffer = buffer .. "<" .. str .. ">\n"
                else
                    tablecache[str] = (tablecache[str] or 0) + 1
                    buffer = buffer .. "(" .. str .. ") {\n"

                    for k, v in pairs(d) do
                        buffer = buffer .. string.rep(padder, depth + 1) .. "[" .. k .. "] => "
                        _dumpvar(v, depth + 1)
                    end

                    buffer = buffer .. string.rep(padder, depth) .. "}\n"
                end
            elseif (t == "number") then
                buffer = buffer .. "(" .. t .. ") " .. str .. "\n"
            else
                buffer = buffer .. "(" .. t .. ") \"" .. str .. "\"\n"
            end
        end
        _dumpvar(obj, 0)

        return self:print(buffer)
    end

    --- Print warning.
    -- Prints warning to vlc warning output. Will attempt to cast warning
    -- to string if other type.
    -- @class IO
    -- @param obj Warning to print.
    -- @return Warning as string on success or false on fail.
    function IO:warning(obj)
        if type(obj) ~= "string" then
            obj = tostring(obj)

            if not obj then
                return false
            end
        end

        if self._prefix then
            obj = string.format(self._format, os.date("%H:%M:%S"), self._prefix, obj)
        else
            obj = string.format(self._format, os.date("%H:%M:%S"), "", obj)
        end

        vlc.msg.warn(obj)

        return obj
    end
end




-------------------
-- MALBot Config --
-------------------

--- Defines the Config class.
-- @return nil.
function define_Config()

    --- Config class.
    -- Configuration handling class. Inherits IO.
    -- @class Config
    -- @field NAME Config file name.
    -- @field PATH Config file path.
    -- @field _defaults Contains default config values.
    -- @field _defaults.username Default username value.
    -- @field _defaults.password Default password value.
    -- @field _defaults.save_credentials Default save user credentials.
    -- @field _loaded Config loaded status.
    -- @field _values Configuration key value store.
    Config = inherits(IO)
    Config.NAME = "MALBot.properties"
    Config.PATH = vlc.config.configdir() .. Config.DIRECTORY_SEPARATOR .. "MALBot"
    Config._defaults = {
        username = "",
        password = "",
        save_credentials = false
    }
    Config._loaded = false
    Config._values = setmetatable({}, {__mode = "kv"}) -- Weak table

    --- Get Config singleton instance.
    -- Gets the singleton instance of the @class Config class.
    -- @class Config
    -- @return Singleton instance of @class Config.
    function Config:instance()
        if not CONFIG_INSTANCE then
            CONFIG_INSTANCE = Config:new()
            CONFIG_INSTANCE:prefix("[MALBot Config]: ")
        end

        return CONFIG_INSTANCE
    end

    --- Get config value by key.
    -- Get the current value of key if configuration is loaded.
    -- @class Config
    -- @param key Configuration value key.
    -- @return Valued matching key if found or nil if config not loaded.
    function Config:get(key)
        if self._loaded then
            return self._values[key]
        end
    end

    --- Load the config.
    -- Load the configuration file into memory. Will create directory
    -- if absent. Reads the file line by line, stripping the comments.
    -- Will attempt to cast values where applicable.
    -- @class Config
    -- @return True on success or already loaded or false on error.
    -- @return Error number on error.
    function Config:load()
        if self._loaded then
            return true
        end

        local path = self.PATH .. self.DIRECTORY_SEPARATOR .. self.NAME

        if self:file_exists(path) then
            self:debug("Found config: " .. path)

            local file, _, errno = io.open(path, "r")

            if not file then
                self._loaded = false
                self:error("Failed to open config: " .. errno)
                return false
            end

            for line in file:lines() do
                line = string.match(line, "^[^#]+") -- Ignore comments

                if line then
                    local parts = string_split(line, "=", 2)
                    local k, v = parts[1], parts[2]

                    if type(k) == "string" and string_trim(k) ~= "" then
                        k = string_trim(k)

                        -- "Cast" strings to more appropriate values
                        if v == "true" then
                            v = true
                        elseif v == "false" then
                            v = false
                        elseif tonumber(v) ~= nil then
                            v = tonumber(v)
                        end

                        self._values[k] = v
                    end
                end
            end

            self._loaded = true

            return true
        else
            self:debug("Config not found")

            return self:reset(true)
        end
    end

    --- Get config loaded status.
    -- Returns the configs current loaded status.
    -- @class Config
    -- @return True if config is loaded or false otherwise.
    function Config:loaded()
        return self._loaded
    end

    --- Reset the config.
    -- Reset the current config values in memory.
    -- @class Config
    -- @param save Save to file instantly.
    -- @return True on success or false on error.
    -- @return Error number on error.
    function Config:reset(save)
        -- Overwrite current values with defaults
        self._values = table_shallow_copy(self._defaults)
        self._loaded = true

        self:debug("Config was reset to defaults")

        if save then
            return self:save()
        end

        return true
    end

    --- Save the config.
    -- Save the current config values in memory to file.
    -- @class Config
    -- @return True on success or false on error.
    -- @return Error number on error.
    function Config:save()
        -- TODO: Don't rewrite entire config everytime!

        if not self._loaded then
            return false
        end

        -- Check if folder exists
        if not self:dir_exists(self.PATH) then
            self:debug("Creating directory: " .. self.PATH)
            local status = self:create_dir(self.PATH)

            if status ~= 0 then -- Might be -1 one on fail?
                self:error("Failed to create config dir: " .. status)
                return false, status
            end
        end

        local path = self.PATH .. self.DIRECTORY_SEPARATOR .. self.NAME
        local file, _, errno = io.open(path, "w+") -- Somehow change to w later

        if not file then
            self:error("Failed to open config: " .. errno)
            return false, errno
        end

        local line = "# Last modified: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"

        file:write(line)

        local save_credentials = self:get("save_credentials")

        for k, v in pairs(self.values) do
            if (string_trim(k) == "username" or string_trim(k) == "password") and not save_credentials then
                -- Do nothing
            else
                if v ~= nil and string_trim(k) ~= "" then
                    line = string_trim(k) .. "=" .. tostring(v) .. "\n"

                    file:write(line)
                end
            end
        end

        file:flush()
        file:close()

        self:debug("Config saved: " .. path)

        return true
    end

    --- Set a config value by key.
    -- Sets a new or existing config key to input value.
    -- @class Config
    -- @param key Key to add or alter.
    -- @param value Value to set.
    -- @return Value on success or nil if config not loaded.
    function Config:set(key, value)
        if self._loaded then
            self._values[key] = value
            return value
        end
    end

    --- Global Config singleton instance.
    -- Holds the Config singleton instance, available through
    -- method Config:instance().
    CONFIG_INSTANCE = Config:new()
    CONFIG_INSTANCE:prefix("[MALBot Config]: ")
end




----------------
-- MALBot GUI --
----------------

--- Defines the GUI class.
-- @return nil.
function define_GUI()

    --- GUI class.
    -- Contains methods to handle the VLC qt4 interface.
    -- @class GUI
    -- @field _dialog qt4 dialog userdata object.
    -- @field _input Dialog input table.
    -- @field _widgets Table containing active qt4 widgets.
    GUI = inherits(nil)
    GUI._dialog = nil
    GUI._input = {}
    GUI._widgets = {}

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

            self._dialog:delete()
            self._dialog = nil

            collectgarbage()
        end
    end

    --- Show the login dialog.
    -- Setup and show the login dialog.
    -- @class GUI
    -- @return nil.
    function GUI:login()
        self:close()

        local function auth_button_on_click()
            local username = self._widgets["username"]:get_text()
            local password = self._widgets["password"]:get_text()
            local remember = self._widgets["remember"]:get_checked()

            if string_trim(username) ~= "" and password ~= "" then
                self._input["username"] = string_trim(username)
                self._input["password"] = password
                self._input["remember"] = remember

                self:close()
            end
        end

        self._dialog = vlc.dialog("Login")

        self._dialog:add_label("MALBot requires your MAL login credentials to continue.", 1, 1, 6, 1)

        self._dialog:add_label("Username:", 1, 2, 2, 1)
        self._widgets["username"] = self._dialog:add_text_input("", 3, 2, 4, 1)

        self._dialog:add_label("Password:", 1, 3, 2, 1)
        self._widgets["password"] = self._dialog:add_password("", 3, 3, 4, 1)

        self._widgets["remember"] = self._dialog:add_check_box("Remember me", false, 3, 4, 4, 1)

        self._dialog:add_button("Authorize", auth_button_on_click, 3, 5, 2, 1)
        self._dialog:add_button("Cancel", vlc.deactivate, 5, 5, 2, 1)
    end
end




-----------------------------
-- VLC Extension Functions --
-----------------------------

--- Get extension description.
-- Fetches extension information from the MALBot class.
-- @return A table with all the extension information.
function descriptor()
    return MALBot.info
end

--- Activate the extension.
-- Called by VLC when extension is activated.
-- @return nil.
function activate()
    oo() -- Define classes
    MALBot:activate()
end

--- Deactivate the extension.
-- Called when extension is deactivated by the user, extension or VLC.
-- @return nil.
function deactivate()
    MALBot:deactivate()
end

--- Close extension dialog.
-- Called on dialog close by VLC or internally by the extension.
-- @return nil.
function close()
    -- Deactivate for now...
    vlc.deactivate()
end
