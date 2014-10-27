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


--- LessAnimeTabbing class.
-- The main class of the extension. Not defined within a define_ OO function
-- since we need instant access to information.
-- @class LessAnimeTabbing
-- @field _endpoints Array with available endpoints.
-- @field _endpoints.class Endpoint class name.
-- @field _endpoints.config Endpoint config name.
-- @field info Contains extension information.
-- @field info.title Extension title.
-- @field info.version Extension version.
-- @field info.author Extension author.
-- @field info.url Extension url.
-- @field info.shortdesc Short extension description.
-- @field info.description Extension description.
-- @field info.capabilities Extension capabilities like menu, input and meta.
-- @field _locale Contains an instance of @class Locale.
LessAnimeTabbing = {
    _endpoint_configs = {{
        class = "MyAnimeListEndpoint",
        config = "LessAnimeTabbing.MyAnimeList", -- Should this be in the class?
    }, {
        class = "HummingbirdEndpoint",
        config = "LessAnimeTabbing.Hummingbird",
    }},
    _endpoints = {},
    info = {
        title = "LessAnimeTabbing",
        version = "0.0.3a",
        author = "Linus Sörensen",
        url = 'https://github.com/SouD/LessAnimeTabbing',
        shortdesc = "LessAnimeTabbing", -- Text shown in rclick menu
        description = "Keep track of your anime without tabbing!",
        capabilities = {}
    },
    _locale = nil
}

--- Activate LessAnimeTabbing.
-- Called when the extension is activated.
-- @class LessAnimeTabbing
-- @return nil.
function LessAnimeTabbing:activate()
    -- Init members
    self._locale = Locale:new()

    -- Init endpoints
    self:init_endpoints()

    IO:debug("Activated")
end

--- Deactivate LessAnimeTabbing.
-- Called when the extension is deactivated.
-- @class LessAnimeTabbing
-- @return nil.
function LessAnimeTabbing:deactivate()
    IO:debug("Deactivated")
end

function LessAnimeTabbing:init_endpoints()
    local _G = getfenv(0)
    local parser = OBJDEF:new()

    for i = 1, #self._endpoint_configs do
        local class = self._endpoint_configs[i].class
        local config_name = self._endpoint_configs[i].config

        if class and _G[class] ~= nil then
            local config = Config:new(config_name, self._locale, parser)
            local endpoint = (_G[class]):new(config)
            table.insert(self._endpoints, endpoint)
        end
    end
end
