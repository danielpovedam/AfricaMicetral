library(dplyr)
library(data.table)
library(BITEV2)
library(OptM)
library(plyr)
library(phytools)
source("/home/dpoveda/micetral/software/mmd/treemix/old_angsd/TreeMix_functions.R") #path to required functions for this analysis



########################################################
################## (B) Plot Tree #######################
########################################################

## 1. From the final runs, compare tree likelihoods, select tree with highest likelihood, remove duplicates and retain tree(s) with unique topology. 
#Adapted from R functions written by Zecca, Labra and Grassi (2019).

setwd("/home/dpoveda/micetral/software/mmd/treemix/old_angsd/final_runs")                                             #folder with all TreeMix outputs from the final runs
maxLL("FINAL_1m_finalrun_", nt=25)                                         #first argument is stem of TreeMix output files, nt = number of runs
                                                                  #shows ML trees and highest likelihood, as well as tree(s) with unique topology. Outputs "TreeLLs.txt" into workign directory

#If n of unique trees = 1, continue with step #2, if n > 1, you might want to create a consensus tree. 
#Note that bootstrap and migration values will not be available for consensus tree, thus you could also choose one ML tree 

cfTrees("FINAL_1m_finalrun_1", nt=25, p=1, m='PH85')                        #m is the method to calculate pairwise distances between unique trees (default is Robinson-Foulds distance)
                                                                  #p (number from 0.5 to 1)-proportion for a clade to be represented in the consensus tree. Default (1) is strict tree, 0.5 for majority-rule
                                                                  #plots consensus tree and saves "Consensus.newick" into working directory

## 2. Now plot and save unique tree with highest likelihood:

pdf("TreeMix_output.pdf")                                          
treemix.bootstrap("FINAL_1m_finalrun_1", out.file = "tmp",                 #stem of TreeMix files (as above) + number of run with highest likelihood and unique topology
                  phylip.file = "tree_constree.newick",           #consensus tree in newick format (from the bootstrap procedure generated with PHYLIP)    
                  nboot = 1000, fill = TRUE,                       #nboot is the number of bootstraps used
                  pop.color.file = "col.txt",                     #specify colours with a tab delimited pop.color.file - first column is pop name, second the colour
                  boot.legend.location = "topright")

treemix.drift(in.file = "FINAL_1m_finalrun_1",                             #pairwise matrix for drift estimates with specified order of pops 
              pop.order.color.file = "poporder.txt") + 
              title("Drift")     

plot_resid("FINAL_1m_finalrun_1",                                          #pairwise matrix for residuals
           pop_order = "poporder.txt") +
           title("Residuals")                         
dev.off()


########################################################
######### (C) Weights, Std. Err and p-values ###########
########################################################

#Output reports mean weight of edge, the jackknife estimate of the weight and standard error (averaged over N independent runs), 
#the least significant p-value recovered  over N runs for each migration event. Set working directory to the final_runs folder.

GetMigrStats(input_stem="FINAL_1m_finalrun_", nt=25)                       #arguments as above, writes file "MS_and_stats.txt" into current directory

########################################################
#### Migration support and corrected MS (Optional) #####
########################################################

#From bootstrap replicates, few other support statistic might be calculated.
#The MS is the percentage of times each pair of label sets is present among n bootstrap replicates.
#Calculated as: (number of matches / number of bootstrap replicates)*100 from all independent runs in the current working directory.
#For the Extended MS (MSE), the number of counts is corrected for multiple matches to avoid over-counting.
#Based on R funcions written by Zecca, Labra and Grassi, 2019.

GetPairsOfSets(skipL=1)                                           #create pairs of sets of populations/taxa from TreeMix output (with treeout.gz extension) in /final_runs folder, writes "PairsOfSets.txt" file
                                                                  #if you used the flag -noss, set skipL=2 (default is 1) - the number of lines to skip before reading the tree

#Now set working directory to folder with all bootstrap replicates generated with optimum number of m in Step 3.
setwd("/home/dpoveda/micetral/software/mmd/treemix/old_angsd/final_runs/bootstrap")

#Copy PairsOfSets.txt into directory
GetMigrSupp(skipL=1)                                              #calculates MS over all bootstrap replicates, writes file "MigrSupp.txt" into current directory

GetMS_MSe(nmigr=1, min_n=2, fixed="To", skipL=1)                  #default input file is "MigrSupp.txt" created with GetMigrSupp(), writes file "MS_MSE.txt" into working directory
                                                                  #nmigr = number of migrations, fixed = specifies which taxa/species label set of each pair is kept fixed
                                                                  #fixed = "From" fixes the origin of m; fixed = "To" (default) fixes the destination of the same m 
                                                                  #min_n = minimum number of taxa/species labels to be included within the unfixed set(s)

#Ouputs table with columns 'From' (subset of species below the origin of migration edges),
#'To' (the subset of species below the destination of migration edges), Migration Support (MS) and corrected MS with respect to bootstraps (MSE).




treemix.bootstrap("FINAL_1m_finalrun_1", out.file = "tmp",                 
                  phylip.file = "FINAL_finalconstree.newick",           
                  nboot = 1000, fill = TRUE,                      
                  pop.color.file = "col.txt",                     
                  boot.legend.location = "topright")
                  
                  
                  
                  

pdf("TreeMix_output.pdf")                                          
treemix.bootstrap("FINAL_1m_finalrun_1", out.file = "tmp",                 
                  phylip.file = "FINAL_finalconstree.newick",              
                  nboot = 1000, fill = TRUE,                       
                  pop.color.file = "col.txt",                     
                  boot.legend.location = "topright")

treemix.drift(in.file = "FINAL_1m_finalrun_1",                              
              pop.order.color.file = "poporder.txt") + 
              title("Drift")     

plot_resid("FINAL_1m_finalrun_1",                                          
           pop_order = "poporder.txt") +
           title("Residuals")                         
dev.off()