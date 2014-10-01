#!/usr/bin/env tarantool

box.cfg{
    listen=3301,
    slab_alloc_arena=12.0
}

box.schema.user.grant('guest','execute,read,write','universe') 

trends_uint_tablename = 'trends_uint'

box.schema.create_space(trends_uint_tablename, {if_not_exists = true})
if not box.space[trends_uint_tablename].index.primary then 
	box.space[trends_uint_tablename]:create_index('primary', {type = 'HASH', parts = {1, 'NUM', 2, 'NUM'}})
end
