-- duplicate the elements of a list
-- > dupli{'a', 'b', 'c', 'd', 'c'}
-- {'a', 'a', 'b', 'b', 'c', 'c', 'd', 'd', 'c', 'c'}

dupli = function (t)
    local res = {}
    for i = 1, #t do
        table.insert(res, t[i])
        table.insert(res, t[i])
    end
    return res
end

dofile 'dumper.lua'
print(DataDumper(dupli{'a', 'b', 'c', 'd', 'c'}))
