#!/usr/bin/env perl

use lib 'lib';
use Mojolicious::Lite;
use TwoGather::Vote;
use TwoGather::VoteSet;
use KiokuDB;
sub kioku_dir {
	return KiokuDB->connect("dbi:SQLite:dbname=siatka.db");
}


get '/' => sub {
	shift->redirect_to('show');
} => 'index';

get '/show' => sub {
	my $self = shift;
	my $dir = kioku_dir;
	
	my $scope = $dir->new_scope;
	my $vs = $dir->lookup(1);	# a kind of magic
	$self->render('show', votes => $vs, kioku => $dir);
} => 'show';

post '/delete' => sub {
	
} => 'delete';

post '/add' => sub {
	my $self = shift;
	my $dir = kioku_dir;
	
	my $scope = $dir->new_scope;
	my $vs = $dir->lookup(1);	# a kind of magic
	
	my $v = TwoGather::Vote->new(name => 'Przemek Wesołek', opt => 'maybe', min_people => 3);
	$vs->votes([ @{$vs->votes}, $v]);
	$dir->store($vs);
	
	$self->redirect_to('show');
} => 'add';

get '/edit/:vid' => sub {
	
} => 'edit';

#use Data::Dumper;
#print Dumper(do_magic());
#print "OK";
shagadelic;


sub do_magic {
	my $v1 = TwoGather::Vote->new(opt => 'maybe', min_people => 3);
	my $v2 = TwoGather::Vote->new(opt => 'yes');
	my $vs1 = TwoGather::VoteSet->new;
	$vs1->votes([$v1, $v2]);
	
	my $dir = kioku_dir;
	my $scope = $dir->new_scope;
	$dir->store($vs1);
	return $vs1->hope_for;
}

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
		<td><%== $v->opt %></td>
		<td><%== $v->opt eq 'maybe' ? $v->min_people : '' %></td>
		<td><form action="<%== url_for("delete") %>" method="POST"><input type="hidden" name="id" value="<%==$vid%>"><button type="submit">Usuń</button></form></td>
		<td><form action="<%== url_for("edit", vid => $vid) %>" method="GET"><button type="submit">Popraw</button></form></td>
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
<td>
	<input type="radio" name="opt" value="yes">Tak</input><br>
	<input type="radio" name="opt" value="no">Nie</input><br>
	<input type="radio" name="opt" value="maybe">Może...</input>
</td>
<td>gdy będzie co najmniej <input type="text" name="min_people" size="2"> osób</td>
<td><button type="submit">Dodaj</button></td>

@@ layouts/std.html.ep
<!doctype html><html>
	<head>
		<title>Siatka</title>
		<meta name="http-equiv" value="Content-Type: text/html; charset=UTF-8">
	</head>
	<body><%== content %></body>
</html>
