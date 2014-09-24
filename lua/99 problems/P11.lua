-- modify the result of problem 10 in such a way that if an 
-- element has no duplicates it is simply copied into the 
-- result list. Only elements with duplicates are transferred
-- as {N, E} lists
-- > encodeModified{1, 1, 1, 1, 2, 3, 3, 1, 1, 4, 5, 5, 5, 5}
-- {{4, 1}, 2, {2, 3}, {2, 1}, 4, {4, 5}}

encodeModified = function (t)
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
        if cnts[i] > 1 then
            table.insert(res, {cnts[i], vals[i]})
        else
            table.insert(res, vals[i])
        end
    end
    return res
end

dofile 'dumper.lua'
print(DataDumper(encodeModified{1, 1, 1, 1, 2, 3, 3, 1, 1, 4, 5, 5, 5, 5}))
