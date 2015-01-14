package KelvenWeb::Controller::Image;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Upload;
use utf8;
use Encode;
use Digest::MD5 qw(md5 md5_hex);
use DBI;
use lib '../../../';
use CMSConfig;

sub index {
  my $self = shift;
  my $sess = $self->session('user_id');
  if ($sess) {
    $self->stash(admin => $sess);
    $self->render('/image/index');
  } else {
    $self->render(text => '请登录');
  }
}

sub upload {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $description = $self->param('description');
  my $linked_to = $self->param('linked_to');
  my $category = $self->param('category');
  my $subcategory = $self->param('subcategory');
  my $article = $self->param('article');
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});

  # Check file size
  return $self->render(text => 'File is too big.', status => 200)
  if $self->req->is_limit_exceeded;

  # Process uploaded file
  if ($sess) {
    return $self->redirect_to('/image/index') unless my $file = $self->param('fileupload');
    my $size = $file->size;
    my $name = $file->filename;
    return $self->render(text => '请选择文件') unless $name;
    my ($prefix, $postfix) = split /\./, $name;
    $prefix .= '-' . int(rand(10000));
    $description = $prefix unless $description;
    $name = encode('utf8', $prefix);
    $name = md5_hex($name);
    my $url = '/root/www/kelven_web/public/upload/' . $name . "." . "$postfix";
    my $weburl = '/upload/' . $name . "." . "$postfix";
    my $sql = qq{insert into Image (url, description, linked_to, category, subcategory, article_i) values ("$weburl", "$description", "$linked_to", "$category", "$subcategory", "$article");};
    $dbh->do($sql);
    $dbh->commit;
    $file->move_to($url);
    $self->stash(admin => $sess);
    $self->redirect_to('/image/index');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}

sub update {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $num = $self->param('num');
  my $description = $self->param("desc-$num");
  my $weburl = $self->param("weburl-$num");
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $sql = qq{update Image set description = "$description", linked_to = "$weburl" where id = "$num";};
    $dbh->do($sql);
    $dbh->commit;
    $self->stash(admin => $sess);
    $self->redirect_to('/image/index');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->disconnect;
}

sub delete {
  my $self = shift;
  my $sess = $self->session('user_id');
  my $num = $self->param('num');
  my $description = $self->param("desc-$num");
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  if ($sess) {
    my $sth = $dbh->prepare(qq{select url from Image where id = "$num"});
    $sth->execute();
    my @url = $sth->fetchrow_array();
    $sth->finish;
    my $sql = qq{delete from Image where id = "$num";};
    my $realurl = '../../../public' . $url[0];
    my $delresult = qx "rm $realurl";
    $dbh->do($sql);
    $self->stash(admin => $sess);
    $self->redirect_to('/image/index');
  } else {
    $self->render(text => '请登录');
  }
  $dbh->commit;
  $dbh->disconnect;
}

1;
