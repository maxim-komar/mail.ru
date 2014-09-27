-- extract a slice from a list
-- > slice({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k'}, 3, 7)
-- {'c', 'd', 'e', 'f', 'g'}

slice = function (t, from, to)
    local res = {}
    for i = from, to do
        table.insert(res, t[i])
    end
    return res
end

dofile 'dumper.lua'
print(DataDumper(slice({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k'}, 3, 7)))
