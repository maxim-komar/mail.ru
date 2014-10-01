#!/usr/bin/python
import sys
import time
from tarantool import Connection
c = Connection("127.0.0.1", 3301)

filename = sys.argv[1]
with open(filename) as f:
    content = f.readlines()

data = [ [ int(x) for x in line.split() ] for line in content ]

st = time.time()
for x in data:
    c.select('trends_uint', x)
ft = time.time()

print "%s\t-\t-\t%d\t%.4f\t%.6f" % (sys.argv[0], len(data), (ft - st), (ft - st) / len(data))
