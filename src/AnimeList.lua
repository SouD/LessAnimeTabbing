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


--- Defines the AnimeList class.
-- @return nil.
function define_AnimeList()

    --- AnimeList class.
    -- Represents a list fille with anime.
    -- @class AnimeList
    AnimeList = inherits(List)
    AnimeList._anime_id_map = nil
    AnimeList._publisher = nil

    AnimeList._new = AnimeList.new
    --- AnimeList constructor.
    -- Creates a new instance of @class AnimeList.
    -- @class AnimeList
    -- @param config An instance of @class Config.
    -- @return Instance of @class AnimeList.
    function AnimeList:new(config, publisher)
        return self._new(self, {
            _anime_id_map = config,
            _publisher = publisher
        })
    end

    function AnimeList:_update_elements(list)
        for i, item in ipairs(list) do
            if not self._values[i] or item.name ~= self.values[i]:raw_name() then
                self:add(Anime:new(item))
            end
        end
    end

    function AnimeList:_update_ids()

    end

    function AnimeList:update(list)
        if type(list) == "table" and #list > 0 then
            self:_update_elements(list)
        end

        if #self._values > 1 then
            self:_update_ids()

            return true
        else
            return false
        end
    end
end
