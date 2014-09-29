#!/usr/bin/perl -w
use strict;

use DBI;
use Time::HiRes qw(gettimeofday);

my ($file) = @ARGV;
open(FILE, '<', $file);
my @data = <FILE>;
close FILE;

my $pat = qr/^(\d+)\t(\d+)\t(\d+)\t(\d+)/;
my @tuples = map { $_ =~ $pat; {num => $1, itemid => $2, from => $3, to => $4} } @data;

my $dbh = DBI->connect('dbi:mysql:database=test', 'testuser', 'testpass');

my $start = gettimeofday;
foreach(@tuples){
    my $r = $dbh->selectall_arrayref('select * from trends_uint where itemid=? and clock>=? and clock<=?', undef, $_->{itemid}, $_->{from}, $_->{to});
    die "$_->{itemid}, $_->{from}, $_->{to}\n" unless @$r == $_->{num}
}
my $finish = gettimeofday;

printf "%s\t%d\t%.2f\t%.6f\n", $file, scalar @tuples, ($finish - $start), ($finish - $start) / @tuples;
