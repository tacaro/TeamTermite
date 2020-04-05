%first attempt at combining agents and landscape for a simple run and
%tumble model. 

%%STEP 1: initialize landscape using initialize_landscape_1.m
%function landscape = initialize_landscape_1(x_dim, y_dim, fertilizer_xy)
fertilizer_xy = [1,1;2,2;6,5;39,31;49,43;29,39]; %made up for now.
xdim = 50
ydim = 50

xx = 50 %%what are xx and yy?
yy = 50
landscape = initialize_landscape_1(xdim,ydim, fertilizer_xy);


%STEP2: agents move through landscape.

        %set time step 
        steps = 1000;

        %create trajectory
        location = zeros(steps,2); 

        %%movement loop
        location(1,:) = [25,25]; %start at center XY
        curr_location = location(1,:);

        for t=1:steps 
            %move_and_feed_1(landscape, x1, y1, x2, y2, boundary, feed_amount, feed_time)
            x1 = curr_location(1);
            y1 = curr_location(2);
            feed_time = 1; %always 
            boundary = 2; %always
            feed_amount = 2; %always
            
            
          
            [grass_quantity, nutrition] = current_location(landscape,x1, y1);
     
            if  grass_quantity > 5 & nutrition > 4 %add something about nutrition in here
                decide_to_stay = 1;
                disp('stay')
                location(t,:) = curr_location; %agent doesn't move
                x2 = curr_location(1);
                y2 = curr_location(2);
                 %update landscape
                [landscape, grass_consumed, nutrition, leave] = move_and_feed_1(landscape,...
                    x1, y1, x2, y2, boundary, feed_amount, feed_time);
           
                
            else
                decide_to_stay = 0; %agent moves
                disp('move')
                turning_angle =  unifrnd(0,2*pi); %uniform dist 0->360 deg

                if nutrition < 5 %move farther if nutrition is low
                    d = unifrnd(2, 8); %uniform dist of step size
                else  %stay closer if nutrition is high
                    d = unifrnd(0.5, 2);
                end 
                
                location(t, :) = [curr_location(1)+d*sin(turning_angle), ...
                  curr_location(2)+d*cos(turning_angle)]; %agent moves 
                
                curr_location = location(t, :); %update location
                
                %taurus wrap
                if curr_location(1) < 0 %went off negative: add to other side
                    curr_location(1) = curr_location(1) + xdim  
                end
                
                if curr_location(1) >  xdim % off the positive end
                       curr_location(1) = 1
                end
                
                if curr_location(2) < 0 %went off negative: add to other side
                    curr_location(2) = curr_location(2) + ydim
                end
                
                if curr_location(2) > ydim % off the positive end
                        curr_location(2) = 1
                end
                
             
                curr_location = (round(curr_location));

                if curr_location(1) == 0 %sometimes location rounds down, need to 
                    curr_location(1) = 1
                end 
                
                if curr_location(2) == 0 %sometimes location rounds down
                    curr_location(2) = 1
                end 
                
                x2 = (curr_location(1));
                y2 = (curr_location(2));
                
                [landscape, grass_consumed, nutrition, leave] = move_and_feed_1(landscape,...
                    x1, y1, x2, y2, boundary, feed_amount, feed_time);
             
            end

        end
         

 %visualization of path
        
plot(location(:,1), location(:,2));

%quantity
surf(landscape(:,:,1));
%nutrition
surf(landscape(:,:,2));
%dung 
%surf(landscape(:, :, 3));
