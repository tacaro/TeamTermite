# TeamTermite
Agent based model of ungulate grazing amid nutrient-rich termite mounds

Current working script: **termite_model.m**

For parameter sweeps, each set of parameters defines the name of the output data. Each individual set of parameters is called a "batch" which has a unique ID based off the parameters used for the batch. Currently the parameters we care about are tum_turn_mean, tum_turn_var, run_turn_mean, run_turn_var, and n_memories.
Thus: batch_IDs are created like so
`Create batch_ID based off of user-defined parameters
% in the format {mean tumble}{fKappa tumble}{mean run}{fKappa
% run}{n_memories}
% where decimals are rounded to nearest integer

batch_ID = strcat(num2str(round(tum_turn_mean)), "_", num2str(tum_turn_var), "_", num2str(run_turn_mean), "_", num2str(run_turn_var), "_", num2str(n_memories));`

For every "batch" of a set of parameters, the script will loop through each landscape to run a single simulation, or "sim". The "sim_ID" is what identifies each individual simulation

Data is output into the newly created 'output' folder. The output data from our spring 2020 work remains in the 'dfs' folder.
