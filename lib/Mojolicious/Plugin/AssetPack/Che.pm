package Mojolicious::Plugin::AssetPack::Che;
use Mojo::Base 'Mojolicious::Plugin::AssetPack';
use Mojolicious::Plugin::AssetPack::Util qw( checksum );
use Mojo::URL;

has [qw(config)];

sub register {
  my ($self, $app, $config) = @_;
  $self->config($config);
  $self->SUPER::register($app, $config);
  
  my $process = $config->{process};
  $self->process(ref eq 'ARRAY' ? @$_ : $_) #($_->[0], map Mojo::URL->new($_), @$_[1..$#$_])
    for ref $process eq 'HASH' ? map([$_=> @{$process->{$_}}], keys %$process) : ref $process eq 'ARRAY' ? @$process : ();
  
  
  
  
  #~ $self->store->_types->type('html', ['text/html;charset=UTF-8']);
    #~ if $html;
  #~ my $html = $config->{combine_html};
  #~ $self->combine_html(ref eq 'ARRAY' ? @$_ : $_)
    #~ for ref $html eq 'HASH' ? map([$_=> @{$html->{$_}}], keys %$html) : ref $html eq 'ARRAY' ? @$html : ();
  
  #~ $app->routes->route('/assets/*topic')->via(qw(HEAD GET))
    #~ ->name('assetpack by topic')->to(cb => $self->_cb_serve_by_topic);
  
  return $self;
}

#~ sub combine_html {
  #~ my ($self, $topic, @input) = @_;
  #~ my $assets = Mojo::Collection->new();    # Do not mess up input
  
  #~ push @$assets, $self->store->asset($_)
    #~ for @input;
  
  #~ my $content = $assets->map(sub { $_->content(sprintf("@@@ %s\n%s", $_->url, $_->content)) } )->map('content')->join;
  
  #~ $self->store->save(\$content, {key => 'combine-html', url=>$topic, name=>$topic, checksum=>checksum($topic), minified=>0, format=>'html',});#
#~ }

sub Mojo::URL::checksum {
  1;
  
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



__END__
package Mojolicious::Plugin::AssetPack::Pipe::CombineHTML;
use Mojo::Base 'Mojolicious::Plugin::AssetPack::Pipe';
#~ use Mojolicious::Plugin::AssetPack::Util qw(diag load_module DEBUG);
 
sub process {
  my ($self, $assets) = @_;
  my $store = $self->assetpack->store;
  my $file;
  
  my $topic = $self->topic;
  my $format = $self->_format($topic);
  return
    if $format ne 'html';# or $asset->minified;
  my $content = $assets->map(sub { $_->content(sprintf("@@@ %s\n%s", $_->url, $_->content)) } )->map('content')->join;
  #~ return unless $self->assetpack->minify;
  return $assets->each(
    sub {
      my ($asset, $index) = @_;
      my $attrs = $asset->TO_JSON;
      $attrs->{key}      = 'combine-html';
      $attrs->{minified} = 0;
      
      return $asset->content($file)->minified(1)
        if $file = $store->load($attrs);
      load_module 'CSS::Minifier::XS' or die qq(Could not load "CSS::Minifier::XS": $@);
      diag 'Minify "%s" with checksum %s.', $asset->url, $asset->checksum if DEBUG;
      my $css = CSS::Minifier::XS::minify($asset->content);
      $asset->content($store->save(\$css, $attrs))->minified(0);
    }
  );
}

sub _format {
  my ($self, $url) = shift;
  my $name
    = $url =~ /^https?:/
    ? Mojo::URL->new($url)->path->[-1]
    : (split m!(\\|/)!, $url)[-1];
 
  return $name =~ /\.(\w+)$/ ? lc $1 : '';
};
 
1;