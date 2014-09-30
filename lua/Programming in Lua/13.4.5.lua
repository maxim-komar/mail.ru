-- read-only tables

readOnly = function (t)
    local proxy = {}
    local mt = {
        __index = t,
        __newindex = function (t, k, v)
            error("attempt to update a read-only table", 2)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

days = readOnly{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}

print(days[1])
-- Monday
days[2] = "No day"
-- lua: 13.4.5.lua:17: attempt to update a read-only table
-- ...
