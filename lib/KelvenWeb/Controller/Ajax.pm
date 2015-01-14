package KelvenWeb::Controller::Ajax;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use lib '../../../';
use CMSConfig;
use Encode;
use utf8;

sub subc {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $name = $self->param('name');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $cc = $dbh->prepare(qq{select id from Category where name = "$name";});
    $cc->execute;
    my @subid = $cc->fetchrow_array();
    $cc->finish;
    my $sql = qq{SELECT id, name FROM Subcategory where belong_to = "$subid[0]";};
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    my $sub = $sth->fetchall_arrayref();
    $sth->finish;
    for (@{$sub}) {
      $_->[1] = decode 'utf8', $_->[1];
    }
    my @json;
    for (@{$sub}) {
      push @json, {id => $_->[0], name => $_->[1]};
    }
    $self->render(json => [@json]);
  } else {
    $self->render(text => 'permision denied');
  }
  $dbh->disconnect;
}

sub suba {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $pri = $self->param('pri');
  my $name = $self->param('name');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $cc = $dbh->prepare(qq{select id,title from Articles where category = "$pri" and subcategory = "$name" and subcategory is not null and model = 'i';});
    $cc->execute;
    my $articles = $cc->fetchall_arrayref();
    $cc->finish;
    for (@{$articles}) {
      $_->[1] = decode 'utf8', $_->[1];
    }
    my @json;
    for (@{$articles}) {
      push @json, {id => $_->[0], name => $_->[1]};
    }
    $self->render(json => [@json]);
  } else {
    $self->render(text => 'permision denied');
  }
  $dbh->disconnect;
}

sub ucheck {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $username = $self->param('username');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $uc = $dbh->prepare(qq{select user from Users where user = "$username"});
    $uc->execute();
    my $ucc = $uc->fetchall_arrayref();
    $uc->finish;
    my @json;
    for (@{$ucc}) {
      $_->[0] = decode 'utf8', $_->[0];
      push @json, {name => $_->[0]};
    }
    push @json, {name => ''} unless @{$ucc};
    $self->render(json => [@json]);
  } else {
    $self->render(text => 'permission denied');
  }
  $dbh->disconnect;
}

sub pcheck {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $user = $self->param('username');
  my $password = $self->param('password');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $uc = $dbh->prepare(qq{select pass from Users where user = "$user"});
    $uc->execute();
    my $ucc = $uc->fetchall_arrayref();
    $uc->finish;
    my @json;
    for (@{$ucc}) {
      $_->[0] = decode 'utf8', $_->[0];
      if ($password eq $_->[0]) {
        push @json, {name => "yes"};
      } else {
        push @json, {name => ''};
      }
    }
    $self->render(json => [@json]);
  } else {
    $self->render(text => 'permission denied');
  }
  $dbh->disconnect;
}

1;
