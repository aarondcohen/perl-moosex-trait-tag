package MooseX::Trait::Label;

=head1 NAME

MooseX::Trait::Label - give a label to an attribute

=cut

use Moose::Role;
use namespace::autoclean;

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This module provides a way to give a Moose attribute an arbitrary label.
By marking any attribute with the label, various methods are installed
into the package declaring the attribute allowing for actions to be taken
on only the labeled attributes.  This module is a generalization of
L<http://search.cpan.org/~ether/Moose/lib/Moose/Cookbook/Meta/Labeled_AttributeTrait.pod>

Example usage:

	package Foo;
	use Moose;
	use MooseX:Trait::Label qw{metadata};

	has field1 => (is => 'rw', traits => [qw{metadata}]);
	has field2 => (is => 'ro', traits => [qw{metadata}]);
	has field3 => (is => 'rw', traits => []);

	__PACKAGE__->meta->make_immutable;

	package main;

	my $foo = Foo->new;

	my @metadata_fields = sort $foo->metadata_attributes;
	# @metadata_fields => qw{ field1 field2 }

	print "Yes\n" if $foo->is_attribute_metadata('field1');
	print "No\n" if !$foo->is_attribute_metadata('field3');

	$foo->update_metadata(
		field1 => 6,
		field2 => 7,
		field3 => 8,
		field4 => 9,
	);
	# => only field1 is modified

=cut

=head1 METHODS

=cut

sub import {
	my $class = shift;
	$class->register_label($_) for @_;
}

sub register_label {
	my $class = shift;
	my ($label) = @_;

#TODO: figure out how to make labels orthogonal
#	my $package = "$class\::$label";
#	Moose::Meta::Role->initialize($package);# => (superclasses => [$class]));
#	Moose::Exporter->setup_import_methods(exporting_package => $package);
#	Moose::Util::meta_attribute_alias($label, $package);
	Moose::Util::meta_attribute_alias($label);

	after 'install_accessors' => sub {
		my $attribute = shift;
		my $realclass = $attribute->associated_class();
		my $attribute_name = $attribute->name;
# DEBUGGING
#		warn "rc: $realclass attr: $attribute_name lbl: $label";
#		use Data::Dumper;
#		warn Dumper($attribute);

=head2 is_attribute_<label>( $attribute_name )

Given an attribute name, determine if it is registered to the label.
Requires an attribute name.

=cut

		$realclass->add_method("is_attribute_$label", sub {
			my $attribute = (shift)->meta->find_attribute_by_name(@_);
			return $attribute && $attribute->does($label);
		}) unless $realclass->has_method("is_attribute_$label");

=head2 <label>_attributes( )

Returns the names of all attributes marked with the label.

=cut

		$realclass->add_method("$label\_attributes", sub {
			map { $_->name }
			grep { $_->does($label) }
			(shift)->meta->get_all_attributes
		}) unless $realclass->has_method("$label\_attributes");

=head2 update_<label>( attribute1 => $new_value1, ... )

Given name-value pairs, update each writable attribute with the new value
if it is associated with the appropriate label.

=cut

		$realclass->add_method("update_$label", sub {
			my ($self, %args) = @_;

			for my $attribute (grep { $_->does($label) } $self->meta->get_all_attributes) {
				next unless exists $args{$attribute->name};
				my $writer = $attribute->get_write_method;
				next unless $writer;
				$self->$writer($args{$attribute->name});
			}

			return;
		}) unless $realclass->has_method("update_$label");
	};
}

1;
