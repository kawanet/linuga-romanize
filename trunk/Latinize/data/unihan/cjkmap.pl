#!/usr/bin/perl

use strict;
use warnings;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

require "zhmap.pl";
require "jamap.pl";
require "komap.pl";
main(@ARGV);

sub main {
	my $args = [@_];
	foreach my $cmd (@$args) {
		next if ( $cmd =~ /^-/ );
		no strict 'refs';
		&$cmd();
	}
}

sub taipei {
	my $data = {};
	$data->{read}    = zhmap::mandarin_read();
	$data->{variant} = zhmap::traditional_variant();
	zhutil::save_amf( $data, 'taipei.amf' );
}

sub beijing {
	my $data = {};
	$data->{read}    = zhmap::mandarin_read();
	$data->{variant} = zhmap::simplified_variant();
	zhutil::save_amf( $data, 'beijing.amf' );
}

sub hongkong {
	my $data = {};
	$data->{read}    = zhmap::cantonese_read();
	$data->{variant} = zhmap::traditional_variant();
	zhutil::save_amf( $data, 'hongkong.amf' );
}

sub tokyo {
	my $data = {};
	$data->{variant} = jamap::japanese_variant();
	zhutil::save_amf( $data, 'tokyo.amf' );
}

sub seoul {
	my $data = {};
	$data->{read} = komap::korean_hangul();
	zhutil::save_amf( $data, 'seoul.amf' );
}
