package ABFS::Handler;
use Moose::Role;

# A handler takes service requests

requires 'get', 'post';

requires 'service';

1;
