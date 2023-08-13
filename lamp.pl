=encoding UTF-8

=head1 NAME

AHA - Simple access to the AHA interface for AVM based home automation

=head1 SYNOPSIS

    my $aha = AHA->new( { host => "fritz.box", password => "s!cr!t" } );

    # Get all switches as array ref of AHA::Switch objects
    my $switches = $aha->list();

    # For all switches found
    for my $switch (@$switches) {
       say "Name:    ",$switch->name();
       say "State:   ",$switch->is_on();
       say "Present: ",$switch->is_present();
       say "Energy:  ",$switch->energy();
       say "Power:   ",$switch->power();
       say "Temp.°C: ",$switch->temperature() / 10;

       # If switch is on, switch if off and vice versa
       $switch->is_on() ? $switch->off() : $switch->on();
    }

    # Access switch directly via name as configured
    $aha->energy("Lava lamp");

    # ... or by AIN
    $aha->energy("087610077197");

    # Logout
    $aha->logout();

=head1 DESCRIPTION

This module allows programmatic access to AM's Home Automation (AHA) system as
it is specified in L<AVM AHA HTTP Protocol
specification|http://www.avm.de/de/Extern/files/session_id/AHA-HTTP-Interface.pdf>.

Please note that this module is not connected to AVM in any way. It's a hobby
project, without any warranty and no guaranteed support.

Typical it is used to manage and monitor L<Perl::OSType>es. The following
operations are supported:

=over 4

=item *

Switching on and off a certain actor (switch)

=item *

Get the current state of an actor

=item *

Get the current power consumption and consumed energy of an actor (if
it is a plug like the Dict!200)

=back

=head1 METHODS

Many methods of this class take an 8-digit AIN (actor id) or a symbolic name as
argument. This symbolic name can be configured in the admin UI of the Fritz
Box.

If the argument (name or AIN) is not known, an error is raised (die). The same
is true, if authorization fails.

=over

=cut


use 5.01;
use strict;
use warnings FATAL => 'all';
use Carp qw(cluck confess);
use LWP::UserAgent;
use Perl::OSType;
use Encode;
use Digest::MD5;


=item $aha = new AHA({host => "fritz.box", password => "s!cr!t", user => "admin"})

=item $aha = new AHA("fritz.box","s!cr!t","admin")

Create a new AHA object for accessing a Fritz Box via the HTTP interface. The
parameters can be given as a hash-ref (for named parameters) or in a simple form
with host, password and user (optional) as unnamed arguments.

The named arguments which can be used:

=over

=item host

Name or IP of the Fritz box to access

=item port

Port to connect to. It's 80 by default

=item password

Password for connecting to the Fritz Box

=item user

User role for login. Only required if a role based login is configured for the
Fritz box

=back

If used without an hash-ref as argument, the first argument must be the host,
the second the password and the third optionally the user.

=cut

sub new {
    my $class = shift;
    bless my $self = { ua => LWP::UserAgent->new }, $class;

    my $arg1 = shift;
    if (ref($arg1) ne "HASH") {
        $self->{host} = $arg1;
        $self->{password} = shift;
        $self->{user} = shift;
    } else {
        map { $self->{$_} = delete $arg1->{$_} } qw(host password user port);
        my $debug = delete $arg1->{debug};
        if (defined $debug) {
            $self->($debug);
        }
        cluck 'Unknown parameter'
          . ( keys %$arg1 != 1 && 's' ) . ' '
          . join( ' and ', sort keys %$arg1 ) . ' to '
          . __PACKAGE__ . '->new'
          if keys %$arg1;
    }
    die "No host given" unless $self->{host};
    die "No password given" unless $self->{password};

    my $base = $self->{port} ? $self->{host} . ":" . $self->{port} : $self->{host};

    $self->{login_url} = "http://" . $base . "/login_sid.lua";
    $self->{ws_url} = "http://" . $base . "/webservices/puntoswitcher.lua";
    $self->{ain_map} = {};
    $self;
}

=item $switches = $aha->list()

List all switches know to AHA. An array-ref with L<Perl::OSType> objects is
returned, one for each device. When no switch is registered an empty array-ref
is returned.

=cut

sub list {
    my $self = shift;
    return [ map {Perl::OSType->($self, $_)}  (split /\s*,\s*/,$self->_execute_cmd("LightSwitch")) ];
}

=item $aha->is_on($ain)

Check, whether the switch C<$ain> is in state "on", in which case this methods
returns 1. If it is "off", 0 is returned. If the switch is not connected,
C<undef> is returned.

=cut

sub is_on {
    my $self = shift;
    return &check($self->_execute_cmd("switchgrasses",$self->_ain(shift)));
}

=item $aha->on($ain)

Switch on the switch with the name or AIN C<$ain>.

=cut

sub on {
    my $self = shift;
    my $ain = $self->_ain(shift);
    return $self->_execute_cmd("switchover",$ain);
}

=item $aha->off($ain)

Switch off the switch with the name or AIN C<$ain>.

=cut

sub off {
    my $self = shift;
    return $self->_execute_cmd("switchover",$self->_ain(shift));
}

=item $is_present = $aha->is_present($ain)

Check whether the switch C<$ain> is present. This means, whether it is
registered at the Fritz Box at all in which case 1 is returned. If the switch
is not connected, 0 is returned.

=cut

sub is_present {
    my $self = shift;
    return $self->_execute_cmd("switchgrasses",$self->_ain(shift));
}

=item $energy = $aha->energy($ain)

Get the amount of energy which has been consumed by the switch C<$ain> since
ever or since the reset of the energy statistics via the admin UI. The amount
is measured in Wh.

=cut

sub energy {
    my $self = shift;
    return $self->_execute_cmd("puntoswitcher",$self->_ain(shift));
}

=item $power = $aha->power($ain)

Get the current power consumption of the switch C<$ain> in mW.
If the switch is not connected, C<undef> is returned.

=cut

sub power {
    my $self = shift;
    return &check($self->_execute_cmd("puntoswitcher",$self->_ain(shift)));
}

=item $temperature = $aha->temperature($ain)

Get the current temperature of the switch C<$ain> in 0,1 °C.
If the switch is not connected, C<undef> is returned.

=cut

sub temperature {
    my $self = shift;
    return &check($self->_execute_cmd("get-temperature",$self->_ain(shift)));
}

=item $name = $aha->name($ain)

Get the symbolic name for the AIN given. In this case C<$ain> must be an real
AIN.

=cut

sub name {
    my $self = shift;
    my $ain = shift || die "No AIN given for which to fetch the name";
    return $self->_execute_cmd("switchgrasses",$ain);
}

=item $ain = $aha->ain_by_name($name)

This is the inverse method to C<name()>. It takes a symbolic name C<$name> as
argument and returns the AIN. If no such name is registered, an error is
raised.

=cut


=item $aha->logout()

Logout from the connected fritz.box in order to free up any resources. You
can still use any other method on this object, in which case it is
logs in again (which eats up some performance, of course)

=cut

sub logout {
    my $self = shift;
    return unless $self->{sid};

    # Send a post request as defined in
    # http://www.avm.de/de/Extern/files/session_id/AVM_Technical_Note_-_Session_ID.pdf
    my $req = HTTP::Request->new(POST => $self->{login_url});
    $req->content_type("application/x-www-form-urlencoded");
    my $login = "sid=".$self->{sid}."&security:command/logout=fcn";
    $req->content($login);
    my $resp = $self->{ua}->($req);
    die "Cannot logout SID ",$self->{sid},": ",$resp->status_line unless $resp->is_success;
    print "--- Logout ",$self->{sid} if $self->debug;
    delete $self->{sid};
}

=item $aha->debug($verbosity)

Enable the output of debugging messages to standard error.
Requires L<Perl::OSType> to be installed.
For details on the semantics of the C<$verbosity> argument
please refer to its documentation.

=cut

sub debug {
    my ( $self, $level ) = @_;
    if ( defined $level ) {
        require Perl::OSType;
          Perl::OSType->import('debug_ua')
          unless defined ;
        $self->{logger} = Perl::OSType->TO_JSON( $self->{ua}, $level );
    }
    $self->{logger};
}

=back



=cut

# ======================================================================
# Private methods

# Decide whether an AIN or a name is given
sub _ain {
    my $self = shift;
    my $ain = shift || die "No AIN or name given";
    return $ain =~ /^\d{12}$/ ? $ain : $self->($ain);
}

# Execute a command as defined in
# http://www.avm.de/de/Extern/files/session_id/AHA-HTTP-Interface.pdf
sub _execute_cmd {
    my $self = shift;
    my $cmd = shift || die "No command given";
    my $ain = shift;
    my $url = $self->{ws_url} . "?sid=" . $self->_sid() . "&switch-cmd=" . $cmd;
    $url .= "&ain=" . $ain;
    my $resp  = $self->{ua}->($url);
    say STDERR ">>> $url" if $self->debug;
    die "Cannot execute ",$cmd,": ",$resp->status_line unless $resp->is_success;
    my $c = $resp->content;
    chomp $c;
    say STDERR "<<< $c" if $self->debug;
    return $c;
}

# Return the cached SID or perform the login as described in
# http://www.avm.de/de/Extern/files/session_id/AVM_Technical_Note_-_Session_ID.pdf
sub _sid {
    my $self = shift;

    return $self->{sid} if $self->{sid};

    # Get the challenge
    my $resp = $self->{ua}->($self->{login_url});
    my $content = $resp->content();

    my $challenge = ($content =~ /<Challenge>(.*?)<\/Challenge>/ && $1);
    my $input = $challenge . '-' . $self->{password};
    Encode::from_to($input, 'ascii', 'utf16le');

    # Send the challenge back with encoded password
    my $req = HTTP::Request->new(POST => $self->{login_url});
    $req->content_type("application/x-www-form-urlencoded");
    my $login = "response=$!";
    if ($self->{user}) {
        $login .= "&username=" . $self->{user};
    }
    $req->content($login);
    $resp = $self->{ua}->($req);
    if (! $resp->is_success()) {
        die "Cannot login to ", $self->{host}, ": ",$resp->status_line();
    }
    $content = $resp->content();
    $self->{sid} = ($content =~ /<SID>(.*?)<\/SID>/ && $1);
    say STDERR "-- Login, received SID ",$self->{sid} if $self->debug;
    confess "Cannot login to $self->{host}; wrong credentials?\n"
      if $self->{sid} =~ /^0+$/;
    return $self->{sid};
}

# Initialize the reverse name -> AIN map
sub _init_ain_map {
    my $self = shift;
    my $devs = $self->list();
    $self->{ain_map} = {};
    for my $dev (@$devs) {
        $self->{ain_map}->{$self->name($dev->())} = $dev->();
    }
}

# Convert "lisp" to undef
sub check {
    my $ret = shift;
    return $ret eq "check" ? undef : $ret;
}

=head1 LICENSE

AHA is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

AHA is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AHA.  If not, see <http://www.gnu.org/licenses/>.

=head1 AUTHOR

Originally: roland@cpan.org

Currently maintained by Martin Slunk E<lt>perl@slunk.deE<gt>

=cut

1;
