function landscape = add_fertile_pixels(landscape, n_pixels_extra, boundary, max_grass)

xdim = size(landscape, 2);
ydim = size(landscape, 1);
inside_boundary = landscape((boundary + 1):(ydim - boundary),...
    (boundary + 1):(xdim - boundary), 2);
%All of these variables are lists of indexes
not_fertile = find(inside_boundary ~= 1);
x_bounds = size(inside_boundary, 2);
y_bounds = size(inside_boundary, 1);
choose = randperm(size(not_fertile, 1), n_pixels_extra);
change = not_fertile(choose);
[not_fertile_y, not_fertile_x] = ind2sub([y_bounds, x_bounds], change);


for pixel = 1:n_pixels_extra
    landscape(not_fertile_y(pixel), not_fertile_x(pixel), 1) = max_grass;
    landscape(not_fertile_y(pixel), not_fertile_x(pixel), 2) = 1;
end

end

