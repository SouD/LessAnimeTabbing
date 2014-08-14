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


--- Defines the Net, Request and Response classes.
-- @return nil.
function define_Net()

    --- Net class.
    -- Contains methods for using the internet. Sort of.
    -- @class Net
    -- @field _connection The current connection.
    -- @field _connected Connection status boolean.
    Net = inherits(IO)
    Net._connection = nil
    Net._connected = false

    --- Request class.
    -- Represents a HTTP request.
    -- @class Request
    -- @field _data Contains request data.
    -- @field _executed Request status boolean.
    -- @field _host Request host.
    -- @field _method Request method.
    -- @field _path Request path.
    Request = inherits(nil)
    Request.GET = "GET"
    Request.POST = "POST"
    Request._data = nil
    Request._executed = false
    Request._headers = {}
    Request._host = nil
    Request._method = nil
    Request._path = nil

    Request._new = Request.new
    --- Request constructor.
    -- Creates a new instance of @class Request.
    -- @class Request
    -- @param path Request path.
    -- @param host Request host.
    -- @param data Request data.
    -- @return Instance of @class Request.
    function Request:new(method, path, host, data)
        return self._new(self, {
            _method = method,
            _path = path,
            _host = host,
            _data = data
        })
    end

    --- Add basic auth to request.
    -- Adds the basic authentication header to the request. Base64
    -- encodes the given username and password to the correct format.
    -- @class Request
    -- @param username Username to send.
    -- @param password Password to send.
    -- @return True on success or false on error.
    function Request:add_basic_auth(username, password)
        if self._executed then
            return false
        end

        if type(username) ~= "string" or username == "" then
            return false
        end

        if type(password) ~= "string" or password == "" then
            return false
        end

        local header = "Authorization"
        local creadentials = username .. ":" .. password
        local value = "Basic " .. enc(creadentials)

        return self:add_header(header, value)
    end

    --- Add header to request.
    -- Adds a header with the associated value to the request.
    -- @class Request
    -- @param header Header field to add.
    -- @param value Value of header field.
    -- @return True on success or false on error.
    function Request:add_header(header, value)
        if self._executed then
            return false
        end

        if type(header) ~= "string" or header == "" then
            return false
        end

        if value == nil then
            return false
        end

        if type(self._headers) ~= "table" then
            self._headers = {}
        end

        self._headers[header] = value

        return true
    end
end
