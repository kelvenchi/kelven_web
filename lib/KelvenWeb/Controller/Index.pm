package KelvenWeb::Controller::Index;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use lib '../../../';
use CMSConfig;

sub show {
  my $self = shift;
  $self->render('/index');
}

sub admin {
  my $self = shift;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => $sess);
    $self->render('/index/index');
  } else {
    $self->render(text => "请登录");
  }
}

sub cover {
  my $self = shift;
  my $sess = $self->session('user_id');
  my @params = $self->param(['company_name', 'propagation']);
  my $sql = qq{update IndexCover set a = "$params[0]", b = "$params[1]";};
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    $dbh->do($sql);
    $dbh->commit;
    $dbh->disconnect;
    $self->stash(admin => $sess);
    $self->render('/index/index');
  } else {
    $self->render(text => "请登录")
  }
}

sub outline {
  my $self = shift;
  my $sess = $self->session('user_id');
  my @params = $self->param(['pcategory', 'introduction']);
  my $sql = qq{update IndexOutline set a = "$params[0]", b = "$params[1]";};
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    $dbh->do($sql);
    $dbh->commit;
    $dbh->disconnect;
    $self->stash(admin => $sess);
    $self->render('/index/index');
  } else {
    $self->render(text => "请登录")
  }
}

sub concept {
  my $self = shift;
  my $sess = $self->session('user_id');
  my @params = $self->param(['title1', 'subtitle1', 'image1', 'image2', 'image3', 'image4', 'image5', 'image6', 'image7']);
  my $sql = qq{update IndexConcept set a = "$params[0]", b = "$params[1]", c = "$params[2]", d = "$params[3]", e = "$params[4]", f = "$params[5]", g = "$params[6]", h = "$params[7]", i = "$params[8]";};
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    $dbh->do($sql);
    $dbh->commit;
    $dbh->disconnect;
    $self->stash(admin => $sess);
    $self->render('/index/index');
  } else {
    $self->render(text => "请登录")
  }
}

sub dev {
  my $self = shift;
  my $sess = $self->session('user_id');
  my @params = $self->param(['title2', 'subtitle2', 'image-dev']);
  my $sql = qq{update IndexDev set a = "$params[0]", b = "$params[1]", c = "$params[2]";};
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    $dbh->do($sql);
    $dbh->commit;
    $dbh->disconnect;
    $self->stash(admin => $sess);
    $self->render('/index/index');
  } else {
    $self->render(text => "请登录")
  }
}

sub introduce {
  my $self = shift;
  my $sess = $self->session('user_id');
  my @params = $self->param(['title3', 'subtitle3', 'imglist1', 'imglist-desc1','imglist2', 'imglist-desc2','imglist3', 'imglist-desc3','imglist4', 'imglist-desc4','imglist5', 'imglist-desc5','imglist6', 'imglist-desc6','imglist7', 'imglist-desc7','imglist8', 'imglist-desc8', 'imglist9', 'imglist-desc9']);
  my $sql = qq{update IndexIntroduce set a = "$params[0]", b = "$params[1]", c = "$params[2]", d = "$params[3]", e = "$params[4]", f = "$params[5]", s = "$params[6]", t = "$params[7]", g = "$params[8]", h = "$params[9]", i = "$params[10]", j = "$params[11]", k = "$params[12]", l = "$params[13]", m = "$params[14]", n = "$params[15]", o = "$params[16]", p = "$params[17]", q = "$params[18]", r = "$params[19]";};
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    $dbh->do($sql);
    $dbh->commit;
    $dbh->disconnect;
    $self->stash(admin => $sess);
    $self->render('/index/index');
  } else {
    $self->render(text => "请登录")
  }
}

sub qdev {
  my $self = shift;
  my $sess = $self->session('user_id');
  my @params = $self->param(['title4', 'subtitle4', 'dev1', 'dev2','dev3','dev4','dev5']);
  my $sql = qq{update IndexQDev set a = "$params[0]", b = "$params[1]", c = "$params[2]", d = "$params[3]", e = "$params[4]", f = "$params[5]", g = "$params[6]";};
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    $dbh->do($sql);
    $dbh->commit;
    $dbh->disconnect;
    $self->stash(admin => $sess);
    $self->render('/index/index');
  } else {
    $self->render(text => "请登录")
  }
}

1;
