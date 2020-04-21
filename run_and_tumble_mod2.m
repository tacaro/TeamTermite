% Contents:
%     - Model Script
%     - Export metadata
%     - Model Vizualization
%     - Data visualization



%% Model Script
%Set variable model parameters
%%%%grazing parameters
feed_time = 1; %relative to total movement time (of 1)
max_feed = 5; %max amount can feed per turn
energy_spent = 3; %fullness lost per turn

%%%movement angle/dist parameters
max_turn_angle = pi;
angle_ratio = 3; %How much less max turn angle is for run than tumble.
min_tumb = 0.5; %minimum tumble distance
max_tumb = 2; %max tumble dist
run_tumb_ratio = 4; %how much longer is run dist than tumble?
min_run = min_tumb * run_tumb_ratio;
max_run = max_tumb * run_tumb_ratio;
boundary = max_run;

%parameters for decision-making
stay_grass = 30;
stay_nutrition = 5;
run_nutrition = 3; 
stop_food = 0.8;

%%%landscape parameters (dimension, # animals, mound placement) 
xdim = 100;
ydim = 100;

% N mounds need to be the same in both landscapes! 
n_mounds_side = 5; %if regularly placed.
n_mounds = n_mounds_side^2; % number of termite mounds if randomly placed
max_grass = 27.4; %starting grass/nutrition level for fertilizer patches
food_ratio = 1; %ratio of initial grass quantity and nutrition on fertilizered patches vs off

steps = 200; %set max time steps
num_animals = 0;  %set number of animals to walk the Earth
fertilizer_pattern = 1;  %can be 0: random or 1: uniform.


%set up fertilizer mound locations
if fertilizer_pattern == 1 
    fert_x = linspace((boundary + 1), (xdim - boundary), n_mounds_side);
    fert_y = linspace((boundary + 1), (ydim - boundary), n_mounds_side);
    %fert_x(1) = [];, fert_x(end) = []; %Remove fertilizer right on edge
    %fert_y(1) = [];, fert_y(end) = []; %Remove fertilizer right on edge
    [X,Y] = meshgrid(fert_x, fert_y);
    fertilizer_xy = round([X(:), Y(:)]);
elseif fertilizer_pattern == 0
    %random_fert = [randi([1 xdim],1,n_mounds) ; randi([1 ydim],1,n_mounds)];
    %fertilizer_xy = transpose(random_fert);
    %Above allows fertilizer patches outside the boundary.
    fert_x = randi([(1+boundary), (xdim - boundary)], 1, n_mounds);
    fert_y = randi([(1+boundary), (ydim - boundary)], 1, n_mounds);
    fertilizer_xy = transpose( [fert_x; fert_y]);
end 


%ready to initialize landscape
landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy, max_grass, food_ratio);
landscape_before_run = landscape; % take snapshot of first frame for later reference
% Preallocate dataframe to track food concentration over time
landscape_time = zeros(xdim, ydim, steps);


%STEP2: agents move through landscape.

%Record trajectory of all animals. First three columns are first animal,
%fourth through sixth columns are second animal, etc. x, y coords then
%food consumed at that step.

%trajectories are saved as xpos, ypos, and fullness for each agent. 
trajectories = zeros(steps, 3*num_animals);
time_until_leaving = zeros(num_animals,1); %record time animal exits
dist_to_closest_mound = zeros(steps, num_animals);
proximity_to_boundary = zeros(steps, num_animals); 

curr_location = zeros(1,2);
memory = zeros(1,3);

for animal = 1:num_animals
    %%movement loop
    animal_x = 3*animal - 2;%These are for indexing trajectories array
    animal_y = animal_x + 1;
    animal_z = animal_x + 2;
    
    %random starting position on perimeter of landscape: 
    %pick x or y to start on, other var is 1 or max. 
    A = [1+boundary, xdim-boundary];
    astart = A(randi(length(A), 1));
    %bstart = (randi(xdim, 1)); %%%I think this allows a coordinate outside the boundary?
    bstart = boundary + randi(xdim - 2*boundary);
    starting_pos = [astart,bstart ; bstart,astart ]; 
    start_pos = starting_pos(:,randi(2,1));
   
    %Set starting directions.
    if start_pos(1) == 1+boundary
        direction = (-pi/2) + (pi*rand);
    elseif start_pos(1) == xdim-boundary
        direction = (pi/2) + (pi*rand);
    elseif start_pos(2) == 1+boundary
        direction = -(pi*rand);
    elseif start_pos(2) == xdim-boundary
        direction = (pi*rand);
    else
        disp("something wrong with starting direction");
    end
    
    trajectories(1, animal_x : animal_y) = [start_pos]; 
    %initialize. Goes to 1 when animal leaves boundary on landscape.
    leave = 0;
    memory(:) = 0;
    %memory(1) is most recent, (3) least recent.
    
    for t=1:steps
        
        curr_location = trajectories(t, animal_x : animal_y);
        x1 = curr_location(1);
        y1 = curr_location(2);
        [grass_quantity, nutrition] = current_location(landscape,x1, y1);
        food_here = round(grass_quantity * nutrition * max_feed / max_grass, 1);

%Decide on movement strategy and calculate next location
      
            %Choose turn size & movement distance 
            %Could try making tumble just pi + run angles
            %for now, decision to run vs tumble both a fct of food here and
            %recent memory. 
            recent_memory = mean(memory);
            
            
            %** this is where the run vs tumble decision is finally made,
            %and also where it probably makes sense to try to get a sense
            %for what seems reasonable. 
            if food_here > 3 || recent_memory > 0.3 %TUMBLE
                turning_angle = unifrnd(-max_turn_angle, max_turn_angle); 
                d = unifrnd(min_tumb, max_tumb); 
            else %RUN 
                turning_angle = unifrnd(-max_turn_angle/angle_ratio, max_turn_angle/angle_ratio);
                d = unifrnd(min_run, max_run); 
            end 
            
            direction = rem(direction + turning_angle, (2*pi)); %take remainder so always between [-2*pi, 2*pi] 
          
            
            %agent moves 
            x2 = x1+d*cos(direction);
            y2 = y1+d*sin(direction);
            
   

        %Update landscape and trajectories array
        %returned x2 and y2 will be different from inputs if animal crossed
        %boundary or crossed a good patch and stopped.
        [landscape, grass_consumed, nutrition, x_stop, y_stop, leave] = ...
            move_and_feed_1(landscape, x1, y1, x2, y2, boundary, max_feed, max_grass, feed_time, stop_food);
        if leave == 1
            for remaining_steps = t+1 : steps+1
                trajectories(remaining_steps, animal_x : animal_z) = NaN;
                time_until_leaving(animal) = t;
            end
            break
            %ends "t" loop. returns to "animal" loop.
        end
        
        %animals consume more food if quality is higher
        food_consumed = grass_consumed * nutrition; 
        
        trajectories(t+1, animal_x : animal_y) = [x2, y2]; %update location
        trajectories(t+1, animal_z) = food_consumed;
        memory(3) = memory(2);, memory(2) = memory(1);, memory(1) = food_consumed;
        
       
        %calculate distance to nearest mound        
        mound_dists = zeros(n_mounds,1);
        for m = 1:n_mounds 
            mound = fertilizer_xy(m,:);
            pts = [mound; x2,y2];
            mound_dists(m) = pdist(pts, 'euclidean');
        end 
        
        dist_to_closest_mound(t, animal) = min(mound_dists);
        
        %calculate distance to nearest boundary
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

%% Data Export
writematrix(trajectories, 'dfs/trajectories.csv'); % trajectories
writematrix(landscape(:,:,1), 'dfs/quantity_end.csv'); % quantity
writematrix(landscape(:,:,2), 'dfs/nutrition_end.csv'); % nutrition
writematrix(landscape(:,:,3), 'dfs/dung_end.csv'); % dung
writematrix(landscape_before_run(:,:,1), 'dfs/quantity_start.csv'); % quantity at start
writematrix(landscape_before_run(:,:,2), 'dfs/nutrition_start.csv'); % nutrition at start
writematrix(landscape_before_run(:,:,3), 'dfs/dung_start.csv'); % dung at start
