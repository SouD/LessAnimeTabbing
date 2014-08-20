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
    -- if string.match(vlc.config.datadir(), "^(%w:\\).+$") then
    if vlc.win then
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

    --- Create path.
    -- Attemts to create everything on the give path. All directories
    -- missing will be created. If the path ends with a file the file
    -- will also be created.
    -- @class IO
    -- @param path Path to create.
    -- @return True if path was created or false on error.
    -- @return Error number on error.
    function IO:create_path(path)
        if type(path) ~= "string" then
            return false
        end

        if self:file_exists(path) then
            return true
        end

        local path, file, extension = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")

        if not self:dir_exists(path) then
            local status

            if vlc.win then
                status = os.execute('mkdir "' .. path ..'"')
            else
                status = os.execute("mkdir -p " .. path)
            end

            self:debug("Executed OS cmd mkdir with status: " .. status)

            if status ~= 0 then
                return false, status
            end
        end

        if file then
            return self:create_file(path .. file)
        else
            return true
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
