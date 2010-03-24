# Makefile

scripts = zhmap.pl cjkutil.pl cjkmap.pl jamap.pl
unihan_files = Unihan_Readings.txt Unihan_Variants.txt Unihan_OtherMappings.txt
zh_amf = taipei.amf beijing.amf hongkong.amf
ja_amf = tokyo.amf
ko_amf = seoul.amf
trad2jnew_csv = trad2jnew.csv

all: $(zh_amf) $(ja_amf) $(ko_amf)

clean:
	/bin/rm -f $(zh_amf) $(ja_amf) $(ko_amf) Unihan.zip $(unihan_files)

Unihan.zip:
	wget -nc http://www.unicode.org/Public/UNIDATA/Unihan.zip

Unihan_Readings.txt: Unihan.zip
	unzip -u $< $@
	touch $@

Unihan_Variants.txt: Unihan.zip
	unzip -u $< $@
	touch $@

Unihan_OtherMappings.txt: Unihan.zip
	unzip -u $< $@
	touch $@

taipei.amf: $(scripts) $(unihan_files) $(trad2jnew_csv)
	perl cjkmap.pl taipei

beijing.amf: $(scripts) $(unihan_files) $(trad2jnew_csv)
	perl cjkmap.pl beijing

hongkong.amf: $(scripts) $(unihan_files) $(trad2jnew_csv)
	perl cjkmap.pl hongkong

tokyo.amf: $(scripts) $(unihan_files) $(trad2jnew_csv)
	perl cjkmap.pl tokyo
	
seoul.amf: $(scripts) $(unihan_files)
	perl cjkmap.pl seoul
