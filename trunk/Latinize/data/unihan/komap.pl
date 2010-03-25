#!/usr/bin/perl

package komap;
use strict;
use warnings;
use utf8;
require "cjkutil.pl";

# Unihan_Readings.txt
# U+3401  kMandarin       TIAN3 TIAN4
sub korean_hangul {
	my $readmap  = zhutil::read_readings();
	my $kohangul = $readmap->{kHangul};

	my $map = {};
	foreach my $src ( sort keys %$kohangul ) {
		my $dst = lc( $kohangul->{$src} );
		$dst =~ s/\s+/\//g;
		$map->{$src} = $dst;
	}
	my $keynum = scalar keys %$map;
	print STDERR "korean_hangul: ", $keynum, " keys.\n";
	$map;
}

