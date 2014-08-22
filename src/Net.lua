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


--- Defines the Net class.
-- @return nil.
function define_Net()

    --- Net class.
    -- Contains methods for using the internet. Sort of.
    -- @class Net
    -- @field _connection The current connection (a number mapped to a file descriptor).
    -- @field _connected Connection status boolean.
    Net = inherits(IO)
    Net._connection = nil
    Net._connected = false

    --- Open a new tcp connection.
    -- Attempts to open a new tcp connection to the given host
    -- on the given port.
    -- @class Net
    -- @param host Host to connect to.
    -- @param port Port to connect on.
    -- @return True if connection was successful or false on error.
    function Net:connect(host, port)
        local l = Locale:new()
        assert(vlc.net, l:get("ASSERT_VLC_NET_FAIL"))

        if self._connected then
            self:disconnect()
        end

        if type(host) ~= "string" or host == "" then
            return false
        end

        if type(port) ~= "number" or port < 1 then
            return false
        end

        -- This will be -1 on error, maybe...
        self._connection = vlc.net.connect_tcp(host, port)

        if self._connection == -1 then
            self:error(string.format(l:get("CONNECTION_FAIL"), host, port))
            self._connected = false
        else
            self._connected = true
        end

        return self._connected
    end

    --- Disconnect current connection.
    -- Attempts to disconnect from the current tcp connection.
    -- @class Net
    -- @return True if disconnected or false on error.
    function Net:disconnect()
        local l = Locale:new()
        assert(vlc.net, l:get("ASSERT_VLC_NET_FAIL"))

        if self._connection == -1 then
            return false
        end

        if not self._connected then
            return true
        end

        -- Disregard output from this
        vlc.net.close(self._connection)

        return true
    end

    --- Receive data on current connection.
    -- Attempts to receive data on the current connection
    -- if one exists.
    -- @class Net
    -- @return Response from connection or false on error or nil if no response (socket not ready).
    function Net:recv(size)
        local l = Locale:new()
        assert(vlc.net, l:get("ASSERT_VLC_NET_FAIL"))

        if not self._connected then
            return false
        end

        if type(size) ~= "number" or size < 1 then
            size = 1024
        end

        local response = vlc.net.recv(self._connection, size)

        if response then
            self:debug(string.format(l:get("RECV_CHARS"), string.len(response)))
        end

        return response -- Can be nil or string
    end

    --- Send data on connection.
    -- Attempts to send the given data on the current connection
    -- if one exists.
    -- @class Net
    -- @param data String to send.
    -- @return True on success or false on error.
    -- @return Amount of chars sent if successful.
    function Net:send(data)
        local l = Locale:new()
        assert(vlc.net, l:get("ASSERT_VLC_NET_FAIL"))

        if not self._connected then
            return false
        end

        if type(data) ~= "string" or data == "" then
            return false
        end

        -- local len = string.len(data)
        local result = vlc.net.send(self._connection, data)

        if result == -1 then
            self:error(l:get("SEND_FAIL"))
            return false
        else
            self:debug(string.format(l:get("SENT_CHARS"), result))
            return true, result
        end
    end
end
