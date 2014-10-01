#!/bin/sh
ITER=1000000

myfunc () {
    ./mysql.pl $1 $2 $ITER
    ./mysql2.pl $1 $2 $ITER
    ./mysql_hs.pl $1 $2 $ITER
    ./mysql_hs2.pl $1 $2 $ITER
    ./tnt.py $1 $2 $ITER
}

myfunc 23348 1409515200
echo
myfunc 218562 1411160400
echo
myfunc 145467 1399057200
