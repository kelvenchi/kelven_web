package KelvenWeb;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->secrets(['HuBeiMingLei']);

  # Log
  $self->app->log->is_level('debug');
  if ( $self->app->log->is_level('debug') ) {
    no warnings 'redefine';
    *Mojo::Log::_format = sub {
      my ($self, $level, @lines) = @_;
      my @caller = caller(4);
      my $caller = join ' ', $caller[0], $caller[2];
      return '[' . localtime(time) . "][$level] [$caller] " . join("\n", @lines) . "\n";
    }
  }

  #listen on 80 port
  $self->app->config(hypnotoad => {listen => ['http://*:80']});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r = $r->under('/' => sub {
      my $c = shift;
      $c->res->headers->server("HuBeiMingLei");
      return 1;
    }
  );

  # for pages
  $r->get('/')->to('index#show');
  $r->get('/index')->to('index#show');
  $r->get('/article/:num')->to('article#show');
  $r->get('/admin/login')->to('login#page');
  $r->get('/admin/add')->to('articlemgmt#add_page');
  $r->get('/admin/index')->to('login#index_show');
  $r->get('/article/edit/:num')->to('articlemgmt#edit');
  $r->get('/article/delete/:num')->to('articlemgmt#delete');
  $r->get('/category/index')->to('category#index');
  $r->get('/category/add')->to('category#add');
  $r->get('/category/edit/:num')->to('category#edit');
  $r->get('/category/delete/:num')->to('category#delete');
  $r->get('/category/subedit/:num')->to('category#subedit');
  $r->get('/category/subdelete/:num')->to('category#subdelete');
  $r->get('/image/index')->to('image#index');
  $r->get('/index/index/')->to('index#admin');
  $r->get('/site/index')->to('site#show');
  $r->get('/recommend/index')->to('recommend#show');

  # for actions
  $r->post('/recommend/update')->to('recommend#update');
  $r->post('/site/deluser')->to('site#deluser');
  $r->post('/site/adduser')->to('site#adduser');
  $r->post('/site/edituser')->to('site#edituser');
  $r->post('/ajax/pcheck')->to('ajax#pcheck');
  $r->post('/ajax/ucheck')->to('ajax#ucheck');
  $r->post('/index/cover')->to('index#cover');
  $r->post('/index/outline')->to('index#outline');
  $r->post('/index/concept')->to('index#concept');
  $r->post('/index/dev')->to('index#dev');
  $r->post('/index/introduce')->to('index#introduce');
  $r->post('/index/qdev')->to('index#qdev');
  $r->post('/ajax/subc')->to('ajax#subc');
  $r->post('/ajax/suba')->to('ajax#suba');
  $r->post('/image/upload')->to('image#upload');
  $r->post('/image/update')->to('image#update');
  $r->post('/image/delete')->to('image#delete');
  $r->post('/category/rm')->to('category#rm');
  $r->post('/category/add_pri')->to('category#add_pri');
  $r->post('/category/add_sub')->to('category#add_sub');
  $r->post('/category/update_pri')->to('category#update_pri');
  $r->post('/category/update_sub')->to('category#update_sub');
  $r->post('/login')->to('login#check');
  $r->post('/articlemgmt/logout')->to('login#logout');
  $r->post('/articlemgmt/update')->to('articlemgmt#update');
  $r->post('/articlemgmt/insert')->to('articlemgmt#insert');
  $r->post('/articlemgmt/operate')->to('articlemgmt#operate');
  $r->post('/articlemgmt/filtrate')->to('articlemgmt#filtrate');
  $r->any([qw(get post)] => '/articlemgmt/search')->to('articlemgmt#search');
  $r->any([qw(get post)] => '/articlemgmt/add')->to('articlemgmt#add');
}

1;
