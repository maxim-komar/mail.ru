#!/usr/bin/perl -w
use strict;
use DBI;
use Data::Dumper;
use Time::HiRes 'gettimeofday';
use Net::HandlerSocket;

my ($filename) = @ARGV;

open(F, '<', $filename);
my @lines = <F>;
close F;

my @data = map { chomp; [ split /\t/ ] } @lines;
my ($st, $ft);

# mysql
my $dbh = DBI->connect('dbi:mysql:database=test', 'testuser', 'testpass', { RaiseError => 1 });

$st = gettimeofday;
mysql(@$_) foreach(@data);
$ft = gettimeofday;
printf "%s\t-\t-\t%d\t%.4f\t%.6f\n", 'mysql', scalar @data, ($ft - $st), ($ft - $st) / @data;

# mysql prepared statement
my $sth = $dbh->prepare('select * from trends_uint where itemid=? and clock=?');

$st = gettimeofday;
mysql_prep(@$_) foreach(@data);
$ft = gettimeofday;
printf "%s\t-\t-\t%d\t%.4f\t%.6f\n", 'mysql prep', scalar @data, ($ft - $st), ($ft - $st) / @data;

# mysql handlersocket (read-only port)
my $hs = new Net::HandlerSocket({ host => '127.0.0.1', port => 9998 });
$hs->open_index(0, 'test', 'trends_uint', 'PRIMARY', 'itemid,clock,value_avg');
$st = gettimeofday;
mysql_hs(@$_) foreach(@data);
$ft = gettimeofday;
printf "%s\t-\t-\t%d\t%.4f\t%.6f\n", 'mysql hs', scalar @data, ($ft - $st), ($ft - $st) / @data;

# mysql handlersocket (read-write port)
my $hsrw = new Net::HandlerSocket({ host => '127.0.0.1', port => 9999 });
$hsrw->open_index(0, 'test', 'trends_uint', 'PRIMARY', 'itemid,clock,value_avg');
$st = gettimeofday;
mysql_hsrw(@$_) foreach(@data);
$ft = gettimeofday;
printf "%s\t-\t-\t%d\t%.4f\t%.6f\n", 'mysql hs (rw)', scalar @data, ($ft - $st), ($ft - $st) / @data;

sub mysql {
    $dbh->selectall_arrayref('select * from trends_uint where itemid=? and clock=?', undef, @_);
}

sub mysql_prep {
    $sth->execute(@_);
    $sth->fetchall_arrayref;
}

sub mysql_hs {
    $hs->execute_single(0, '=', [@_], 1, 0);
}

sub mysql_hsrw {
    $hsrw->execute_single(0, '=', [@_], 1, 0);
}
