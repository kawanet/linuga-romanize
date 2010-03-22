#!/usr/bin/perl

package zhmap;
use strict;
use warnings;
use utf8;
require "cjkutil.pl";

# Unihan_Readings.txt
# U+3401  kMandarin       TIAN3 TIAN4
sub cantonese_read {
	my $readmap  = zhutil::read_readings();
	my $cantread = $readmap->{kCantonese};

	my $map = {};
	foreach my $src ( sort keys %$cantread ) {
		my $dst = lc( $cantread->{$src} );
		$dst =~ s/\s+/\//g;
		$map->{$src} = $dst;
	}
	my $keynum = scalar keys %$map;
	print STDERR "cantonese_read: ", $keynum, " keys.\n";
	$map;
}

# Unihan_Readings.txt
# U+3400  kCantonese      jau1
sub mandarin_read {
	my $readmap  = zhutil::read_readings();
	my $mandread = $readmap->{kMandarin};

	my $map = {};
	foreach my $src ( sort keys %$mandread ) {
		my $dst  = lc( $mandread->{$src} );
		my $list = [];
		foreach my $roman ( split( /\s/, $dst ) ) {
			next if ( $roman eq "" );
			my $pinyin = zhutil::tone($roman);
			push( @$list, $pinyin );
		}
		next unless scalar @$list;
		$map->{$src} = join( "/" => @$list );
	}
	my $keynum = scalar keys %$map;
	print STDERR "mandarin_read: ", $keynum, " keys.\n";
	$map;
}

# Unihan_Variants.txt
# U+3469	kTraditionalVariant	U+5138
sub traditional_variant {
	my $varimap  = zhutil::read_variants();
	my $tradvari = $varimap->{kTraditionalVariant} or die "kTraditionalVariant not found.\n";
	my $zvari    = $varimap->{kZVariant} or die "kZVariant not found.\n";
	my $encmap   = zhutil::read_mappings();
	my $big5enc  = $encmap->{kBigFive} or die "kBigFive not found.\n";

	my $map = {};
	foreach my $simp ( sort keys %$tradvari ) {
		next if $big5enc->{$simp};
		my $uni = $tradvari->{$simp};
		my $trad = zhutil::code2str($uni) or next;
		next if ( $simp eq $trad );
		$map->{$simp} = $trad;
	}

	my $jisenc = $encmap->{kJis0} or die "kJis0 not found.\n";
	my $trad2jnew = zhutil::read_trad2jnew();
	foreach my $trad ( sort keys %$trad2jnew ) {
		my $jnew = $trad2jnew->{$trad};
		next if $map->{$jnew};
		next if $big5enc->{$jnew};
		next unless $big5enc->{$trad};
		next if ( $jnew eq $trad );
		$map->{$jnew} = $trad;
	}

	my $keynum = scalar keys %$map;
	print STDERR "traditional_variant : ", $keynum, " keys . \n ";
	$map;
}

# Unihan_Variants.txt
# U+380F	kSimplifiedVariant	U+37C6
sub simplified_variant {
	my $varimap  = zhutil::read_variants();
	my $simpvari = $varimap->{kSimplifiedVariant} or die "kSimplifiedVariant not found . \n ";
	my $encmap   = zhutil::read_mappings();
	my $gb0enc   = $encmap->{kGB0} or die "kGB0 not found . \n ";

	my $map = {};
	foreach my $trad ( sort keys %$simpvari ) {
		next if $gb0enc->{$trad};
		my $uni = $simpvari->{$trad};
		my $simp = zhutil::code2str($uni) or next;
		next if ( $trad eq $simp );
		$map->{$trad} = $simp;
	}

	my $jisenc = $encmap->{kJis0} or die "kJis0 not found.\n";
	my $trad2jnew = zhutil::read_trad2jnew();
	foreach my $trad ( sort keys %$trad2jnew ) {
		next unless exists $map->{$trad};
		my $simp = $map->{$trad} or next;
		my $jnew = $trad2jnew->{$trad};
		next if $map->{$jnew};
		next if $gb0enc->{$jnew};
		next unless $gb0enc->{$simp};
		next if ( $jnew eq $simp );
		$map->{$jnew} = $simp;
	}

	my $keynum = scalar keys %$map;
	print STDERR "simplified_variant : ", $keynum, " keys . \n ";
	$map;
}

