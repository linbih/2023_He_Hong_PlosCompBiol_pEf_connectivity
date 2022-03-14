
1) ConSum_Behavior_allPRmean.m
This scripts summarize the positive effective connectivity and negative effective connectivity
based on their groups.
Network-level effective connectivity positive and negative strength were computed.
The positive and negative network strength was computed as the sum of all positive and negative ...
connection parameters from one network node set to the other network node set ...
(or to itself as self-connection network strength), respectively.
Each connection strength was correlated with mean pupillary response (PR) of oddball trials.

This script was used to generate results in Figure 5A.


2) ConSum_Behavior_allPRmean_AtlasROI.m
This scripts also test for the correlation between network-level effective connectivity strength and 
pupillary response of oddball trials.
But here, the ROIs from Salience Network, Default Mode Network, and Dorsal Attention network were used 
in the state-space modeling of effective connectivity. The results from the model were used here for 
correlation analysis.
The ROIs in these networks were defined with HCP Atlas.

This script was used to generate results in Figure 5B and 5C.

