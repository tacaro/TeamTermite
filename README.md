# TeamTermite
Agent based model of ungulate grazing amid nutrient-rich termite mounds

Current working script: run_and_tumble_mod2.m

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
