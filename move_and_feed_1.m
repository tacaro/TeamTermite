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
    


function [landscape, grass_consumed, nutrition, x_stop, y_stop, leave] = move_and_feed_1(landscape, x1, y1,...
    x2, y2, boundary, max_feed, max_grass, feed_time, stop_food)



%LEAVE?
%{
if (x2 + boundary) > size(landscape, 2) || ...
        (x2 - boundary) < 1 || (y2 + boundary) > size(landscape,1) || ...
        (y2 - boundary) < 1
    leave = true;
    grass_consumed = 0;
    nutrition = 0;
    x_stop = x2;
    y_stop = y2;
    return
    %does not record animal's path as it exists (could add that function to check_path)
else
    leave = false;
end
%}
%MOVE


[path_array, crossing_array] = move_1(x1, y1, x2, y2);
[path_array, leave, x_stop, y_stop] = check_path(landscape, path_array, crossing_array, max_grass, stop_food, boundary);
num_squares = size(path_array, 1);
for square = 1:num_squares
    xx = path_array(square, 1);
    yy = path_array(square, 2);
    new_dung = path_array(square, 3);
    landscape(yy, xx, 3) = landscape(yy, xx, 3) + new_dung;
end
move_time = sum(path_array(:,3));
%if animal stopped along its path, the remaining time will be added to the 
%square it stopped in addition to the feed time (below)


%FEED
if leave == 0
    x_f = path_array(num_squares, 1);
    y_f = path_array(num_squares, 2);
    %I define x_f and y_F instead of x2 and y2 in the case that x2 or y2 is
    %exactly on a grid line (so it does not round nonsensically).
    grass = landscape(y_f, x_f, 1);
    nutrition = landscape(y_f, x_f, 2);
    grass_consumed = round(grass * nutrition * max_feed / max_grass, 1);
    landscape(y_f, x_f, 1) = grass - grass_consumed;
    landscape(y_f, x_f, 3) = landscape(y_f, x_f, 3) + feed_time + (1 - move_time);
    
else
    grass_consumed = 0;
    nutrition = 0;
    
end



end
    