-- MariaDB [test]>  select min(clock),max(clock) from trends_uint;
-- +------------+------------+
-- | min(clock) | max(clock) |
-- +------------+------------+
-- | 1103659200 | 1411196400 |
-- +------------+------------+

local from = 1103659200
local to = 1411196400
local part_size = part_size

for i = math.floor(from / part_size), math.floor(to / part_size) do
    create_trends_uint_part(i)
end

-- usage example:
--
-- tarantool
-- > box.cfg{}
-- > console = require('console')
-- > console.connect('localhost', 3301)
-- > dofile '/home/max/projects/mail.ru/tarantool/comparison/zabbix/init.lua'
