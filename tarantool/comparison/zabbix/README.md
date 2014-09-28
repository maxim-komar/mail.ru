## Краткое описание задачи

[Zabbix](http://www.zabbix.com) - система мониторинга с открытым кодом.

Для хранения данных могут использоваться такие СУБД, как MySQL, PostgreSQL, Oracle.

Некоторые данные хорошо ложатся на модель key-value. Возьмем в качестве примера таблицу [trends_uint](http://maxim-komar.ru/data/kv/mysql.sql), из которой мы брали содержимое для наполнения tarantool в [секции конфигурации клиента](https://github.com/maxim-komar/mail.ru/tree/master/tarantool/client):

    CREATE TABLE `trends_uint` (
        `itemid` bigint(20) unsigned NOT NULL,
        `clock` int(11) NOT NULL DEFAULT '0',
        `num` int(11) NOT NULL DEFAULT '0',
        `value_min` bigint(20) unsigned NOT NULL DEFAULT '0',
        `value_avg` bigint(20) unsigned NOT NULL DEFAULT '0',
        `value_max` bigint(20) unsigned NOT NULL DEFAULT '0',
        PRIMARY KEY (`itemid`,`clock`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    /*!50100 PARTITION BY RANGE ( clock)
    (PARTITION p2014_04 VALUES LESS THAN (1398888000) ENGINE = InnoDB,
    PARTITION p2014_05 VALUES LESS THAN (1401566400) ENGINE = InnoDB,
    PARTITION p2014_06 VALUES LESS THAN (1404158400) ENGINE = InnoDB,
    PARTITION p2014_07 VALUES LESS THAN (1406836800) ENGINE = InnoDB,
    PARTITION p2014_08 VALUES LESS THAN (1409515200) ENGINE = InnoDB,
    PARTITION p2014_09 VALUES LESS THAN (1412107200) ENGINE = InnoDB) */

В данной таблице хранятся агрегированные значения за час для каждого мониторящегося итема (среднее, максимальное, минимальное) с целочисленным типом. Основной объем запросов к этой таблице составляет чтение (к примеру, мы хотим нарисовать график по трафику на порту, веб-интерфейс zabbix за данными пойдет в эту табличку)

### Вопрос

Насколько оправданным будет использование tarantool для хранения этих данных, если мы хотим увеличить скорость, с которой они будут отдаваться (в сравнении с MySQL).

## Решение

### Запустим tarantool и соединимся

запустим tarantool с конфигурационным файлом **myinstance.lua** и соединимся

    tarantool
    -- > box.cfg{}
    -- > console = require('console')
    -- > console.connect('localhost', 3301)


### Как мы будем хранить данные в tarantool

Я не нашел способа, чтобы по primary key сделать запрос вроде:

    select * from trends_uint where itemid=? and clock>=? and clock<=?

В tarantool мы можем сделать выборку select с условием **>=**, но, тогда могут попасть итемы с другим itemid. Посмотрим на живом примере:

    localhost:3301> box.space.trends_uint16160:select({23595, 1396303200}, {iterator = 'GE', limit = 4})
    ---
    - [23595, 1396303200, 59, 1, 1, 1]
    - [23595, 1396306800, 58, 1, 1, 1]
    - [23666, 1396296000, 60, 0, 0, 0]
    - [23666, 1396299600, 60, 0, 0, 0]
    ...

Поэтому я решил делать выборку по условию **EQ** для itemid, а необходимый диапазон значений для clock отфильтровать скриптом. Чтобы данных было не слишком много, я решил разбить таблицу на куски (партиционирование) и делать выборку только из соответствующих кусков.

**Я знаю, что в trends_uint хранятся агрегированные данные за час, выборка чаще всего осуществляется раз в сутки, делить на части я буду по полю clock с шагом в сутки!!!**

Для нашего конкретного примера произведем инициализацию таблицы **trends_uint** (мы сейчас в консоли tarantool):

    dofile '/home/max/projects/mail.ru/tarantool/comparison/zabbix/init.lua'


### Зальем данные в tarantool

Данные для этого теста выбраны из MySQL командой **SELECT ... INTO OUTFILE**.
Я подготовил небольшой скрипт, для того, чтобы эти текстовые (tsv) данные преобразовать в набор команд, которые можно будет выполнить в консоли tarantool. Выполним в шелле операционной системы:

    ./gen_load_data.sh

Скрипт выведет, какую команду нужно выполнить в консоли tarantool. На данный момент это:

    dofile '/tmp/data/load_data.lua'

Некоторые ньюансы:

    - сначала я хотел загрузить данные в память и вставить их в консоли tarantool, но **not enough memory**, пришлось делить на мелкие файлы (отсюда split)
    - split я сначала делал с размером 1000000, но **constant table overflow**, поэтому опустил до 65000
    - понадобится в сумме до 25GB свободного места на диске

### Проверим, что все данные на месте

Проверим количество строк в исходных файлах (смотри файл **gen_load_data.sh**):

    zcat /tmp/data/trends_uint.2014.0* | wc -l
    147099501

И сколько вставлено в сумме в таблицы в tarantool (в консоли tarantool):

    localhost:3301> dofile '/home/max/projects/mail.ru/tarantool/comparison/zabbix/check.lua'
    ---
    - 147099501
    ...

