package Mojolicious::Plugin::AssetPack::Che;
use Mojo::Base 'Mojolicious::Plugin::AssetPack';

sub register {
  my ($self, $app, $config) = @_;
  $self->SUPER::register($app, $config);
  $self->process(ref eq 'ARRAY' ? @$_ : $_)
    for ref $config->{process} eq 'HASH' ? map([$_=> @{$config->{process}{$_}}], keys %{$config->{process}}) : ref $config->{process} eq 'ARRAY' ? @{$config->{process}} : ();
  return $self;
}

=pod

=encoding utf8

Доброго всем

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

Mojolicious::Plugin::AssetPack::Che - Child of Mojolicious::Plugin::AssetPack for little bit code.

Since version 1.28.

=head1 VERSION

Version 1.28

=cut

our $VERSION = '1.28';


=head1 SYNOPSIS

See parent module L<Mojolicious::Plugin::AssetPack> for full documentation.

On register the plugin  C<config> can contain additional optional argument B<process>:

  $app->plugin(AssetPack => pipes => [...], process => {foo.js=>[...], ...});
  # or
  $app->plugin(AssetPack => pipes => [...], process => [[foo.js=>(...)], ...]);
  # or
  $app->plugin(AssetPack => pipes => [...], process => [$definition_file1, ...]);


=head1 SEE ALSO

L<Mojolicious::Plugin::AssetPack>

=head1 AUTHOR

Михаил Че (Mikhail Che), C<< <mche[-at-]cpan.org> >>

=head1 BUGS / CONTRIBUTING

Please report any bugs or feature requests at L<https://github.com/mche/Mojolicious-Plugin-AssetPack-Che/issues>. Pull requests also welcome.

=head1 COPYRIGHT

Copyright 2016 Mikhail Che.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.



=cut

1; # End of Mojolicious::Plugin::AssetPack::Che
