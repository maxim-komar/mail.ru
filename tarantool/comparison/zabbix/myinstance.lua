#!/usr/bin/env tarantool

box.cfg{
    listen=3301,
    slab_alloc_arena=12.0
}

box.schema.user.grant('guest','execute,read,write','universe') 

trends_uint_tablename = 'trends_uint'
part_size = 86400

create_trends_uint_part = function (num)
    local pname = trends_uint_tablename .. tostring(num)

    box.schema.create_space(pname, {if_not_exists = true})
    pcall(box.space[pname]:create_index('primary', {type = 'TREE', parts = {1, 'NUM', 2, 'NUM'}}))
end

insert_trends_uint = function (t)
    local itemid, clock = unpack(t)
    local pname = trends_uint_tablename .. tostring(math.floor(clock / part_size))
    
    box.space[pname]:replace(t)
end
