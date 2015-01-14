package KelvenWeb::Controller::Recommend;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use Encode;
use lib '../../../';
use CMSConfig;

sub show {
  my $self = shift;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => "$sess");
    $self->render('/recommend/recommend');
  } else {
    $self->render(text => '请登录');
  }
}

sub update {
  my $self = shift;
  my $sess = $self->session('user_id');
  my @params = $self->param(['pdt1', 'pdt2', 'pdt3', 'pdt4', 'pdt5', 'pdt6', 'pdt7', 'pdt8']);
  $_ = encode 'utf8', $_ for @params;
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $sql = qq{update Recommend set url1 = ?, url2 = ?, url3 = ?, url4 = ?, url5 = ?, url6 = ?, url7 = ?, url8 = ?};
    $dbh->do($sql, undef, map {$_} @params);
    $dbh->commit;
    $self->stash(admin => "$sess");
    $self->render('/recommend/recommend');
  }
  else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}

1;
