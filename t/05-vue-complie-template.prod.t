use Mojo::Base -strict;
use Test::More;

plan skip_all => 'Set env MOJO_ASSETPACK_DEBUG="vue-template-compiler" to enable this test. Those npm: parcel & vue-template-compiler are require.'
  unless $ENV{MOJO_ASSETPACK_DEBUG} && $ENV{MOJO_ASSETPACK_DEBUG} eq 'vue-template-compiler';

BEGIN {
  $ENV{MOJO_MODE}    = 'production';
  #~ $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
}

 
use FindBin;
require "$FindBin::Bin/app-vue.pl";

use Mojo::File;
 
use Test::Mojo;
 
my $t = Test::Mojo->new;


$t->get_ok('/')->status_is(200)->tx->res->dom->find('script')->each(sub { $t->get_ok($_->attr('src'))->status_is(200); });
#->content_like(qr'foo.css')->tx->res->dom->find('head link')->each(sub {$t->get_ok($_->attr('href'))->status_is(200); })->size, 2, 'assets count';#;

$t->get_ok('/assets/main.js')->status_is(200); #->tx->res->body;
$t->get_ok('/assets/js/dist/рендер.js')->status_is(200);
#~ $t->get_ok('/assets/t1.html')->status_is(200)->header_is('Content-Type'=>'text/html;charset=UTF-8')->header_is('Content-Length'=>'62182');

Mojo::File->new("t/assets/cache")->remove_tree();
Mojo::File->new("t/assets/js/dist")->remove_tree();

done_testing();