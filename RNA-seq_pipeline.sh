#!/bin/bash
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
    ?)
      echo "UNKNOWN argument"
      exit 1
      ;;
  esac
done

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
cuffdiff -o diff_out -b ${ref_genome}.fa -p 8 -L $(echo ${tissue}|sed 's/ /,/g') -u merged_asm/merged.gtf ${i}_${j}_thout/accepted_hits.bam,${i}_${j}_thout/accepted_hits.bam,${i}_${j}_thout/accepted_hits.bam ${i}_${j}_thout/accepted_hits.bam,${i}_${j}_thout/accepted_hits.bam,${i}_${j}_thout/accepted_hits.bam
Rscript cummeRbund.R diff_out
