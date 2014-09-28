local c = 0

local tinfo = box.space._space:select()
local tname = {}

for i = 1, #tinfo do
    local j = string.find(tinfo[i][3], trends_uint_tablename)
    if j then table.insert(tname, tinfo[i][3]) end
end

for i = 1, #tname do
    c = c + box.space[tname[i]].index.primary:count()
end
return c
