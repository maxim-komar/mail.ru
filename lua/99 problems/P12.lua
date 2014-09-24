-- decode a run-length encoded list.
-- given a run-length code list generated as specified in problem 11.
-- construct its uncompressed version
-- > decodeModified{{4, 'a'}, 'b', {2, 'c'}, {2, 'a'}, 'd', {4, 'e'}}
-- {'a', 'a', 'a', 'a', 'b', 'c', 'c', 'a', 'a', 'd', 'e', 'e'}

decodeModified = function (t)
    local res = {}
    for i = 1, #t do
        if type(t[i]) == "table" then
            for j = 1, t[i][1] do
                table.insert(res, t[i][2])
            end
        else
            table.insert(res, t[i])
        end
    end
    return res
end

dofile 'dumper.lua'
print(DataDumper(decodeModified{{4, 'a'}, 'b', {2, 'c'}, {2, 'a'}, 'd', {4, 'e'}}))
