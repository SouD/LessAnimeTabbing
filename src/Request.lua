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


--- What the HTTPRequest might look like!
-- GET /api/account/verify_credentials.xml HTTP/1.1
-- Host: myanimelist.net
-- User-Agent: MALBot
-- Authorization: Basic U291ZGF5bzpmcmFnZ2VyMg==
--
-- Data goes here!

--- Defines the Request class.
-- @return nil.
function define_Request()

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
            _prefix = "[LessAnimeTabbing Request]: ",
            _method = method,
            _path = path,
            _host = host,
            _data = data,
            _user_agent = user_agent
        })
    end

    --- Compiles all data.
    -- Takes all data from the @field _data and turns it into a string.
    -- @class Request
    -- @return All data in string format or empty string on error.
    function Request:_compile_data()
        if self._executed then
            return ""
        end

        -- TODO: Actually compile data to string!

        return ""
    end

    --- Compiles all headers.
    -- Takes all header fields and their values from
    -- the @field _headers and turns them into one string.
    -- @class Request
    -- @return Formatted HTTP request header string or empty string on error.
    function Request:_compile_headers()
        if self._executed then
            return ""
        end

        local headers = {
            string.format("%s %s HTTP/1.1", self._method, self._path),
            "Host: " .. self._host,
            "Connection: keep-alive",
            "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Charset: utf-8",
            "User-Agent: " .. (self._user_agent or "LessAnimeTabbing"),
        }

        for field, value in pairs(self._headers) do
            table.insert(headers, string.format("%s: %s", field, value))
        end

        table.insert(headers, "")
        table.insert(headers, "")

        return table.concat(headers, "\r\n")
    end

    --- Execute a http request.
    -- Executes the given http request and returns and instance
    -- of @class Response. This works on both windows and posix
    -- systems, but should only be used on windows since the _posix_execute
    -- is superior due to vlc.net.poll being available.
    -- @class Request
    -- @param request Complete HTTP Request to send.
    -- @return Instance of @class Response or nil on error/fail.
    function Request:_win_execute(request)
        if self._executed then
            return nil
        end

        local result = nil

        if self:connect(self._host, 80) then
            if self:send(request) then
                local response = ""
                local size = 1024 -- Chunk size, probably fine at 1024
                local received = self:recv(size)

                if received == nil then
                    repeat
                        received = self:recv(size)

                        if received ~= nil then
                            response = response .. received

                            -- By resetting to nil the loop will keep on
                            -- until received is shorter than size.
                            if string.len(received) >= size then
                                received = nil
                            end

                        -- If we get nil and there is something in response we
                        -- need to break to avoid infinite looping.
                        elseif received == nil and string.len(response) > 1 then
                            break
                        end
                    until received ~= nil
                else -- Not nil on first try, yeah as if this is ever gonna happen...
                    if string.len(received) >= size then
                        response = received

                        repeat
                            received = self:recv(size)

                            if received ~= nil then
                                response = response .. received

                                if string.len(received) >= size then
                                    received = nil
                                end
                            elseif received == nil and string.len(response) > 1 then
                                break
                            end
                        until received ~= nil
                    else
                        response = received
                    end
                end

                -- Now there should be something in response
                result = Response:new(response)
            end

            self:disconnect()
        end

        return result
    end

    --- Execute a http request.
    -- Executes the given http request and returns and instance
    -- of @class Response. This method does not work on Windows!
    -- @class Request
    -- @param request Complete HTTP Request to send.
    -- @return Instance of @class Response or nil on error/fail.
    function Request:_posix_execute(request)
        if vlc.win then
            return self:_win_execute(request)
        end

        self:error("_posix_execute not implemented!")
        -- TODO: Implement.

        return nil
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
    -- @response Instance of @class Response or nil on error/fail.
    function Request:execute()
        if self._executed then
            return false
        end

        if type(self._path) ~= "string" or self._path == "" then
            return false
        end

        if type(self._host) ~= "string" or self._host == "" then
            return false
        end

        if self._method ~= self.GET or self._method ~= self.POST then
            self._method = self.GET
        end

        local header = self:_compile_headers()
        local data = self:_compile_data()
        local request = header .. data
        local result = nil

        -- Select os specific implementation
        if vlc.win then
            result = self:_win_execute(request)
        else -- Hurray for POSIX!
            result = self:_posix_execute(request)
        end

        self._executed = true

        return result
    end

    --- Get executed status.
    -- Getter for @field _executed.
    -- @class Request
    -- @return Executed status boolean.
    function Request:executed()
        return self._executed
    end
end
