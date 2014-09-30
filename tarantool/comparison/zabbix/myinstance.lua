#!/usr/bin/env tarantool

box.cfg{
    listen=3301,
    slab_alloc_arena=12.0
}

box.schema.user.grant('guest','execute,read,write','universe') 

trends_uint_tablename = 'trends_uint'
part_size = 86400

create_trends_uint_part = function (num)
    local pname = part_to_tname(num)

    box.schema.create_space(pname, {if_not_exists = true})
    pcall(box.space[pname]:create_index('primary', {type = 'TREE', parts = {1, 'NUM', 2, 'NUM'}}))
end

insert_trends_uint = function (t)
    local itemid, clock = unpack(t)
    local pname = part_to_tname(clock_to_part(clock))
    
    box.space[pname]:replace(t)
end

clock_to_part = function (id)
    return math.floor(id / part_size)
end

part_to_tname = function (part)
    return trends_uint_tablename .. tostring(part)
end

select_from_trends_uint = function (itemid, from, to)
    ps = clock_to_part(from)
    pf = clock_to_part(to)

    ts = part_to_tname(ps)
    tf = part_to_tname(pf)

    local res = {}
    if ts == tf then
        local data = box.space[ts]:select({itemid}, {iterator = 'EQ'})
        for i = 1, #data do
            if (data[i][2] >= from) and (data[i][2] <= to) then table.insert(res, data[i]) end
        end
    else
        local data = box.space[ts]:select({itemid}, {iterator = 'EQ'})
        for i = 1, #data do
            if (data[i][2] >= from) then table.insert(res, data[i]) end
        end

        for i = clock_to_part(from) + 1, clock_to_part(to) - 1 do
            local tname = part_to_tname(i)
            local data = box.space[tname]:select({itemid}, {iterator = 'EQ'})
            for i = 1, #data do table.insert(res, data[i]) end
        end

        local data = box.space[tf]:select({itemid}, {iterator = 'EQ'})
        for i = 1, #data do
            if (data[i][2] <= to) then table.insert(res, data[i]) end
        end
    end
    return #res
end

select_from_trends_uint2 = function (itemid, from, to)
    ps = clock_to_part(from)
    pf = clock_to_part(to)

    ts = part_to_tname(ps)
    tf = part_to_tname(pf)

    local res = {}
    if ts == tf then
        local data = box.space[ts]:select({itemid}, {iterator = 'EQ'})
        for i = 1, #data do
            if (data[i][2] >= from) and (data[i][2] <= to) then table.insert(res, data[i]) end
        end
    else
        local data = box.space[ts]:select({itemid}, {iterator = 'EQ'})
        for i = 1, #data do
            if (data[i][2] >= from) then table.insert(res, data[i]) end
        end

        for i = clock_to_part(from) + 1, clock_to_part(to) - 1 do
            local tname = part_to_tname(i)
            local data = box.space[tname]:select({itemid}, {iterator = 'EQ'})
            for i = 1, #data do table.insert(res, data[i]) end
        end

        local data = box.space[tf]:select({itemid}, {iterator = 'EQ'})
        for i = 1, #data do
            if (data[i][2] <= to) then table.insert(res, data[i]) end
        end
    end
    return res
end
