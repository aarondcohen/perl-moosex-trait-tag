#!/usr/bin/env perl

use strict;
use warnings qw(all);

use FindBin;
use lib "$FindBin::Bin/../lib/";

use Set::Functional;
use Test::Most tests => 13;

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

	use MooseX::Trait::Label qw{nothing};

	has bar => (
		is => 'rw',
		default => 3573573,
	);

	__PACKAGE__->meta->make_immutable;
}

my $foo = Foo->new();
my $bare = Bare->new();

cmp_set [$foo->metadata_attributes], [qw{bar baz}], '<label>_attributes find all labeled attributes';
cmp_set [Set::Functional::intersection [$foo->metadata_attributes], [$foo->tag_attributes]], [qw{baz}], 'Multiple labels on an attribute are orthogonal to eachother';
ok $foo->is_attribute_metadata('bar'), 'is_attribute_<label> identifies labeled attribute as labeled';
ok ! $foo->is_attribute_metadata('bam'), 'is_attribute_<label> identifies unlabeled attribute as not labeled';
ok ! $foo->is_attribute_metadata('none'), 'is_attribute_<label> identifies non-existent attribute as not labeled';
dies_ok { $foo->is_attribute_metadata() } 'is_attribute_<label> fails when not given an attribute';
lives_ok { $foo->update_metadata(bar => 235, baz => 789, bam => 'wont update', none => 'also wont update') } 'update_<labeled> handles all input';
is $foo->bar, 235, 'update_<label> modifies writable labeled attributes';
is $foo->baz, 94796, 'update_<label> does not modify read-only labeled attributes';
is $foo->bam, 94745, 'update_<label> does not modify unlabled attributes';
throws_ok { $bare->metadata_attributes } qr/Can't locate object method/, 'Injecting a label does not pollute other classes';
lives_ok { $bare->nothing_attributes; $bare->is_attribute_nothing('nothing'); $bare->update_nothing } 'Injecting a label adds all appropriate methods to the importing class, regardless of the attributes';
