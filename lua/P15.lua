-- replicate the elements of a list a given number of times
-- > repli({'a', 'b', 'c'}, 3)
-- {'a', 'a', 'a', 'b', 'b', 'b', 'c', 'c', 'c'}

repli = function (t, n)
    local res = {}
    for i = 1, #t do
        for j = 1, n do
            table.insert(res, t[i])
        end
    end
    return res
end

dofile 'dumper.lua'
print(DataDumper(repli({'a', 'b', 'c'}, 3)))
