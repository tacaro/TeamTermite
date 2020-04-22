%{
Called by move_and_feed_1
Given path_array created by move_1, determines if there are any patches in
which to stop along the way (grass_quantity > fullness).

Outputs:
path_array is updated to end where animal discovered good grass.
x_stop, y_stop = new end point of path
path_array ends halfway through path through stopping grid square.

I think because of the way MATLAB deals with passing inputs to functions,
it is okay to pass the landscape because it is not modified, so MATLAB does
not make a copy of it. (Otherwise it would be a laborious task for the
computer)
%}

function [path_array, leave, x_stop, y_stop] = check_path(landscape, path_array, crossing_array, max_grass, stop_food, boundary, able2stop)

num_squares = size(path_array, 1);
x_stop = crossing_array(end, 1);
y_stop = crossing_array(end, 2);
leave = 0;

%Leave?
for square = 2:num_squares
        %start at 2 so won't stay in same square if wanted to leave.
    xx = path_array(square, 1);
    yy = path_array(square, 2);
    if (xx + boundary) > size(landscape, 2) || ...
        (xx - boundary) < 1 || (yy + boundary) > size(landscape, 1) || ...
        (yy - boundary) < 1 
        path_array( (square : num_squares), : ) = [];
        num_squares = size(path_array, 1); %Reassign for stop check.
        x_stop = crossing_array(square, 1);
        y_stop = crossing_array(square, 2);
        leave = 1;
        break
    end    
end

%Stop?
for square = 2:num_squares %can't stop in same square as started.
    
    if able2stop
        if landscape(yy, xx, 1) .* landscape(yy, xx, 1) / max_grass > stop_food %Make this connect to parameters from top of run_and_tumble
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
       
            break
        end
    end
    
end


end
