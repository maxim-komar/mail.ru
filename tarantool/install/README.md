## Установка
Установка на ubuntu тривиальна и описана в [документации](http://tarantool.org/doc/master/user_guide.html#getting-started-binary):

    cd 
    wget http://tarantool.org/dist/public.key
    sudo apt-key add ./public.key
    release=`lsb_release -c -s`
    echo "deb http://tarantool.org/dist/master/ubuntu/ $release main" | \
    sudo tee -a /etc/apt/sources.list.d/tarantool.list
    echo "deb-src http://tarantool.org/dist/master/ubuntu/ $release main" | \
    sudo tee -a /etc/apt/sources.list.d/tarantool.list
    sudo apt-get update
    sudo apt-get install tarantool
    sudo apt-get install tarantool-client

## Запуск

    cd
    mkdir tarantool_sandbox
    cd tarantool_sandbox/
    /usr/bin/tarantool

## Пример работы (в командной строке tarantool)

    box.cfg{listen=3301}
    s = box.schema.create_space('space0')
    s:create_index('primary', {type = 'TREE', parts = {1, 'NUM', 2, 'NUM'}})

    s:insert({23348, 1409515200, 1, 84, 84, 84})
    s:insert({23348, 1409518800, 1, 84, 84, 84})
    s:insert({23348, 1409522400, 1, 84, 84, 84})
    s:insert({23348, 1409526000, 1, 84, 84, 84})
    s:insert({23356, 1409515200, 105, 20943307, 20945124, 20946847})
    s:insert({23356, 1409518800, 117, 20946877, 20948646, 20950447})
    s:insert({23356, 1409522400, 118, 20950477, 20952261, 20954047})
    s:insert({23356, 1409526000, 120, 20954077, 20955862, 20957647})
    s:insert({39213, 1409515200, 55, 41855, 49118, 60819})
    s:insert({39213, 1409518800, 60, 22224, 32672, 48228})
    s:insert({39213, 1409522400, 60, 17775, 23100, 34519})
    s:insert({39213, 1409526000, 60, 13374, 17136, 24170})

    s.index.primary:count()
    s:select({39213})
    s:select({iterator = 'ALL'})
    s:select()

