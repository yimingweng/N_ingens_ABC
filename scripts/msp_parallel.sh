#!/bin/bash
# this script is used to run msprime in 25 threads

for thread in {1..25}
do
    start=$(echo $((${thread}*40000-39999)))
    stop=$(echo $((${thread}*40000+1)))
    python3 ingens_admix_model.py ${start} ${stop} -o admix &
done

# put all the results together
# working dir: weng@rslas-denali:/data1/Yiming/msp/
for file in indep*.out
do
    start=$(echo "${file}" | cut -d "_" -f 2)
    echo -e "${file}\t${start}" >> indep_table
done

for file in $(cat indep_table | sort -k2 | cut -d $'\t' -f 1)
do
    cat ${file} >> indep_sim.out
done
rm indep_table


for file in admix*.out
do
    start=$(echo "${file}" | cut -d "_" -f 2)
    echo -e "${file}\t${start}" >> admix_table
done

for file in $(cat admix_table | sort -k2 | cut -d $'\t' -f 1)
do
    cat ${file} >> admix_sim.out
done
rm admix_table