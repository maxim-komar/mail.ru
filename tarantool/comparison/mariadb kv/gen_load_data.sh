#!/bin/sh

DIR=/tmp/data
rm -rf $DIR
mkdir -p $DIR
cd $DIR

wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.04.txt.gz -O "$DIR/trends_uint.2014.04.txt.gz"
wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.05.txt.gz -O "$DIR/trends_uint.2014.05.txt.gz"
wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.06.txt.gz -O "$DIR/trends_uint.2014.06.txt.gz"
wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.07.txt.gz -O "$DIR/trends_uint.2014.07.txt.gz"
wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.08.txt.gz -O "$DIR/trends_uint.2014.08.txt.gz"
wget -q http://maxim-komar.ru/data/kv/trends_uint.2014.09.txt.gz -O "$DIR/trends_uint.2014.09.txt.gz"

md5sum trends_uint.2014.04.txt.gz
# ae3ba45203232ca6c96536b9dfea3f42  trends_uint.2014.04.txt.gz
md5sum trends_uint.2014.05.txt.gz
# c92f7cbc4aadd64de7a7c07a344f7cd8  trends_uint.2014.05.txt.gz
md5sum trends_uint.2014.06.txt.gz
# 02c3e41ea3ecc9f6a7418948389940cf  trends_uint.2014.06.txt.gz
md5sum trends_uint.2014.07.txt.gz
# 65f262d3dfab882a5c569163fe11442a  trends_uint.2014.07.txt.gz
md5sum trends_uint.2014.08.txt.gz
# a6607d6d72d9ce76204cd43a73e4851e  trends_uint.2014.08.txt.gz
md5sum trends_uint.2014.09.txt.gz
# d84de534c74471b9d490f3eed2e51bb8  trends_uint.2014.09.txt.gz

FILE=load_data.lua
zcat trends_uint.2014.0[4-9].txt.gz | perl -ne 'chomp; @a = split /\t/; printf "box.space[trends_uint_tablename]:insert{%s}\n", join(",", @a)' > $FILE

split -l 60000 $FILE

for i in `find /tmp/data/ -name 'x*'`; do echo "dofile '$i'"; done > $FILE
echo "dofile '$DIR/$FILE'"
