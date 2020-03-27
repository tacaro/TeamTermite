%time step 
steps = 1000;

%create agents 
a1 = %dummy agent for now
agent = a1; %set agent type 


%create trajectory
location = zeros(steps,2); 


%%movement loop
location(1,:) = [0,0]; %start at center XY
directions = ['N','S','E','W']; 

for t=2:steps 
    quality = %landscape(curr_location(quality)) %assess quality of the food 
    decide_to_stay %some function(quality, etc.) 
    if decide_to_stay==1 
        location(t,:) = curr_location;
    else 
        direction = datasample(directions,1);
        if direction == 'N'
            location(t,: )= [location(t-1,1), location(t-1,2)+1];
            curr_location = location(t, :);
        elseif direction == 'S'
            location(t,: )= [location(t-1,1), location(t-1,2)-1];
            curr_location = location(t, :);
        elseif direction == 'E'
            location(t,: )= [location(t-1,1)+1, location(t-1,2)];
            curr_location = location(t, :);    
        elseif direction == 'W'
            location(t,: )= [location(t-1,1)-1, location(t-1,2)];
            curr_location = location(t, :);  
    end 
    
    
    
    end 
