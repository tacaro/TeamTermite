# TeamTermite
Agent based model of ungulate grazing amid nutrient-rich termite mounds

Current working script: **termite_model.m**


**Notes after meetings 4-21 (Liam)**

We are pretty confident with the model, and are moving into data analysis.

Big questions:

->Random vs. regular (uniform) vs control landscape:
It seemed like Dan and Orit liked the idea of the control landscape starting as a binary landscape with the same number of, and values for, the fertile and background grid squares, but that the fertile grid squares are assigned randomly and individually instead of in fertilizer circles.
Liam can implement this while debugging move_and_feed.

->Dan was curious about a run and tumble with no stop option, and Orit was curious about a run and tumble with no maximum distance traveled on the run steps. Maybe a true random walk would be a good control as well? Any of these options are probably secondary to getting some good data with the current implementation.
->Added able2stop which (if false) does not allow stopping.
->Would just need to make the run distance = xdim in order to run Orit’s version.
->For a true random walk, just make the run angles [-pi, pi] and the angle and distance ratios both 1.

Data collection and analysis:
	
I didn’t write down what Tristan/Jack were already working on, and definitely missed a bunch, but things that were discussed include:
->Maybe have a cutoff for a minimum number of steps, or a minimum distance from boundary achieved for an animal to be counted for any statistics other than “portion of animals that left really quickly”
->Make max steps really high (like 1000)
->Put some dots or circles where the mounds are on plots such as dung counts.
	
->Track total distance moved by each animal.'
->Track total depletion of mounds.
->Track average number of steps between mounds.
->Track likelihood of finding a second patch if found a first patch.
->Portion of time spent in fertile areas
->Total time spent on landscape
->Average distance from edge of nearest mound.




**Tristan's Notes as of 4/19**
Data export: The model now exports simulation data in .csv format. To keep this tidy, in the Data Export section, I generate a unique `run_ID`, create a new directory using `run_ID`, and save all the data there. The files are saved with their names' containing specific information about the number of animals, the number of steps, and the fertilizer pattern. For example:
`uniform_200_300_dung_end.csv` is a uniform plot, 200 steps, 300 animals, containing the dung counts at the end of the simulation.

In order to analyze data from different simulation runs down the road, we'll need to know after-the-fact what the key parameters were. To keep track of these values, I organize them into a cell array and then export them as a .csv. This file is called 'metadata' and is found in the directory containing simulation data.

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
