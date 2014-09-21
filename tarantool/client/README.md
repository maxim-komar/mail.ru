## Клиенты

Показаны простые примеры работы с tarantool при помощи разных языков.
Предполагается использование сервера tarantool на 127.0.0.1:3301

## Данные

    wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.04.txt.gz
    wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.05.txt.gz
    wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.06.txt.gz
    wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.07.txt.gz
    wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.08.txt.gz
    wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.09.txt.gz
    

    $ md5sum trends_uint.2014.04.txt.gz 
    ae3ba45203232ca6c96536b9dfea3f42  trends_uint.2014.04.txt.gz
    $ md5sum trends_uint.2014.05.txt.gz 
    c92f7cbc4aadd64de7a7c07a344f7cd8  trends_uint.2014.05.txt.gz
    $ md5sum trends_uint.2014.06.txt.gz 
    02c3e41ea3ecc9f6a7418948389940cf  trends_uint.2014.06.txt.gz
    $ md5sum trends_uint.2014.07.txt.gz 
    65f262d3dfab882a5c569163fe11442a  trends_uint.2014.07.txt.gz
    $ md5sum trends_uint.2014.08.txt.gz 
    a6607d6d72d9ce76204cd43a73e4851e  trends_uint.2014.08.txt.gz
    $ md5sum trends_uint.2014.09.txt.gz 
    d84de534c74471b9d490f3eed2e51bb8  trends_uint.2014.09.txt.gz

    $ zcat trends_uint.2014.04.txt.gz | wc -l
    21903167
    $ zcat trends_uint.2014.05.txt.gz | wc -l
    27202080
    $ zcat trends_uint.2014.06.txt.gz | wc -l
    27221400
    $ zcat trends_uint.2014.07.txt.gz | wc -l
    27977314
    $ zcat trends_uint.2014.08.txt.gz | wc -l
    26155160
    $ zcat trends_uint.2014.09.txt.gz | wc -l
    16640380


## Запуск tarantool
    
    rm -rf /tmp/tarantool_sandbox
    mkdir /tmp/tarantool_sandbox
    tarantool


    box.cfg{listen=3301, slab_alloc_arena=24.0, work_dir='/tmp/tarantool_sandbox'}
    s = box.schema.create_space('test1')
    s:create_index('primary', {type = 'TREE', parts = {1, 'NUM', 2, 'NUM'}})
    box.schema.user.grant('guest', 'read', 'space', '_space')
    box.schema.user.grant('guest', 'read,write', 'space', 'test1')

## Кормим паука

    date
    zcat trends_uint.2014.04.txt.gz | python/example.py &
    zcat trends_uint.2014.05.txt.gz | python/example.py &
    zcat trends_uint.2014.06.txt.gz | python/example.py &
    zcat trends_uint.2014.07.txt.gz | python/example.py &
    zcat trends_uint.2014.08.txt.gz | python/example.py &
    zcat trends_uint.2014.09.txt.gz | python/example.py &

после этого завершаем работу tarantool и запускаем его с тем же конфигом (посмотрим на процесс восстановления данных с диска):

    date
    tarantool


    box.cfg{listen=3301, slab_alloc_arena=24.0, work_dir='/tmp/tarantool_sandbox'}

## Цель

- Сейчас нужно посмотреть объем занимаемых данных (в нашем случае > 147m записей).
- Также оценить работу с tarantool на разных языках

## Результаты

Вывод команды top после скармливания всех данных:

     PID   USER      PR   NI  VIRT   RES  SHR  S   %CPU %MEM    TIME+    COMMAND
     30655 max       20   0   34,1g  18g  8,8g S   0,0  59,2    60:30.07 tarantool

Размер рабочей директории после скармливания всех данных:

    $ du -sm /tmp/tarantool_sandbox/
    8915    /tmp/tarantool_sandbox/

Количество записей в test1:

    tarantool> s.index.primary:count()
    ---
    - 147099501
    ...

После перезапуска tarantool:

    tarantool> box.space.test1.index.primary:count()
    ---
    - 147099501
    ...


## Графические результаты

- первый всплеск с 23.18 до 01.12: вставка данных скриптом
- второй всплекс с 6.55 до 6.57: восстановление данных после перезапуска tarantool

![cpu utilization](https://raw.githubusercontent.com/maxim-komar/mail.ru/master/images/client.cpu.util.png)
![disk IO](https://raw.githubusercontent.com/maxim-komar/mail.ru/master/images/client.sda1.io.png)

