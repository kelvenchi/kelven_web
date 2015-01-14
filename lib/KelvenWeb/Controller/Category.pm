package KelvenWeb::Controller::Category;
use Mojo::Base 'Mojolicious::Controller';
use Encode;
use utf8;
use DBI;
use lib '../../../';
use CMSConfig;

sub index {
  my $self = shift;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => $sess);
    $self->render('/category/index');
  } else {
    $self->render(text => '请登录');
  }
}

sub add {
  my $self = shift;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => $sess);
    $self->render('/category/add');
  } else {
    $self->render(text => '请登录');
  }
}

sub rm {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $first = $self->session('first');
  my $rows = $self->session('rows');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my @chosen;
  for(@{$rows}) {
    push @chosen, $self->param("table_item$_") if $self->param("table_item$_");
  }
  my $chosen = join(',', @chosen);
  if ($sess) {
    $self->render(text => '请选择分类') if $chosen;
    $self->stash(admin => $sess);
    my $sql = qq{delete from Category where id in ($chosen);};
    for (@chosen) {
      my $sth = $dbh->prepare(qq{select name from Category where id = $_});
      $sth->execute;
      my @cname = $sth->fetchrow_array();
      $sth->finish;
      my $sql2 = qq{delete from Subcategory where belong_to = $_;};
      my $sql3 = qq{delete from Articles where category = "$cname[0]"};
      $dbh->do($sql2);
      $dbh->do($sql3);
    }
    $dbh->do($sql) if $chosen;
    $dbh->commit if $chosen;
    $self->redirect_to('/category/index');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}

sub add_pri {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $name = $self->param("category_name");
  my $desc = $self->param("category_desc");
  my $category = $self->session('category');
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    my $sth = $dbh->prepare(qq{select name from Category;});
    $sth->execute;
    my $sname = $sth->fetchall_arrayref();
    $sth->finish;
    $dbh->commit;
    my $samename = 1;
    for (@{$sname}) {
      $samename = '' if decode('utf8', $_->[0]) eq $name
    }
    if ($name && $samename) {
      $name = encode 'utf8', $name;
      $desc = encode 'utf8', $desc;
      my $sql = qq{insert into Category (name, description) values ("$name", "$desc");};
      $dbh->do($sql);
      $dbh->commit;
      $self->stash(admin => $sess);
      $self->redirect_to('/category/index');
    }
    else {
      $self->render(text => "分类名称不能为空也不能重复");
    }
    $dbh->disconnect;
  } else {
    $self->render(text => '请登录');
  }
}

sub add_sub {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $category_id = $self->param('category');
  my $name = $self->param("subcategory_name");
  my $desc = $self->param("subcategory_desc");
  my $subcategory = $self->session('category');
  my $sql;
  unless ($category_id) {
    $self->render(text => "主分类不能为空");
    return;
  }
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    my $samename = 1;
    my $sth = $dbh->prepare(qq{select name from Subcategory;});
    $sth->execute;
    my $sname = $sth->fetchall_arrayref();
    $sth->finish;
    for (@{$sname}) {
      $samename = '' if decode('utf8', $_->[0]) eq $name
    }
    if ($name && $samename) {
      # $name = encode 'utf8', $name;
      # $desc = encode 'utf8', $desc;
      $sql = qq{insert into Subcategory (name, description, belong_to) values ("$name", "$desc", "$category_id");};
      $dbh->do($sql);
      $self->stash(admin => $sess);
      $self->redirect_to('/category/index');
      $dbh->commit;
    }
    else {
      $self->render(text => "分类名称不能为空也不能重名");
    }
    $dbh->disconnect;
  } else {
    $self->render(text => '请登录');
  }
}

sub edit {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $edit_id = $self->stash('num');
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    my $sth = $dbh->prepare(qq{SELECT name, description from Category where id = "$edit_id";});
    $sth->execute();
    my @editnum = $sth->fetchrow_array();
    $self->stash(edit_title => $editnum[0], edit_desc => $editnum[1], edit_id => $edit_id, admin => $sess);
    $sth->finish;
    $dbh->disconnect;
    $self->render('/category/edit');
  } else {
    $self->render(text => "请登录");
  }
}

sub update_pri {
  my $self = shift;
  my $name = $self->param("category_name");
  my $desc = $self->param("category_desc");
  my $sess = $self->session('user_id');
  my $edit_id = $self->session('edit_id');
  my $category = $self->session('category');
  $category = decode 'utf8', $category;
  my ($sql, $sql2, $sql3);
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    if ($name) {
      my $sth = $dbh->prepare(qq{select name from Category where id = "$edit_id"});
      $sth->execute();
      my @result = $sth->fetchrow_array();
      $sth->finish();
      my $name2 = encode 'utf8', $name;
      $sql = qq{update Category set name = "$name", description = "$desc" where id = "$edit_id"};
      $sql2 = qq{update Image set category = "$name2" where category = "$result[0]"};
      $sql3 = qq{update Articles set category = "$name2" where category = "$result[0]"};
      $dbh->do($sql);
      $self->stash(admin => $sess);
      $self->redirect_to('/category/index');
      # $self->render(text => "$name $category");
      $dbh->commit;
    }
    else {
      $self->render(text => "分类名称不能为空");
    }
    $dbh->disconnect;
  } else {
    $self->render(text => '请登录');
  }
}

sub delete {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $delete_id = $self->stash('num');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    $self->stash(admin => $sess);
    my $sql = qq{delete from Category where id in ($delete_id);};
    my $sql2 = qq{delete from Subcategory where belong_to = $delete_id;};
    my $sql3 = qq{delete from Articles where category = $delete_id};
    $dbh->do($sql);
    $dbh->do($sql2);
    $dbh->do($sql3);
    $dbh->commit;
    $self->redirect_to('/category/index');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}

sub subedit {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $subedit_id = $self->stash('num');
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    my $sth = $dbh->prepare(qq{SELECT name, description, belong_to from Subcategory where id = "$subedit_id";});
    $sth->execute();
    my @subeditnum = $sth->fetchrow_array();
    my $sth2 = $dbh->prepare(qq{SELECT name from Category where id = "$subeditnum[2]"});
    $sth2->execute;
    my @editnum = $sth2->fetchrow_array();
    $self->stash(subedit_title => $subeditnum[0], subedit_desc => $subeditnum[1], subedit_belongto => $subeditnum[2], category_name => $editnum[0], admin => $sess);
    $sth->finish;
    $sth2->finish;
    $dbh->disconnect;
    $self->render('/category/subedit');
  } else {
    $self->render(text => "请登录");
  }
}

sub update_sub {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $subedit_id = $self->session("subedit_id");
  my $subedit_title = $self->session('subedit_title');
  my $cname = $self->param("category");
  my $name = $self->param("subcategory_name");
  my $desc = $self->param("subcategory_desc");
  my $category = $self->session('category');
  my ($sql, $sql2, $sql3);
  if ($sess) {
    my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
    $subedit_title = decode 'utf8', $subedit_title;
    if ($name) {
      # $_ = encode 'utf8', $_ for ($name, $desc, $cname);
      $sql = qq{update Subcategory set name = "$name", description = "$desc",  belong_to = "$cname" where belong_to = "$subedit_id" and name = "$subedit_title"};
      $sql2 = qq{update Image set subcategory = "$name" where subcategory="$subedit_title"};
      $sql3 = qq{update Articles set subcategory = "$name" where subcategory = "$subedit_title"};
      $dbh->do($sql);
      $dbh->do($sql2);
      $dbh->do($sql3);
      $self->stash(admin => $sess);
      $self->redirect_to('/category/index');
      $dbh->commit;
    }
    else {
      $self->render(text => "分类名称不能重名或者为空");
    }
    $dbh->disconnect;
  } else {
    $self->render(text => '请登录');
  }
}

sub subdelete {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $delete_id = $self->stash('num');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    $self->stash(admin => $sess);
    my $sth = $dbh->prepare(qq{select name from Subcategory where id = $delete_id;});
    $sth->execute;
    my @sname = $sth->fetchrow_array();
    $sth->finish;
    my $sql1 = qq{delete from Subcategory where id = $delete_id;};
    my $sql2 = qq{delete from Articles where subcategory = "$sname[0]"};
    $dbh->do($sql1);
    $dbh->do($sql2);
    $dbh->commit;
    $self->redirect_to('/category/index');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}

1;
