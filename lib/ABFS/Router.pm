package ABFS::Router;

# Seek responses to of requests.

use Moose;
use MooseX::Method::Signatures;
use ABFS::Data::Message;

has handlers => ( is=>'ro', isa=>'HashRef[ABFS::Handler]', default=>sub{{}} );

method newmsg ( ABFS::Data::Message $msg ) {
  # Which service
  my $service = $msg->service;
  # Request or Response
  if ( $msg->exchange eq 'request' ) {
    
  }
  return 1;
}

__PACKAGE__->meta->make_immutable;
 
1;

