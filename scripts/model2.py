import argparse
import matplotlib.pyplot as plt
import numpy as np
import msprime
import random

# This script is used to simulate genetic data using msprime, the model and parameters have been fixed
# Usage: python3 ingens_admix_model.py start_seed stop_seed -o out_prefix
# if msprime module can't be found, try "pip3 install --user --upgrade msprime" in bash

parser = argparse.ArgumentParser(description='running msprime simulation with predefined models and parameters')
parser.add_argument('start', metavar='start seed', type=int, nargs=None, help='use 1 if single thread of simulation is expected')
parser.add_argument('stop', metavar='stop seed', type=int, nargs=None, help='number of simulation in the interation, then plus 1 (e.g. use 11 if 10 interation is desired)')
parser.add_argument("-o", "--out", type=str,  help='the prefix of the output, can be the short name of the model')
args = parser.parse_args()
length = args.stop- args.start
# Assuming 2 generations an year for this species (Nebria ingens complex)
# the divergence time of the two major lineages are around 1,175,736 years ago, means 587,868 generations ago (from Schoville et al, 2012)

for x in range(args.start, args.stop):
    print("working on seed " + str(x) + ", out of " + str(length))
    # defining the range and distribution of the priors
    conness = int(random.uniform(1000, 10000)) # current population size of Conness
    selden = int(random.uniform(1000, 10000)) # current population size of Selden
    army = int(random.uniform(1000, 10000)) # current population size of Army
    na = int(random.uniform(10000, 100000)) # population size of the commom ancestor of the three populations
    touone = int(random.uniform(487868, 687868)) # the time of the frist population split, ref: Schoville et al, 2012
    toutwo = int(random.uniform(57500, 480000)) # the time when Selden formed from the admixture of Conness and Army (only in admixture model)
    pcs = random.uniform(0.2, 0.8) # the gene contribution from conness to selden (range from 0.2-0.8)
    pas = 1-pcs # the gene contribution from army to selden (aslo range from 0.2-0.8, from 1-pcs)
    seed = x
    # define the demographic model (three independent lineage model)
    demography = msprime.Demography()
    demography.add_population(name="conness", initial_size=conness)
    demography.add_population(name="selden", initial_size=selden)
    demography.add_population(name="army", initial_size=army)
    demography.add_population(name="COS", initial_size=na)
    # define the divergence history
    demography.add_admixture(time=toutwo, derived="selden", ancestral=["conness", "army"], proportions=[pcs, pas])
    demography.add_population_split(time=touone , derived=["conness", "army"], ancestral="COS")
    demography.sort_events()
    # define parameters for the simulation
    ts = msprime.sim_ancestry(
        samples={"conness": 53, "selden": 13, "army": 35}, # this numbers are matched to the observed data
        demography=demography, 
        recombination_rate=2.48e-8, # the rate is from Wilfert et al, 2007 (https://www.nature.com/articles/6800950) 
        sequence_length=1_000_000, 
        random_seed=seed)
    # Add mutation here, the mutation rate is from the Drosophila studies
    mutated_ts = msprime.sim_mutations(ts, rate=2.8e-9, random_seed=seed)
    # define populations in the sample list\
    # C A B <- order of the pops for f3 statistics
    pop_samples = [ts.samples(1), ts.samples(0), ts.samples(2)]
    # calculating dxy and f3 statistics 
    Dxy = mutated_ts.divergence([ts.samples(0), ts.samples(1), ts.samples(2)], indexes=[(0, 1), (0, 2), (1, 2)])
    s = "\t".join(map(str, Dxy))
    f3 = mutated_ts.f3(sample_sets=pop_samples, indexes=None, windows=None, mode='site', span_normalise=True)
    out = open(f"{args.out}_{args.start}_{args.stop}.out", "a")
    out.write(str(x) + "\t" + str(conness) + "\t" + str(selden) + "\t" + str(army) + "\t" + str(na) + "\t" + str(touone) + "\t" + str(f3) + "\t" + str(s) + "\t" + str(pcs)+ "\t" + str(pas)+ "\t" + str(toutwo) + "\n")
    out.close()