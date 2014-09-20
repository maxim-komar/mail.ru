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

