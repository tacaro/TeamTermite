**Updated 4-22-2020 (Liam Friar)**
Everything is run from termite_model.m
Most parameters that could be varied are declared at the top of termite_model.m 
Below is a high level summary of the model and list of parameters, followed by more details about implementation of the model.

****** High level Summary and Parameters *******



**Landscape description:** The landscape has 3 levels: Grass Quantity, Nutritional Value, and Dung Count. Grass Quantity decreases as animals feed. Nutritional value is static. Both are binary to begin with (high on mounds and low off mounds). Dung tracks animal movement (each turn, each animal leaves 1 unit of dung where it feeds, and 1 unit of dung spread along its movement path). Fertilizer mounds are arranged in the landscape in a random, square grid, or hexagonal grid pattern. The input can be a number of fertile pixels and a mound radius or a number of mounds and a mound radius. The size of the landscape can be modified, but the x and y dimensions must be equal for the square grid and should probably be some reasonable proportion for the hexagonal grid. If the landscape is defined with a number of mounds or number of fertile pixels that is impossible given the landscape pattern, mound radius, etc., extra mounds are randomly placed (non-overlapping) and then extra pixels until the parameters are satisfied. So, a 26 mound square grid, for example, would be a 5x5 grid with an extra randomly placed mound.

Parameters with example inputs:
* Landscape type: Random, square, hexagonal
* Size of Landscape: 100x100
* Starting grass value on mounds: 100
* Ratio of on-mound to off-mound grass and nutrition: 5
(^^nutrition on-mound is 1, no matter starting grass value, so if ratio is 5, nutrition is 1 on-mound and 0.2 off mound. Grass could be 100 and 20.)
* Number of mounds: 25
* Number of fertile pixels: 925 (out of 10k)
(^^Want to keep either # mounds or # pixels constant)
* Mound radius: 3.5


**Animal description:** Agents, referred to from hereon as animals, are on the landscape one at a time. Animals initialize just inside the boundary of the landscape oriented into the landscape at some angle between parallel and perpendicular to the nearest edge. Each time step, an animal moves and then feeds. It decides how to move (run or tumble) based on the grass quantity and nutritional value of its current location and a memory of its previous 3 locations. If the animal tumbles, it moves a distance taken from a gamma distribution  and turns at an angle taken from a circular normal distribution centered on pi. If the animal runs, it moves a distance taken from a gamma distribution with the same maximum value as for the tumble, but with a "shape" that gives higher values in that interval, and turns at an angle from a circular normal distribution centered on 0. The amount an animal feeds is a function of the amount of grass at its feeding location. If an animal wanders of the grid, it disappears (leaving dung as it walks off) and the next animal enters.

Parameters:
* Number of animals: hundreds-thousands (Also possible to use a boolean to let animals enter landscape until the landscape is depleted by some amount and then end the simulation)
* Max number of steps per animal
* Able2stop: false (if true, animal can stop if it crosses a good patch along its path)
* Run4ever: false (if true, run steps are infinite until animal leaves landscape or stops on a good patch)
* random_walk: false (if true, animal moves in a random walk instead of run and tumble)
* How much dung animal leaves: 1 during move, 1 during feed each step



**Decision making and parameters:**

* Animals consume grass at final location each time step and deplete the landscape as a function min(grass_here, grass_consumed = max_feed * nutrition * (grass_here / max_grass))
(max_feed is a set value, max_grass is the starting grass quantity on a mound, nutrition is the nutritional value at that location, and grass_here is the grass quantity at the location.)
* Animal has memory of grass_consumed at set number of previous locations.
* Animal makes decision to run or tumble at each time step based on this memory and the same grass_consumed value for its current location though consumed would not be in the past tense if this were normal English. It would be grass_consumable :)

* Animal tumbles if following is true for current location or mean of 3 memory locations:
*  tumble_food * max_grass <  nutrition * grass_here * max_feed / max_grass
(tumble_food = 0.6 currently).

* For context, max_feed = 5 and max_grass = 100, so if on a mound (nutrition = 1), this means grass_here > 60
If off a mound (nutrition = 0.2), so grass_here cannot > 0.6 is impossible for the current location, though the exact value could still matter for affecting the mean of the memory.

* There is also a boolean to stop when crossing a good patch if able2stop == true. This boolean is very similar and should probably be updated to be the same in the future.


****** Implementation Summary *******

After declaring variables, the script begins by creating an x-y array of fertilizer mound locations. The mounds can be in either a random, square grid, or hexagonal grid pattern. For the uniform pattern, the mounds at the edges can be included or not. The landscape is created by calling initialize_landscape_1 given x and y dimensions, the location of fertilizer mounds, and the amount of grass that starts on top of a mound. The x and y dimensions can be varied, although as of now they need to be equal for some code in run_and_tumble to run properly. The landscape has 3 layers: grass quantity (which decreases when it is eaten), nutrition (which currently does not change), and dung (which tracks how much time animals have spent in the given grid square). Dung increases when an animal is grazing and also along its movement path, proportional to the portion of the path that passed through that square. If the largest step an animal could take is 5, then there is a boundary such that any animal coming within 5 grid spaces of the edge of the landscape will disappear. "random_fertilizer" is a function that creates the random fertilizer mound xy coordinates such that the mounds will not overlap.

A boolean "has_patches" allows a control landscape with no fertilizer mounds if false. There should be the same number of total fertile pixels to start, but they are distributed individually instead of in circular mounds. This can still be uniform or random.

The “trajectories” array keeps track of the movement of all animals in a simulation, and of how much food they consumed at each time step. The first two columns are the first animal’s x and y coordinates, the third its food consumed. Columns 4-6 are the coordinates and eating history of animal 2, etc.

After the landscape is initialized, the simulation consists of 2 nested for loops. The outer for loop runs for the number of animals declared for the model. An animal is given a random starting position around the inner boundary, and a random starting direction away from the boundary region. The inner for loop runs for a set number of steps (unless the animal leaves the boundary). Each step, the animal checks the grass quantity and nutrition value at its current location. It then decides whether to "run" or "tumble". If the product of grass quantity and nutrition at the current location is above some threshold, or if the average product of those values from the animal's last 3 time steps is above a different threshold, the animal will "tumble". If the current location and stored food values are too low, the animal will "run". The animal now decides an angle and distance to move, and calculates an endpoint. The angle is chosen by uniform distribution which is narrower if the animal is “running” and larger if “tumbling”. The distance is chosen by uniform distribution over larger values if “running” and smaller values if “tumbling”. 

Note that we use the product of grass_quantity and nutrition to determine food_consumed or to make decisions throughout the model.

The script now calls “move_and_feed_1”. This function updates grass and dung quantities on the landscape from the animal’s motion and returns the amount of grass consumed and nutrition of the animal’s stopping spot. The animal can move on a finer scale than that of the landscape grid. This function creates a path based on the endpoints using move_1.m. It then checks (using check_path) if that path crosses any patches where the animal should stop. The animal stops if the product of grass quantity and nutrition are above some threshold in any grid square that it crosses along its path. That threshold is currently defined separately from the run or tumble threshold. This stop function does not kick in until the animal has left its original square, so it does not get stuck in a very good square. If the animal stops, its new stopping point will be passed back to run_and_tumble_mod2 so everything is in sync. check_path also checks if the animal leaves the boundary area. If it does, that information is passed back to run_and_tumble_mod2. When the animal does stop (either because of check_path or because it reaches the end of it its original path for that step) move_and_feed_1 calculates how much grass the animal consumed by multiplying the maximum amount (defined) an animal can consume by the ratio of grass quantity in its current square to the original max grass_quantity on a fertilizer mound. (So, if fertilizer mound grid squares start with grass_quantity = 100, and the animal is in a square with grass_quantity = 50, and the max it can eat in one step is 5, then it will consume (50/100)*5 = 2.5 units of grass. That value will be multiplied by nutrition when the the trajectories and memory arrays update food_consumed for that step.

Back in run_and_tumble_mod2, if the animal has left, then the inner for loop breaks, and we move to the next animal. All remaining values in the animal’s columns of the trajectories array are NaN. If the animal did not leave, its memory and trajectories arrays are updated and the inner (step) loop iterates again.

Search strategy options:
* Run4ever - if true, the animal will move indefinitely on a "run" step unless it crosses a good patch and stops or leaves the boundary.
* Able2stop - if true, the animal can stop when it crosses a good patch (in check_path function). If false, stops only at end of step or if leaves boundary.
* random_walk - if true, animal does a true random walk instead of run and tumble.

