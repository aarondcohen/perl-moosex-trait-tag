#!/usr/bin/env perl

use strict;
use warnings qw(all);

use FindBin;
use lib "$FindBin::Bin/../lib/";

use Set::Functional;
use Test::Most tests => 12;

use_ok 'MooseX::Trait::Label';

{
	package Foo;
	use Moose;

	use MooseX::Trait::Label qw{metadata tag};

	has bar => (
		traits => [qw/metadata/],
		is => 'rw',
		default => 3573573,
	);
	has baz => (
		traits => [qw/metadata tag/],
		is => 'ro',
		default => 94796,
	);
	has bam => (
		is => 'rw',
		default => 94745,
	);

	__PACKAGE__->meta->make_immutable;
}
{
	package Bare;
	use Moose;

	use MooseX::Trait::Label qw{};

	has bar => (
		is => 'rw',
		default => 3573573,
	);

	__PACKAGE__->meta->make_immutable;
}

my $foo = Foo->new();
my $bare = Bare->new();

throws_ok { $bare->metadata_attributes } qr/Can't locate object method/, 'Injecting a label does not pollute other classes';
cmp_set [$foo->metadata_attributes], [qw{bar baz}], '<label>_attributes find all labeled attributes';
#use Data::Dumper;
#warn Dumper[$foo->metadata_attributes], [$foo->tag_attributes];
#for (qw{bar baz bam}) {
#warn "$_ is m: " . $foo->is_attribute_metadata($_);
#warn "$_ is t: " . $foo->is_attribute_tag($_);
#}
cmp_set [Set::Functional::intersection [$foo->metadata_attributes], [$foo->tag_attributes]], [qw{baz}], 'multiple labels on an attribute are orthogonal to eachother';
ok $foo->is_attribute_metadata('bar'), 'is_attribute_<label> identifies labeled attribute as labeled';
ok ! $foo->is_attribute_metadata('bam'), 'is_attribute_<label> identifies unlabeled attribute as not labeled';
ok ! $foo->is_attribute_metadata('none'), 'is_attribute_<label> identifies non-existent attribute as not labeled';
dies_ok { $foo->is_attribute_metadata() } 'is_attribute_<label> fails when not given an attribute';
lives_ok { $foo->update_metadata(bar => 235, baz => 789, bam => 'wont update', none => 'also wont update') } 'update_<labeled> handles all input';
is $foo->bar, 235, 'update_<label> modifies writable labeled attributes';
is $foo->baz, 94796, 'update_<label> does not modify read-only labeled attributes';
is $foo->bam, 94745, 'update_<label> does not modify unlabled attributes';
