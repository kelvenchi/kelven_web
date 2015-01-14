use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use lib '../lib/';

my $t = Test::Mojo->new('KelvenWeb');
$t->get_ok('192.168.0.253:3000/')->status_is(200)->content_like(qr/<[^>]+>/i);

done_testing();
