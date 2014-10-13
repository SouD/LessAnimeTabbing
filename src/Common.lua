-- TODO: Add credit, everything here is from lua users wiki!

--- Trim a string.
-- Strips a string from trailing whitespace.
-- @param str String to strip.
-- @return The stripped string.
function string_trim(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--- Split a string.
-- Splits a string using a delimiter. Set limit to
-- limit the amount of parts returned.
-- @param str String to split.
-- @param delim Delimiter to use.
-- @param limit Amount of results to return.
-- @return Varying amount of parts depending on delimiter and limit.
function string_split(str, delim, limit)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if limit == nil or limit < 1 then
        limit = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local last_pos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        last_pos = pos
        if nb == limit then break end
    end
    -- Handle the last field
    if nb ~= limit then
        result[nb + 1] = string.sub(str, last_pos)
    end
    return result
end

--- Copy a table.
-- Copys a table and its values to a new table and returns it.
-- Called shallow copy because it will not deeply copy values
-- which are tables. I.e. no recursion!
-- @param t Table to copy.
-- @return A shallow copy of t.
function table_shallow_copy(t)
    local t2 = {}

    for k, v in pairs(t) do
        t2[k] = v
    end

    return t2
end

--- URL encode a string.
-- Source: http://lua-users.org/wiki/StringRecipes
-- @param str String to encode.
-- @return Encoded string or nil.
function url_encode(str)
    if type(str) == "string" then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])", function (c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")

        return str
    end
end
