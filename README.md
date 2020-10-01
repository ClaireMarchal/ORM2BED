# ORM2BED
Conversion program for ORM data to visualize in the nucleome browser

## Program for orm file formating

This program takes two ORM files as input (gtf file containing the fibers and bed file containing the replication segments) and output a BED file and its compressed version and index for visualization with the nucleome browser (https://vis.nucleome.org and github.com/nucleome)

## Usage

`./pipeline_gtf_bed_to_orm_bed6.sh [gtf file path] [bed file path] [base name]`

for example:

`./pipeline_gtf_bed_to_orm_bed6.sh path/to/fibers/1905async.gtf path/to/segments/1905async.bed 1905async`

## Input file format

# Fibers and signal: gtf file

A tab delimited file similar to the gtf format containing one fiber or one signal per line

# Replication segment: bed file

A tab delimited file containing:
  1st column: chromosome
  2nd column: start
  3rd column: stop
  4th column: fiber ID
  Other columns: not used

## Output file format

See https://github.com/nimezhu/ORM/tree/master/browser
