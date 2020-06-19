function [hexCoords, n_mounds_extra] = hexGrid(xdim, ydim, boundary, mound_radius, n_mounds)
%Return coordinates of hexagonal lattice of n_mounds on grid of given
%dimensions with given boundary region. hexCoords is the xy coordinates of
%hexagonally arranged mounds. extra_mounds is the number of mounds from
%n_munds that are not in the lattice. Only tries a hexagonal grid with both
%rows of the alternating coordinate. The alternating row could be removed
%from one or both edges of that dimension.

%{
To determine the x and y dimensions in a hexagonal grid:
(y_per_side + 0.5) / (x_per_side * cos30) == ydim / xdim ;
(as close as possible)
y_per_side * x_per_side = n_mounds;
Using algebra, we get:
y^2 + 0.5y - (n * cos30 * ydim/xdim) = 0

Given the number of x and y points, we get a scale for the grid from:
ydim/(y_per_side + 0.5)
%}

mound_radius = floor(mound_radius);
cos30 = sqrt(3)/2;
%xdim and y dim zoomed inside of boundary. The (-1) accounts for the first
%mound centers being on the edge of the allowed region.
xdim = xdim - 2*boundary - 2*mound_radius - 1;
ydim = ydim - 2*boundary - 2*mound_radius - 1;
aspect = ydim / xdim;

y_roots = roots([1 0.5 (-n_mounds * cos30 * aspect)]);
y_choose = y_roots > 0 ;
y_per_side_1 = ceil(y_roots(y_choose));
x_per_side_1 = floor(n_mounds / y_per_side_1);
y_per_side_2 = floor(y_roots(y_choose));
x_per_side_2 = floor(n_mounds / y_per_side_2);
if (n_mounds - (y_per_side_1 * x_per_side_1)) < ... 
        (n_mounds - (y_per_side_2 * x_per_side_2))
    y_per_side = y_per_side_1;
    x_per_side = x_per_side_1;
else
    y_per_side = y_per_side_2;
    x_per_side = x_per_side_2; 
end
    
n_mounds_extra = n_mounds - (y_per_side * x_per_side);

%scale is distance between points along y axis of xy grid. The (-1) on each
%side of ratio is for the first point along the edge of the allowed area.
y_scale = (ydim - 1) / ((y_per_side - 1) + 0.5);
x_scale = xdim / ((x_per_side - 1) * cos30);
scale = round(min(y_scale, x_scale), 1);

%offset alternates where y coordinates start for consecutive x coords
if mod(x_per_side, 2) == 0
    offset = repmat([0, 0.5], [y_per_side, (x_per_side/2)]);
elseif mod(x_per_side, 2) == 1
    offset = repmat([0, 0.5], [y_per_side, (ceil(x_per_side/2))]);
    offset(:, end) = [];
else
    error('x_per_side not an integer')
end

YY = repmat([0 : y_per_side-1]', [1, x_per_side]);
YY = scale * (YY + offset);
XX = scale * cos30 * repmat([0 : x_per_side-1], [y_per_side, 1]);

YY = YY + boundary + mound_radius + 1;
XX = XX + boundary + mound_radius + 1;


hexCoords = round([XX(:), YY(:)]);

end

