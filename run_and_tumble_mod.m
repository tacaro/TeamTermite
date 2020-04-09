%first attempt at combining agents and landscape for a simple run and
%tumble model. 


%Set variable model parameters
%initialize variables for move_and_feed_1
feed_time = 1; %relative to total movement time (of 1)
feed_amount = 5;
init_fullness = 50;
energy_spent = 3;

vary_angle_or_dist = 0; %set tumble strategy: 0: dist, 1: dist
max_turn_angle = pi;
min_tumb = 0.5;
max_tumb = 2;
run_tumb_ratio = 4;
min_run = min_tumb * run_tumb_ratio;
max_run = max_tumb * run_tumb_ratio;
boundary = max_run;

%parameters for decision-making
stay_grass = 30;
stay_nutrition = 4;
run_nutrition = 40;

xdim = 50; %dimensions of landscape
ydim = 50;
steps = 20; %set max time steps
num_animals = 1; %set number of animals to walk the Earth


%%STEP 1: initialize landscape using initialize_landscape_1.m
%function landscape = initialize_landscape_1(x_dim, y_dim, fertilizer_xy)
%fertilizer_xy = [1,1;2,2;6,5;39,31;49,43;29,39;10,10]; %made up for now.


[X,Y] = meshgrid(linspace(1,45,5),linspace(1,45,5));
fertilizer_xy = round([X(:), Y(:)]);
scatter(X(:),Y(:));
landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy);


%STEP2: agents move through landscape.


%Record trajectory of all animals. First two columns are first animal,
%third and fourth columns are second animal, etc.
trajectories = zeros(steps+1, 2*num_animals);


for animal = 1:num_animals
    %%movement loop
    animal_x = 2*animal - 1;%These are for indexing trajectories array
    animal_y = animal_x + 1;
    trajectories(1, animal_x : animal_y) = [0.5*xdim,0.5*ydim]; %start at center XY
    curr_location = zeros(1,2);
    %initialize. Goes to 1 when animal leaves boundary on landscape.
    leave = 0;
    fullness = init_fullness;
    
    for t=1:steps
        
        curr_location = trajectories(t, animal_x : animal_y);
        x1 = curr_location(1);
        y1 = curr_location(2);
        [grass_quantity, nutrition] = current_location(landscape,x1, y1);

        if  1 == 2
            %grass_quantity > stay_grass && nutrition > stay_nutrition
            %disp('stay')
            %x2 = x1;
            %y2 = y1;
             
        else
           % disp('move')
            turning_angle =  unifrnd(-max_turn_angle, max_turn_angle); %uniform dist within bounds
            
            if nutrition < run_nutrition %move farther if nutrition is low
                d = unifrnd(min_run, max_run); %uniform dist of step size
            else  %stay closer if nutrition is high
                d = unifrnd(min_tumb, max_tumb);
            end 
            
            x2 = x1+d*sin(turning_angle);
            y2 = y1+d*cos(turning_angle); %agent moves 
            
        end 
        
        %Update landscape and trajectories array
        [landscape, grass_consumed, nutrition, x_stop, y_stop, leave] = ... 
            move_and_feed_1(landscape, x1, y1, x2, y2, boundary, feed_amount, feed_time, fullness);

        if leave == 1
            for remaining_steps = t+1 : steps+1
                trajectories(remaining_steps, animal_x : animal_y) = NaN;
            end
            break
            %ends "t" loop. returns to "animal" loop.
        end
        trajectories(t+1, animal_x : animal_y) = [x_stop, y_stop]; %update location
        fullness = fullness + grass_consumed - energy_spent;
    end

end

 %visualization of path
        
plot(trajectories(:,1), trajectories(:,2));


%quantity
surf(landscape(:,:,1));
hold on 
zz =transpose(linspace(100,100,length(trajectories(:,2))));
for animal = 1:num_animals
    xx = animal;
    yy = animal + 1;
    plot3(trajectories(:,xx,1), trajectories(:,yy,1),zz)
end 
hold off
%nutrition
surf(landscape(:,:,2));
hold on
zz =transpose(linspace(100,100,length(trajectories(:,2))));
for animal = 1:num_animals
    xx = animal;
    yy = animal + 1;
    plot3(trajectories(:,xx,1), trajectories(:,yy,1),zz)
end 
hold off
%dung 
%surf(landscape(:, :, 3));
