%first attempt at combining agents and landscape for a simple run and
%tumble model. 


%set time step 
steps = 100;

%create trajectory
location = zeros(steps,2); 


%%movement loop
location(1,:) = [0,0]; %start at center XY
curr_location = location(1,:);

for t=1:steps 
    %quality = fct(landscape(curr_location(quality)) %assess quality of the food 
    decide_to_stay = nbinrnd(1,0.8); %some function(quality, etc.) 
         %randomly setting it to move 80% of the time with neg binomial for now.
         %this decision should be based on whether or not in fertilized
         %area
    
    if decide_to_stay==1 
        location(t,:) = curr_location; %agent doesn't move
    
    elseif decide_to_stay == 0  
        
        turning_angle =  unifrnd(0,2*pi); %uniform dist 0->360 deg
        d = unifrnd(0.01, 1); %uniform dist of step size
       
        location(t, :) = [curr_location(1)+d*sin(turning_angle), ...
            curr_location(2)+d*cos(turning_angle)] %agent moves 
        
        curr_location = location(t, :); %update location
    
    end
    
 end