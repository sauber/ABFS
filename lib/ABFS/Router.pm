package ABFS::Router;

# Seek responses to of requests.

use Moose;
use MooseX::Method::Signatures;

has handlers => ( is=>'ro', isa=>'HashRef[ABFS::Handler]', default=sub{{}} );

method newmsg ( ABFS::Data::Message $msg ) {
  # Which service
  my $service = $newmsg->service;
  # Request or Response
  if ( $msg->exchange eq 'request' ) {
    
  }
}

__PACKAGE__->meta->make_immutable;
 
1;

