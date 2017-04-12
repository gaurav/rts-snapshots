#!/usr/bin/perl -w

use v5.020;
use strict;
use warnings;

our $MASHAPE_KEY = $ENV{'RTS_SNAPSHOTS_KEY'};
die "No Mashape key provided!" unless defined $MASHAPE_KEY and $MASHAPE_KEY ne '';

use LWP::UserAgent;
use HTTP::Request;
use JSON;

my $ua = LWP::UserAgent->new;
$ua->agent("take-snapshot.pl/0.1 ");

my $req = HTTP::Request->new(GET => 'https://transloc-api-1-2.p.mashape.com/vehicles.json?agencies=116');
$req->header('Accept' => 'application/json');
$req->header('X-Mashape-Key' => $MASHAPE_KEY);

my $timestamp = time;
my $res = $ua->request($req);
if(!$res->is_success) {
    say STDERR "Error taking snapshot: " . $res->status_line;
    
    exit 1;
}

my $json = JSON->new;

my $json_content = $res->content;
my $record = $json->decode($json_content);

# TODO: do something interesting with the record here.

open(my $fh_output, ">:encoding(utf8)", "snapshots/$timestamp.json")
    or die "Could not open 'snapshots/$timestamp.json': $!";
say $fh_output $json->pretty->encode($record);
close($fh_output);
