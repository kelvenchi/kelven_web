package KelvenWeb::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use Encode;
use lib '../../../';
use CMSConfig;

# This action will render a template
sub check {
  my $self = shift;

  my ($user, $pass, $sess) = $self->param([qw(user password)]);
  $user = encode 'utf8', $user;
  $pass = encode 'utf8', $pass;
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my $sth = $dbh->prepare("SELECT * FROM Users WHERE user = \'$user\';");
  $sth->execute();
  my $row = $sth->fetchall_hashref('user');
  $sth->finish;
  $dbh->disconnect;

  my $id = $row->{$user};
  $id->{user} = decode 'utf8', $id->{user};
  $id->{pass} = decode 'utf8', $id->{pass};
  if ($id->{pass} eq $pass && $id->{user}) {
    $self->session(user_id => $id->{user});
    $self->stash(admin => "$id->{user}");
    $self->render('/admin/index');
  } else {
    $self->render(text => '错误的用户名或密码');
  }
}

sub logout {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('/admin/login');
}

sub page {
  my $self = shift;
  $self->session(page => 0);
  $self->render('/admin/login', format => 'html');
}

sub index_show {
  my $self = shift;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => $sess);
    $self->render('/admin/index');
  } else {
    $self->render(text => '请登录');
  }
}


1;
