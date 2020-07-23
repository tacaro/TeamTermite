%{
Termite mound landscape grazing model
by Ellen Waddle, Jack Gugel, Liam Friar, Tristan Caro.
Supervised by Dr. Dan Doak and Dr. Orit Peleg
at the University of Colorado, Boulder

Landscape is a square grid. Agents can move at a finer scale.
Each point on grid stores visitation/dung count, current grass quantity,
nutritional quality.

See also: README.md
%}

%{
Sections:
     1. Prepare Model
        a. Define Parameters
        b. Generate batch_ID
     2. Execute Batch Simulation
        a. Prepare landscape library. 
        b. LOOP ? for each landscape:
            i. Run Model
            ii. Export Model Data
%}


%% 1. PREPARE MODEL
    % Cleanup the workspace
    clearvars
    close all

% 1a. DEFINE PARAMETERS
% Presets
    truncate_trajectories = true; % truncate rows (steps) of trajectories array that no animals reached
    num_animals = 1000; % Number of animals to run? (integer)
    steps = 500; % Max steps that each animal is allotted? (integer)
    wide = true; % Set the landscape mound size: True = wide, False = thin
    seed = 1;

    % Grazing parameters
    feed_time = 1; %relative to total movement time (of 1). Affects how dung distributes
    max_feed = 5; %max amount can feed per turn

% Movement angle/dist parameters.
% angles are circular normal from vmrand(mean, var)
% distances are gamma distribution from gamrnd(shape, scale) < max_run
    tum_turn_mean = pi; % mean tumble
    tum_turn_var = 2; % fKappa tumble
    tum_dist_shape = 1;
    tum_dist_scale = 2;
    run_turn_mean = 0; % mean run 
    run_turn_var = 2; % fKappa run
    run_dist_shape = 2; 
    run_dist_scale = 2;
    max_run = 8; % maximum run length

% Parameters for decision-making
    n_memories = 3; % n of steps that animal remembers (for tumble decision)
    tumble_food = 0.6 * max_feed;
    stop_food = 0.8 * max_feed; % Used in check_path iff able2stop == TRUE
    able2stop = false; % If true, animals will stop, feed, and end step if they cross a good patch.   

% 1b. GENERATE batch_ID
    % In the format {mean tumble}{fKappa tumble}{mean run}{fKappa
    % run}{n_memories}
    % where decimals are rounded to nearest integer
    batch_ID = strcat(num2str(round(tum_turn_mean)), "_", num2str(tum_turn_var), "_", num2str(run_turn_mean), "_", num2str(run_turn_var), "_", num2str(n_memories));
    mkdir(strcat("output/", batch_ID)); % Creates new directory with run_ID as name
    disp(strcat("The batch ID for this run is", " ", batch_ID));
    
    comments = "None"; % User comments for this run can go here


%% 2. EXECUTE MODEL 
tic % Start the run time clock [see "toc" at end of script]

% 2a. PREPARE LANDSCAPE LIBRARY
if wide == true
    % Create a struct containing all landscape filenames that are wide
    ls_lib = dir('landscapes/wide/*.csv');
elseif wide == false
    ls_lib = dir('landscapes/thin/*.csv');
end
% Clean up the structure to remove fields we don't need
ls_lib = rmfield(ls_lib, {'folder','date','bytes','isdir','datenum'});

% 2b. ITERATE MODEL THROUGH THE LANDSCAPE LIBRARY
for k = 1:numel(ls_lib)

    grass_filename = ls_lib(k).name; % Extract landscape name
    ls_ID = erase(grass_filename, '.csv'); % Define landscape ID 'ls_ID'
    disp(strcat("Initiating landscape", " ", ls_ID));

    if wide == true
        grass_initial = readmatrix(strcat('landscapes/wide/', grass_filename)); % Load wide landscapes
    elseif wide == false
        grass_initial = readmatrix(strcat('landscapes/thin/', grass_filename));  % Load thin landscape
    end


    xdim = size(grass_initial, 2); % The model uses this parameter
    ydim = size(grass_initial, 1); % The model uses this parameter
    max_grass = max(max(grass_initial)); % The model uses this parameter
    nutrition_initial = grass_initial/max_grass; % The model uses this parameter
    dung_initial = zeros(ydim, xdim); % The model uses this parameter
    landscape = cat(3, grass_initial, nutrition_initial, dung_initial); % Initialize landscape

    % Preallocate dataframe to track landscape over time
    % landscape_before_run = landscape; % take snapshot of first frame for later reference 
    landscape_over_time = zeros(xdim, ydim, steps);
    dung_over_time = zeros(xdim, ydim, steps);

    % AGENTS MOVE THROUGH LANDSCAPE

    % Record trajectory of all animals. First three columns are first animal,
    % fourth through sixth columns are second animal, etc. x, y coords then
    % food consumed at that step.

    % Trajectories are saved as xpos, ypos, grass_consumed, run (1) or tumble (0) for each agent.
    % Note that the first grass_consumed value for each animal will remain nan
    % and final run-tumble value for each animal will remain nan.
    disp("Agents released onto landscape");
    trajectories = nan(steps + 1, 4*num_animals);
    curr_location = zeros(1,2);
    memory = nan(n_memories, 1);

    for animal = 1:num_animals
        % Take snapshot of landscape, append to landscape_over_time
        landscape_over_time(:, :, animal) = landscape(:,:,1);
        dung_over_time(:,:,animal) = landscape(:,:,3);

        % Movement loop
        animal_x = 4*animal - 3;%These are for indexing trajectories array
        animal_y = animal_x + 1;
        animal_z = animal_x + 2;
        animal_zz = animal_x + 3;

        % Random starting position on perimeter of landscape:
        % Pick x or y to start on, other var is 1 or max.
        A = [1, xdim];
        astart = A(randi(length(A), 1));
        bstart = randi(xdim);
        starting_pos = [astart,bstart ; bstart,astart ];
        start_pos = starting_pos(:,randi(2,1));

        % Set starting directions.
        if start_pos(1) == 1
            direction = (-pi/2) + (pi*rand);
        elseif start_pos(1) == xdim
            direction = (pi/2) + (pi*rand);
        elseif start_pos(2) == 1
            direction = -(pi*rand);
        elseif start_pos(2) == xdim
            direction = (pi*rand);
        else
            disp("Something is wrong with starting direction, exiting script!");
            return
        end

        trajectories(1, animal_x : animal_y) = [start_pos];
        %initialize. Goes to 1 when animal leaves boundary on landscape.
        leave = 0;
        memory(:) = nan(1,n_memories);
        %memory(1) is most recent, (n_memories) least recent.


    for t=1:steps

        curr_location = trajectories(t, animal_x : animal_y);
        x1 = curr_location(1);
        y1 = curr_location(2);
        [grass_quantity, nutrition] = current_location(landscape,x1, y1);

        %do we use food here any more? I wasn't sure but didn't want to
        %delete.
        food_here = round(grass_quantity * nutrition * max_feed / max_grass, 1);

% Decide on movement strategy and calculate next location

        % Choose turn size & movement distance
        %  decision to tumble is a fct of memory, which = food consumed. 
        % memory is just how much food was eaten the last N time steps
        recent_memory = nanmean(memory);

        % If we want to weight nutrition even further, could * by
        % nutrition again at current location: 

        % This is where the run vs tumble decision is made
        if recent_memory > tumble_food % TUMBLE
            turning_angle = vmrand(tum_turn_mean, tum_turn_var, 1); % Circular normal. vmrand(mean, var, n)
            d = min(gamrnd(tum_dist_shape, tum_dist_scale, 1),max_run); % Gamma. shape = 1, scale =2. max=max_run
            trajectories(t, animal_zz) = 0; 
        else % RUN 
            turning_angle = vmrand(run_turn_mean, run_turn_var, 1); %vmrand(mean, var, n)
            d = min(gamrnd(run_dist_shape, run_dist_scale, 1),max_run); %gamma. shape = 2, scale =2
            trajectories(t, animal_zz) = 1;
        end


        % Agent moves
        direction = rem(direction + turning_angle, (2*pi)); % Take remainder so always between [-2*pi, 2*pi]
        x2 = x1+d*cos(direction);
        y2 = y1+d*sin(direction);


        % Update landscape and trajectories array
        % returned x2 and y2 will be different from inputs if animal crossed
        % landscape boundary or crossed a good patch and stopped (if able2stop).
        [landscape, grass_consumed, nutrition, x2, y2, leave] = ...
            move_and_feed_1(landscape, x1, y1, x2, y2, max_feed, max_grass, feed_time, stop_food, able2stop);
        if leave == 1
            break
            % Ends "t" loop. returns to "animal" loop.
        end
        trajectories(t+1, animal_x : animal_y) = [x2, y2]; % update location
        trajectories(t+1, animal_z) = grass_consumed;
        memory(2:end) = memory(1:(n_memories-1)); % update memory
        memory(1) = grass_consumed;


        end  % t (step) loop
    end % Animal loop


    % Shorten trajectories array for steps that no animals reached (save memory)
    if truncate_trajectories
        longest_trajectory = 0;
        last_step = 1;
        traj_ii = 0;
        for trajectories_animal =  1 : num_animals
            traj_ii = trajectories_animal * 4 - 3;
            if ~isnan(trajectories(steps+1, traj_ii))
                last_step = steps + 1;
                break
            else
                animal_last_step = find(isnan(trajectories(:, traj_ii)), 1) - 1;
                if animal_last_step > last_step
                    last_step = animal_last_step;
                end
            end
        end
        trajectories(last_step + 1 : steps + 1, :) = [];
    end

    disp(strcat(ls_ID, ' landscape trial is complete. Exporting data...'));


    % EXPORT DATA
    % Residency File Creation

    landscape_time_bi = landscape_over_time;
    landscape_time_bi=landscape_time_bi > 50; % binarize the landscape

    % Reshape the trajectories matrix to be 3D matrix
    % where there are 4 columns: x, y, and fullness, run vs tumble
    % each flat matrix represents a single animal.
    traj = reshape(trajectories, steps+1, 4, num_animals);

    % Initialize residency tracking matrix
    residency = zeros(num_animals, 2);

    for page = 1:size(traj, 4) % for every page [animal traj] in the 3d matrix

        for line = 1:size(traj, 1) % for every line [coord pair] in the page
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

    for line = 1:size(residency,1) % for each line in the residency file
        residency(line, 1) = line; % write the animal_id
    end

    for line = 1:size(residency,1) % for each line in the residency file
        % in the third column, note the run length of the animal in the third
        % column.
        residency(line, 3) = sum(~isnan(traj(:,1,line)));
    end

    run_time = toc; % Stop the run time clock
    % EXPORT DATA
    % Create a hash key that is unique to this simulation run
    % The key is current datetime + two random AZ characters
    % % % % STRnum_animals = num2str(num_animals); % make a string version for data export
    % % % % STRsteps = num2str(steps); % make a string version for data export
    % % % % now = num2str(fix(clock));
    % % % % now = now(~isspace(now));
    % % % % run_ID = strcat(now, randsample(char(97:122), 2));
    % % % % mkdir(['dfs/' run_ID]);


    % Create a "basename" so that all exported csvs share a common format, in
    % the same folder. batch_ID folder is required to exist.
    % Remember that batch_ID is defined at the beginning
    basename = strcat(ls_ID, "_", num2str(seed));


% Output metadata file
    % Create a cell array containing useful simulation parameters
    MTDA = {'batch_ID', batch_ID;
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
            
      MTDA = cell2table(MTDA, 'VariableNames', {'parameter', 'value'});
      writetable(MTDA, strcat("output", "/", batch_ID, "/", basename, '_metadata.csv'));
      disp(strcat("Metadata saved for landscape", " ", ls_ID));

% Output .csv files
    disp(strcat("Exporting data files from landscape", " ", ls_ID));
    writematrix(residency, strcat("output/", batch_ID, "/", basename, '_residency.csv')); % residency time, in ticks
    writematrix(trajectories, strcat("output/", batch_ID, "/", basename, '_trajectories.csv')); % trajectories
    writematrix(landscape(:,:,1), strcat("output/", batch_ID, "/",  basename, '_quantity_end.csv')); % quantity
    writematrix(landscape(:,:,2), strcat("output/", batch_ID, "/", basename, '_nutrition_end.csv')); % nutrition
    writematrix(landscape(:,:,3), strcat("output/", batch_ID, "/", basename, '_dung_end.csv')); % dung
    %writematrix(landscape_before_run(:,:,1), strcat(basename, 'quantity_start.csv')); % quantity at start
    %writematrix(landscape_before_run(:,:,2), strcat(basename, 'nutrition_start.csv')); % nutrition at start
    %writematrix(landscape_before_run(:,:,3), strcat(basename, 'dung_start.csv')); % dung at start

    % Commenting out the dynamic_landscape export ? no longer required
    % dynamic_landscape = permute(landscape_over_time, [1 3 2]);
    % dynamic_landscape = reshape(dynamic_landscape, [], size(landscape_over_time, 2), 1);
    % writematrix(dynamic_landscape, strcat(basename, 'dynamic_landscape.csv'));

    disp(strcat(ls_ID, " files saved successfully!"));
    disp("============================");

end


% Done :)