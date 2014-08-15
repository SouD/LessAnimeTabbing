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
    -- @field _connection The current connection (a number mapped to a file descriptor).
    -- @field _connected Connection status boolean.
    Net = inherits(IO)
    Net._connection = nil
    Net._connected = false

    --- Open a new tcp connection.
    -- Attempts to open a new tcp connection to the given host
    -- on the given port.
    -- @class Net
    -- @param host Host to connect to.
    -- @param port Port to connect on.
    -- @return True if connection was successful or false on error.
    function Net:connect(host, port)
        assert(vlc.net, "Namespace vlc.net not available!")

        if self._connected then
            self:disconnect()
        end

        if type(host) ~= "string" or host == "" then
            return false
        end

        if type(port) ~= "number" or port < 1 then
            return false
        end

        -- This will be -1 on error, maybe...
        self._connection = vlc.net.tcp_connect(host, port)

        if self._connection == -1 then
            self:error("Failed to connect to " .. host .. ":" .. port)
            self._connected = false
        else
            self._connected = true
        end

        return self._connected
    end

    --- Disconnect current connection.
    -- Attempts to disconnect from the current tcp connection.
    -- @class Net
    -- @return True if disconnected or false on error.
    function Net:disconnect()
        assert(vlc.net, "Namespace vlc.net not available!")

        if self._connection == -1 then
            return false
        end

        if not self._connected then
            return true
        end

        -- Disregard output from this
        vlc.net.close(self._connection)

        return true
    end

    --- Receive data on current connection.
    -- Attempts to receive data on the current connection
    -- if one exists.
    -- @class Net
    -- @return Response from connection or false on error or no response.
    function Net:recv()
        assert(vlc.net, "Namespace vlc.net not available!")

        if not self._connected then
            return false
        end

        -- local size = 1024 -- Should work as max size
        local response = vlc.net.recv(self._connection)

        if response == nil then
            self:warning("No data received")
            return false
        else -- Non nil is success in this case!
            self:debug(string.format("Received %d chars", string.len(response)))
            return response
        end
    end

    --- Send data on connection.
    -- Attempts to send the given data on the current connection
    -- if one exists.
    -- @class Net
    -- @param data String to send.
    -- @return True on success or false on error.
    -- @return Amount of chars sent if successful.
    function Net:send(data)
        assert(vlc.net, "Namespace vlc.net not available!")

        if not self._connected then
            return false
        end

        if type(data) ~= "string" or data == "" then
            return false
        end

        -- local len = string.len(data)
        local result = vlc.net.send(self._connection, data)

        if result == -1 then
            self:error("Failed to send data")
            return false
        else
            self:debug(string.format("Sent %d chars", result))
            return true, result
        end
    end

    --- Request class.
    -- Represents a HTTP request.
    -- @class Request
    -- @field _data Contains request data.
    -- @field _executed Request status boolean.
    -- @field _host Request host.
    -- @field _method Request method.
    -- @field _path Request path.
    -- @field _user_agent Request user agent.
    Request = inherits(Net)
    Request.GET = "GET"
    Request.POST = "POST"
    Request._data = nil
    Request._executed = false
    Request._headers = {}
    Request._host = nil
    Request._method = nil
    Request._path = nil
    Request._user_agent = nil

    Request._new = Request.new
    --- Request constructor.
    -- Creates a new instance of @class Request.
    -- @class Request
    -- @param path Request path.
    -- @param host Request host.
    -- @param data Request data.
    -- @return Instance of @class Request.
    function Request:new(method, path, host, data, user_agent)
        return self._new(self, {
            _prefix = "[MALBot Request]: ",
            _method = method,
            _path = path,
            _host = host,
            _data = data,
            _user_agent = user_agent
        })
    end

    --- Compiles all headers.
    -- Takes all header fields and their values from
    -- the @field _headers and turns them into one string.
    -- @class Request
    -- @return Formatted HTTP request header string or false on error.
    function Request:_compile_headers()
        if self._executed then
            return false
        end

        local headers = {
            string.format("%s %s HTTP/1.1", self._method, self._path),
            "Host: " .. self._host,
            "User-Agent: " .. (self._user_agent or "MALBot"),
        }

        for field, value in pairs(self._headers) do
            table.insert(headers, string.format("%s: %s", field, value))
        end

        table.insert(headers, "")
        table.insert(headers, "")

        return table.concat(headers, "\r\n")
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

        return self:add_header(header, value), header, value
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

    --- Execute request.
    -- Executes this request and returns the response.
    -- @class Request
    -- @response Instance of @class Response.
    function Request:execute()
        if self._executed then
            return false
        end

        if self._method ~= self.GET or self._method ~= self.POST then
            self._method = self.GET
        end

        if type(self._path) ~= "string" or self._path == "" then
            return false
        end

        if type(self._host) ~= "string" or self._host == "" then
            return false
        end

        local header = self:_compile_headers()

        -- TODO: Put header and data together.
        -- TODO: Send Complete request.
        -- TODO: Handle potential response.

        self._executed = true

        return {} -- TODO: Change to instance of @class Response later.
    end

    --- Get executed status.
    -- Getter for @field _executed.
    -- @class Request
    -- @return Executed status boolean.
    function Request:executed()
        return self._executed
    end
end
