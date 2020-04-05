%first attempt at combining agents and landscape for a simple run and
%tumble model. 

%%STEP 1: initialize landscape using initialize_landscape_1.m
%function landscape = initialize_landscape_1(x_dim, y_dim, fertilizer_xy)
fertilizer_xy = [1,1;2,2;6,5;39,31;49,43;29,39]; %made up for now.
xdim = 50;
ydim = 50;

landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy);

%initialize variables for move_and_feed_1
feed_time = 1; %always
boundary = 2; %always
feed_amount = 2; %always


%STEP2: agents move through landscape.

%set time step 
steps = 1000;

%create trajectory
location = zeros(steps,2); 

%%movement loop
location(1,:) = [25,25]; %start at center XY
curr_location = zeros(1,2);
%No need for this variable. Can just index from location in for
%loop.


for t=1:steps 
    %t should start at 2, as this is currently written (and would go to steps+1).
    %move_and_feed_1(landscape, x1, y1, x2, y2, boundary, feed_amount, feed_time)
    curr_location = location(t, :);
    x1 = curr_location(1);
    y1 = curr_location(2);
    [grass_quantity, nutrition] = current_location(landscape,x1, y1);

    if  grass_quantity > 5 && nutrition > 4 %add something about nutrition in here
        decide_to_stay = 1;  %Initial define decide_to_stay outside of for loop!
        %What is decide_to_stay used for?
        disp('stay')
        x2 = curr_location(1);
        y2 = curr_location(2);
         %update landscape


    else
        decide_to_stay = 0; %agent moves
        disp('move')
        turning_angle =  unifrnd(0,2*pi); %uniform dist 0->360 deg

        if nutrition < 5 %move farther if nutrition is low
            d = unifrnd(2, 8); %uniform dist of step size
        else  %stay closer if nutrition is high
            d = unifrnd(0.5, 2);
        end 

        curr_location(1) = curr_location(1)+d*sin(turning_angle);
        curr_location(2) = curr_location(2)+d*cos(turning_angle); %agent moves 


        %taurus wrap
        %Do we want the taurus wrap or to just pop agents off when
        %if leave = 1 (so must have boundary >= step size)
        if curr_location(1) < 0.5 %went off negative: add to other side
            curr_location(1) = curr_location(1) + xdim  
        end

        if curr_location(1) > (xdim + 0.5) % off the positive end
               curr_location(1) = curr_location(1) - xdim 
        end

        if curr_location(2) < 0.5 %went off negative: add to other side
            curr_location(2) = curr_location(2) + ydim
        end

        if curr_location(2) > (ydim + 0.5) % off the positive end
                curr_location(2) = curr_location(2) - ydim 
        end
        x2 = (curr_location(1))
        y2 = (curr_location(2))

    end 

        %NEED TO UPDATE THE location array after taurus as well!!!

    [landscape, grass_consumed, nutrition, leave] = move_and_feed_1(landscape,...
            x1, y1, x2, y2, boundary, feed_amount, feed_time);
    location(t+1, :) = curr_location; %update location
end



 %visualization of path
        
plot(location(:,1), location(:,2));

%quantity
surf(landscape(:,:,1));
%nutrition
surf(landscape(:,:,2));
%dung 
%surf(landscape(:, :, 3));
