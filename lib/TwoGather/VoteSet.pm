package TwoGather::VoteSet;
use Moose;
use Moose::Util::TypeConstraints;

use TwoGather::Vote;

has 'votes' => (
	traits => [ 'Array' ],
	is => 'rw',
	isa => 'ArrayRef[TwoGather::Vote]',
	default => sub { [] },
	handles => {
		add_vote => 'push',
		del_vote_at => 'delete',
	}
);

sub hope_for {
	my $self = shift;
	
	my @v = @{$self->votes};
	while (@v) {
		my $num = int @v;
		@v = grep {
			$_->opt eq 'yes' ||
			$_->opt eq 'maybe' && $_->min_people <= $num
		} @v;
		last if $num == int @v;
	}
	return \@v;
}

sub del_vote {
	my ($self, $v) = @_;
	my $votes = $self->votes;
	my @ids = grep { $votes->[$_] == $v } 0..$#$votes;
	$self->del_vote_at($_) for (@ids);
}

no Moose;

1;
