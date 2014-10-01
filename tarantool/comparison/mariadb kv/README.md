## Описание вопроса

Сравним Tarantool с MariaDB, которая будет использоваться в качестве KV-хранилища на SSD-диске. 
В Tarantool будет использоваться HASH-индекс, для MariaDB кроме обычного подключения (протокол MySQL) будет использован плагин handlersocket

## Вывод

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

