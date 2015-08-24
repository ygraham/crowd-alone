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
rdir=batched-hits
wdir=analysis

mkdir $wdir

perl hits2r.pl ad $rdir $wdir > $wdir/ad-latest.csv
wc -l $wdir/ad-latest.csv

R --no-save --args $wdir ad < concurrent-hits.R
R --no-save --args $wdir ad < wrkr-times.R
perl filter-rejected.pl $wdir/ad-wrkr-stats.csv < $wdir/ad-latest.csv > $wdir/ad-approved.csv
perl repeats.pl < $wdir/ad-approved.csv > $wdir/ad-repeats.csv
R --no-save --args $wdir < quality-control.R
perl raw-bad-ref-pval-2-csv.pl < $wdir/ad-trk-stats.txt > $wdir/ad-trk-stats.csv
perl filter-pval-paired.pl < $wdir/ad-trk-stats.csv > $wdir/ad-trk-stats.class
perl filter-latest.pl ad $wdir/ad-trk-stats.class < $wdir/ad-approved.csv > $wdir/ad-good-raw.csv
perl repeats.pl < $wdir/ad-good-raw.csv > $wdir/ad-good-raw-repeats.csv


