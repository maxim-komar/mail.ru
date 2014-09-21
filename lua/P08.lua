-- eliminate consecutive duplicates of list elements
-- > compress{'a', 'a', 'a', 'b', 'c', 'c', 'a', 'a', 'd', 'e', 'e', 'e'}
-- {'a', 'b', 'c', 'a', 'd', 'e'}

unshift = function(t, e)
    local acc = {e}
    for _,v in ipairs(t) do table.insert(acc, v) end
    return acc
end

-- no tail recursion optimization
compress = function (t)
    if t[1] == nil then return {} end

    local tail = {}
    for i = 2, #t do tail[i - 1] = t[i] end

    if t[1] == tail[1] then
        return compress(tail)
    else
        return unshift(compress(tail), t[1])
    end
end
