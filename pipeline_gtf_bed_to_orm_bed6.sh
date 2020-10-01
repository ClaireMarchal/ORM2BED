if [ "$#" -ne 3 ]; then
    echo ""
    echo "Illegal number of parameters"
    echo "Please specify the input files and base name:"
    echo "./pipeline_gtf_bed_to_orm_bed6.sh [gtf file path] [bed file path] [base name]"
    echo "for example:"
    echo "./pipeline_gtf_bed_to_orm_bed6.sh path/to/fibers/1905async.gtf path/to/segments//1905async.bed 1905async"
    echo ""
    echo -e "This script needs bgzip and tabix installed to generate the zip and index files,\nbut it will generate the bed file even if these tools are missing."
    echo ""
    exit
fi


gtf=$1
bed=$2
out=$3

for file in tmp_${out}.bed tmp_${out}_srt.bed tmp_${out}_oneline.bed tmp_${out}_ORM.bed ${out}.bed ${out}.bed.gz ${out}.bed.gz.tbi ${out}.error; do
    if [[ -f $file ]]; then
       echo "Error: $file already exists. Please rename it or remove it."
       exit
    fi
done


for file in $gtf $bed; do
    if [[ ! -f "$file" ]]; then
       echo "Error: $file not found."
       exit
    fi
done

echo ""

echo -e "This script is converting a gtf (fibers + nucleotides) and bed (segments) pair of files into a BED6 file.\
\nIt then compresses and indexes the BED6 file to generate a file compatible with the nucleserver browser."

echo -e "Segments or nucleotides not overlapping with any fiber will be printed in a [base name]\".error\" file."


cat $gtf | awk '/transcript\t/{print $1,$4,$5,$10,"fiber","NA"} !/transcript\t/{if($6!="."){print $1,($4+$5)/2,($4+$5)/2,$12,"nucleotide",$6}}' OFS='\t' | sed 's/[";TRP]//g' > tmp_${out}.bed
cat $bed | awk '//{print $1,$2,$3,$4,"segment","NA"}' OFS='\t' >> tmp_${out}.bed

sort -k4,4 -k5,5 -k1,1 -k2,2n -k3,3n tmp_${out}.bed > tmp_${out}_srt.bed

cat tmp_${out}_srt.bed | awk -v name=${out} '/fiber/{if(NR>1){print ""}; printf $1"\t"$2"\t"$3"\t"$4; chr=$1; start=$2; stop=$3; id=$4} /nucleotide/{if(chr!=$1||start>$2||start>$3||stop<$2||stop<$3||id!=$4){print $0 > (name ".error")} else {printf "\tN\t"$2"\t"$6}} /segment/{if(chr!=$1||start>$2||start>$3||stop<$2||stop<$3||id!=$4){print $0 > (name ".error")} else {printf "\tS\t"$2"\t"$3-$2}} END{print ""}' > tmp_${out}_oneline.bed

cat tmp_${out}_oneline.bed | awk '//{printf $1"\t"$2"\t"$3"\t"$4"\t0\t.\t"(NF-4)/3"\t"; for(i=5;i<=NF;i=i+3){if(i>5){printf ","}; printf $i}; printf "\t"; for(i=6;i<=NF;i=i+3){if(i>6){printf ","}; printf $i-$2}; printf "\t"; for(i=7;i<=NF;i=i+3){if(i>7){printf ","}; printf $i}; print ""}' > tmp_${out}_ORM.bed

sort -k1,1 -k2,2n -k3,3n tmp_${out}_ORM.bed > ${out}.bed
bgzip -c  ${out}.bed > ${out}.bed.gz 
tabix ${out}.bed.gz
rm tmp_${out}.bed tmp_${out}_srt.bed tmp_${out}_oneline.bed tmp_${out}_ORM.bed
