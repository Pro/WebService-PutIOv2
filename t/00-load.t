#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'WebService::PutIOv2' ) || print "Bail out!\n";
}

diag( "Testing WebService::PutIOv2 $WebService::PutIOv2::VERSION, Perl $], $^X" );
