package Mojolicious::Plugin::AssetPack::Che;
use Mojo::Base 'Mojolicious::Plugin::AssetPack';
use Mojolicious::Plugin::AssetPack::Util qw( checksum );
use Mojo::URL;

has [qw(app config)];

sub register {
  my ($self, $app, $config) = @_;
  $self->config($config);
  $self->app($app);
  Scalar::Util::weaken($self->{app});
  $self->SUPER::register($app, $config);
  
  my $process = $config->{process};
  $self->process(ref eq 'ARRAY' ? @$_ : $_) #($_->[0], map Mojo::URL->new($_), @$_[1..$#$_])
    for ref $process eq 'HASH' ? map([$_=> ref $process->{$_} eq 'ARRAY' ? @{$process->{$_}} : $process->{$_}], keys %$process) : ref $process eq 'ARRAY' ? @$process : ();
  
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

Version 1.33

=cut

our $VERSION = '1.33';


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

