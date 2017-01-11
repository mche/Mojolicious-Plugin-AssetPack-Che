package Mojolicious::Plugin::AssetPack::Pipe::HTML;
use Mojo::Base 'Mojolicious::Plugin::AssetPack::Pipe';
use Mojolicious::Plugin::AssetPack::Util qw(diag load_module DEBUG);

has config => sub { shift->assetpack->config->{HTML} || {} };
has minify_opts => sub { {remove_comments => 1, remove_newlines => 1, no_compress_comment => 1, html5 => 1, %{shift->config->{minify_opts} || {}}, } };# do_javascript => 'clean', do_stylesheet => 'minify' ,

sub process {
  my ($self, $assets) = @_;
  my $store = $self->assetpack->store;
  
  return unless $self->assetpack->minify;
  
  my $file;
  return $assets->each(
    sub {
      my ($asset, $index) = @_;
      my $attrs = $asset->TO_JSON;
      $attrs->{key}      = 'html-min';
      $attrs->{minified} = 1;
      return if $asset->format ne 'html' or $asset->minified;
      return $asset->content($file)->minified(1)
        if $file = $store->load($attrs);
      
      return unless length(my $content = $asset->content);
      load_module 'HTML::Packer'
        or die qq(Could not load "HTML::Packer": $@);
      diag 'Minify "%s" with checksum %s.', $asset->url, $asset->checksum if DEBUG;
      HTML::Packer::minify(\$content, $self->minify_opts);
      $asset->content($store->save(\$content, $attrs))->minified(1);
    }
  );
}
 
1;