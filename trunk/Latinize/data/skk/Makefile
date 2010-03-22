# Makefile

DICT = SKK-JISYO.ML.gz SKK-JISYO.L.gz SKK-JISYO.station.gz SKK-JISYO.geo.gz SKK-JISYO.propernoun.gz SKK-JISYO.jinmei.gz

all: japanese.sqlite

clean:
	/bin/rm -f $(DICT) japanese.sqlite japanese.csv

dist: all
	sh dist.sh

japanese.sqlite: japanese.csv japanese.sql
	sqlite3 -init japanese.sql $@ ".quit"

japanese.csv: skkdic2csv.pl $(DICT) addbyhand.csv
	LC_ALL=C perl skkdic2csv.pl addbyhand.csv $(DICT) > $@.tmp
	/bin/mv -f $@.tmp $@

SKK-JISYO.M.gz:
	wget -O SKK-JISYO.M.gz http://openlab.jp/skk/skk/dic/SKK-JISYO.M.gz
SKK-JISYO.ML.gz:
	wget -O SKK-JISYO.ML.gz http://openlab.jp/skk/skk/dic/SKK-JISYO.ML.gz
SKK-JISYO.L.gz:
	wget -O SKK-JISYO.L.gz http://openlab.jp/skk/skk/dic/SKK-JISYO.L.gz
SKK-JISYO.station.gz:
	wget -O SKK-JISYO.station.gz http://openlab.jp/skk/skk/dic/SKK-JISYO.station.gz
SKK-JISYO.geo.gz:
	wget -O SKK-JISYO.geo.gz http://openlab.jp/skk/skk/dic/SKK-JISYO.geo.gz
SKK-JISYO.propernoun.gz:
	wget -O SKK-JISYO.propernoun.gz http://openlab.jp/skk/skk/dic/SKK-JISYO.propernoun.gz
SKK-JISYO.jinmei.gz:
	wget -O SKK-JISYO.jinmei.gz http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei.gz
