#!/bin/bash

function usage(){
  echo "bash $0 [ -p path/to/RNA-seq/data ] [ -t tissue name ] [ -r Repetitions ] [ -l reads length ] [ -g gtf file ] [ -s data size ] [ -f genome reference ]"
  echo -e "\t\t -p path/to/RNS-seq/data. please provide the absoluted path to directory storing your RNA-seq data"
	echo -e "\t\t -t tissue name. please provide your sample name. If you have two or more samples, please separate them with commas"
	echo -e "\t\t -r repetitions. please set your repetitions. It is set to be 3 by default"
	echo -e "\t\t -l reads length. please provide the reads length. This value can be obtained from FastQC output"
	echo -e "\t\t -g gene annotation file(gtf). Store this file in the upper directory of your RNA-seq data"
	echo -e "\t\t -f genome reference. please provide the reference genome. Before it is used, check if it was indexed by Bowtie2-build"
	echo -e "\t\t -s data size. It has only two value, "l" or "s". "l" means large file while "s" means small file size. If it was not set properly, an error will occur and the pipeline will exit"
	exit
}

declare -i repeat=3
declare -i length=150
path="/media/disk1"
gtf_ref="/your/gtf/reference/file"
genome_ref="/your/reference/genome" #this should be indexed by Bowtie2-build
while getopts "p:t:r:l:G" arg
do
  case $arg in 
    p)
      path=${OPTARG}
      ;;
    t)
      tissue=${OPTARG}
      ;;
    r)
      repeat=${OPTARG}
      ;;
    l)
      length=${OPTARG}
      ;;
    g)
      gtf_ref=${OPTARG}
      ;;
    f)
      genome_ref=${OPTARG}
      ;;
    s)
      size=${OPTARG}
      ;;      
    ?)
      usage
      ;;
  esac
done

if [ "$size" != "l" ] && [ "$size" != "s" ]
then
	usage
fi

cd ${path}
tissue=`echo ${tissue} |sed 's/,/ /g'`
for i in ${tissue}
do
  for j in $(seq ${repeat})
  do
    tophat2 -p 8 -r 50 -o ../${i}_${j} --no-mixed -G ${gtf_ref} ${ref_genome} ${i}_${j}_R1.fq.gz ${i}_${j}_R2.fq.gz
    cd ..
    if [ "${size}" = "s" ]
    then
      java -jar /your/path/to/picard.jar CollectInsertSizeMetrics I=./${i}_${j}/accepted_hits.bam O=${i}_${j}_insertsizeMetrics.txt H=${i}_${j}_InsertSize_Histogram.pdf M=0.5
    elif [ "${size}" = "l" ]
    then
      jave -jar /your/path/to/picard.jar CollectInsertSizeMetrics I=./${i}_${j}/accepted_hits.bam O=${i}_${j}_insertsizeMetrics.txt H=${i}_${j}_insertSize_Histogram.pdf
    else
      usage
      exit
    fi
    Insertsize=$(perl insertSize.pl -i ${i}_${j}_insertsizeMetrics.txt -l ${length})
    rm -rf ${i}_${j}
    cd ${path}
    tophat2 -p 8 -r ${insertsize} -G ${gtf_ref} -o ../${i}_${j}_thout --no-mixed ${ref_genome} ${i}_${j}_R1.fq.gz ${i}_${j}_R2.fq.gz
    cd ..
    cufflinks-p 8 -o ${i}_${j}_clout ${i}_${j}_thout/accepted_hits.bam
    echo "${i}_${i}_clout/transcripts.gtf" >>assemblies.txt
  done
done

cuffmerge -g ${gtf_ref} -s ${ref_genome}.fa -p 8 assemblies.txt

declare -a bam_out
for i in ${tissue}
do
	unset bam
	for j in $(seq $repeat)
	do
		if [ "$bam" = "" ]
		then
			bam="${i}_${j}/accepted_hits.bam"
		else
			bam="${bam},${i}_${j}/accepted_hits.bam"
		fi
	done
	bam_out=(${bam_out[*]} ${bam})
done
			
cuffdiff -o diff_out -b ${ref_genome}.fa -p 8 -L $(echo ${tissue}|sed 's/ /,/g') -u merged_asm/merged.gtf ${bam_out[*]}
Rscript cummeRbund.R diff_out
