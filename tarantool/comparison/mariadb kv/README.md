## Описание вопроса

Сравним Tarantool с MariaDB, которая будет использоваться в качестве KV-хранилища на SSD-диске. 
В Tarantool будет использоваться HASH-индекс, для MariaDB кроме обычного подключения (протокол MySQL) будет использован плагин handlersocket

## Вывод

Используемый клиент для tarantool дал результаты, сравнимые с обычными запросами к mysql. 
При этом плагин handlersocket ускоряет решение примерно в 3 раза.
Однако тестовая функция на lua указывает на то, что клиент может быть сильно неоптимальным.

## Решение

### Подготовим хранилища

Конфиг tarantool: **myinstance2.lua**
Конфиг mariadb: **my.cnf** (обратим внимание, query cache отключен)

### Скачаем данные и зальем

#### tarantool

В шелле ОС сформируем набор команд:

    ./gen_load_data.sh

В консоли tarantool:

    dofile '/tmp/data/load_data.lua'

#### mariadb

Операции тривиальны, так что только набросаю, что нужно сделать. Не забываем дать нужные привилегии.

Схема базы данных тут:
    
    http://maxim-komar.ru/data/kv/mysql.sql

Скачанные файлы **/tmp/data/trends_uint.2014.0[4-9].txt.gz** распакуем и зальем с помощью

    LOAD DATA INFILE ... INTO TABLE trends_uint;

#### сравним количество записей там и там:

mysql:

    $ echo 'select count(*) from trends_uint' | mysql -N -utestuser -ptestpass test
    147099501

tarantool (в консоли tarantool):

    localhost:3301> box.space[trends_uint_tablename].index.primary:count()
    ---
    - 147099501
    ...

### Тесты

#### Сделаем много итераций по нескольким парам (itemid, clock) (смотри test.sh)

Результаты в табличном виде:

| solution | select time, us|
|----------|----------------|
| ./mysql.pl | 190 |
| ./mysql2.pl | 144 |
| ./mysql_hs.pl | 65 |
| ./mysql_hs2.pl | 69 |
| ./tnt.py | 199 |


#### Сделаем выборку по большому количество пар:

    $ wget -q http://maxim-komar.ru/data/kv/mytasks2.gz
    $ md5sum mytasks2.gz 
    da6937fbd1cbb62ac03f78909b22949f  mytasks2.gz
    $ gzip -d mytasks2.gz

собственно, сама выборка

    ./t2_mysql.pl mytasks2 > results/maria_ssd_vs_tarantool2.res
    ./tnt2.py mytasks2 >> results/maria_ssd_vs_tarantool2.res

результаты в табличном виде:

| solution | select time, us|
|----------|----------------|
| ./tnt2.py | 180 |
| mysql | 196 |
| mysql hs | 62 |
| mysql hs (rw) | 72 |
| mysql prep | 138 |

#### Сделаем выборку из шелла tarantool:

    localhost:3301> dofile '/home/max/projects/mail.ru/tarantool/comparison/mariadb kv/test_lua.lua'
    ---
    ...
    
    localhost:3301> test_lua()
    ---
    - 1 us
    ...


### профилирование решения на python:

    $ python -m cProfile -s time tnt2.py mytasks2 
    tnt2.py -   -   5290678 1258.7670   0.000238
    1961553310 function calls (1793286586 primitive calls) in 1267.561 seconds

    Ordered by: internal time

    ncalls  tottime  percall  cumtime  percall filename:lineno(function)
    111104258/15872037  151.605    0.000  289.386    0.000 fallback.py:510(_pack)
    119531002  134.163    0.000  157.254    0.000 fallback.py:239(_fb_read)
    83615837/15872037  106.018    0.000  382.605    0.000 fallback.py:382(_fb_unpack)
    10581359  105.633    0.000  105.633    0.000 {method 'recv' of '_socket.socket' objects}
    83615837   97.418    0.000  270.106    0.000 fallback.py:269(_read_header)
    370347581   61.008    0.000   61.008    0.000 {isinstance}
    ...

### ПО и железо

- tarantool 1.6.3-348-g4657acc
- mariadb 10.0.14-MariaDB
- ОС ubuntu 13.10 64 bit

- жесткий диск SSD Intel SSDSC2CW240A3

