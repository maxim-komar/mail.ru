#!/usr/bin/python
import sys
import time
from tarantool import Connection
c = Connection("127.0.0.1", 3301)

itemid = int(sys.argv[1])
clock = int(sys.argv[2])
iterations = int(sys.argv[3])

st = time.time()
for i in range(iterations):
    c.select('trends_uint', [itemid, clock])
ft = time.time()

print "%s\t%d\t%d\t%d\t%.4f\t%.6f" % (sys.argv[0], itemid, clock, iterations, (ft - st), (ft - st) / iterations)
