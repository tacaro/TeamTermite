%{
Initialize landscape for Doak-Peleg rotation project with
Liam Friar, Jack Gugel, Ellen Waddle, and Tristan Caro.

Landscape is a square grid. Agents can move at a finer scale.
Each point on grid stores visitation/dung count, current grass quantity,
nutritional quality.
Location of termite mounds or fertilization patches will be an initial
input, and initial attributes of grid points will be determined from those
inputs.

Note: x dimension refers to column, and y dimension to row. X dimension
increases left to right, Y dimension top to bottom.
%}

%{ 
Contents:
     - Set User-Defined Parameters
     - Model Script
     - Model Vizualization
     - Export Metadata
%}



%% SET USER-DEFINED PARAMETERS:
    % random or uniform, (neutral)? (string)
    fertilizer_pattern = "random";
    has_patches = true; %if false, landcape has same number of individual fertile grid squares, but arranged as single squares instead of in patches.
    % Number of animals to run? (integer)
    num_animals = 300;  %set number of animals to walk the Earth
    STRnum_animals = num2str(num_animals); % make a string version for data export
    % Max steps that each animal is allotted? (integer)
    steps = 200;
    STRsteps = num2str(steps); % make a string version for data export
    able2stop = false; %If set to false, animals will not stop if they cross a good patch.
    
    
    
    
    
    
    
    
    
    
    
    

%% Model Script
% Model parameters
    % Grazing parameters
    feed_time = 1; %relative to total movement time (of 1)
    max_feed = 5; %max amount can feed per turn
    energy_spent = 3; %fullness lost per turn

% Movement angle/dist parameters
    max_turn_angle = pi;
    angle_ratio = 3; %How much less max turn angle is for run than tumble.
    min_tumb = 0.5; %minimum tumble distance
    max_tumb = 2; %max tumble dist
    run_tumb_ratio = 4; %how much longer is run dist than tumble?
    min_run = min_tumb * run_tumb_ratio;
    max_run = max_tumb * run_tumb_ratio;
    boundary = max_run;

% Parameters for decision-making
    stay_grass = 30;
    stay_nutrition = 5;
    run_nutrition = 3; 
    stop_food = 0.8;

% Landscape parameters (dimension, # animals, mound placement) 
    xdim = 100;
    ydim = 100;
    mound_radius = 3.5;
% N mounds need to be the same in both landscapes! 
    n_mounds_side = 5; %if regularly placed.
    n_mounds = n_mounds_side^2; % number of termite mounds if randomly placed
    max_grass = 100; %starting grass/nutrition level for fertilizer patches

%ratio of initial grass quantity and nutrition on fertilizered patches vs off
if fertilizer_pattern == "neutral"
    food_ratio = 1;
else
    food_ratio = 5;
end

if ~has_patches %No patches! individual fertile squares!
    size_circle = 37; %hardcoded in for mound_radius 3.5
    n_mounds = n_mounds*size_circle;
    n_mounds_side = floor(sqrt(n_mounds));
    n_mounds_extra = n_mounds - n_mounds_side^2;
    mound_radius = 0.5;
else
    n_mounds_extra = 0;
end  

% Set up fertilizer mound locations, initialize landscape
if fertilizer_pattern == "uniform" 
    fert_x = linspace((boundary + 1), (xdim - boundary), n_mounds_side);
    fert_y = linspace((boundary + 1), (ydim - boundary), n_mounds_side);
    %fert_x(1) = [];, fert_x(end) = []; %Remove fertilizer right on edge
    %fert_y(1) = [];, fert_y(end) = []; %Remove fertilizer right on edge
    [X,Y] = meshgrid(fert_x, fert_y);
    fertilizer_xy = round([X(:), Y(:)]);
    if n_mounds_extra ~= 0  %The circles do not contain a perfect square number of gridspaces, so randomly assign remainder.
        fertilizer_xy = random_fertilizer(fertilizer_xy, n_mounds_extra, xdim, ydim, boundary, mound_radius);    
    end
    landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy, max_grass, food_ratio, mound_radius);
    landscape_before_run = landscape; % take snapshot of first frame for later reference 
elseif fertilizer_pattern == "random"
    fertilizer_xy = zeros(n_mounds, 2);
    fertilizer_xy = random_fertilizer(fertilizer_xy, n_mounds, xdim, ydim, boundary, mound_radius);
    landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy, max_grass, food_ratio, mound_radius);
    landscape_before_run = landscape; % take snapshot of first frame for later reference
 %{
elseif fertilizer_pattern == "random"
    %random_fert = [randi([1 xdim],1,n_mounds) ; randi([1 ydim],1,n_mounds)];
    %fertilizer_xy = transpose(random_fert);
    %Above allows fertilizer patches outside the boundary.
    fert_x = randi([(1+boundary), (xdim - boundary)], 1, n_mounds);
    fert_y = randi([(1+boundary), (ydim - boundary)], 1, n_mounds);
    fertilizer_xy = transpose( [fert_x; fert_y]);
    landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy, max_grass, food_ratio, mound_radius);
    landscape_before_run = landscape; % take snapshot of first frame for later reference
%}
        %{
elseif fertilizer_pattern == "neutral"
    fert_x = linspace((boundary + 1), (xdim - boundary), n_mounds_side);
    fert_y = linspace((boundary + 1), (ydim - boundary), n_mounds_side);
    %fert_x(1) = [];, fert_x(end) = []; %Remove fertilizer right on edge
    %fert_y(1) = [];, fert_y(end) = []; %Remove fertilizer right on edge
    [X,Y] = meshgrid(fert_x, fert_y);
    fertilizer_xy = round([X(:), Y(:)]);
    landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy, max_grass, food_ratio, mound_radius);
    landscape_before_run = landscape; % take snapshot of first frame for later reference
%}
else
    disp("Exception: Fertilizer pattern not recognized. The options are 'random', 'uniform', and 'neutral'.")
    clearvars
    return
end     
    
% Preallocate dataframe to track landscape over time
    landscape_over_time = zeros(xdim, ydim, num_animals);


%STEP 2: agents move through landscape.

% Record trajectory of all animals. First three columns are first animal,
% fourth through sixth columns are second animal, etc. x, y coords then
% food consumed at that step.

% Trajectories are saved as xpos, ypos, and fullness for each agent. 
trajectories = zeros(steps, 3*num_animals);
time_until_leaving = zeros(num_animals,1); %record time animal exits
dist_to_closest_mound = zeros(steps, num_animals);
proximity_to_boundary = zeros(steps, num_animals); 

curr_location = zeros(1,2);
memory = zeros(1,3);

for animal = 1:num_animals
    % Take snapshot of landscape, append to landscape_over_time
    landscape_over_time(:, :, animal) = landscape(:,:,1);
    
    % Movement loop
    animal_x = 3*animal - 2;%These are for indexing trajectories array
    animal_y = animal_x + 1;
    animal_z = animal_x + 2;
    
    % Random starting position on perimeter of landscape: 
    % Pick x or y to start on, other var is 1 or max. 
    A = [1+boundary, xdim-boundary];
    astart = A(randi(length(A), 1));
    %bstart = (randi(xdim, 1)); %%%I think this allows a coordinate outside the boundary?
    bstart = boundary + randi(xdim - 2*boundary);
    starting_pos = [astart,bstart ; bstart,astart ]; 
    start_pos = starting_pos(:,randi(2,1));
   
    % Set starting directions.
    if start_pos(1) == 1+boundary
        direction = (-pi/2) + (pi*rand);
    elseif start_pos(1) == xdim-boundary
        direction = (pi/2) + (pi*rand);
    elseif start_pos(2) == 1+boundary
        direction = -(pi*rand);
    elseif start_pos(2) == xdim-boundary
        direction = (pi*rand);
    else
        disp("Something is wrong with starting direction, exiting script!");
        return
    end
    
    trajectories(1, animal_x : animal_y) = [start_pos]; 
    %initialize. Goes to 1 when animal leaves boundary on landscape.
    leave = 0;
    memory(:) = 0;
    %memory(1) is most recent, (3) least recent.
    
    %landscape_over_time = landscape_over_time(:,:,landscape(:,:,1);
    
    for t=1:steps
        
        curr_location = trajectories(t, animal_x : animal_y);
        x1 = curr_location(1);
        y1 = curr_location(2);
        [grass_quantity, nutrition] = current_location(landscape,x1, y1);
        food_here = round(grass_quantity * nutrition * max_feed / max_grass, 1);

% Decide on movement strategy and calculate next location
      
            % Choose turn size & movement distance 
            % Could try making tumble just pi + run angles
            % for now, decision to run vs tumble both a fct of food here and
            % recent memory. 
            recent_memory = mean(memory);
            
            
            % ** this is where the run vs tumble decision is finally made,
            % and also where it probably makes sense to try to get a sense
            % for what seems reasonable. 
            if food_here > 3 || recent_memory > 0.3 % TUMBLE
                turning_angle = unifrnd(-max_turn_angle, max_turn_angle); 
                d = unifrnd(min_tumb, max_tumb); 
            else % RUN 
                turning_angle = unifrnd(-max_turn_angle/angle_ratio, max_turn_angle/angle_ratio);
                d = unifrnd(min_run, max_run); 
            end 
            
            direction = rem(direction + turning_angle, (2*pi)); % Take remainder so always between [-2*pi, 2*pi] 
          
            
            % Agent moves 
            x2 = x1+d*cos(direction);
            y2 = y1+d*sin(direction);
            
   

        % Update landscape and trajectories array
        % returned x2 and y2 will be different from inputs if animal crossed
        % boundary or crossed a good patch and stopped.
        [landscape, grass_consumed, nutrition, x2, y2, leave] = ...
            move_and_feed_1(landscape, x1, y1, x2, y2, boundary, max_feed, max_grass, feed_time, stop_food, able2stop);
        if leave == 1
            for remaining_steps = t+1 : steps+1
                trajectories(remaining_steps, animal_x : animal_z) = NaN;
                time_until_leaving(animal) = t;
            end
            break
            % Ends "t" loop. returns to "animal" loop.
        end
        
        % Animals consume more food if quality is higher
        food_consumed = grass_consumed * nutrition; 
        
        trajectories(t+1, animal_x : animal_y) = [x2, y2]; %update location
        trajectories(t+1, animal_z) = food_consumed;
        memory(3) = memory(2);, memory(2) = memory(1);, memory(1) = food_consumed;
        
       
        % Calculate distance to nearest mound  
        if has_patches
            mound_dists = zeros(n_mounds,1);
            for m = 1:n_mounds 
                mound = fertilizer_xy(m,:);
                pts = [mound; x2,y2];
                mound_dists(m) = pdist(pts, 'euclidean');
            end 

            dist_to_closest_mound(t, animal) = min(mound_dists);
        end
        %}
        % Calculate distance to nearest boundary
        dist_to_boundary = [x2; xdim - x2; y2; ydim - y2] - boundary; 
        proximity_to_boundary(t, animal) = min(dist_to_boundary);
        time_until_leaving(animal) = steps;
    
    end

end


%% Visualization

% Time spent on landscape
    hist(time_until_leaving,num_animals/5)
    title('time steps spent in simluation')


% Plot fullness through time for each animal 
    hold on
    for animal = 1:num_animals
        fullness_level = trajectories(:,3*animal);
        t_spent = time_until_leaving(animal);
        plot(1:t_spent, fullness_level(1:t_spent));
    end 
    xlim([1 steps])
    ylim([1 max_feed+2])
    title('fullness through time ');
    hold off 

% Distance to nearest boundary.
    figure
    hold on 
    for animal = 1:num_animals
        plot(1:steps, proximity_to_boundary(:, animal))

    end 
    title('distance to boundary thru time')
    hold off 

% Plot distance to mound center through time for each animal
    figure
    hold on 
    for animal = 1:num_animals
        plot(1:steps, dist_to_closest_mound(:, animal))

    end 
    title('distance to closest mound thru time')
    hold off 

% Quantity Plot
    figure, surf(landscape(:,:,1));
    hold on 
    zz =transpose(linspace(100,100,length(trajectories(:,2))));
    for animal = 1:num_animals
        xx = 3*animal - 2;
        yy = xx + 1;
        plot3(trajectories(:,xx,1), trajectories(:,yy,1),zz)
    end 
    title('ending landscape grass quantity values');
    hold off

% Nutrition Plot 
    figure, surf(landscape(:,:,2));
    hold on
    zz =transpose(linspace(100,100,length(trajectories(:,2))));
    for animal = 1:num_animals
        xx = 3*animal - 2;
        yy = xx + 1;
        plot3(trajectories(:,xx,1), trajectories(:,yy,1),zz)
    end 
    title('ending landscape nutrition values');
    hold off


% Dung Plot 
    surf(landscape(:, :, 3));zz =transpose(linspace(100,100,length(trajectories(:,2))));
    hold on
    for animal = 1:num_animals
        xx = 3*animal - 2;
        yy = xx + 1;
        plot3(trajectories(:,xx,1), trajectories(:,yy,1),zz)
    end 
    title('dung location pileups');
    hold off 
    
    
    
%% Residency File Creation

landscape_time_bi = landscape_over_time;
landscape_time_bi=landscape_time_bi > 50;

% Reshape the trajectories matrix to be 3D matrix
% where there are 3 columns: x, y, and fullness
% each flat matrix represents a single animal.
traj = reshape(trajectories, steps+1, 3, num_animals);

% Initialize residency tracking matrix
residency = zeros(num_animals, 2);

for page = 1:size(traj, 3) % for every page in the 3d matrix

    for line = 1:size(traj, 1) % for every line in the page
        x = traj(line, 1, page); % note the x coord
        y = traj(line, 2, page); % note the y coord
        if isnan(x) || isnan(y) % if the x or y coordinates are NaN
            continue % skip this iteration
        end
        if landscape_over_time(round(x),round(y)) > 50 % if the x,y coords of landscape are in TRUE (high nutrient)
            residency(page, 2) = residency(page, 2) + 1; % add one to the value
        %elseif landscape_over_time(round(x),round(y)) == 0 % else if x,y are in FALSE (low nutrient)
           %residency(page, 2) = residency(page, 2) + 0; % add zero the the value
        end
    end
    
end

for line = 1:size(residency,1)
    residency(line, 1) = line;
end

%% Data Export
% Create a hash key that is unique to this simulation run
% The key is current datetime + two random AZ characters
now = num2str(fix(clock));
now = now(~isspace(now));
run_ID = strcat(now, randsample(char(97:122), 2));
mkdir(['dfs/' run_ID]);


% Create a "basename" so that all exported csvs share a common format, in
% the same folder. 'dfs/' folder is required to exist.
basename = strcat('dfs/', run_ID, "/", fertilizer_pattern, "_", STRsteps, "_", STRnum_animals, "_");

% Output metadata file
    % Create a cell array containing useful simulation parameters
    MTDA = {'run_ID', run_ID;
            'fertilizer_pattern', fertilizer_pattern;
            'max_steps', steps;
            'num_animals', num_animals;
            'food_ratio', food_ratio;
            'max_feed', max_feed;
            'max_grass', max_grass;
            'max_run', max_run;
            'max_tumb', max_tumb;
            'max_turn_angle', max_turn_angle;
            'min_run', min_run;
            'min_tumb', min_tumb;
            'n_mounds', n_mounds;
            'stay_grass', stay_grass;
            'stay_nutrition', stay_nutrition;
            'run_nutrition', run_nutrition;
            'stop_food', stop_food;
            };
      MTDA = cell2table(MTDA, 'VariableNames', {'Parameter', 'Value'});
      writetable(MTDA, strcat(basename, 'metadata.csv'));

% Output .csv files
    disp("Saving files . . .")
    disp(strcat("This run's identifier is:", run_ID));
    writematrix(residency, strcat(basename, 'residency.csv')); % residency time, in ticks
    writematrix(trajectories, strcat(basename, 'trajectories.csv')); % trajectories
    writematrix(landscape(:,:,1), strcat(basename, 'quantity_end.csv')); % quantity
    writematrix(landscape(:,:,2), strcat(basename, 'nutrition_end.csv')); % nutrition
    writematrix(landscape(:,:,3), strcat(basename, 'dung_end.csv')); % dung
    writematrix(landscape_before_run(:,:,1), strcat(basename, 'quantity_start.csv')); % quantity at start
    writematrix(landscape_before_run(:,:,2), strcat(basename, 'nutrition_start.csv')); % nutrition at start
    writematrix(landscape_before_run(:,:,3), strcat(basename, 'dung_start.csv')); % dung at start

% In order to export the three dimensional landscape_over_time matrix in a way that makes sense
% I'm going to export it as a two dimensional matrix with each slice pasted
% below the proceeding one.
dynamic_landscape = permute(landscape_over_time, [1 3 2]);
dynamic_landscape = reshape(dynamic_landscape, [], size(landscape_over_time, 2), 1);
writematrix(dynamic_landscape, strcat(basename, 'dynamic_landscape.csv'));

disp("All files saved successfully!")

% Done :)


