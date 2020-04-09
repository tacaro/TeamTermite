
%Set variable model parameters
%initialize variables for move_and_feed_1
feed_time = 1; %relative to total movement time (of 1)
boundary = 8;
feed_amount = 5;
init_fullness = 10;

vary_angle_or_dist = 0; %set tumble strategy: 0: dist, 1: dist
max_turn_angle = 2*pi;
min_tumb = 0.5;
max_tumb = 2;
run_tumb_ratio = 4;
min_run = min_tumb * run_tumb_ratio;
max_run = max_tumb * run_tumb_ratio;

%parameters for decision-making
stay_grass = 30;
stay_nutrition = 4;
run_nutrition = 6; %didn't we say that nutrition varied from 0-100? these might be far too low

xdim = 50;
xdim = ydim;  
n_mounds = 10;

feed_amount = 5; 
steps = 2000; %set max time steps
num_animals = 10 ;%set number of animals to walk the Earth


[X,Y] = meshgrid(linspace(1,xdim,n_mounds/2),linspace(1,ydim,n_mounds/2));
uniform_fert = round([X(:), Y(:)]);

random_fert = [randi([1 xdim],1,n_mounds) ; randi([1 ydim],1,n_mounds)];
random_fert = transpose(random_fert);

fertilizer_xy = random_fert; %options: uniform_fert or random_fert 

landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy);



%STEP2: agents move through landscape.


=======
[X,Y] = meshgrid(linspace(1,45,5),linspace(1,45,5));
fertilizer_xy = round([X(:), Y(:)]);
scatter(X(:),Y(:))
landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy);



%Record trajectory of all animals. First two columns are first animal,
%third and fourth columns are second animal, etc.
trajectories = zeros(steps+1, 2*num_animals);
time_until_leaving = zeros(num_animals);



for animal = 1:num_animals
    %%movement loop
    animal_x = 2*animal - 1;%These are for indexing trajectories array
    animal_y = animal_x + 1;
    
    %random starting position on perimeter of landscape: 
    %pick x or y to start on, other var is 1 or max. 
    A = [1, xdim];
    astart = A(randi(length(A), 1));
    bstart = (randi(xdim, 1));
    starting_pos = [astart,bstart ; bstart,astart ]; 
    start_pos = starting_pos(:,randi(2,1));
    
    trajectories(1, animal_x : animal_y) = [start_pos]; 
    curr_location = zeros(1,2);
    %initialize. Goes to 1 when animal leaves boundary on landscape.
    leave = 0;
    
    for t=1:steps
        
        curr_location = trajectories(t, animal_x : animal_y);
        x1 = curr_location(1);
        y1 = curr_location(2);
        [grass_quantity, nutrition] = current_location(landscape,x1, y1);


        if  grass_quantity > stay_grass && nutrition > stay_nutrition

            %disp('stay')
            x2 = curr_location(1);
            y2 = curr_location(2);
             
        else
           % disp('move')
            turning_angle =  unifrnd(-max_turn_angle, max_turn_angle); %uniform dist within bounds
            
            if nutrition < run_nutrition %move farther if nutrition is low
                d = unifrnd(min_run, max_run); %uniform dist of step size

            else  %stay closer if nutrition is high
                d = unifrnd(min_tumb, max_tumb);
            end 
            
            curr_location(1) = curr_location(1)+d*sin(turning_angle);
            curr_location(2) = curr_location(2)+d*cos(turning_angle); %agent moves 
            x2 = (curr_location(1));
            y2 = (curr_location(2));
            
        end 
        %Update landscape and trajectories array

        [landscape, grass_consumed, nutrition, leave] = move_and_feed_1(landscape,...
                x1, y1, x2, y2, boundary, feed_amount, feed_time);
         
        if leave == 1
            for remaining_steps = t+1 : steps+1
                trajectories(remaining_steps, animal_x : animal_y) = NaN;
            end
            break
            %ends "t" loop. returns to "animal" loop.
       end
            
        trajectories(t+1, animal_x : animal_y) = curr_location; %update location
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
surf(landscape(:, :, 3));
