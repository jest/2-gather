#!/usr/bin/env perl

use lib 'lib';
use lib 'extlib/Validator-Custom-Ext-Mojolicious';

use 5.010;

use utf8;

use Mojolicious::Lite;
use Validator::Custom::Ext::Mojolicious;

use TwoGather::Vote;
use TwoGather::VoteSet;

use KiokuDB;
sub kioku_dir {
	my $dir = KiokuDB->connect("dbi:SQLite:dbname=siatka.db");
	return ($dir, $dir->new_scope);
}

my $validator = Validator::Custom::Ext::Mojolicious->new(
	validator => 'Validator::Custom::HTMLForm',
	rules     => {
		create => [
			title => [ [ { length => [ 0, 255 ] }, 'Title is too long' ] ],
			brash => [
				[ 'not_blank', 'Select brach' ],
				[
					{ 'in_array' => [qw/bash cpp c-sharp/] }, 'Brash is invalid'
				]
			],
			content => [
				[ 'not_blank', "Input content" ],
				[ { length => [ 0, 4096 ] }, "Content is too long" ]
			]
		],
		index => [

			# ...
		],
		
		add => [
			name => [
				[ 'not_blank', "Nie podano nazwiska" ]
			],
			opt => [
				[ { in_array => [ qw(yes no maybe) ] }, "Nie wybrano opcji" ],
			],
			min_people => [
				[ 'uint', "Liczba osób nie jest prawidłowa" ],
			]
		]
	}
);


get '/' => sub { shift->redirect_to('show'); } => 'index';

sub show_action {
	my $self = shift;
	my ($dir, $scope) = kioku_dir;
	
	my $vs = $dir->lookup(1);	# a kind of magic
	$self->render('show',
		votes => $vs,
		kioku => $dir,
		OptNames => { yes => 'Tak', no => 'Nie', maybe => 'Może...' }
	);
}

get '/show' => \&show_action => 'show';

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
	
	$self->param('min_people', 0) unless length($self->param('min_people') // '') > 0;
	my $vresu = $validator->validate($self);
	if (! $vresu->is_valid) {
		my $err = $vresu->errors;
		$self->stash('errors', $err);
		return show_action($self);
	}
	
	my ($dir, $scope) = kioku_dir;
	my $vs = $dir->lookup(1);	# a kind of magic
	
	my $v = TwoGather::Vote->new(
		map { $_ => $self->param($_) } qw(name opt min_people)
	);
	$vs->votes([ @{$vs->votes}, $v]);
	$dir->store($vs);
	
	$self->redirect_to('show');
} => 'add';

shagadelic;


__DATA__

@@ show.html.ep
% layout 'std';
<table>
%== $self->render_partial('people-list');
<tr>
<form action="<%== url_for("add") %>" method="POST">
%== $self->render_partial('vote-form');
</form>
</tr>
</table>
%== $self->render_partial('errors-pane');

@@ people-list.html.ep
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

@@ errors-pane.html.ep
% if (defined $self->stash('errors')) {
<div class="errors-list">
<p>Wystąpiły błędy:</p>
<ul>
% for (@{$self->stash('errors')}) {
<li><%== $_ %></li>
% }
</ul>
</div>
% }

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
		<style type="text/css">
			.errors-list {
				color: red;
			}
		</style>
	</head>
	<body>
	<h2>Lista obecności</h2>
	<%== content %>
	</body>
</html>
