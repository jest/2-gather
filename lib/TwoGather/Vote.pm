package TwoGather::Vote;
use Moose;
use Moose::Util::TypeConstraints;

enum 'TwoGather::VoteType' => qw( yes no maybe );
has 'opt' => ( is => 'rw', isa => 'TwoGather::VoteType', required => 1 );
has 'min_people' => ( is => 'rw', isa => 'Int', default => 0 );

no Moose;

1;