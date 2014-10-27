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


--- Defines the MyAnimeListEndpoint class.
-- @return nil.
function define_MyAnimeListEndpoint()

    --- MyAnimeListEndpoint class.
    -- Defines the MAL enpoint.
    -- @class MyAnimeListEndpoint
    MyAnimeListEndpoint = inherits(Endpoint)

    MyAnimeListEndpoint._new = MyAnimeListEndpoint.new
    --- MyAnimeListEndpoint constructor.
    -- Creates a new instance of @class MyAnimeListEndpoint.
    -- @class MyAnimeListEndpoint
    -- @param config Instance of @class Config.
    -- @return Instance of @class MyAnimeListEndpoint.
    function MyAnimeListEndpoint:new(config)
        return self._new(self, {
            _config = config,
            _name = "MyAnimeList",
            _prefix = "[LessAnimeTabbing MyAnimeList]: "
        })
    end
end
