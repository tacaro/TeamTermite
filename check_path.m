%{
Called by move_and_feed_1
Given path_array created by move_1, determines if there are any patches in
which to stop along the way (grass_quantity > fullness).

Outputs:
path_array is updated to end where animal discovered good grass.
x_stop, y_stop = new end point of path
path_array ends halfway through path through stopping grid square.

%}

function [path_array, leave, x_stop, y_stop] = check_path(grass_scape, path_array, crossing_array, fullness, boundary)

num_squares = size(path_array, 1);
x_stop = crossing_array(end, 1);
y_stop = crossing_array(end, 2);
leave = 0;

for square = 1:num_squares
    xx = path_array(square, 1);
    yy = path_array(square, 2);
    
    if grass_scape(yy, xx) > fullness
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
        disp("stop");
        disp(x_stop);, disp(y_stop);
        break
    elseif (xx + boundary) > size(grass_scape, 2) || ...
        (xx - boundary) < 1 || (yy + boundary) > size(grass_scape, 1) || ...
        (yy - boundary) < 1
        path_array( (square : num_squares), : ) = [];
        x_stop = crossing_array(square, 1);
        y_stop = crossing_array(square, 2);
        leave = 1;
        disp("leave");
        disp(xx);, disp(yy);
        break
    end
    
end
%}