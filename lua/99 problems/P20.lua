-- remove the k'th element from a list
-- > removeAt(2, {'a', 'b', 'c', 'd'})
-- {'a', 'c', 'd'}

removeAt = function (k, t)
    local res = t
    table.remove(t, 2)
    return res
end

dofile 'dumper.lua'
print(DataDumper(removeAt(2, {'a', 'b', 'c', 'd'})))
