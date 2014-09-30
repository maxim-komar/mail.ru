#!/usr/bin/python
import sys
import time
from tarantool import Connection
c = Connection("127.0.0.1", 3301)

def conv(line):
    return [ int(x) for x in line.split() ]

filename = sys.argv[1]
with open(filename) as f:
    content = f.readlines()
data = [ conv(line) for line in content ]

if len(data) == 0:
    sys.exit(0)

def check_res(x):
    res = c.call('select_from_trends_uint', [x[1], x[2], x[3]])
    rval = list(res)[0][0]
    return rval == x[0]

start = time.time()
for x in data:
    if not check_res(x):
        raise Exception(x)

finish = time.time()

print "%s\t%d\t%.2f\t%.6f" % (filename, len(data), finish - start, (finish - start) / len(data))
