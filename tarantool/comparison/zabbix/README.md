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

Поэтому я решил делать выборку по условию **EQ** для itemid, а необходимый диапазон значений для clock отфильтровать скриптом. Чтобы данных было не слишком много, я решил разбить таблицу на куски (партиционирование) и делать выборку только из соответствующих кусков (то есть выбираем из нужных подтаблиц x:select({itemid}, {iterator = 'EQ'}), объединяем результат, фильтруем по полю clock >=, <=)

**Я знаю, что в trends_uint хранятся агрегированные данные за час, выборка осуществляется за период не меньше 24 часов, делить на части я буду по полю clock с шагом в сутки!!!**

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

### Набор задач для тестов

Я сгенерировал набор задач для тестов, скачать можно так:

    wget -q http://maxim-komar.ru/data/kv/mytasks.tar.gz

Проверим и распакуем:

    $ md5sum mytasks.tar.gz 
    8bdb8d293bc80d8c623496742ddf075b  mytasks.tar.gz
    $ tar zxfp mytasks.tar.gz

Архив представляет собой набор файлов в tsv-формате, столбцы означают:

1. количество записей, которое должно вернуться по запросу: itemid = param1 && clock >= param2 && clock <= param3
2. itemid (param1 в запросе выше)
3. начало временного промежутка (param2 в запросе выше)
4. конец временного промежутка (param3 в запросе выше)

Первое поле необходимо нам, чтобы проверить, что функция, которая будет делать выборку из MySQL и Tarantool, возвращает результат, похожий на правду.

### тесты (один поток)

#### mysql

    for i in `ls mytasks.[0-9]* `; do ./mysql.pl $i; done > results/mysql.res

#### tarantool

    for i in `ls mytasks.[0-9]* `; do ./tnt.py $i; done > results/tarantool.tree.py.res

### сравнение результатов

    $ ./aggregate_results.pl results/tarantool.tree.py.res 
    1351 - 2700 0.002918
    51 - 200    0.000696
    701 - 1350  0.004274
    20 - 50 0.000375
    201 - 350   0.000990
    351 - 700   0.001562

    $ ./aggregate_results.pl results/mysql.res 
    1351 - 2700 0.007387
    51 - 200    0.000864
    701 - 1350  0.004408
    20 - 50 0.000393
    201 - 350   0.001508
    351 - 700   0.002459

В табличном виде (в столбцах фигурирует объем получившейся выборки)

| Решение     | [20, 50], мс | [51, 200], мс | [201, 350], мс | [351, 700], мс | [701, 1350], мс | [1351, 2700], мс |
|-------------|--------------|---------------|----------------|----------------|-----------------|------------------|
| Mysql       | 0.000393     | 0.000864      | 0.001508       | 0.002459       | 0.004408        | 0.007387         |
| Tarantool   | 0.000375     | 0.000696      | 0.000990       | 0.001562       | 0.004274        | 0.002918         |

Возможно, хороший результат на большой выборке у Tarantool достигается за счет того, что передается в **select_from_trends_uint** не список кортежей, а их количество. Немного изменим скрипты.
