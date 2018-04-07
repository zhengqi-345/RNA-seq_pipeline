#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Std;
use vars qw($opt_i $opt_l);
getopt('i:l:');
if($opt_i && $opt_l){
	$/="##";
	open FILE, "$opt_i" || die "Can not open the file:$!";
	my @array= <FILE>;
	close FILE;
	
}else{
  &usage;
}
sub usage{
  die(
    qq!
        Usage: perl InsertSize.pl [ -i Input file name ] [ -l reads length ] [ ... ]
     Function: This script is used to collect the best InsertSize from Picard CollectInsertSizeMetrics tool output. Then compute the 
			 				 proper expected (mean) inner distance between mate pairs for Tophat2 with the function "the expected inner distance 
							 equals to $insertSize -2*reads_length";
		parameter: -i Input file name(Required). This parameter need to be provided by CollectInsertSizeMetrics plain text output.
							 -l Reads length(Required). This parameter can be provided from the output of FastQC.
		Author(s): Qi Zheng, zhengqi345\@126.com
		  Version: v1.0
			  Notes: --
		\n!
	)
}
