#!/usr/bin/python
import sys
from tarantool import Connection

c = Connection("127.0.0.1", 3301)

for line in sys.stdin:
    fields = line.rstrip().split('\t')
    num_fields = [int(x) for x in fields]
    c.insert("test1", tuple(num_fields))
