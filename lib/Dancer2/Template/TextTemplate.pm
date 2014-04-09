package Dancer2::Template::TextTemplate;
# ABSTRACT: Text::Template engine for Dancer2

use 5.010001;
use strict;
use warnings;
use utf8;

our $VERSION = '0.1'; # VERSION

use Carp 'croak';
use Moo;
use Dancer2::Core::Types 'InstanceOf';
use Dancer2::Template::TextTemplate::FakeEngine;
use namespace::clean;

with 'Dancer2::Core::Role::Template';


has '+engine' =>
  ( isa => InstanceOf['Dancer2::Template::TextTemplate::FakeEngine'] );

sub _build_engine {
    my $self = shift;
    my $engine = Dancer2::Template::TextTemplate::FakeEngine->new;
    for (qw/ caching expires delimiters cache_stringrefs /) {
        $engine->$_($self->config->{$_}) if $self->config->{$_};
    }
    return $engine;
}


sub render {
    my ( $self, $template, $tokens ) = @_;
    return $self->engine->process( $template, $tokens )
      or croak $Dancer2::Template::TextTemplate::FakeEngine::ERROR;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dancer2::Template::TextTemplate - Text::Template engine for Dancer2

=head1 VERSION

version 0.1

=head1 SYNOPSIS

To use this engine, you may configure L<Dancer2> via C<config.yml>:

    template: text_template

=head1 DESCRIPTION

B<This is an alpha version: it basically works, but it has not been
extensively tested and it misses interesting features.>

This template engine allows you to use L<Text::Template> in L<Dancer2>.

Contrary to other template engines (like L<Template::Toolkit>), where I<one>
instance may work on I<multiple> templates, I<one> L<Text::Template> instance
is created I<for each> template. Therefore, if:

=over 4

=item *

you don't use a huge amount of different templates;

=item *

you don't use each template just once;

=back

then it may be interesting to B<cache> Text::Template instances for later use.
Since these conditions seem to be common, this engine uses a cache (I<via>
L<CHI>) B<by default>.

If you're OK with caching, you should specify a B<timeout> (C<expires>) after
which cached Text::Template instances are to be refreshed, since you might
have changed your template sources without restarting Dancer2. Use the value
C<0> to tell the engine that templates never expire.

To enable caching in your C<config.yml>:

    template: text_template
    engines:
        text_template:
            caching: 1                  # default
            expires: 3600               # in seconds; default; 0 to disable
            cache_stringrefs: 1         # default
            delimiters: [ "{", "}" ]    # default

Just like with L<Dancer2::Template::Toolkit>, you can pass templates either as
filenames (for a template file) or string references ("string-refs", which are
dereferenced and used as the template's content). In some cases, you may want
to disable caching just for string-refs: for instance, if you generate a lot
of templates on-the-fly and use them only once, caching them is useless and
fills your cache. You can therefore disable caching for string-refs only by
setting C<cache_stringrefs> to C<0>.

The C<delimiters> option allows you to specify a custom delimiters pair
(opening and closing) for your templates. See the L<Text::Template>
documentation for more about delimiters, since this module just pass them to
Text::Template. This option defaults to C<{> and C<}>, meaning that in C<< a
{b} c >>, C<b> (and only C<b>) will be interpolated.

=head1 METHODS

=head2 render( $template, \%tokens )

Renders the template.

=over 4

=item *

C<$template> is either a (string) filename for the template file or a

reference to a string that contains the template.

=item *

C<\%tokens> is a hashref for the tokens you wish to pass to

L<Text::Template> for rendering, as if you were using
C<Text::Template::fill_in>.

=back

L<Carp|Croak>s if an error occurs.

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
