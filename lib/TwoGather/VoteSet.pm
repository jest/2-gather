package TwoGather::VoteSet;
use Moose;
use Moose::Util::TypeConstraints;
use TwoGather::Vote;

has 'votes' => ( is => 'rw', isa => 'ArrayRef[TwoGather::Vote]', default => sub { [] } );

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

no Moose;

1;
