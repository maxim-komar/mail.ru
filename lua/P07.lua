-- flattend a nested list structure
-- > flatten{1, 2, {3, 4, {5, 6}, 7}, 8, 9}
-- {1, 2, 3, 4, 5, 6, 7, 8, 9}

concat = function (a, b)
    if type(a) ~= "table" and type(b) ~= "table" then
        return {a, b}
    elseif type(a) ~= "table" and type(b) == "table" then
        local acc = {a}
        for _,v in ipairs(b) do table.insert(acc, v) end
        return acc
    elseif type(a) == "table" and type(b) ~= "table" then
        local acc = a
        table.insert(acc, b)
        return acc
    else
        local acc = a
        for _,v in ipairs(b) do table.insert(acc, v) end
        return acc
    end
end

flatten = function (t)
    if t[1] == nil then
        return {}
    else
        local tail = {}
        for i=2, #t do tail[i - 1] = t[i] end
        if type(t[1]) ~= "table" then
            return concat(t[1], flatten(tail))
        else
            return concat(flatten(t[1]), flatten(tail))
        end
    end
end
