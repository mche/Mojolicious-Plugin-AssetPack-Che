package Mojolicious::Plugin::AssetPack::Pipe::CombineFile;
use Mojo::Base 'Mojolicious::Plugin::AssetPack::Pipe';
use Mojolicious::Plugin::AssetPack::Util qw(checksum diag DEBUG);
 
has enabled => sub { shift->assetpack->minify };

sub new {
  my $self = shift->SUPER::new(@_);
  $self->assetpack->store->_types->type('html', ['text/html;charset=UTF-8']);# Restore deleted Jan
  $self->assetpack->_app->routes->route('/assets/*topic')->via(qw(HEAD GET))
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
    if ($asset->isa('Mojolicious::Plugin::AssetPack::Asset::Null')) {
      next;
    }
    elsif (grep { $asset->format eq $_ } qw(css js html)) {
      push @$combine, $asset;
    }
    else {
      push @other, $asset;
    }
  }
  
  @$assets = ();
  
  if (@$combine) {
    my $format = $combine->[0]->format;
    my $checksum = checksum $topic;#$combine->map('url')->join(':');
    my $name = checksum $topic;
    $combine->map(sub { $_->content(sprintf("@@@ %s\n%s", $_->url, $_->content)) } )
      if $format eq 'html';
    my $content = $combine->map('content')->map(sub { /\n$/ ? $_ : "$_\n" })->join;
   
    diag 'Combining assets into "%s" with checksum[%s] and format[%s].', $topic, $checksum, $format
      if DEBUG;
    
    push @$assets,
      $self->assetpack->store->save(\$content, {key => "combine-file", url=>$topic, name=>$name, checksum=>$checksum, minified=>1, format=>$format,})
  }
  
  push @$assets, @other;# preserve assets such as images and font files
}

sub _cb_route_by_topic {
  my $assetpack  =shift->assetpack;
return sub {
  my $c  = shift;
  my $topic = $c->stash('topic');
  
   my $assets = $assetpack->processed($topic)
    or $c->render(text => "// The asset [$topic] does not exists or not found\n", status => 404)
    and return;

  #~ return $c->render(text => $assets->map('content')->join);
  my $format = $assets->[0]->format;
  my $checksum = checksum $topic;#assets->map('checksum')->join(':');
  my $name = checksum $topic;
  
  my $asset = $assetpack->store->load({key => "combine-file", url=>$topic, name=>$name, checksum => $checksum, minified=>1, format=>$format});#  $format eq 'html' ? 0 : 1
  
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

Mojolicious::Plugin::AssetPack::Pipe::CombineFile - Store combined asset to cache file instred of memory.


=head1 SYNOPSIS

  $app->plugin('AssetPack::Che' => {
          pipes => [qw(Sass Css JavaScript CombineFile)],
          process => {
            'tmpl1.html'=>['templates/foo.html', 'templates/bar.html',],
            ...,
          },
        });


=head1 ROUTE

Get combined asset by url:

  //your-domain.com/assets/tmpl1.html


=cut