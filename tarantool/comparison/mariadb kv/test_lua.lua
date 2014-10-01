
test_lua = function ()
    local s = os.time()
    local count = 1000000
    for i = 1, count do
		box.space[trends_uint_tablename]:select({23271,1406012400})
		box.space[trends_uint_tablename]:select({23271,1406098800})
		box.space[trends_uint_tablename]:select({23271,1405926000})
		box.space[trends_uint_tablename]:select({23271,1406012400})
		box.space[trends_uint_tablename]:select({23271,1405839600})

		box.space[trends_uint_tablename]:select({23271,1405926000})
		box.space[trends_uint_tablename]:select({23271,1405753200})
		box.space[trends_uint_tablename]:select({23271,1405839600})
		box.space[trends_uint_tablename]:select({23271,1405666800})
		box.space[trends_uint_tablename]:select({23271,1405753200})
    end
    return string.format("%d us", math.floor((os.time() - s) * 1000000 / (count * 10)))
end
