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
    Config._values = {}

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

        for k, v in pairs(self._values) do
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
