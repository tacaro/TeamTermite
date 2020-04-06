%first attempt at combining agents and landscape for a simple run and
%tumble model. 

%%STEP 1: initialize landscape using initialize_landscape_1.m
%function landscape = initialize_landscape_1(x_dim, y_dim, fertilizer_xy)
%fertilizer_xy = [1,1;2,2;6,5;39,31;49,43;29,39;10,10]; %made up for now.

[X,Y] = meshgrid(linspace(1,45,5),linspace(1,45,5));
fertilizer_xy = round([X(:), Y(:)]);
scatter(X(:),Y(:))

%plot(xpts,ypts);
%scatter(spots);
xdim = 50;
ydim = 50;

landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy);

%initialize variables for move_and_feed_1
feed_time = 1; %always
boundary = 8; %always
feed_amount = 5; %always


%STEP2: agents move through landscape.

%set max time steps
steps = 1000;
%set number of animals to walk the Earth
num_animals = 10;

%Record trajectory of all animals. First two columns are first animal,
%third and fourth columns are second animal, etc.
trajectories = zeros(steps+1, 2*num_animals);



for animal = 1:num_animals
    %%movement loop
    animal_x = 2*animal - 1;
    animal_y = animal_x + 1;
    trajectories(1, animal_x : animal_y) = [0.5*xdim,0.5*ydim]; %start at center XY
    curr_location = zeros(1,2);
    %initialize. Goes to 1 when animal leaves boundary on landscape.
    leave = 0;
    
    for t=1:steps
        
        curr_location = trajectories(t, animal_x : animal_y);
        x1 = curr_location(1);
        y1 = curr_location(2);
        [grass_quantity, nutrition] = current_location(landscape,x1, y1);

        if  grass_quantity > 30 && nutrition > 4 %add something about nutrition in here
            %disp('stay')
            x2 = curr_location(1);
            y2 = curr_location(2);
             %update landscape


        else
           % disp('move')
            turning_angle =  unifrnd(0,2*pi); %uniform dist 0->360 deg

            if nutrition < 6 %move farther if nutrition is low
                d = unifrnd(2, 8); %uniform dist of step size
            else  %stay closer if nutrition is high
                d = unifrnd(0.5, 2);
            end 

            curr_location(1) = curr_location(1)+d*sin(turning_angle);
            curr_location(2) = curr_location(2)+d*cos(turning_angle); %agent moves 
            x2 = (curr_location(1));
            y2 = (curr_location(2));

        end 

            %NEED TO UPDATE THE location array after taurus as well!!!

        [landscape, grass_consumed, nutrition, leave] = move_and_feed_1(landscape,...
                x1, y1, x2, y2, boundary, feed_amount, feed_time);
        if leave == 1
            for remaining_steps = t+1 : steps+1
                trajectories(remaining_steps, animal_x : animal_y) = ...
                    trajectories(t, animal_x : animal_y);
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
%surf(landscape(:, :, 3));
