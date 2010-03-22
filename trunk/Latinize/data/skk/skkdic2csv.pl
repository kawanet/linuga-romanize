#!/usr/bin/perl

# このファイルは UTF-8 とする

use strict;
use utf8;
use IO::Zlib;
use IO::File;
use Encode;
main(@ARGV);

sub main {
	binmode( STDOUT, ":utf8" );
	binmode( STDERR, ":utf8" );
	my $hash  = {};
	my $score = 1;
	foreach my $file (@_) {
		if ( $file =~ /csv$/ ) {
			info("reading CSV file $file");
			$hash = read_csv_file( $file, $hash, $score++ );
		}
		else {
			info("reading SKK file $file");
			$hash = read_skk_dic( $file, $hash, $score++ );
		}
	}
	info( ( scalar keys %$hash ) . " keys found." );
	info("adding forward match entries.");
	add_forward_match($hash);
	info("sorting.");
	my $list = sort_surface($hash);
	info( ( scalar @$list ) . " keys." );
	output_csv($list);
}

sub add_forward_match {
	my $hash = shift;
	my $keys = [ keys %$hash ];
	foreach my $key (@$keys) {
		my $maxlen = length($key) - 1;
		foreach my $len ( 1 .. $maxlen ) {
			my $short = substr( $key, 0, $len );
			$hash->{$short} ||= {};
		}
	}
}

sub output_csv {
	my $list = shift;
	my $c    = 0;
	foreach my $line (@$list) {
		print $line->[0], ",", $line->[1], "\n";
		$c++;
		print STDERR "."     if ( $c % 2000 == 0 );
		print STDERR " $c\n" if ( $c % 100000 == 0 );
	}
	print STDERR " $c\n";
}

sub sort_surface {
	my $data = shift;
	my $out  = [];
	foreach my $surface ( sort keys %$data ) {
		my $word = $data->{$surface};
		my $keys = [ sort { $word->{$a} <=> $word->{$b} } keys %$word ];

		if ( 1 < scalar @$keys ) {    # enshort
			my $min = ( sort { $a <=> $b } values %$word )[0];
			$keys = [ grep { $word->{$_} == $min } @$keys ];
		}
		my $join = join( "/", @$keys );
		my $line = [ $surface, $join ];
		push( @$out, $line );
	}
	$out;
}

sub read_csv_file {
	my $file  = shift;
	my $data  = shift || {};
	my $score = shift || 0;
	my $fh;
	$fh = new IO::File( $file, "r" ) or die "$! - $file\n";
	my $utf8 = Encode::find_encoding('UTF-8');

	my $c = 0;
	while (<$fh>) {
		$_ = $utf8->decode($_);
		next if /^#/;
		chomp;

		my ( $kanji, $slash ) = split( /,/, $_, 2 );
		$data->{$kanji} ||= {};
		foreach my $kana ( split( "/", $slash ) ) {
			$data->{$kanji}->{$kana} = $score;
		}
		$c++;
		print STDERR "."     if ( $c % 2000 == 0 );
		print STDERR " $c\n" if ( $c % 100000 == 0 );
	}
	print STDERR " $c\n";
	close($fh);
	return $data;
}

sub read_skk_dic {
	my $file  = shift;
	my $data  = shift || {};
	my $score = shift || 0;
	my $fh;
	if ( $file =~ /\.gz$/ ) {
		$fh = new IO::Zlib( $file, "rb" ) or die "$! - $file\n";
	}
	else {
		$fh = new IO::File( $file, "r" ) or die "$! - $file\n";
	}
	my $eucjp = Encode::find_encoding('EUC-JP');

	# binmode( $fh, ":encoding(euc-jp)" );
	my $c = 0;
	while (<$fh>) {
		$_ = $eucjp->decode($_);
		next if /^;/;
		chomp;

		my ( $kana, $slash ) = split( /\s+/, $_, 2 );

		next unless ( $kana =~ /[\x{3000}-\x{9FFF}]/ );    # no japanese
		next if ( $kana =~ /[\#\>\(\)]/ );
		my $okuri = $1 if ( $kana =~ s/([a-z])$// );
		foreach my $kanji ( grep { $_ ne "" } split( "/", $slash ) ) {
			next if $kanji =~ /;.*\(\x{9023}\x{6fc1}\)/;                                              # 連濁
			next if $kanji =~ /\x{682a}\x{5f0f}\x{4f1a}\x{793e}.*;.*\[\x{4f01}\x{696d}\x{540d}\]/;    # 株式会社 企業名
			$kanji =~ s/;.*$//s;
			next if ( $kanji =~ /[\#\>\s\(\)]/ );
			next if ( $kanji =~ /^[\x00-\x{3040}\x{FFF0}-\x{FFFF}]+$/ );                              # latin - kigou only

			# next unless ( $kanji =~ /[\x{3041}-\x{3094}\x{30A1}-\x{30F4}\x{3400}-\x{9FFF}]/ );      # no kana&kanji
			next unless ( $kanji =~ /[\x{3400}-\x{9FFF}]/ );                                          # no kanji
			$kanji .= $okuri if $okuri;                                                               # okuri-ari
			$data->{$kanji} ||= {};
			next if exists $data->{$kanji}->{$kana};
			$data->{$kanji}->{$kana} = $score;
		}

		$c++;
		print STDERR "."     if ( $c % 2000 == 0 );
		print STDERR " $c\n" if ( $c % 100000 == 0 );
	}
	print STDERR " $c\n";
	close($fh);
	return $data;
}

sub is_japanese {
	return 1 if ( $_[0] =~ /^[\x{3400}-\x{9FFF}]+$/ );    # CJK unified
	return 1 if ( $_[0] =~ /^[\x{3041}-\x{3094}]+$/ );    # hiragana
	return 1 if ( $_[0] =~ /^[\x{30A1}-\x{30F4}]+$/ );    # katakana
	info( 'is_japanese:' . $_[0] . '=' . sprintf( " %4X  %4X  %4X ", unpack( 'W*' => $_[0] ) ) );
	undef;
}

sub info {
	print STDERR @_, "\n";
}
