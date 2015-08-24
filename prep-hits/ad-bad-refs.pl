#!/usr/bin/perl;
#
# Copyright 2015 Yvette Graham 
# 
# This file is part of Crowd-Alone.
# 
# Crowd-Alone is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Crowd-Alone is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Crowd-Alone.  If not, see <http://www.gnu.org/licenses/>
 
use strict;
use POSIX;

my $src = $ARGV[0];
my $trg = $ARGV[1];
my $rdir = $ARGV[2];
my $wdir = $ARGV[3];
my $testset = $ARGV[4];

$rdir .= "/$src-$trg";

if( ! -e $rdir){
  print STDERR "lang pair directory does not exist $rdir";
}

my $lng = "$src-$trg";
my @systems;

my @read_systems;
opendir(DIR, $rdir) or die "cant open $rdir";
@read_systems = readdir(DIR);
closedir DIR;

foreach my $s (sort @read_systems){
  
    if( $s =~ /^$testset\.$lng\.(.*)$/ ){

        my $sys = $1;
        push(@systems,$sys);

        my $fn = "$rdir/$s";
        open(F,"<$fn") or die "cant open $fn";

        $fn = "$wdir/$s";
        open(O,">$fn") or die "cant open $fn";

        while( my $l = <F> ){

            chomp($l);
      
            my @sys_wrds = split(/\ /,$l);
            my $len = scalar(@sys_wrds);
            my $random_start = rand($len-2) + 1;
            my $num_to_skip;

            if( (2 <= $len) && ( $len <= 3 )){
                $num_to_skip = 1;
            }elsif($len <= 5 ){
                $num_to_skip = 2;
            }elsif($len <= 8 ){
                $num_to_skip = 3;
            }elsif($len <= 15 ){
                $num_to_skip = 4;
            }elsif($len <= 20){ 
                $num_to_skip = 5;
            }else{ 
                $num_to_skip = ceil(($len/5));
            }

            my $str = "";


            if( $len == 1 ){

                if( ($trg eq "fr") || ($trg eq "es") ){
                    $str = "La";
                }elsif( $trg eq "de" ){
                    $str = "Die";
                }else{
                    $str = "The";
                }

            }else{

                $str = $sys_wrds[0]; # always include first word

                my $start = floor(rand($len-$num_to_skip-1) + 1);
                my $skipped = 0;

                for( my $j=1; $j<scalar(@sys_wrds); $j++ ){
              
                    if( ($j < $start) || ($skipped >= $num_to_skip) ){
                        $str .= " ".$sys_wrds[$j];
                    }else{
                        $skipped++;
                    }
                }
            }
      
            print O "$str\n";

      }
  }
  
  close(O);
  close(F);

}

