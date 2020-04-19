# TeamTermite
Agent based model of ungulate grazing amid nutrient-rich termite mounds

Current working script: **termite_model.m**

**Tristan's Notes as of 4/19**
Data export: The model now exports simulation data in .csv format. To keep this tidy, in the Data Export section, I generate a unique `run_ID`, create a new directory using `run_ID`, and save all the data there. The files are saved with their names' containing specific information about the number of animals, the number of steps, and the fertilizer pattern. For example:
`uniform_200_300_dung_end.csv` is a uniform plot, 200 steps, 300 animals, containing the dung counts at the end of the simulation.

Key user-defined parameters are defined at the start of the script. I added "sections" using the double %% notation.

Saving the entire landscape as it changes through time: `landscape_over_time` is a three dimensional matrix, each z-slice containing a snapshot of the matrix after the z'th animal completes its journey. These large files are notated as `dynamic_landscape` and are saved in .csv format by concatenating each snapshot below the next. Careful: these files get very large (MB) very quickly!

Tracking residency time: Within `%% Residency File Creation`, the time an animal spends in a high nutrient patch is calculated by binarizing the `landscape_over_time`, where high nutrient values are TRUE; low nutrient values are FALSE. The trajectory values are then mapped onto the binarized landscape, `landscape_time_bi`. The number of trajectory xy pairs that map to TRUE landscape coordinates is summed for each animal. This data is then exported as `residency.csv`.

R analysis: In the R_analysis folder lives `residence_time.R`, a script that takes in a `residency.csv` corresponding to a random and uniform landscape. The script generates a boxplot showing the relative residency times for both conditions. As of 4/19, a second type of boxplot is generated where I remove "zero values", or animals that spent zero time steps in a high nutrient patch. This filters out animals that quickly contacted the boundary. On this note, I think it would also be useful to determine the *relative proportion* of residency in high_nutrient patch, as opposed to absolute values.

Under construction: I made a copy of the termite_model.m called `termite_model_batchrunner.m` that can hopefully run large batches of simulations at once over a range of parameters. This doesn't work yet!

**4/13 Meeting Notes**
- Change mound shape from point source with decreasing quantity in favor of "step-function" where there are high quality and low quality spots.
- Consider relative attractiveness as 3-5X "more attractive" for high quality spots than low quality spots.
- How to choose parameter values? Choose step size at extremes e.g. step size choose 1px then choose 15px and see how behavior changes at extremes. We should search for qualitative behavior changes at extremes. E.g. turning angle distribution range: 180˚ vs. 5˚.
- What are the most important data to collect? Is there a tendency to feed closeby fert mounds? On fert mounds? Does that relationship shift from random to regular landscapes? That's the lowest hanging fruit. Also measure: total time spent in high quality patches.
- Put a final number on total amount of dung. Compare that number to two different scenarios where you have organized array vs random.
- Plot across the sequential animals: as you accumulate time spent, how quickly is grass removed? Does the rate differ between unifrom and ranodm.
- Need to do parameter sweep between random and uniform distribution.
- Data to collect: residence time in/outside of patches, dung counts, run/tumble ratio.
- Save trajectories, agent internal state, and landscape snapshots for post-processing!
- Animations!

Notes on model:
- Have the agents remove less grass. Current might lead to idiosyncratic behavior between agents.
- Set z values of trajectories to be super high so they are always on top of the heatmap plot.
