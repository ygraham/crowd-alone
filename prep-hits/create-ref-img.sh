
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

rfile=$1;
wdir=$2;

mkdir -p $wdir
split --lines=1 --numeric-suffixes --suffix-length=4 $rfile $wdir/S
n=`ls $wdir | wc -l`

echo "About to create reference translation image files -- printing . when 100 new images created"

for (( i=0; i<$n; i++ )) do 
	rfile=$wdir/S`printf %04d $i`
	if [ -e $rfile ] 
	then
		cat $rfile | convert -fill dimgrey -interline-spacing 5 -pointsize 14 -size 900 caption:@- $wdir/S`printf %04d $i`.gif; 

        if (($i % 100==0))
        then
            printf "."
        fi
    fi
done

rm $wdir/S[0-9][0-9][0-9][0-9]
echo ""
echo "Reference translation image files created: $wdir"
