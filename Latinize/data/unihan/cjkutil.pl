package zhutil;

use strict;
use warnings;
use utf8;
use open IO => ":utf8";
use Data::AMF;
use File::Temp;

our $BASEDIR = "./";
my $MAPFILE   = "Unihan_OtherMappings.txt";
my $READFILE  = "Unihan_Readings.txt";
my $VARIFILE  = "Unihan_Variants.txt";
my $TRAD2JNEW = "trad2jnew.csv";

my $TONEMAP = {
	a          => [ "a",        "\x{0101}", "\x{00E1}", "\x{01CE}", "\x{00E0}" ],
	e          => [ "e",        "\x{0113}", "\x{00E9}", "\x{011B}", "\x{00E8}" ],
	i          => [ "i",        "\x{012B}", "\x{00ED}", "\x{01D0}", "\x{00EC}" ],
	o          => [ "o",        "\x{014D}", "\x{00F3}", "\x{01D2}", "\x{00F2}" ],
	u          => [ "u",        "\x{016B}", "\x{00FA}", "\x{01D4}", "\x{00F9}" ],
	"\x{00fc}" => [ "\x{00fc}", "\x{01d6}", "\x{01d8}", "\x{01da}", "\x{01dc}" ],    # "u:"
};

my $MAPCACHE;
my $RAEDCACHE;
my $FILECACHE;

sub read_trad2jnew {
	print STDERR "read_file: ", $TRAD2JNEW, "\n";
	open( IN, $TRAD2JNEW ) or die "$! - $TRAD2JNEW\n";
	binmode( IN, ":encoding(utf-8)" );
	my $map = {};
	while (<IN>) {
		next if /^#/;
		chomp;
		my ( $src, $dst ) = split( /,/, $_, 2 ) or next;
		next if ( length($src) != 1 );
		next if ( length($dst) != 1 );
		next if ( $src eq $dst );
		$map->{$src} = $dst;
	}
	close(IN);
	$map;
}

sub save_amf {
	my $itable = shift;
	my $file   = shift;
	my $amf    = Data::AMF->new( version => 3 );
	print STDERR "save_amf: serializing\n";
	my $otable = {};
	foreach my $name ( keys %$itable ) {
		my $hash = $itable->{$name};
		my $list = [%$hash];
		foreach my $val (@$list) {
			utf8::encode($val);
		}
		$otable->{$name} = {@$list};
	}
	my $bin = $amf->serialize($otable);
	print STDERR "save_amf: ", ( length $bin ), " bytes.\n";
	my $temp = File::Temp->new( UNLINK => 0 );
	print $temp $bin;
	$temp->close();
	print STDERR "save_amf: ", $file, "\n";
	rename $temp, $file;
}

sub save_csv {
	my $map  = shift;
	my $file = shift;
	open( CSV, "> $file" ) or die "$! - $file\n";
	my $keys = [ sort keys %$map ];
	print STDERR "save_csv: ", $file, " (", ( scalar @$keys ), " keys)\n";
	foreach my $key (@$keys) {
		my $val = $map->{$key};
		my $str = $key . "," . $val . "\n";
		utf8::decode($str);
		print CSV $str;
	}
	close(CSV);
}

sub read_mappings {
	$MAPCACHE ||= &read_file( $BASEDIR . $MAPFILE );
}

sub read_readings {
	$RAEDCACHE ||= &read_file( $BASEDIR . $READFILE );
}

sub read_variants {
	$FILECACHE ||= &read_file( $BASEDIR . $VARIFILE );
}

sub read_file {
	my $file = shift;
	print STDERR "read_file: ", $file, "\n";
	open( IN, $file ) or die "$! - $file\n";
	my $map = {};
	while (<IN>) {
		next if /^#/;
		chomp;
		my ( $uni, $key, $val ) = split( /\t/, $_, 3 ) or next;
		my $hex = ( $uni =~ /^U\+(\w+)$/ )[0] or next;
		my $code = hex($hex);
		next if ( $code > 0xFFFF );
		my $chr = chr($code);
		$map->{$key} ||= {};
		$map->{$key}->{$chr} = $val;
	}
	close(IN);
	$map;
}

sub tone {
	my $roman = shift;
	$roman =~ s/(a)([a-z:]*)([1-4])$/$TONEMAP->{$1}->[$3].$2/ies;
	$roman =~ s/([eo])([a-z:]*)([1-4])$/$TONEMAP->{$1}->[$3].$2/ies;
	$roman =~ s/(i)(u)([1-4])$/$1.$TONEMAP->{$2}->[$3]/ies;
	$roman =~ s/(u)(i)([1-4])$/$1.$TONEMAP->{$2}->[$3]/ies;
	$roman =~ s/(u:|\x{00DC})/\x{00fc}/igs;
	$roman =~ s/([ui\x{00fc}])([a-z:]*)([1-4])$/$TONEMAP->{$1}->[$3].$2/ies;
	$roman =~ s/[1-5]$//s;                                                     # incl. "ng1" = "ㄥ"
	$roman;
}

sub code2str {
	my $uni  = shift;
	my $hex  = ( $uni =~ /^U\+(\w+)/ )[0] or return;
	my $code = hex($hex);
	return if ( $code > 0xFFFF );
	chr($code);
}

1;
