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


--- Localization table.
-- Holds all the localizations. This really should've been
-- handled differently but VLC has a 1 file restriction so
-- there isn't really much I can do about it.
-- Ideally I'd want it to be a separate file with globals but
-- that won't really work here...
LOCALES = LOCALES or {}
LOCALES.en = {
    AUTH_SUCCESS = "Authentication successful, welcome %s",
    AUTH_FAIL = "Authentication failed",
    AUTH_UNEXPECTED_CODE = "Unexpected HTTP response status code %d",

    CONF_LOAD_INVALID_ARG = "Invalid argument 1 to method Config:load()",
    CONF_PARSE_FAIL = "Failed to parse config name %s",
    CONF_CREATE_SUCCESS = "Created config %s",
    CONF_CREATE_FAIL = "Failed to create config %s",
    CONF_NOT_FOUND = "Config not found on %s",
    CONF_OPEN_FAIL = "Failed to open config, errno %d",
    CONF_LOAD_SUCCESS = "Loaded config %s from %s",
    CONF_RESET = "Resetting config %s",
    CONF_LAST_MODIFIED = "# Last modified: %s \n",
    CONF_SAVED = "Saved config %s to %s",

    LOGIN_LABEL = "MALBot requires your MAL login credentials to continue.",
    USERNAME = "Username:",
    PASSWORD = "Password:",
    REMEMBER_ME = "Remember me",
    AUTHORIZE = "Authorize",
    CANCEL = "Cancel",

    ASSERT_VLC_NET_FAIL = "Namespace vlc.net not available!",
    RECV_CHARS = "Received %d chars",
    SEND_FAIL = "Failed to send data",
    SENT_CHARS = "Sent %d chars",
    CONNECTION_FAIL = "Failed to connect to %s:%d",

    MSG_SENT_TO_SUBS = "%s sent to %d subscriber(s)",

    ASSERT_WIN_FAIL = "Windows not supported!"
}
