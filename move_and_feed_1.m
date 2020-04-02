%{
Move and feed on landscape for Doak-Peleg rotation project w/
Liam Friar, Jack Gugel, Ellen Waddle, Tristan Caro

Note: x dimension refers to column, and y dimension to row. X dimension
increases left to right, Y dimension top to bottom.

landscape is passed as an input, updated, and returned as an output.
Path currently input as start and end x-y points, but could be a start
point and an angle+distance. Would just add a first line of code
determining the end point. speed determines how much time is spent
along path vs. at endpoint, and feed-amount is how much to increment
grass quantity.
    
MOVE: Record time spent within each grid space along path. Currently
just a fraction of 1, proportional to how much of path passes through
that grid space.
    
FEED: return grass_consumed and nutrition values, determine time spent
grazing update the landscape (increment grass and dung). As of now,
dung increments by input "feed_time"
    
LEAVE: leave is TRUE if animal moved to be within "boundary" number of
grid spaces of the edge of the landscape array.
%}
    


function [landscape, grass_consumed, nutrition, leave] = move_and_feed_1(landscape, x1, y1,...
    x2, y2, boundary, feed_amount, feed_time)

%MOVE

path_array = move_1(x1, y1, x2, y2);
num_squares = size(path_array, 1);
for square = 1:num_squares
    xx = path_array(square, 1);
    yy = path_array(square, 2);
    new_dung = path_array(square, 3);
    landscape(yy, xx, 3) = landscape(yy, xx, 3) + new_dung;
end


%FEED

x_f = path_array(num_squares, 1);
y_f = path_array(num_squares, 2);
%I define x_f and y_F instead of x2 and y2 in the case that x2 or y2 is
%exactly on a grid line (so it does not round nonsensically).
grass = landscape(y_f, x_f, 1);
nutrition = landscape(y_f, x_f, 2);
grass_consumed = min(grass, feed_amount);
landscape(y_f, x_f, 1) = grass - grass_consumed;
landscape(y_f, x_f, 3) = landscape(y_f, x_f, 3) + feed_time;


%LEAVE?

if (x_f + boundary) > size(landscape, 2) || ...
        (x_f - boundary) < 1 || (y_f + boundary) > size(landscape,1) || ...
        (y_f - boundary) < 1
    leave = true;
else
    leave = false;
end



end
    