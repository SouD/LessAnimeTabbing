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


--- Defines the Anime class.
-- @return nil.
function define_Anime()

    --- Anime class.
    -- Represents an anime video in the vlc playlist.
    -- @class Anime
    -- @field PATTERN Patterns table constant.
    -- @field PATTERN.EPISODE Episode pattern constant.
    -- @field PATTERN.NAME Name pattern constant.
    -- @field PATTERN.SEASON Season pattern constant.
    -- @field PATTERN.STRIP Strip pattern table constant.
    -- @field _episode The anime episode number.
    -- @field _name The parsed anime name.
    -- @field _raw_name The raw anime file name.
    -- @field _season The anime season number.
    Anime = inherits(nil)
    Anime.PATTERN = {
        EPISODE = "%s*[Ee]*[pisode]*(%d+)",
        NAME = "[%A]*([^%d%c%.]+)",
        SEASON = "%s*[Ss][eason]*(%d+)",
        STRIP = {}
    }
    Anime.PATTERN.STRIP["_"] = " "
    Anime.PATTERN.STRIP["[~%-]"] = ""
    Anime.PATTERN.STRIP["%s[Ee]p[isode]*"] = ""
    Anime.PATTERN.STRIP["^%s*(.-)%s*$"] = "%1"
    Anime.PATTERN.STRIP["(%s%s*)"] = " "
    Anime.PATTERN.STRIP["%s[SPE]$"] = ""
    Anime._episode = nil
    Anime._name = nil
    Anime._raw_name = nil
    Anime._season = nil

    Anime._new = Anime.new
    --- Anime constructor.
    -- Creates a new instance of @class Anime.
    -- @class Anime
    -- @param playlist_item A playlist item.
    -- @return Instance of @class Anime.
    function Anime:new(playlist_item)
        local capture
        local episode = -1
        local name = "Unknown"
        local raw_name
        local season = -1
        local strip

        if playlist_item and type(playlist_item) == "table" and playlist_item.name then
            raw_name = playlist_item.name

            strip = string.gsub(string.gsub(playlist_item.name, "%b[]", ""), "%b()", "")

            capture = string.match(strip, self.PATTERN.EPISODE)
            if capture and tonumber(capture) ~= nil then
                episode = tonumber(capture)
            end

            capture = string.match(strip, self.PATTERN.SEASON)
            if capture and tonumber(capture) ~= nil then
                season = tonumber(capture)
            end

            capture = string.match(strip, self.PATTERN.NAME)
            if capture and string.len(capture) > 1 then
                for pattern, replace in pairs(self.PATTERN.STRIP) do
                    capture = string.gsub(capture, pattern, replace)
                end

                name = capture
            end
        end

        return self._new(self, {
            _episode = episode,
            _name = name,
            _raw_name = raw_name,
            _season = season
        })
    end

    --- Getter/Setter for @field _episode.
    -- Returns the current episode number. If @param episode is present and
    -- is a number it will set it as the new episode number.
    -- @class Anime
    -- @param episode Episode number to set.
    -- @return The current episode number.
    function Anime:episode(episode)
        if type(episode) == "number" then
            self._episode = episode
        end

        return self._episode
    end

    --- Getter/Setter for @field _name.
    -- Returns the current anime name. If @param name is present and
    -- is a non-empty string it will set it as the new anime name.
    -- @class Anime
    -- @param name New anime name to set.
    -- @return The current anime name.
    function Anime:name(name)
        if type(name) == "string" and string_trim(name) ~= "" then
            self._name = name
        end

        return self._name
    end

    --- Getter/Setter for @field _raw_name.
    -- Returns the current raw file name. If @param raw_name is present and
    -- is a non-empty string it will set it as the new raw file name.
    -- @class Anime
    -- @param name Raw file name to set.
    -- @return The current raw file name.
    function Anime:raw_name(raw_name)
        if type(raw_name) == "string" and string_trim(raw_name) ~= "" then
            self._raw_name = raw_name
        end

        return self._raw_name
    end

    --- Getter/Setter for @field _season.
    -- Returns the current season number. If @param season is present and
    -- is a number it will set it as the new season number.
    -- @class Anime
    -- @param season Season number to set.
    -- @return The current season number.
    function Anime:season(season)
        if type(season) == "number" then
            self._season = season
        end

        return self._season
    end
end
