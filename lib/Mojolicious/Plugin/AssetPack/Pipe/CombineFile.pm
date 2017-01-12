package Mojolicious::Plugin::AssetPack::Pipe::CombineFile;
use Mojo::Base 'Mojolicious::Plugin::AssetPack::Pipe';
use Mojolicious::Plugin::AssetPack::Util qw(checksum diag DEBUG);
 
has enabled => sub { shift->assetpack->minify };
has config => sub { my $config = shift->assetpack->config; ($config && $config->{CombineFile}) || {}; };

sub new {
  my $self = shift->SUPER::new(@_);
  $self->app->routes->route('/assets/*topic')->via(qw(HEAD GET))
    ->name('assetpack by topic')->to(cb => $self->_cb_route_by_topic);
  $self;
}

sub process {
  my ($self, $assets) = @_;
  my $combine = Mojo::Collection->new;
  my @other;
  my $topic = $self->topic;
 
  #~ return unless $self->enabled;!!! below
 
  for my $asset (@$assets) {
    next
      if $asset->isa('Mojolicious::Plugin::AssetPack::Asset::Null');
    
    push @$combine, $asset
      and next
      if grep $asset->format eq $_, qw(css js html);
    
    push @other, $asset;
    
  }
  
  my @process = ();
  
  if (@$combine) {
    my $format = $combine->[0]->format;
    my $checksum = checksum $topic;#$combine->map('url')->join(':');
    #~ my $name = checksum $topic;
    if ($format eq 'html') {# enabled always
      #~ my $pre_name = $self->config->{html} && $self->config->{html}{pre_name};
      my $url_lines = $self->config->{url_lines};
      
      $combine->map( sub {
        my $url = $_->url;
        return # 
          unless $url_lines && exists $url_lines->{$url};# && !$url_lines->{$url};
        
        my $url_line = $url_lines->{$url};
        utf8::encode($url_line);
        $_->content(sprintf("%s\n%s", $url_line,  $_->content));

      } );
      
      $self->assetpack->store->_types->type(html => ['text/html;charset=UTF-8'])# Restore deleted Jan
        unless $self->assetpack->store->_types->type('html');
      
    } else {
      return unless $self->enabled;
    }
    my $content = $combine->map('content')->map(sub { /\n$/ ? $_ : "$_\n" })->join;
   
    DEBUG && diag 'Combining assets into "%s" with checksum[%s] and format[%s].', $topic, $checksum, $format;
    
    push @process,
      $self->assetpack->store->save(\$content, {key => "combine-file", url=>$topic, name=>$checksum, checksum=>$checksum, minified=>1, format=>$format,})
  }
  
  push @process, @other;# preserve assets such as images and font files
  @$assets = @process;
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
          CombineFile => {html=>{names=>"@@@ ", url_lines=>{'templates/bar.html'=>'t/bar',},},},
          process => {
            'tmpl1.html'=>['templates/foo.html', 'templates/bar.html',],
            ...,
          },
        });

=head1 CONFIG

B<CombineFile> determine config for this pipe module. Hashref has keys for format extensions and also:

B<url_lines> - hashref maps url of asset to some line and place this line as first in content. If not defined thecontent will not change.


=head1 ROUTE

B</assets/*topic> will auto place.

Get combined asset by url

  <scheme>//<host>/assets/tmpl1.html

=head1 SEE ALSO

L<Mojolicious::Plugin::AssetPack::Che>

=head1 AUTHOR

Михаил Че (Mikhail Che), C<< <mche[-at-]cpan.org> >>

=cut