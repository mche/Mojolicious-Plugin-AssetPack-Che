package Mojolicious::Plugin::AssetPack::Pipe::CombineFile;
use Mojo::Base 'Mojolicious::Plugin::AssetPack::Pipe';
use Mojolicious::Plugin::AssetPack::Util qw(checksum diag DEBUG);
 
has enabled => sub { shift->assetpack->minify };
has config => sub { shift->assetpack->config->{CombineFile} || {} };

sub new {
  my $self = shift->SUPER::new(@_);
  $self->assetpack->app->routes->route('/assets/*topic')->via(qw(HEAD GET))
    ->name('assetpack by topic')->to(cb => $self->_cb_route_by_topic);
  $self;
}

sub process {
  my ($self, $assets) = @_;
  my $combine = Mojo::Collection->new;
  my @other;
  my $topic = $self->topic;
 
  return unless $self->enabled;
 
  for my $asset (@$assets) {
    next
      if $asset->isa('Mojolicious::Plugin::AssetPack::Asset::Null');
    
    push @$combine, $asset
      and next
      if grep $asset->format eq $_, qw(css js html);
    
    push @other, $asset;
    
  }
  
  @$assets = ();
  
  if (@$combine) {
    my $format = $combine->[0]->format;
    my $checksum = checksum $topic;#$combine->map('url')->join(':');
    #~ my $name = checksum $topic;
    if ($format eq 'html') {
      my $names = $self->config->{html} && $self->config->{html}{names};
      my $map_names = $self->config->{html} && $self->config->{html}{map_names};
      
      $combine->map( sub {
        
        return
          unless defined($names);
        
        my $url = $_->url;
        return # 
          if $map_names && exists($map_names->{$url}) && !$map_names->{$url};
        
        my $map_name = $map_names && $map_names->{$url};
        $_->content(sprintf("%s%s\n%s", $names, $map_name || $url,  $_->content));

      } );
      
      $self->assetpack->store->_types->type(html => ['text/html;charset=UTF-8'])# Restore deleted Jan
        unless $self->assetpack->store->_types->type('html');
    }
    my $content = $combine->map('content')->map(sub { /\n$/ ? $_ : "$_\n" })->join;
   
    diag 'Combining assets into "%s" with checksum[%s] and format[%s].', $topic, $checksum, $format
      if DEBUG;
    
    push @$assets,
      $self->assetpack->store->save(\$content, {key => "combine-file", url=>$topic, name=>$checksum, checksum=>$checksum, minified=>1, format=>$format,})
  }
  
  push @$assets, @other;# preserve assets such as images and font files
}

sub _cb_route_by_topic {
  my $assetpack  =shift->assetpack;
return sub {
  my $c  = shift;
  my $topic = $c->stash('topic');
  
   my $assets = $assetpack->processed($topic)
    or $c->render(text => "// The asset [$topic] does not exists (not processed) or not found\n", status => 404)
    and return;

  #~ return $c->render(text => $assets->map('content')->join);
  my $format = $assets->[0]->format;
  my $checksum = checksum $topic;#assets->map('checksum')->join(':');
  #~ my $name = checksum $topic;
  
  my $asset = $assetpack->store->load({key => "combine-file", url=>$topic, name=>$checksum, checksum => $checksum, minified=>1, format=>$format});#  $format eq 'html' ? 0 : 1
  
  #~ warn $c->dumper($asset);#->format('tmpl')
  
  $assetpack->store->serve_asset($c, $asset)
    and return $c->rendered
    if $asset;
 
  $c->render(text => "// No such asset [$topic]\n", status => 404);
};
}
 
1;

=pod

=encoding utf8

Доброго всем

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

Mojolicious::Plugin::AssetPack::Pipe::CombineFile - Store combined asset to cache file instead of memory.


=head1 SYNOPSIS

  $app->plugin('AssetPack::Che' => {
          pipes => [qw(Sass Css JavaScript CombineFile)],
          CombineFile => {html=>{names=>"@@@ ", map_names=>{'templates/bar.html'=>'bar',},},},
          process => {
            'tmpl1.html'=>['templates/foo.html', 'templates/bar.html',],
            ...,
          },
        });

=head1 CONFIG

B<CombineFile> determine config for this pipe module. Hashref has keys for format extensions. Now implements only B<html> format options:

B<names> - string for prepending inserting names to result asset content, if not defined then names will not inserts.

B<map_names> - hashref maps url asset to other name, if not defined then use url of asset

Case the C<< map_names=>{< url >  => undef || 0 || '', } >> then name of url will be skip inserts.

=head1 ROUTE

B</assets/*topic> will auto place.

Get combined asset by url

  <scheme>//<host>/assets/tmpl1.html

=head1 SEE ALSO

L<Mojolicious::Plugin::AssetPack::Che>

=head1 AUTHOR

Михаил Че (Mikhail Che), C<< <mche[-at-]cpan.org> >>

=cut