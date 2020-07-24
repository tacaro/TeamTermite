# TeamTermite
Agent based model of ungulate grazing amid nutrient-rich termite mounds

Current working script: **termite_model.m**

## Data Generation and Export
Each individual set of parameters that the user defines is called a "batch" which has a unique batch_ID. Currently the parameters we care about are tum_turn_mean, tum_turn_var, run_turn_mean, run_turn_var, n_memories, and seed. If these values were 3,2,0,2,3,1 respectively, the batch_ID would then be **3_2_0_2_3_1**.

For every "batch" of a set of parameters, the script will loop through each landscape to run a single simulation. Each landscape is identified by its landscape ID, `ls_ID`.

Data is output into the 'output' folder. The output data from our spring 2020 work remains in the 'dfs' folder.

### Process
Sections:
     1. Prepare Model
        a. Define Parameters
        b. Generate batch_ID
     2. Execute Batch Simulation
        a. Prepare landscape library.
        b. LOOP – for each landscape:
            i. Run Model
            ii. Export Model Data

#### 1. Prepare Model
This section is where parameters are defined. The parameters that we are changing for this set of sweeps are: tum_turn_mean, tum_turn_var, run_turn_mean, run_turn_var, n_memories, and seed. These are used to generate a unique `batch_ID` that governs the file export name. For example, if these values were 3,2,0,2,3,1 respectively, the batch_ID would then be **3_2_0_2_3_1**.

The 'seed' or random number generator seed, is defined by setting `seed` to an integer value of the user's choice then defining a random number generator structure `randfunc = rng`. We set the `Seed` field of this struct to the `seed` variable (note lower case) that was defined by the user `randfunc.Seed = seed;`. Finally, we set the MATLAB random number generator to the user-defined struct we just generation.

#### 2. Execute Model
a. First, runtime measurement is started with a call of the `tic` command. Total runtime for the model is exported in the metadata.csv file.

Next, the landscape library is prepared. One of the parameters that the user has the choice to define is `wide`. If TRUE, the script will load the "wide" landscapes. If FALSE, the script will load the "thin" landscapes. This is set to TRUE by default.

Based on this choice, the script then loads landscape names into a MATLAB struct using the dir command.

b. The script iterates through each landscape.
First, it identifies the landscape it will be using as `grass_filename` and generates a unique `ls_ID` for export purposes. It then executes the model on this loaded landscape.

After the model has been executed, the script exports simulation data.

First, it outputs a metadata.csv file with the following fields:
```{'batch_ID', batch_ID;
    'wide', wide;
    'seed', seed;
    'tum_turn_mean', tum_turn_mean;
    'tum_turn_var', tum_turn_var;
    'tum_dist_shape', tum_dist_shape;
    'tum_dist_scale', tum_dist_scale;
    'run_turn_mean', run_turn_mean;
    'run_turn_var', run_turn_var;
    'run_dist_shape', run_dist_shape;
    'run_dist_scale', run_dist_scale;
    'xdim', xdim;
    'ydim', ydim;
    'max_grass', max_grass;
    'max_feed', max_feed;
    'num_animals', num_animals;
    'steps', steps;
    'able2stop', able2stop;
    'n_memories', n_memories;
    'max_run', max_run;
    'grass_consumed', grass_consumed;
    'run_time', run_time;
    'comments', comments};
```
Second, it exports information about the simulation:
- residency.csv: residency in high/low nutrient areas
- trajectories.csv: animal trajectories over time
- quantity_end.csv: grass quantity at the end of the simulation
- nutrition_end.csv: nutritional value at the end of the simulation
- dung_end.csv: dung counts on the landscape at the end of the simulation

Note that the starting values for quantity, nutrition, and dung are all pre-defined by the landscape.

A string of equals signs "================" is displayed to signal that all the files were saved successfully and that the loop is continuing.



### File Structure
**Abbreviated tree diagram showing location of exported data**
**Where h,i,j,k,l are user-defined parameters**
```
TeamTermite
├── README.md
├── R_analysis
├── dfs
├── output
│  ├── 3_2_0_2_3 (batch 1)
│    ├── AA_1_metadata.csv (landscape 1)
│    ├── AA_1_dung_end.csv
│    ├── AA_1_nutrition.csv
│    ├── AA_1_trajectories.csv
│    ├── AA_1_residency.csv
│    ├── AA_1_quantity_end.csv
│    ├── ...
│    ├── n_1_metadata.csv (landscape n)
│  ├── ...
│  ├── h_i_j_k_l (batch n)
└── termite_model.m
```
