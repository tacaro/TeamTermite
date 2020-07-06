%{
Called by move_and_feed_1
Given path_array created by move_1, determines if there are any patches in
which to stop along the way (grass_quantity > fullness).
Inputs:
path_array is a list of grid coordinates (at the landscape level) in the
order they are crossed in this move and what portion of the move is in each
square.
crossing_array is a list of grid coordinates (at the animal level) starting
with the starting xy, ending with ending xy, and with the coordinates of
each landscape grid line crossed in between.

Outputs:
path_array is updated to end where animal discovered good grass.
x_stop, y_stop = new end point of path
path_array ends halfway through path through stopping grid square.

I think because of the way MATLAB deals with passing inputs to functions,
it is okay to pass the landscape because it is not modified, so MATLAB does
not make a copy of it. (Otherwise it would be a laborious task for the
computer)
%}

function [path_array, leave, x_stop, y_stop] = check_path(landscape, path_array, crossing_array, max_grass, stop_food, max_feed, able2stop)

num_squares = size(path_array, 1);
num_crosses = size(crossing_array, 1);
x_stop = crossing_array(end, 1);
y_stop = crossing_array(end, 2);
leave = 0;

%Leave?
for cross = 2:num_crosses
        %start at 2 so won't stay in same square if wanted to leave.
    xx = crossing_array(cross, 1);
    yy = crossing_array(cross, 2);
    if xx >= size(landscape, 2) + 0.5 || xx <= 0.5 || ...
            yy >= size(landscape, 1) + 0.5 || yy <= 0.5 
        %disp("path"), disp(path_array);
        %disp("crossing"), disp(crossing_array);
        path_array( (cross : num_squares), : ) = [];
        %note if cross == num_crosses, this exceeds array bounds, but also > num_squares, so nothing happens.
        num_squares = size(path_array, 1); %Reassign for stop check.
        x_stop = crossing_array(cross, 1);
        y_stop = crossing_array(cross, 2);
        leave = 1;
        %disp("leave"), disp(xx), disp(yy), disp(x_stop), disp(y_stop) %%%REMOVE
        break
    end    
end

%Stop?
if able2stop
    for square = 2:num_squares %can't stop in same square as started.
        xx = path_array(square, 1);
        yy = path_array(square, 2);
        if max_feed * (landscape(yy, xx, 1) / max_grass) * landscape(yy, xx, 2) > stop_food
            path_array( (square + 1 : num_squares), : ) = [];
            path_array(square, 3) = path_array(square, 3)/2;
            %path_array ends halfway through stopping patch.
            %calculate new stopping coordinates below.
            x_i = crossing_array(square, 1);
            x_f = crossing_array(square+1, 1);
            y_i = crossing_array(square, 2);
            y_f = crossing_array(square+1, 2);
            x_stop = (x_i + x_f) / 2;
            y_stop = (y_i + y_f) / 2;
            leave = 0; %In case left, but now stopped before leaving
            %disp("stop"), disp(xx), disp(yy), disp(landscape(yy,xx,1))
            break
        end
    end
    
end


end
