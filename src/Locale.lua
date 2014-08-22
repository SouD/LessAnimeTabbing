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


--- Defines the Locale class.
-- @return nil.
function define_Locale()

    --- Locale class.
    -- Contains methods to handle localization.
    -- @class Locale
    -- @field _values Translations key value store.
    Locale = inherits(nil)
    Locale._values = nil

    Locale._new = Locale.new
    --- Locale constructor.
    -- Creates a new instance of @class Locale.
    -- @class Locale
    -- @param locale Lang code specifying locale to load.
    -- @return Instance of @class Locale.
    function Locale:new(locale)
        assert(type(LOCALES) == "table", "No locales found!")

        if not locale then
            locale = os.getenv("LANG")

            if locale then -- POSIX
                locale = string.sub(locale, 0, 2)
            else -- Windows
                locale = string.match(os.setlocale("", "collate"), "^[^_]+")
            end
        end

        local l = LOCALES[locale] or LOCALES["en"] or {}

        return self._new(self, {
            _values = l
        })
    end

    --- Get localized string by key.
    -- Get the translated string matching the given key.
    -- @class Locale
    -- @param key Translated string key.
    -- @return Translated string or empty string on fail.
    function Locale:get(key)
        return self._values[key] or ""
    end
end
