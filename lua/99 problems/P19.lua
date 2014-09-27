-- rotate a list N places to the left
-- > rotate({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'}, 3)
-- {'d', 'e', 'f', 'g', 'h', 'a', 'b', 'c'}

rotate = function(t, n)
    local res = {}

    if n < 0 then n = #t + n end
    for i = n + 1, #t do table.insert(res, t[i]) end
    for i = 1, n do table.insert(res, t[i]) end
    return res
end

dofile 'dumper.lua'
print(DataDumper(rotate({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'}, 3)))
print(DataDumper(rotate({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'}, -2)))

