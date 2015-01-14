package KelvenWeb::Controller::Article;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use lib '../../../';
use CMSConfig;

sub show {
  my $self = shift;
  my $id = $self->stash('num');
  my $page = $self->param('page');
  $page = 0 unless $page;
  my $dbh = DBI->connect("DBI:mysql:database=$CMSConfig::database;host=$CMSConfig::host","$CMSConfig::user","$CMSConfig::pass", {RaiseError => 1, AutoCommit => 0});
  my $sth = $dbh->prepare(qq{select category, subcategory, model, title, content, author, date, url from Articles where id = $id;});
  $sth->execute;
  my @judge = $sth->fetchrow_array();
  $sth->finish;
  my ($category, $subcategory, $model, $title, $content, $author, $date, $url) = @judge;
  my $sth2 = $dbh->prepare(qq{select url from Articles where category = "$category" limit 1});
  my $sth3 = $dbh->prepare(qq{select url from Articles where title = "$subcategory"});
  $sth2->execute;
  $sth3->execute;
  my @curl = $sth2->fetchrow_array();
  my @surl = $sth3->fetchrow_array();
  $sth2->finish;
  $sth3->finish;
  $self->stash(title => $title, content => $content, author => $author, date => $date, category => $category, subcategory => $subcategory, id => $id);
  $self->stash(curl => $curl[0], surl => $surl[0], url => $url, page => $page);
  if ($model eq 'c') {
    $self->render('/article/article');
  } elsif ($model eq 'l') {
    $self->render('/article/articleset');
  } elsif ($model eq 'i') {
    $self->render('/article/imageset');
  } elsif($model eq 's') {
    $self->render('/article/imageset-s');
  } elsif($model eq 'ic') {
    $self->render('/article/imageset-ic');
  } else {
    $self->render(text => '您访问的也面不存在');
  }
  $dbh->disconnect;
}

1;
