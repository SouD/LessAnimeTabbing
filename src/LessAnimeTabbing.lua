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
-- @field _config_name Name of config file.
-- @field _config Contains an instance of @class Config.
-- @field info Contains extension information.
-- @field info.title Extension title.
-- @field info.version Extension version.
-- @field info.author Extension author.
-- @field info.url Extension url.
-- @field info.shortdesc Short extension description.
-- @field info.description Extension description.
-- @field info.capabilities Extension capabilities like menu, input and meta.
-- @field _locale Contains an instance of @class Locale.
-- @field _publisher Contains an instance of @class Publisher.
LessAnimeTabbing = {
    _config_name = "LessAnimeTabbing.LessAnimeTabbing",
    _config = nil,
    _endpoints = {},
    info = {
        title = "LessAnimeTabbing",
        version = "0.0.3a",
        author = "Linus Sörensen",
        url = 'https://github.com/SouD/LessAnimeTabbing',
        shortdesc = "LessAnimeTabbing", -- Text shown in context menu
        description = "Keep track of your anime without tabbing!",
        capabilities = {}
    },
    _locale = nil,
    _publisher = nil
}

--- Activate LessAnimeTabbing.
-- Called when the extension is activated.
-- @class LessAnimeTabbing
-- @return nil.
function LessAnimeTabbing:activate()
    -- Init members
    self._locale = Locale:new()
    self._config = Config:new(self._config_name, self._locale)
    -- Almost like dependency injection! Sugoi!

    IO:debug("Activated!")
end

--- Deactivate LessAnimeTabbing.
-- Called when the extension is deactivated.
-- @class LessAnimeTabbing
-- @return nil.
function LessAnimeTabbing:deactivate()
    self._config:save()
end
