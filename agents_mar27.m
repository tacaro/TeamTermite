%time step 
steps = 500;

%create agents (there's nothing really happening here right now)
%dummy agent for now
%agent = a1; %set agent type 


%create trajectory
location = zeros(steps,2); 


%%movement loop
location(1,:) = [0,0]; %start at center XY
directions = ['N','S','E','W']; 

for t=2:steps 
    quality = 1 ;%landscape(curr_location(quality)) %assess quality of the food 
    decide_to_stay = nbinrnd(1,0.66);%some function(quality, etc.) . randomly setting it to move 2/3 of the time with neg binomial for now.
    if decide_to_stay==1 
        location(t,:) = curr_location;
    elseif decide_to_stay == 0  
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
    
    
 end
    
    
 
plot(location(:,1), location(:,2))