#!/usr/bin/env perl

use strict;
use warnings qw(all);

use FindBin;
use lib "$FindBin::Bin/../lib/";

use Set::Functional;
use Test::Most tests => 14;

use_ok 'MooseX::Trait::Tag';

{
	package Foo;
	use Moose;

	use MooseX::Trait::Tag qw{metadata tag};

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

	use MooseX::Trait::Tag qw{nothing};

	has bar => (
		is => 'rw',
		default => 3573573,
	);

	__PACKAGE__->meta->make_immutable;
}

my $foo = Foo->new();
my $bare = Bare->new();

cmp_set [$foo->all_metadata], [qw{bar baz}], 'all_<tag> find all tagged attributes';
cmp_set [Set::Functional::intersection [$foo->all_metadata], [$foo->all_tag]], [qw{baz}], 'Multiple tags on an attribute are orthogonal to eachother';
ok $foo->is_metadata('bar'), 'is_<tag> identifies tagged attribute as tagged';
ok ! $foo->is_metadata('bam'), 'is_<tag> identifies untagged attribute as not tagged';
ok ! $foo->is_metadata('none'), 'is_<tag> identifies non-existent attribute as not tagged';
dies_ok { $foo->is_metadata() } 'is_<tag> fails when not given an attribute';
is_deeply {$foo->get_metadata}, {bar => 3573573, baz => 94796}, 'get_<tag> returns they key-value pairs of thetagged attributes';
lives_ok { $foo->set_metadata(bar => 235, baz => 789, bam => 'wont update', none => 'also wont update') } 'set_<tag> handles all input';
is $foo->bar, 235, 'set_<tag> modifies writable tagged attributes';
is $foo->baz, 94796, 'set_<tag> does not modify read-only tagged attributes';
is $foo->bam, 94745, 'set_<tag> does not modify untagged attributes';
throws_ok { $bare->all_metadata } qr/Can't locate object method/, 'Injecting a tag does not pollute other classes';
lives_ok { $bare->all_nothing; $bare->is_nothing('nothing'); $bare->get_nothing; $bare->set_nothing } 'Injecting a tag adds all appropriate methods to the importing class, regardless of the attributes';
