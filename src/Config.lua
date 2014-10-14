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

--- Defines the Config class.
-- @return nil.
function define_Config()

    --- Config class.
    -- Configuration handling class. Inherits IO.
    -- @class Config
    -- @field EXTENSION Config file extension constant.
    -- @field _locale Contains an instance of @class Locale.
    -- @field _name Config name.
    -- @field _parser A JSON parser.
    -- @field _path Config file path.
    -- @field _loaded Config loaded status.
    -- @field _values Configuration key value store.
    Config = inherits(IO)
    Config.EXTENSION = ".json"
    Config._altered = false
    Config._locale = nil
    Config._name = nil
    Config._parser = nil
    Config._path = nil
    Config._loaded = false
    Config._values = nil

    Config._new = Config.new
    --- Config constructor.
    -- Creates a new instance of @class Config.
    -- @class Config
    -- @param config Name of config to load.
    -- @param locale An instance of @class Locale.
    -- @param parser A JSON parser.
    -- @return Instance of @class Config.
    function Config:new(config, locale, parser)
        local c = self._new(self, {
            _locale = locale,
            _name = config,
            _parser = parser,
            _prefix = "[LessAnimeTabbing Config]: ",
            _values = {}
        })

        c:load(config, true)

        return c
    end

    --- Get config value by key.
    -- Get the current value of key if configuration is loaded.
    -- Can take a dot separated "path" as key, e.g. PARENT_PROP.CHILD_PROP.
    -- @class Config
    -- @param key Configuration value key.
    -- @return Valued matching key if found or nil.
    function Config:get(key)
        if self._loaded then
            local nodes = string_split(key, "%.")
            local value = nil

            if #nodes > 1 then
                local branch = self._values

                repeat
                    local node = table.remove(nodes, 1)

                    if branch[node] ~= nil then
                        if #nodes > 0 then
                            if type(branch[node]) == "table" then
                                branch = branch[node]
                            else
                                break
                            end
                        else
                            value = branch[node]
                        end
                    end
                until #nodes < 1
            elseif #nodes == 1 then
                value = self._values[key]
            end

            return value
        end
    end

    --- Load the config.
    -- Parses the first argument to determine the path where to find
    -- the config file. If the second argument is set then it will create
    -- the file and any missing directories if they don't already exist.
    -- If they file is created or found it reads the file line by line,
    -- stripping the comments. Will attempt to cast values where applicable.
    -- The format of the first argument should be a dot separated name,
    -- e.g: NAMESPACE.FILE will attempt to load the
    -- file vlc_config_dir/NAMESPACE/FILE.json.
    -- @class Config
    -- @param config Config to load.
    -- @param create Create config if missing.
    -- @return True on success or already loaded or false on error.
    function Config:load(config, create)
        if self._loaded then
            return true
        end

        if type(config) ~= "string" or string.len(config) < 1 then
            self:error(self._locale:get("CONF_LOAD_INVALID_ARG"))
            return false
        end

        local tree = string_split(config, "%.")
        local path = vlc.config.configdir() .. self.DIRECTORY_SEPARATOR

        if #tree > 1 then
            self._path = path .. table.concat(tree, self.DIRECTORY_SEPARATOR) .. self.EXTENSION
        elseif #tree == 1 then
            self._path = path .. tree[1] .. self.EXTENSION
        else
            self:error(string.format(self._locale:get("CONF_PARSE_FAIL"), config))
            return false
        end

        if not self:file_exists(self._path) then
            if create then
                if self:create_path(self._path) then
                    self:debug(string.format(self._locale:get("CONF_CREATE_SUCCESS"), self._path))
                else
                    self:error(string.format(self._locale:get("CONF_CREATE_FAIL"), self._path))
                    return false
                end
            else
                self:error(string.format(self._locale:get("CONF_NOT_FOUND"), self._path))
                return false
            end
        end

        local file, _, errno = io.open(self._path, "r")

        if not file then
            self:error(string.format(self._locale:get("CONF_OPEN_FAIL"), errno))
            return false
        end

        local json = file:read("*all")
        file:close()

        self._values = self._parser:decode(json)

        self:debug(string.format(self._locale:get("CONF_LOAD_SUCCESS"), self._name, self._path))

        self._loaded = true

        return true
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
    -- @return True on success or false on error.
    -- @return Error number on error.
    function Config:reset()
        if self._loaded then
            if type(self._name) == "string" then
                self._values = {}
                self._altered = false
                self._loaded = false

                self:debug(string.format(self._locale:get("CONF_RESET"), self._name))

                return self:load(self._name)
            else
                return false
            end
        else
            return true
        end
    end

    --- Save the config.
    -- Save the current config values in memory to file.
    -- @class Config
    -- @return True on success or false on error.
    -- @return Error number on error.
    function Config:save()
        if not self._loaded or not self._altered then
            return false
        end

        if not self:file_exists(self._path) then
            if not self:create_path(self._path) then
                self:error(string.format(self._locale:get("CONF_CREATE_FAIL"), self._path))
                return false
            end
        end

        local file, _, errno = io.open(self._path, "w+") -- Change to w later

        if not file then
            self:error(string.format(self._locale:get("CONF_OPEN_FAIL"), errno))
            return false, errno
        end

        local json = self._parser:encode_pretty(self._values)
        file:write(json)
        file:flush()
        file:close()

        self:debug(string.format(self._locale:get("CONF_SAVED"), self._name, self._path))

        return true
    end

    --- Set a config value by key.
    -- Sets a new or existing config key to input value.
    -- @class Config
    -- @param key Key to add or alter.
    -- @param value Value to set.
    -- @return nil.
    function Config:set(key, value)
        if type(key) == "string" then
            self._altered = true
            -- TODO: Handle setting of properties.
        elseif not key and type(value) == "table" then
            self._altered = true
            self._values = value
        end
    end
end
