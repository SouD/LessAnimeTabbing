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


--- Defines the API class.
-- @return nil.
function define_API()

    --- myanimelist.net API class.
    -- Contains methods to handle interfacing with MAL's public API.
    -- @class API
    -- @field HOST API host.
    -- @field PORT API port.
    -- @field VERIFY_CREDENTIALS Authentication path.
    -- @field ANIME_SEARCH Search for anime path.
    -- @field ANIME_ADD Add anime to list path.
    -- @field ANIME_UPDATE Update anime list entry path.
    -- @field ANIME_DELETE Delete anime from list path.
    -- @field _auth Authentication status boolean.
    API = inherits(nil)
    API.HOST = "myanimelist.net"
    API.PORT = 80
    API.VERIFY_CREDENTIALS = "/api/account/verify_credentials.xml" -- GET
    API.ANIME_SEARCH = "/api/anime/search.xml?q=%s" -- GET, req auth
    API.ANIME_ADD = "/api/animelist/add/%d.xml" -- POST, req auth
    API.ANIME_UPDATE = "/api/animelist/update/%d.xml" -- POST, req auth
    API.ANIME_DELETE = "/api/animelist/delete/%d.xml" -- POST|DELETE, req auth
    API._auth = false

    --- Authenticate user credentials.
    -- Attempts to authenticate input user credentials against MAL's API.
    -- @param username Username to authenticate.
    -- @param password Password to authenticate.
    -- @return True on success or false on fail.
    function API:auth(username, password)
        if type(username) ~= "string" or username == "" then
            return false
        end

        if type(password) ~= "string" or password == "" then
            return false
        end

        local req = Request:new(Request.GET, self.VERIFY_CREDENTIALS, self.HOST, nil)

        req:add_basic_auth(username, password)

        return false
    end
end
