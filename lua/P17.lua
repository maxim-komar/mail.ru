-- split a list into two pairs; the length of the first pair is given
-- > split({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k'}, 3)
-- {{'a', 'b', c'}, {'d', 'e', 'f', 'g', 'h', 'i', 'k'}}

split = function (t, n)
    local part1 = {}
    local part2 = {}

    for i = 1, n do
        table.insert(part1, t[i])
    end

    for i = n + 1, #t do
        table.insert(part2, t[i])
    end
    return {part1, part2}
end

dofile 'dumper.lua'
print(DataDumper(split({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k'}, 3)))
