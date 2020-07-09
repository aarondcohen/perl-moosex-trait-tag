# NAME

MooseX::Trait::Tag - Add an arbitrary tag to an attribute

# VERSION

Version 1.04

# SYNOPSIS

This module provides a way to give a Moose attribute an arbitrary tag.
Various methods are installed into the package declaring the attribute,
allowing for actions to be taken on only the tagged attributes.
This module is inspired by [http://search.cpan.org/~ether/Moose/lib/Moose/Cookbook/Meta/Labeled\_AttributeTrait.pod](http://search.cpan.org/~ether/Moose/lib/Moose/Cookbook/Meta/Labeled_AttributeTrait.pod)

Example usage:

        package Foo;
        use Moose;
        use MooseX::Trait::Tag qw{metadata};

        has field1 => (is => 'rw', traits => [qw{metadata}]);
        has field2 => (is => 'ro', traits => [qw{metadata}]);
        has field3 => (is => 'rw', traits => []);

        __PACKAGE__->meta->make_immutable;

        package main;

        my $foo = Foo->new;

        my @metadata_fields = sort $foo->all_metadata_attributes;
        # @metadata_fields => qw{ field1 field2 }

        print "Yes\n" if $foo->is_metadata_attribute('field1');
        print "No\n" if !$foo->is_metadata_attribute('field3');

        $foo->set_metadata(
                field1 => 6,
                field2 => 7,
                field3 => 8,
                field4 => 9,
        );
        # => only field1 is modified

        my %field_to_value = $foo->get_metadata;
        # %field_to_value => (field1 => 6, field2 => undef)

# METHODS

## register\_tag(importing\_class => $importing\_class, tag => $tag)

Install the methods asociated with the tag into the importing class.

# INSTALLED METHODS

## is\_&lt;tag>\_attribute( $attribute\_name )

Given an attribute name, determine if it is registered to the tag.
Requires an attribute name.

## all\_&lt;tag>\_attributes( )

Return the names of all attributes marked with the tag.

## get\_&lt;tag>( )

Return all name-value pairs for each readable attribute associated with the
appropriate tag.

## set\_&lt;tag>( attribute1 => $new\_value1, ... )

Given name-value pairs, update each writable attribute with the new value
if it is associated with the appropriate tag.

# AUTHOR

Aaron Cohen, `<aarondcohen at gmail.com>`

# ACKNOWLEDGEMENTS

This module was made possible by [Shutterstock](http://www.shutterstock.com/)
([@ShutterTech](https://twitter.com/ShutterTech)).  Additional open source
projects from Shutterstock can be found at
[code.shutterstock.com](http://code.shutterstock.com/).

# BUGS

Please report any bugs or feature requests to `bug-moosex-trait-tag at rt.cpan.org`, or through
the web interface at [https://github.com/aarondcohen/perl-moosex-trait-tag/issues](https://github.com/aarondcohen/perl-moosex-trait-tag/issues).  I will
be notified, and then you'll automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::Trait::Tag

You can also look for information at:

- Official GitHub Repo

    [https://github.com/aarondcohen/perl-moosex-trait-tag](https://github.com/aarondcohen/perl-moosex-trait-tag)

- GitHub's Issue Tracker (report bugs here)

    [https://github.com/aarondcohen/perl-moosex-trait-tag/issues](https://github.com/aarondcohen/perl-moosex-trait-tag/issues)

- CPAN Ratings

    [http://cpanratings.perl.org/d/MooseX-Trait-Tag](http://cpanratings.perl.org/d/MooseX-Trait-Tag)

- Official CPAN Page

    [http://search.cpan.org/dist/MooseX-Trait-Tag/](http://search.cpan.org/dist/MooseX-Trait-Tag/)

# LICENSE AND COPYRIGHT

Copyright 2013 Aaron Cohen.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
