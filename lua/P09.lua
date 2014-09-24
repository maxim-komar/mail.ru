-- pack consecutive duplicates of list elements into sublists. 
-- if a list contains repeated elements they should be placed
-- in separate sublists:
-- > pack{1, 1, 1, 1, 2, 3, 3, 1, 1, 4, 5, 5, 5, 5}
-- {{1, 1, 1, 1}, {2}, {3, 3}, {1, 1}, {4}, {5, 5, 5, 5}}

pack = function (t)
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
        cur = vals[i]
        local tmp = {}
        for j = 1, cnts[i] do
            table.insert(tmp, cur)
        end
        table.insert(res, tmp)
    end
    return res
end

pack{1, 1, 1, 1, 2, 3, 3, 1, 1, 4, 5, 5, 5, 5}
