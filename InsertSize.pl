#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Std;
use vars qw($opt_i $opt_l);
getopt('i:l:');
if($opt_i && $opt_l){
}else{
  &usage;
}
sub usage{
  
}
