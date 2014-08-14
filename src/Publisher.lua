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


--- Defines the Publisher class.
-- @return nil.
function define_Publisher()

    --- Publisher class.
    -- Can publish messages (events) and pipe to all subscribers.
    -- @class Publisher
    -- @field _subs Table with all message subscribers.
    Publisher = inherits(nil)
    Publisher._subs = {} -- Lets pretend that this is a static member...

    --- Publish a message.
    -- Invokes every subscribe handler for the given message. Any additional
    -- arguments will be passed along to the handler.
    -- @class Publisher
    -- @param msg Message to publish.
    -- @param ... Message args to send.
    -- @return True if at least one handle was called or false if none.
    function Publisher:publish(msg, ...)
        if type(msg) ~= "string" or msg == "" then
            return false
        end

        local subs = Publisher._subs[msg] or {}
        local count = 0

        for _, handler in pairs(subs) do
            if type(handler) == "function" then
                handler(msg, ...)
                count = count + 1
            end
        end

        if count > 0 then
            -- TODO: Inherit IO or use global namespace?
            vlc.msg.dbg(string.format("%s [MALBot Publisher]: %s sent to %d subscriber(s)",
                os.date("%H:%M:%S"), msg, count))
        end

        return count > 0
    end

    --- Subscribe to a message.
    -- When the message is published the supplied handler will be
    -- called with any extra parameters sent to Publisher:publish().
    -- Chainable.
    -- @class Publisher
    -- @param msg Message to subscribe to.
    -- @param handler Message handler.
    -- @return False on error else self.
    function Publisher:subscribe(msg, handler)
        if type(msg) ~= "string" or msg == "" then
            return false
        end

        if type(Publisher._subs[msg]) ~= "table" then
            Publisher._subs[msg] = {}
        end

        Publisher._subs[msg][tostring(handler)] = handler

        return self
    end

    --- Unsubscribe from a message.
    -- Removes the supplied handler from the give message subscriber list.
    -- Chainable.
    -- @class Publisher
    -- @param msg Message to unsubscribe from.
    -- @param handler Handler to unsubscribe.
    -- @return False on error else self.
    function Publisher:unsubscribe(msg, handler)
        if type(msg) ~= "string" or msg == "" then
            return false
        end

        if type(Publisher._subs[msg]) == "table" then
            Publisher._subs[msg][tostring(handler)] = nil
            collectgarbage()
        end

        return self
    end
end
