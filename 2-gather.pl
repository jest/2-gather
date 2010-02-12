#!/usr/bin/env perl

use lib 'lib';

use utf8;

use Mojolicious::Lite;

use TwoGather::Vote;
use TwoGather::VoteSet;

use KiokuDB;
sub kioku_dir {
	my $dir = KiokuDB->connect("dbi:SQLite:dbname=siatka.db");
	return ($dir, $dir->new_scope);
}

get '/' => sub { shift->redirect_to('show'); } => 'index';

get '/show' => sub {
	my $self = shift;
	my ($dir, $scope) = kioku_dir;
	
	my $vs = $dir->lookup(1);	# a kind of magic
	$self->render('show',
		votes => $vs,
		kioku => $dir,
		OptNames => { yes => 'Tak', no => 'Nie', maybe => 'Może...' }
	);
} => 'show';

post '/delete' => sub {
	my $self = shift;
	my ($dir, $scope) = kioku_dir;
	my $vs = $dir->lookup(1);	# a kind of magic
	
	my $id = $self->param('id');
	my $v = $dir->lookup($id) if $id;
	if ($id && $v) {
		$vs->del_vote($v);
		$dir->delete($v);
	}
	$dir->update($vs);
	$self->redirect_to('show');
} => 'delete';

post '/add' => sub {
	my $self = shift;
	my ($dir, $scope) = kioku_dir;
	my $vs = $dir->lookup(1);	# a kind of magic
	
	my $v = TwoGather::Vote->new(name => 'Przemek Wesołek', opt => 'maybe', min_people => 3);
	$vs->votes([ @{$vs->votes}, $v]);
	$dir->store($vs);
	
	$self->redirect_to('show');
} => 'add';

shagadelic;


__DATA__

@@ show.html.ep
% layout 'std';
<h2>Lista obecności</h2>
<table>
<tr>
	<th>Imię i nazwisko</th>
	<th>Głos</th>
	<th>Minimalna liczba osób</th>
</tr>
% for my $v (@{$votes->votes}) {
% my $vid = $kioku->object_to_id($v);
	<tr>
		<td><%== $v->name %></td>
		<td><%== $OptNames->{$v->opt} %></td>
		<td><%== $v->opt eq 'maybe' ? $v->min_people : '&mdash;' %></td>
		<td><form action="<%== url_for("delete") %>" method="POST"><input type="hidden" name="id" value="<%==$vid%>"><button type="submit">Usuń</button></form></td>
	</tr>
% }
<tr>
<form action="<%== url_for("add") %>" method="POST">
%== $self->render_partial('vote-form');
</form>
</tr>
</table>

@@ vote-form.html.ep
<td><input type="text" name="name"></td>
<td colspan="2">
	<input type="radio" name="opt" value="yes">Tak</input><br>
	<input type="radio" name="opt" value="no">Nie</input><br>
	<input type="radio" name="opt" value="maybe">Tak, jeśli będzie co najmniej <input type="text" name="min_people" size="2"></input> osób</input>
</td>
<td><button type="submit">Dodaj</button></td>

@@ layouts/std.html.ep
<!doctype html><html>
	<head>
		<title>Siatka</title>
		<meta name="http-equiv" value="Content-Type: text/html; charset=UTF-8">
	</head>
	<body><%== content %></body>
</html>
