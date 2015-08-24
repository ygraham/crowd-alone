#!/usr/bin/perl;

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
use List::Util qw(shuffle);

my $dir = $ARGV[0];
my $lng = $ARGV[1]."-".$ARGV[2];
my $testset = $ARGV[3];

$dir = "$dir/$lng";

print STDERR "generating rnd keys for newstest files in $dir\n";

my @systems;
my @read_systems;

opendir(DIR, $dir) or die "cant open $dir";
@read_systems = readdir(DIR);
closedir DIR;

my $max_snt_id;

foreach my $s (sort @read_systems){

    if( $s =~ /^$testset\.$lng\.(.*)$/ ){
        my $sys = $1;
      
        push(@systems,$1);

        open(F,"<$dir/$s") or die "Cant open $s\n";
        my @l = <F>;
        $max_snt_id = scalar(@l)-1;

        close(F);
        print STDERR "File = ".$s." lines = ".($max_snt_id+1)."\n";
    }
}

my $max_rnd = (scalar(@systems)*2) * ($max_snt_id+1);
my @rnd_lst = (1..$max_rnd);
@rnd_lst = shuffle @rnd_lst;

# loop thru systems and sents giving each two random ids
my @new_lst;
my $k = 0;
my $l = 0;

for( my $i=0; $i<scalar(@systems); $i++ ){
    for( my $j=0; $j<=$max_snt_id; $j++ ){
        $new_lst[$l] = $systems[$i]."\t".$j."\t".$rnd_lst[$k]."\t".$rnd_lst[$k+1]."\n";  
        $k += 2;
        $l++;
  }
}

@new_lst = shuffle @new_lst;

print "sys_id\tsnt_id\trnd_id\tcal_rnd_id\n";

for( my $i=0; $i<scalar(@new_lst); $i++ ){
    print $new_lst[$i];
}

