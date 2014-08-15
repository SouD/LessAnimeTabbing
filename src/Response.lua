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

--- Defines the Response class.
-- @return nil.
function define_Response()

    --- Response class.
    -- Represents a HTTP response.
    -- @class Response
    -- @field _body Contains response body.
    -- @field _headers Table containing response headers.
    -- @field _status Contains the response status code.
    Response = inherits(nil)
    Response._body = nil
    Response._headers = nil
    Response._status = nil

    Response._new = Response.new
    --- Response constructor.
    -- Creates a new instance of @class Response.
    -- @class Response
    -- @param raw Raw HTTP response string.
    -- @return Instance of @class Response.
    function Response:new(raw)
        if type(raw) ~= "string" then
            raw = ""
        end

        local raw_header, raw_body = string.match(raw, "(.-\r?\n)\r?\n(.*)")
        local headers = {}
        local status = nil

        if raw_header == nil then
            raw_header = ""
        end

        for k, s, v in string.gmatch(raw_header, "([^%s:]+)(:?)%s([^\n]+)\r?\n") do
            if s == "" then
                status = tonumber(string.sub(v, 1, 3))
            else
                headers[k] = v
            end
        end

        return self._new(self, {
            _body = raw_body,
            _headers = headers,
            _status = status
        })
    end

    --- Get HTTP response body.
    -- @class Response
    -- @return HTTP response body.
    function Response:body()
        return self._body
    end

    --- Get a HTTP response header value.
    -- Get the value associated with the given header name.
    -- @class Response
    -- @return HTTP response header value as string.
    function Response:header(field)
        return self._headers[field]
    end

    --- Get a HTTP response headers.
    -- Get all of the headers in the HTTP response.
    -- @class Response
    -- @return Table with all the headers.
    function Response:headers()
        return self._headers
    end

    --- Get HTTP response status code.
    -- @class Response
    -- @return HTTP response status code number.
    function Response:status()
        return self._status
    end
end
