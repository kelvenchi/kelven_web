package KelvenWeb::Controller::Site;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use Encode;
use lib '../../../';
use CMSConfig;

sub show {
  my $self = shift;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => "$sess", curuser => "$sess");
    $self->render('/site/site');
  } else {
    $self->render(text => '请登录');
  }
}

sub adduser {
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my $self = shift;
  my $user = $self->param('username');
  my $pass = $self->param('password');
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => "$sess", curuser => "$sess");
    $user = encode 'utf8', $user;
    $pass = encode 'utf8', $pass;
    my $sql = qq{insert into Users (user, pass) values ("$user", "$pass")};
    $dbh->do($sql);
    $dbh->commit;
    $self->render('/site/site');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}

sub deluser {
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my $self = shift;
  my $user = $self->param('deluser');
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => "$sess", curuser => "$sess");
    my $sql = qq{delete from Users where user = "$user"};
    $dbh->do($sql);
    $dbh->commit;
    $self->render('/site/site');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}

sub edituser {
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my $self = shift;
  my $user = $self->param('edituser');
  my $pass = $self->param('password_e');
  $user = encode 'utf8', $user;
  $pass = encode 'utf8', $pass;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => "$sess", curuser => "$sess");
    my $sql = qq{update Users set pass = "$pass" where user = "$user"};
    $dbh->do($sql);
    $dbh->commit;
    $self->render('/site/site');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}


1;
