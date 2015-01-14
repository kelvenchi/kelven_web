package KelvenWeb::Controller::Articlemgmt;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use utf8;
use Encode;
use lib '../../../';
use CMSConfig;

sub operate {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $operate = $self->param('operation');
  my $page = $self->session('page');
  my $count = $self->session('count');
  my $first = $self->session('first');
  my $rows = $self->session('rows');
  my @chosen;
  for ($first .. $rows->[0]) {
    push @chosen, $self->param("table_item$_") if ($self->param("table_item$_"));
  }
  if ($sess) {
    $self->$operate(@chosen) unless $operate =~ qr/all/;
    $self->stash(admin => $sess);
    $self->render('/admin/index');
  } else {
    $self->render(text => '请登录');
  }
}

sub search {
}

sub remove {
  my $self = shift;
  my @chosen = @_;
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my $chosen = join ',', @chosen;
  if ($chosen) {
    my $sql = qq{delete from Articles where id in ($chosen);};
    $dbh->do($sql);
    $dbh->commit;
  }
  $dbh->disconnect;
}

sub republish {
  my $self = shift;
  my @chosen = @_;
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my $chosen = join ',', @chosen;
  if ($chosen) {
    my $sql = qq{update Articles set date = curdate() where id in ($chosen)};
    $dbh->do($sql);
    $dbh->commit;
  }
  $dbh->disconnect;
}

sub filtrate {
  my $self = shift;
  my $date = $self->param('date');
  my $category = $self->param('category');
  my $sess = $self->session('user_id');
  $self->stash(date => $date);
  $self->stash(admin => $sess);
  $self->stash(category => $category);
  my $sql;
  if ($date && $category && $sess) {
    $sql = qq{SELECT * FROM Articles where date = '$date' and category = '$category' ORDER BY id DESC;};
    $self->stash(sql => $sql);
    $self->render('/admin/filtrate');
  } elsif ($date && !$category && $sess) {
    $sql = qq{SELECT * FROM Articles where date = '$date' ORDER BY id DESC;};
    $self->stash(sql => $sql);
    $self->render('/admin/filtrate');
  } elsif (!$date && $category && $sess) {
    $sql = qq{SELECT * FROM Articles where category = '$category' ORDER BY id DESC;};
    $self->stash(sql => $sql);
    $self->render('/admin/filtrate');
  } elsif (!$date && !$category && $sess) {
    $sql = qq{SELECT * FROM Articles ORDER BY id DESC;};
    $self->stash(sql => $sql);
    $self->render('/admin/filtrate');
  } else {
    $self->render(text => '请登录');
  }
}

sub add_page {
  my $self = shift;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => $sess);
    $self->render('/admin/add');
  } else {
    $self->render(text => '请登录');
  }

}

sub insert {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $id_max = $self->session('id_max');
  my $url = "/article/$id_max";
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my @param = $self->param(['title', 'content', 'category', 'subcategory', 'model']);
  $_ = encode 'utf8', @param;
  if (!$param[2] && !$param[3] || !$param[4]) {
    $self->render(text => '请选择标题和模板');
  } elsif ($sess) {
    my $sql = qq{insert into Articles (title, content, date, category, subcategory, author, url, model) values (?, ?, curdate(), ?, ?, ?, ?, ?);};
    $dbh->do($sql, undef, $param[0], $param[1], $param[2], $param[3], $sess, $url, $param[4]);
    $dbh->commit;
    $self->stash(admin => $sess);
    $self->render('/admin/index');
  } else {
    $self->render(text => '非法操作');
  }
  $dbh->disconnect;
}

sub edit {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $num = $self->stash('num');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $sth = $dbh->prepare(qq{SELECT title, content, category, subcategory FROM Articles where id = $num});
    $sth->execute();
    my @edit = $sth->fetchrow_array();
    $_ = decode 'utf8', $_ for @edit;
    $sth->finish;
    $self->stash(admin => $sess, title => $edit[0], content => $edit[1], category => $edit[2], subcategory => $edit[3], id => $num);
    $self->render('/admin/edit');
  } else {
    $self->render(text => '请登录')
  }
  $dbh->disconnect;
}

sub update {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $id = $self->session('id');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my @param = $self->param(['title', 'content', 'category', 'subcategory']);
  $_ = encode 'utf8', $_ for @param;
  if (!$param[2] && !$param[3]) {
    $self->render(text => '请选择分类');
  } elsif ($sess && @param) {
    my $sql = qq{update Articles set title = ?, content = ?, date = curdate(), category = ?, subcategory = ? where id = $id};
    $dbh->do($sql, undef, $param[0], $param[1], $param[2], $param[3]);
    $dbh->commit;
    $self->stash(admin => $sess);
    $self->render('/admin/index');
  } else {
    $self->render(text => '非法操作');
  }
  $dbh->disconnect;
}

sub delete {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $delete_id = $self->stash('num');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $sql = qq{delete from  Articles where id = $delete_id};
    $dbh->do($sql);
    $dbh->commit;
    $self->stash(admin => $sess);
    $self->render('/admin/index');
  } else {
    $self->render(text => '非法操作');
  }
  $dbh->disconnect;
}

1;
