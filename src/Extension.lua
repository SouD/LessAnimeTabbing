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


--- Classes used.
-- An array of all classes.
-- The classes will become available in the global namespace
-- in the order they are defined in.
-- The order is important since an error would occur
-- if a class attempts to inherit another class which
-- hasn't been loaded.
local classes = {
    "Locale",
    "Anime",
    "List",
    "Publisher",
    "IO",
    "Config",
    "Net",
    "Response",
    "Request",
    "MAL",
    "GUI"
}

--- Get extension description.
-- Fetches extension information from the MALBot class.
-- @return A table with all the extension information.
function descriptor()
    return MALBot.info
end

--- Activate the extension.
-- Called by VLC when extension is activated.
-- @return nil.
function activate()
    oo() -- Define classes
    MALBot:activate()
end

--- Deactivate the extension.
-- Called when extension is deactivated by the user, extension or VLC.
-- @return nil.
function deactivate()
    MALBot:deactivate()
end

--- Close extension dialog.
-- Called on dialog close by VLC or internally by the extension.
-- @return nil.
function close()
    -- Deactivate for now...
    vlc.deactivate()
end

--- Input media changed.
-- Called by VLC when the input media has changed.
-- This occurs when EOF is reached or the media is stopped or started.
-- @return nil.
function input_changed()

end

--- Media meta changed.
-- Called by VLC when media meta has changed.
-- This occurs when the playlist is updated or the media meta actually changes.
-- @return nil.
function meta_changed()

end

--- Playing media changed.
-- Called by VLC when the playing media changed.
-- This occurs when the something triggers a next/prev action.
-- @return nil.
function playing_changed()

end
