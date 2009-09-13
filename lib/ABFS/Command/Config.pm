package ABFS::Command::Config;
use base ('ABFS::Command::Plugin');
use YAML::Syck qw(Dump Load);

=head1 NAME

ABFS::Command::Config - Read and execute config instructions

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

#sub _properties {
#  <<EOF;
#Command:
#  configread:
#
#Config:
#
#Depend:
# - command
#
#Event:
#
#Request:
#EOF
#}

#sub _properties {
#  #my $self = shift;
#  #my $config = Load $self->SUPER::_properties();
#  #$config->{Command} = [ qw(config) ];
#  #Dump $config
#  <<EOF;
#Depend:
# - Command::Load
#EOF
#}

sub _commandhelp {
  <<EOF;
Command:
  configread:
    summary: Reads commands from a string, and executes
    description: Line seperated commands are executed
    syntax: <commands>
EOF
} 




=head1 SYNOPSIS

  use ABFS::Command::Config;;

  my $config = ABFS::Command::Config;->new();

=head1 DESCRIPTION

Handles global configuration of all modules. Process configuration directives
from file or string.

=head1 FUNCTIONS

=head2 configread 

=cut

sub configread {
  my ( $self, $msg ) = @_;

  # XXX: Test if request can reach here.
  #warn "We reached configread\n";
  #use Data::Dumper; # XXX: debug
  #warn "Configcmd: " . Dumper $msg;

  # Read config from file or command string
  my @configlines;
  if ( $msg->{configfile} and -r $msg->{configfile} ) {
    open FH, $msg->{configfile};
    push @configlines, <FH>;
    close FH;
  }
  if ( $msg->{configcmd} ) {
    push @configlines, split /\n/, $msg->{configcmd};
  }

  # Generate messages for each config line
  # XXX: The request queue might execute these out of order. That could be
  #      a problem for example when trying to establisg a tcp connection
  #      before connection module is loaded.
  # XXX: Somehow use makerequest instead.
  return map {
    ABFS::Core::Message->new(
      command => 'commandline',
      message => $_,
      )
  } @configlines;
}

=head2 file

  $config->file( $filename );

Process config commands from file $filename.

=cut

sub file {
  my ( $self, $filename ) = @_;

  # XXX: todo
  # open filename
  #   line by line handle to command module for processing
  #   as request? commandrequest? where to send output?
  # close file
}

=head2 command

  $config->command( $cmdstr );
 

=cut

sub command {
  my ( $self, $cmdstr ) = @_;

  # This is were Request loop starts
  for my $l ( split /\n/, $cmdstr ) {

    #$self->{request}->add();
  }
}

=head2 conf

  $config->conf();
  $config->conf($key);
  $config->conf($key,$value[,$key2,$value2[,...]]);

List all config settings.
List one config setting.
Set one or more config setting.

=cut

sub conf {
  my $self = shift;

  if ( $#_ == -1 ) {

    # List one setting
    return $self->_allglobalconfig();
  }
  if ( $#_ == 0 ) {
    return $self->getmoduleconfig( $_[0] );
  } else {

    # Set setting
    $self->setmoduleconfig(@_);
  }
}

# List all global configuration
#
sub _allglobalconfig {
  my $self = shift;

  # List all settings
  if ( $self->{modules} ) {

    # Compile list of config from all modules, if any
    my $config;
    for my $m ( $self->_modulelist() ) {
      my $obj = $self->{modules}->getobj($m);

      # XXX: getconfig does not yet exists
      $config->{$m} = $obj->getconfig();
    }
    return $config;
  } elsif ( $self->{config} ) {

    # No modules exists, so I just return my own config if it exists
    return $self->{config} ? { config => $self->{config} } : undef;
  }
}

=head2 setmoduleconfig

  $config->setmoduleconfig($key,$value[,$key2,$value2[,...]]);

Set config values in modules.

If key of the form 'modulename:key' is used, then key in module named
modulename will be set. Otherwise a module that has a matching key is
searched for and set if possible.

=cut

# Set configuration in modules
#
sub setmoduleconfig {
  my ( $self, %parms ) = @_;

  my ( %obj, $modulelist );
PAIR: while ( my ( $key, $value ) = each %parms ) {

    # If key is of form 'module:key' then set in correct module
    if ( $key =~ /(\w+):(.*)/ ) {
      my $modulename = $1;
      my $modulekey  = $2;

      # If module not loaded, try to load and cache
      unless ( $obj{$modulename} ) {
        $obj{$modulename} = undef;
        $self->{modules}
          and $obj{$modulename} = $self->{modules}->getobj($modulename);
      }
      $obj{$modulename}->setconfig( $modulekey => $value )
        if $obj{$modulename};
    } else {

      # Try to guess which module has this config
      $modulelist ||= [ $self->_modulelist() ];
      for my $modulename (@$modulelist) {
        next unless $modulename;

        #warn "Guess modulename: $modulename\n"; # XXX: debug
        $obj{$modulename} ||= $self->{modules}->getobj($modulename);
        next unless $obj{$modulename}->getconfig($key);
        $obj{$modulename}->setconfig( $key, $value );
        next PAIR;
      }
    }

    # If we reach here, no module was found for setting config. Perhaps it
    # belong in config module itself?
    $self->setconfig( $key, $value ) if $self->getconfig($key);
  }
}

# Generate list of modules loaded, if any
#
sub _modulelist {
  my $self = shift;

  return $self->{modules}->nodelist() if $self->{modules};
}

# Process one line of config
# If the command is 'conf' skip command module
#
sub _processone {
  my ( $self, $line ) = @_;

  # Trim leading and trailing white space
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  my ($cmnd) = split /\s+/, $line, 2;
  if ( $cmnd eq 'conf' ) {
    $self->conf($line);
  } else {

    # If I have access to cmnd module, then hand over
    # XXX: Should probably make this a regular event request
    #      Which means compile a list of requests to return to caller
    if ( $self->{modules}
      and my $cmdobj = $self->{modules}->getobj('command') )
    {
      $cmdobj->process($line);
    }
  }
}

=head2 getmoduleconfig

  my $value = $config->getmoduleconfig($key);

Searches through all modules for one holding $key. Returns the value.
Key can be of the form 'module:key' or just 'key'.

=cut

sub getmoduleconfig {
  my ( $self, $key ) = @_;

  # If key is of form 'module:key' then return from specified module.
  if ( $key =~ /^(\w+):(.*)$/ ) {
    my $modulename = $1;
    my $modulekey  = $2;
    if ( $self->{modules}
      and my $obj = $self->{modules}->getobj($modulename) )
    {
      return $obj->getconfig($modulekey);
    }
  }

  # Otherwise search for module that has key
  else {
    for my $modulename ( $self->_modulelist() ) {
      next unless $modulename;
      my $obj = $self->{modules}->getobj($modulename);
      if ( my $value = $obj->getconfig($key) ) {
        return $value;
      }
    }
  }

  # If we reach here, no modules where found. Perhaps it's in our module?
  return $self->getconfig($key);
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Config;

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Config;
