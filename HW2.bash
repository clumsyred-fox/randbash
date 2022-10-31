#!/bin/bash

cd /home/li_gany/HW/hw2_randbash
mkdir hw1_rnaseqdata
ln -s /home/narek/VS_Code/NGS/ngs_hw1/data hw1_rnaseqdata

cp /home/narek/.local/bin/stringtie /home/li_gany/.local/bin

wget http://ftp.ensembl.org/pub/release-107/gtf/mus_musculus/Mus_musculus.GRCm39.107.gtf.gz -q
gunzip -q Mus_musculus.GRCm39.107.gtf.gz  
wget http://ftp.ensembl.org/pub/release-107/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.19.fa.gz -q
gunzip -q Mus_musculus.GRCm39.dna.chromosome.19.fa.gz

mkdir chr19
mkdir chr19/indexes

grep -P '^19\t' Mus_musculus.GRCm39.107.gtf > chr19_an.gtf
hisat2-build Mus_musculus.GRCm39.dna.chromosome.19.fa Mus_index
hisat2_extract_splice_sites.py chr19_an.gtf > chr19/splice_sites.gtf
hisat2_extract_exons.py chr19_an.gtf > chr19/chr19_exons.gtf

mv *.ht2 chr19/indexes
mv Mus_musculus* chr19

mv chr19_* chr19 
mkdir -p mapped mapped_new
mkdir -p annotation
cd /home/li_gany/HW/hw2_randbash/hw1_rnaseqdata/data && for file in *; do hisat2 --known-splicesite-infile /home/li_gany/HW/hw2_randbash/chr19/splice_sites.gtf --no-softclip --no-unal -x /home/li_gany/HW/hw2_randbash/chr19/indexes/Mus_index -U /home/li_gany/HW/hw2_randbash/hw1_rnaseqdata/data/$file --new-summary | samtools view -Sb - > /home/li_gany/HW/hw2_randbash/mapped/out_$file.bam; done
cd /home/li_gany/HW/hw2_randbash/hw1_rnaseqdata/data && for file in *; do samtools sort -o /home/li_gany/HW/hw2_randbash/mapped/out_$file.sorted.bam /home/li_gany/HW/hw2_randbash/mapped/out_$file.bam; done
cd /home/li_gany/HW/hw2_randbash/hw1_rnaseqdata/data && for file in *; do stringtie /home/li_gany/HW/hw2_randbash/mapped/out_$file.sorted.bam -o /home/li_gany/HW/hw2_randbash/annotation/$file.gtf -G /home/li_gany/HW/hw2_randbash/chr19/chr19_an.gtf; done

ls -1 /home/li_gany/HW/hw2_randbash/annotation/*gtf > /home/li_gany/HW/hw2_randbash/annotation/annotations.list
stringtie --merge /home/li_gany/HW/hw2_randbash/annotation/annotations.list -G /home/li_gany/HW/hw2_randbash/chr19/chr19_an.gtf -o /home/li_gany/HW/hw2_randbash/chr19/merged.gtf
hisat2_extract_splice_sites.py /home/li_gany/HW/hw2_randbash/chr19/merged.gtf > /home/li_gany/HW/hw2_randbash/chr19/splice_sites2.gtf
cd /home/li_gany/HW/hw2_randbash/hw1_rnaseqdata/data && for file in *; do hisat2 --known-splicesite-infile /home/li_gany/HW/hw2_randbash/chr19/splice_sites2.gtf --no-softclip --no-unal -x /home/li_gany/HW/hw2_randbash/chr19/indexes/Mus_index -U /home/li_gany/HW/hw2_randbash/hw1_rnaseqdata/data/$file --new-summary | samtools view -Sb - > /home/li_gany/HW/hw2_randbash/mapped_new/out_$file.bam; done

