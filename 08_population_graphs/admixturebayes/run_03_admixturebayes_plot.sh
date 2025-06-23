#!/bin/bash


for i in {1..3}; do cd resultsadm.${i}; python ../admixturebayes/makePlots.py --plot top_trees --posterior thinned_samples.csv --write_rankings chain${i}rankings.txt; python ../admixturebayes/makePlots.py --plot estimates --posterior thinned_samples.csv; python ../admixturebayes/makePlots.py --plot consensus_trees --posterior thinned_samples.csv ; cd ..; done

