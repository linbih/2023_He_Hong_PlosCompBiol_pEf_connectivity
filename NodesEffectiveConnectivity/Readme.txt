
GroupBayesian_Bmats.m
This script ran group level analysis of effect connectivity matrix across subjects.
We used a Bayesian parameter averaging approach.
The runs with failed model fitting (monitored by computing ELBO) were discarded.
The group level mean and standard deviation of the parameter estimation were obtained.
p level was set at 0.05 with Bonferroni multiple comparison correction.
The results were used for Figure 4, Supplementary Figure 2, and Supplementary Figure 3

Inputs: task (standard or oddball stimuli) modulated effect connectivity matrix of each subject's run
Outputs: group level task (standard or oddball stimuli) modulated effect connectivity matrix

