%{
Called by the function move_and_feed_1.
Input: starting and ending coordinates
Output:
path-array:
a 3-column array with rows in order as path traveled. Columns:
1: x-coordinate of grid space traveled through.
2: y-coordinate of grid space traveled through.
3: Portion of path spent in that grid space.
crossing_array:
x-y coordinates of grid lines crossed (in order of travel)

%}


function [path_array, crossing_array] = move_1(x1, y1, x2, y2)

%round coordinates for landscape grid.
x1_round = round(x1);
x2_round = round(x2);
y1_round = round(y1);
y2_round = round(y2);

num_x_crossings = abs(x2_round-x1_round);
num_y_crossings = abs(y2_round-y1_round);
total_crossings = num_x_crossings + num_y_crossings;
total_distance = sqrt((x2 - x1)^2 + (y2 - y1)^2);

if total_crossings == 0
    %animal did not move grid squares!
    path_array = [x2_round, y2_round, 1];
    crossing_array = [x1, y1; x2, y2];
    
else
    %animal moved to new grid square
    x_direction = sign(x2_round-x1_round);
    y_direction = sign(y2_round-y1_round);
    slope = (y2-y1)/(x2-x1);
    
    crossing_array = zeros(2+total_crossings, 2);
    %Each row will be x, y. Contains end points and all points that cross a
    %grid line.
    crossing_array(1, 1:2) = [x1, y1];
    crossing_array(2+total_crossings, 1:2) = [x2, y2];
    
    
    for x_crossing = 1:num_x_crossings
        
        x = x1_round + (x_crossing - 0.5)*x_direction;
        y = y1 + (x - x1) * slope;
        crossing_array(1+x_crossing, 1:2) = [x, y]; 
    end   
    for y_crossing = 1:num_y_crossings
        array_index = 1 + num_x_crossings + y_crossing;
        
        y = y1_round + (y_crossing - 0.5)*y_direction;
        x = x1 + (y - y1) / slope;
        crossing_array(array_index, 1:2) = [x, y];
    end

%Get points in correct order and eliminate duplicate points
    if x_direction == 1
        crossing_array_x = sort(crossing_array(:,1), 'ascend');
    else
        crossing_array_x = sort(crossing_array(:,1), 'descend');
    end
    if y_direction == 1
        crossing_array_y = sort(crossing_array(:,2), 'ascend');
    else
        crossing_array_y = sort(crossing_array(:,2), 'descend');
    end

    crossing_array = [crossing_array_x, crossing_array_y];
%{
    %crossing_array = round(crossing_array, 2);
        %Rounding is to avoid small differences in calculating a duplicate
        %point in multiple ways from hiding that duplicate point. This
        %whole section is probably unnecessary, but it is still here in
        %case errors start to appear, as the code worked fine with this
        %except in the very rare circumstance that an animal started or
        %stopped exactly on a grid boundary (n.5000) or crossed a grid
        %boundary by less than 0.01.
    i_array = sort([2:size(crossing_array, 1)], 'descend'); 
    for pp = i_array
        if crossing_array(pp, 1) == crossing_array(pp-1, 1) && ...
                crossing_array(pp, 2) == crossing_array(pp-1, 2)
            crossing_array(pp, :) = [];    
        end
    end
 %}
 
%Create array of landscape coords of gridsquares crossed, and distance
%traveled through each square.
    num_squares = size(crossing_array, 1) - 1;
    path_array = zeros(num_squares, 3);
    %first two values are xy coords of gridsquare, third is distance.
    for square = 1 : num_squares
        x_i = crossing_array(square, 1);
        x_f = crossing_array(square+1, 1);
        y_i = crossing_array(square, 2);
        y_f = crossing_array(square+1, 2);
        path_array(square, 1) = round( (x_i + x_f) / 2 );
        path_array(square, 2) = round( (y_i + y_f) / 2 );
        path_array(square, 3) = sqrt((x_f - x_i)^2 + (y_f - y_i)^2);
    end
    
%Divide distances by total distance
    path_array(:, 3) = path_array(:, 3) / total_distance;         
    
end

end