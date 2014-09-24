-- run-length encoding of a list. Use the result of problem P09
-- to implement the so-called run-length encoding data compression
-- method. Consecutive duplicates of elements are encoded as 
-- lists {N, E}, where N is the number of duplicates of the 
-- element E:
-- > encode{1, 1, 1, 1, 2, 3, 3, 1, 1, 4, 5, 5, 5, 5}
-- {{4, 1}, {1, 2}, {2, 3}, {2, 1}, {1, 4}, {4, 5}}

encode = function (t)
    local vals = {}
    local cnts = {}
    local hpos = 0
    local cur

    for i = 1, #t do
        if t[i] ~= cur then
            hpos = hpos + 1
            cur = t[i]
            cnts[hpos] = 0
        end
        vals[hpos] = t[i]
        cnts[hpos] = cnts[hpos] + 1
    end

    local res = {}
    for i = 1, #vals do
        table.insert(res, {cnts[i], vals[i]})
    end
    return res
end

dofile 'dumper.lua'
print(DataDumper(encode{1, 1, 1, 1, 2, 3, 3, 1, 1, 4, 5, 5, 5, 5}))
