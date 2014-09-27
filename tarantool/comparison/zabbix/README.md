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

Насколько оправданным будет использование tarantool для хранения этих данных, если мы хотим увеличить скорость, с которой они будут отдаваться
