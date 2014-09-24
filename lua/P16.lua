-- drop every n'th element from a list
-- > dropEvery({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k'}, 3)
-- {'a', 'b', 'd', 'e', 'g', 'h', 'k'}

dropEvery = function (t, n)
    local res = {}
    for i = 1, #t do
        if i % n ~= 0 then 
            table.insert(res, t[i])
        end
    end
    return res
end

dofile 'dumper.lua'
print(DataDumper(dropEvery({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k'}, 3)))
