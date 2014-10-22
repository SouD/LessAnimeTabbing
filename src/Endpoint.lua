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


--- Defines the Endpoint class.
-- @return nil.
function define_Endpoint()

    --- Endpoint class.
    -- Defines an anime list service endpoint (API).
    -- @class Endpoint
    -- @field _config Instance of @class Config.
    -- @field _name Name of endpoint.
    Endpoint = inherits(IO)
    Endpoint._config = nil
    Endpoint._name = nil

    Endpoint._new = Endpoint.new
    --- Endpoint constructor.
    -- Creates a new instance of @class Endpoint.
    -- @class Endpoint
    -- @param config Instance of @class Config.
    -- @param name Name of endpoint.
    -- @return Instance of @class Endpoint.
    function Endpoint:new(config, name)
        name = (name or "Endpoint")

        return self._new(self, {
            _config = config,
            _name = name,
            _prefix = "[LessAnimeTabbing " .. name .. "]: "
        })
    end

    --- Authenticate using endpoint.
    -- Abstract endpoint authentication method.
    -- Overload with implementation in inheriting class.
    -- @return nil.
    function Endpoint:authenticate()
        self:warning("Unimplemented abstract method :authenticate")
    end

    --- Create using endpoint.
    -- Abstract endpoint creation method.
    -- Overload with implementation in inheriting class.
    -- @return nil.
    function Endpoint:create()
        self:warning("Unimplemented abstract method :create")
    end

    --- Read using endpoint.
    -- Abstract endpoint reading method.
    -- Overload with implementation in inheriting class.
    -- @return nil.
    function Endpoint:read()
        self:warning("Unimplemented abstract method :read")
    end

    --- Updated using endpoint.
    -- Abstract endpoint update method.
    -- Overload with implementation in inheriting class.
    -- @return nil.
    function Endpoint:update()
        self:warning("Unimplemented abstract method :update")
    end

    --- Delete using endpoint.
    -- Abstract endpoint deletion method.
    -- Overload with implementation in inheriting class.
    -- @return nil.
    function Endpoint:delete()
        self:warning("Unimplemented abstract method :delete")
    end
end
