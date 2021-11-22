### 2021.June.30
This note is part of "Hybrid Speciation Project", describing the work of detecting historical introgression from *N. ingens* and/or *N. riversi* to the hybrid populations. The main goal is to prove that the occurrence of historical hybridization.  

1. Because this work is to detect the admixture event between *N. riversi* and *N. ingens*, we only focus on the summary statistics that are sensitive to admixture
2. Two models are considered, and the simulation with be based on this two models, and the ABC approach will be performed to find the better model.
<img align="right" src="https://user-images.githubusercontent.com/39805460/142492420-5667dab1-ef32-4789-9eee-9c6875373536.png" width="300" height="240">

3. I use [msprime](https://tskit.dev/msprime/docs/latest/intro.html) to simulate the data with the models being written in python scripts and stored in the [screpts](https://github.com/yimingweng/N_ingens_ABC/tree/master/scripts) folder:
4. The simulation was perform in parallel threads with the script call [msp_parallel.sh](https://github.com/yimingweng/N_ingens_ABC/blob/master/scripts/msp_parallel.sh), where I need to specify the number of threads to be used.  
### 2021.Oct.25
1.  For the observed data, I also need to calculate the same summary statistics. The three population with least rescent gene flow were chosen: Conness, Selden, and Army.
2.  I used [treemix](https://bitbucket.org/nygcresearch/treemix/wiki/Home) to calculate the f3 statistics.
3.  Prepare the input file for treemix using vcftools to count the allele frequency for each focal population.
```
# working dir: sean@Fuji:/media/Jade/YMW/f3/treemix
vcftools --gzvcf /media/Jade/YMW/imputation/lcs_final_maf005.vcf.gz --counts --keep /media/Jade/YMW/imputation/samples_of_populations/Conness.txt --out Conness
vcftools --gzvcf /media/Jade/YMW/imputation/lcs_final_maf005.vcf.gz --counts --keep /media/Jade/YMW/imputation/samples_of_populations/Army.txt --out Army
vcftools --gzvcf /media/Jade/YMW/imputation/lcs_final_maf005.vcf.gz --counts --keep /media/Jade/YMW/imputation/samples_of_populations/Selden.txt --out Selden
```
4. Prepare the input in the order of popA, popB, popC
```
echo -e "Conness\tArmy\tSelden" >> treemix_f3_input
paste <(awk '{print $5,$6}' Conness.frq.count ) <(awk '{print $5,$6}' Selden.frq.count ) <(awk '{print $5,$6}' Army.frq.count) >> treemix_f3_input
sed -i 's/[ATCG*]://g' treemix_f3_input
sed -i 's/ /,/g' treemix_f3_input
sed -i 's/\t/ /g' treemix_f3_input
nano treemix_f3_input # remove the second line with "{ALLELE:COUNT}"
gzip -k  treemix_f3_input
```
5. Run threepop function in treemix
```
threepop -i treemix_f3_input.gz -k 100
#total_nsnp 1236322 nsnp 1237702
#Army;Conness,Selden 0.0633775 0.000361913 175.118
#Conness;Army,Selden 0.164155 0.00067865 241.885
#Selden;Conness,Army 0.177819 0.000817377 217.548
```
6. note that the estimate 0.0633775 is the estimate from 1236332 variant sites (number of site in vcf file), so it should be converted to the whole genome size which is 147351587 bps. It should be 0.0633775\*1236322/147351587=0.0005317

### 2021.Nov.15
1. With both the observed and simulated data available, I use R package call [abc](https://cran.r-project.org/web/packages/abc/index.html) to run ABC.
2. The R script is [here](https://github.com/yimingweng/N_ingens_ABC/blob/master/scripts/ingensabc.r)
3. The resutls suggest the admixture model, with parameters being astimated as follow:
  
T1 generation  
Min.:                  464282.7  
Weighted 2.5 % Perc.:  493831.8  
Weighted Median:       596005.1  
Weighted Mean:         596553.0  
Weighted Mode:         576124.0  
Weighted 97.5 % Perc.: 699333.8  
Max.:                  745889.5  
  
T2 generation  
Min.:                  349988.4  
Weighted 2.5 % Perc.:  376080.1  
Weighted Median:       401074.7  
Weighted Mean:         401125.2  
Weighted Mode:         401401.8  
Weighted 97.5 % Perc.: 426477.8  
Max.:                  453032.5  
  
Contribution from Conness to admixed Selden at T2  
(not very consistent from different runs)  
Min.:                  0.3361  
Weighted 2.5 % Perc.:  0.4727  
Weighted Median:       0.5980  
Weighted Mean:         0.5952  
Weighted Mode:         0.5981
Weighted 97.5 % Perc.: 0.7021  
Max.:                  0.7882  
