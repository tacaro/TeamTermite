
%Set variable model parameters
%%%%grazing parameters
feed_time = 1; %relative to total movement time (of 1)
feed_amount = 5; %max amount can feed per turn
init_fullness = 50;
energy_spent = 3; %fullness lost per turn

%%%movement angle/dist parameters
max_turn_angle = pi;
angle_ratio = 3; %How much less max turn angle is for run than tumble.
min_tumb = 0.5;
max_tumb = 2;
run_tumb_ratio = 4;
min_run = min_tumb * run_tumb_ratio;
max_run = max_tumb * run_tumb_ratio;
boundary = max_run;

%parameters for decision-making
stay_grass = 30;
stay_nutrition = 5;
run_nutrition = 3; 
stop_grass = 30;

%%%landscape parameters (dimension, # animals, mound placement) 
xdim = 50;
ydim = 50;
n_mounds_side = 3; %if regularly placed.
n_mounds = 5; % number of termite mounds if randomly placed
max_food = 100; %starting grass/nutrition level for fertilizer patches

steps = 100; %set max time steps
num_animals = 10;%set number of animals to walk the Earth
fertilizer_pattern = 1;  %can be 0: random or 1: uniform. 


%set up fertilizer mound locations
if fertilizer_pattern == 1 
    fert_x = linspace((boundary + 1), (xdim - boundary), n_mounds_side);
    fert_y = linspace((boundary + 1), (ydim - boundary), n_mounds_side);
    %fert_x(1) = [];, fert_x(end) = []; %Remove fertilizer right on edge
    %fert_y(1) = [];, fert_y(end) = []; %Remove fertilizer right on edge
    [X,Y] = meshgrid(fert_x, fert_y);
    fertilizer_xy = round([X(:), Y(:)]);
    n_mounds = size(fertilizer_xy, 1);
elseif fertilizer_pattern == 0
    %random_fert = [randi([1 xdim],1,n_mounds) ; randi([1 ydim],1,n_mounds)];
    %fertilizer_xy = transpose(random_fert);
    %Above allows fertilizer patches outside the boundary.
    fert_x = randi([(1+boundary), (xdim - boundary)], 1, n_mounds);
    fert_y = randi([(1+boundary), (ydim - boundary)], 1, n_mounds);
    fertilizer_xy = transpose( [fert_x; fert_y]);
end 


%ready to initialize landscape
landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy, max_food);


%STEP2: agents move through landscape.

%Record trajectory of all animals. First two columns are first animal,
%third and fourth columns are second animal, etc.
trajectories = zeros(steps, 2*num_animals);
time_until_leaving = zeros(num_animals,1); %record time animal leaves
dist_to_closest_mound = zeros(steps, num_animals);
proximity_to_boundary = zeros(steps, num_animals); 

curr_location = zeros(1,2);

for animal = 1:num_animals
    %%movement loop
    animal_x = 2*animal - 1;%These are for indexing trajectories array
    animal_y = animal_x + 1;
    
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
    fullness = init_fullness;
    
    for t=1:steps
        
        curr_location = trajectories(t, animal_x : animal_y);
        x1 = curr_location(1);
        y1 = curr_location(2);
        [grass_quantity, nutrition] = current_location(landscape,x1, y1);

%Decide on movement strategy and calculate next location
        if  grass_quantity >= stay_grass || fullness < 2 %&& nutrition >= stay_nutrition
            
            x2 = x1;
            y2 = y1;
            
        else
            %Choose turn size
            %Could try making tumble just pi + run angles
            if fullness < 5 %if hungry, turns are narrower. 
                turning_angle = unifrnd(-max_turn_angle/angle_ratio, max_turn_angle/angle_ratio);
            else 
                turning_angle = unifrnd(-max_turn_angle, max_turn_angle); 
            end 
            direction = rem(direction + turning_angle, (2*pi)); %take remainder so always between [-2*pi, 2*pi] so easier to look at.
            
            %Choose movement distant
            if nutrition < run_nutrition %move farther if nutrition is low
                d = unifrnd(min_run, max_run); %uniform dist of step size
            else  %stay closer if nutrition is high
                d = unifrnd(min_tumb, max_tumb);
                
            end 
            
            x2 = x1+d*cos(direction);
            y2 = y1+d*sin(direction); %agent moves 
            
        end 

        %Update landscape and trajectories array
        %returned x2 and y2 will be different from inputs if animal crossed
        %boundary or crossed a good patch and stopped.
        [landscape, grass_consumed, nutrition, x2, y2, leave] = ... 
            move_and_feed_1(landscape, x1, y1, x2, y2, boundary, feed_amount, feed_time, stop_grass, fullness);

        if leave == 1
            for remaining_steps = t+1 : steps+1
                trajectories(remaining_steps, animal_x : animal_y) = NaN;
            end
            break
            %ends "t" loop. returns to "animal" loop.
        end
        trajectories(t+1, animal_x : animal_y) = [x2, y2]; %update location
        fullness = fullness + grass_consumed - energy_spent;
       
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
            
    end

end


%%% visualization 

%time spent on landscape
hist(time_until_leaving,num_animals/5)
title('time steps spent in simluation')

%distance to nearest boundary
figure
hold on 
for animal = 1:num_animals
    plot(1:steps, proximity_to_boundary(:, animal))
    
end 
title('distance to boundary thru time')
hold off 

%plot distance to mound center through time for each animal
figure
hold on 
for animal = 1:num_animals
    plot(1:steps, dist_to_closest_mound(:, animal))
    
end 
title('distance to closest mound thru time')
hold off 

%quantity. this plot is hard to look at at first, need to ajust it w your
%mouse
figure, surf(landscape(:,:,1));
hold on 
zz =transpose(linspace(100,100,length(trajectories(:,2))));
for animal = 1:num_animals
    xx = 2*animal - 1;
    yy = xx + 1;
    plot3(trajectories(:,xx,1), trajectories(:,yy,1),zz)
end 
title('ending landscape grass quantity values');
hold off

%nutrition this plot is hard to look at at first, need to ajust it w your
%mouse 
figure, surf(landscape(:,:,2));
hold on
zz =transpose(linspace(100,100,length(trajectories(:,2))));
for animal = 1:num_animals
    xx = 2*animal - 1;
    yy = xx + 1;
    plot3(trajectories(:,xx,1), trajectories(:,yy,1),zz)
end 
title('ending landscape nutrition values');
hold off


%dung  this plot is hard to look at at first, need to ajust it w your
%mouse
surf(landscape(:, :, 3));zz =transpose(linspace(100,100,length(trajectories(:,2))));
hold on
for animal = 1:num_animals
    xx = 2*animal - 1;
    yy = xx+1;
    plot3(trajectories(:,xx,1), trajectories(:,yy,1),zz)
end 
title('dung location pileups');
hold off 

