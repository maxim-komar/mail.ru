Set = {}
Set.mt = {}

Set.new = function (t)
    local set = {}
    setmetatable(set, Set.mt)
    for _, k in ipairs(t) do set[k] = true end
    return set
end

Set.union = function (a, b)
    local res = Set.new{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end

Set.intersection = function (a, b)
    local res = Set.new{}
    for k in pairs(a) do
        res[k] = b[k]
    end
    return res
end

Set.tostring = function (set)
    local s = "{"
    local sep = ""
    for e in pairs(set) do
        s = s .. sep .. e
        sep = ", "
    end
    return s .. "}"
end

Set.print = function (set)
    print(Set.tostring(set))
end

Set.mt.__add = Set.union
Set.mt.__mul = Set.intersection

a = Set.new{1,2,3,4,5,6}
b = Set.new{1,3,5,7}

Set.print(a)
Set.print(b)
Set.print(a + b)
Set.print(a * b)

-- {1, 2, 3, 4, 5, 6}
-- {1, 7, 5, 3}
-- {1, 2, 3, 4, 5, 6, 7}
-- {1, 5, 3}

