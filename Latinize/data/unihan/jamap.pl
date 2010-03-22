#!/usr/bin/perl

package jamap;
use strict;
use warnings;
use utf8;
require "cjkutil.pl";

# Unihan_Variants.txt
# U+380F	kSimplifiedVariant	U+37C6
# U+3469	kTraditionalVariant	U+5138
sub japanese_variant {
	my $varimap = zhutil::read_variants();
	my $mapmap  = zhutil::read_mappings();

	my $jis0map  = $mapmap->{kJis0}                or die "kJis0 not found.\n";
	my $tradvari = $varimap->{kTraditionalVariant} or die "kTraditionalVariant not found.\n";
	my $simpvari = $varimap->{kSimplifiedVariant}  or die "kSimplifiedVariant not found.\n";

	my $map = zhutil::read_trad2jnew();
	foreach my $varihash ( $tradvari, $simpvari ) {
		foreach my $src ( sort keys %$varihash ) {
			next if $jis0map->{$src};
			my $uni = $varihash->{$src};
			my $dst = zhutil::code2str($uni) or next;
			$dst = $map->{$dst} if exists $map->{$dst};
			next if ( $src eq $dst );
			next unless $jis0map->{$dst};
			$map->{$src} = $dst;
		}
	}
	my $keynum = scalar keys %$map;
	print STDERR "japanese_variant: ", $keynum, " keys.\n";
	$map;
}
