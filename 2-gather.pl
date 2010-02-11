#!/usr/bin/env perl

use lib 'lib';
use Mojolicious::Lite;
use TwoGather::Vote;
use TwoGather::VoteSet;
use KiokuDB;
sub kioku_dir {
	return KiokuDB->connect("dbi:SQLite:dbname=siatka.db");
}


get '/' => 'index';

get '/show' => sub {
	my $self = shift;
	my $dir = kioku_dir;
	
	$self->render('show');
};

get '/:groovy' => sub {
	my $self = shift;
	do_magic();
	$self->render('test');
};


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

@@ test.html.ep
% layout 'funky';


@@ index.html.ep
% layout 'funky';
Yea baby!

@@ layouts/funky.html.ep
<!doctype html><html>
	<head><title>Funky!</title></head>
	<body><%== content %></body>
</html>
