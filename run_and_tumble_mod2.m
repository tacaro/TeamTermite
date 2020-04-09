%first attempt at combining agents and landscape for a simple run and
%tumble model. 

%%STEP 1: initialize landscape using initialize_landscape_1.m
xdim = 50;
xdim = ydim;  
n_mounds = 10;
feed_time = 1; 
boundary = 8;
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



%Record trajectory of all animals. First two columns are first animal,
%third and fourth columns are second animal, etc.
trajectories = zeros(steps+1, 2*num_animals);
time_until_leaving = zeros(num_animals);



for animal = 1:num_animals
    %%movement loop
    animal_x = 2*animal - 1;
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

        if  grass_quantity > 30 && nutrition > 40 %add something about nutrition in here
            %disp('stay')
            x2 = curr_location(1);
            y2 = curr_location(2);
             %update landscape


        else
           % disp('move')
            turning_angle =  unifrnd(0,2*pi); %uniform dist 0->360 deg

            if nutrition < 40 %move farther if nutrition is low
                d = unifrnd(2, 4); %uniform dist of step size
            else  %stay closer if nutrition is high
                d = unifrnd(0.5, 2);
            end 

            curr_location(1) = curr_location(1)+d*sin(turning_angle);
            curr_location(2) = curr_location(2)+d*cos(turning_angle); %agent moves 
            x2 = (curr_location(1));
            y2 = (curr_location(2));

        end 


        [landscape, grass_consumed, nutrition, leave] = move_and_feed_1(landscape,...
                x1, y1, x2, y2, boundary, feed_amount, feed_time);
            
             if leave == 1
            trajectories( (t+1 : steps+1), (animal_x : animal_y) ) = NaN;
            time_until_leaving(animal) = t;
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
