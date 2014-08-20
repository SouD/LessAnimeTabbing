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


--- My Anime List Bot class.
-- The main class of the extension. Not defined within a define_ OO function
-- since we need instant access to information.
-- @class MALBot
-- @field _api Contains an instance of @class API.
-- @field _gui Contains an instance of @class GUI.
-- @field info Contains extension information.
-- @field info.title Extension title.
-- @field info.version Extension version.
-- @field info.author Extension author.
-- @field info.url Extension url.
-- @field info.shortdesc Short extension description.
-- @field info.description Extension description.
-- @field info.capabilities Extension capabilities like menu, input and meta.
-- @field _publisher Contains an instance of @class Publisher.
MALBot = {
    _api = nil,
    _gui = nil,
    info = {
        title = "MALBot",
        version = "0.0.2a",
        author = "Linus Sörensen",
        url = 'http://soud.se',
        shortdesc = "Map to MAL", -- Text shown in context menu
        description = "TODO: Write description here.",
        capabilities = {}
    },
    _publisher = nil
}

--- Activate MALBot.
-- Called when the extension is activated.
-- @class MALBot
-- @return nil.
function MALBot:activate()

    -- Init config
    if not Config:instance():load() then
        Config:instance():error("Failed to load config")

        if not Config:instance():loaded() then
            Config:instance():reset() -- Load defaults into memory
        end
    end

    -- Subscribe to messages
    self._publisher = Publisher:new()
    self._publisher:subscribe(MSG_GUI_INPUT_AUTH, function(msg, ...)
        self:auth_input_handler(msg, ...)
    end)

    -- Init members
    self._api = API:new()
    self._api:prefix("[MALBot API]: ")
    -- Hey this is almost like dependency injection! Sugoi!
    self._gui = GUI:new(Publisher:new())

    local save_credentials = Config:instance():get("save_credentials")

    if not save_credentials then
        self._gui:login()
    else
        self:auth()
    end
end

--- Run authentication.
-- Attempts to authenticate the user with input or saved credentials.
-- @class MALBot
-- @return nil.
function MALBot:auth()
    local username = Config:instance():get("username")
    local password = Config:instance():get("password")

    if self._api:authenticate(username, password) then
        self:run()
    else -- Show login dialog on fail
        self._gui:login()
    end
end

--- Handler for auth input.
-- This is a handler function which responds to the
-- MSG_GUI_INPUT_AUTH message. It retreives the input
-- user data and stores it in the config.
-- @param msg Message this handler is subscribed to.
-- @param ... Any other args sent.
-- @return nil.
function MALBot:auth_input_handler(msg, ...)
    Config:instance():set("username", self._gui:get("username"))
    Config:instance():set("password", self._gui:get("password"))
    Config:instance():set("save_credentials", self._gui:get("save_credentials"))

    self._gui:clear_input()

    self:auth()
end

--- Deactivate MALBot.
-- Called when the extension is deactivated.
-- @class MALBot
-- @return nil.
function MALBot:deactivate()
    Config:instance():save()
end

--- Run MALBot.
-- Run through the entire workflow once.
-- Will perform the following tasks in order:
--   1. Check if there is anything in the playlist.
--   2. If there is, show the mapping dialog.
--   3. For each item, parse out info like name, ep. number and season if possible.
--   4. Use the gathered data to attempt to get the items MAL entry.
--   5. Update the items info with the info from MAL.
--   6. Show the mapping dialog window.
-- @class MALBot
-- @return nil.
function MALBot:run()
    -- TODO: Implement this.
    -- local playlist = vlc.playlist.get("playlist")
    -- IO:print_r(playlist)
end
