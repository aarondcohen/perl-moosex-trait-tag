#!/usr/bin/env perl

use strict;
use warnings qw(all);

use FindBin;
use lib "$FindBin::Bin/../lib/";

use Test::Most tests => 10;

use_ok 'MooseX::Trait::Metadata';

{
	package Foo;
	use Moose;

	has bar => (
		traits => [qw/Metadata/],
		is => 'rw',
		default => 3573573,
	);
	has baz => (
		traits => [qw/Metadata/],
		is => 'ro',
		default => 94796,
	);
	has bam => (
		is => 'rw',
		default => 94745,
	);

	__PACKAGE__->meta->make_immutable;
}

my $foo = Foo->new();

cmp_set [$foo->metadata_attributes], [qw{bar baz}], 'metadata_attributes find all metadata attributes';
ok $foo->is_metadata_attribute('bar'), 'is_metadata_attribute identifies metadata attribute as metadata';
ok ! $foo->is_metadata_attribute('bam'), 'is_metadata_attribute identifies non-metadata attribute as not metadata';
ok ! $foo->is_metadata_attribute('none'), 'is_metadata_attribute identifies non-existent attribute as not metadata';
dies_ok { $foo->is_metadata_attribute() } 'is_metadata_attribute fails when not given an attribute';
lives_ok { $foo->update_metadata(bar => 235, baz => 789, bam => 'wont update', none => 'also wont update') } 'update_metadata handles all input';
is $foo->bar, 235, 'update_metadata modifies writable metadata attributes';
is $foo->baz, 94796, 'update_metadata does not modify read-only metadata attributes';
is $foo->bam, 94745, 'update_metadata does not modify non-metadata attributes';
