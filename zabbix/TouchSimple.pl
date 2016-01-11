#!/usr/bin/perl -w

##
## a zabbix agent script for collecting ping response time
##

use strict;

my %error_code = (
    'LostPackage'     => -1,
    'DNSResolveError' => -2,
    'ICMPError'       => -3,
    'UnknowError'     => -99,
);

my $r = `fping -d -A -u -p 100 -C 3 $ARGV[0] 2>&1`;

## DNS Resolve Error
if ( $r =~ /(.*?)\saddress not found/ ) {
    print $error_code{"DNSResolveError"}, "\n";
    exit(0);
}

## ICMP Error
my ( $node, $stat ) = split / :/, $r;
$node =~ s/\s//g;
if ( $node =~ /ICMP(.*?)from.*?ICMPEchosentto(.*?)\(/ ) {
    print $error_code{"DNSResolveError"}, "\n";
    exit(0);
}
                                               
## Ping
if ( $stat =~ /([\d\.-]+)\s+([\d\.-]+)\s+([\d\.-]+)/ ){

    ## Bad Ping
    if ($1 eq '-' || $3 eq '-' || $3 eq '-') {
        print $error_code{"LostPackage"}, "\n";
        exit(0);
    }

    my $max = $1 > $2 ? ( $1 > $3 ? $1 : $3 ) : ( $2 > $3 ? $2 : $3 );
    print $max, "\n";
    exit(0);
}

print $error_code{"UnknowError"},"\n";
